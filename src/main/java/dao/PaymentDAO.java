/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author BT
 */
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;
import java.util.logging.Logger;
import model.Payment;
import utils.DBContext;

public class PaymentDAO {

    public boolean createPayment(Payment payment) {

        String sql = """
            INSERT INTO Payments
            (order_id, payment_method, transaction_code,
             amount, payment_status, paid_at, created_at)
            VALUES (?, ?, ?, ?, ?, ?, GETDATE())
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, payment.getOrderId());
            ps.setString(2, payment.getPaymentMethod());
            ps.setString(3, payment.getTransactionCode());
            ps.setBigDecimal(4, payment.getAmount());
            ps.setString(5, payment.getPaymentStatus());
            ps.setTimestamp(6, null);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean validatePaymentRequest(int orderId, BigDecimal amount) {

        String sql = """
            SELECT final_amount, status
            FROM Orders
            WHERE order_id = ?
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return false;
                }

                BigDecimal finalAmount = rs.getBigDecimal("final_amount");
                String status = rs.getString("status");

                if (!"Pending".equalsIgnoreCase(status)) {
                    return false;
                }

                if (amount == null
                        || amount.compareTo(BigDecimal.ZERO) <= 0) {
                    return false;
                }

                return amount.compareTo(finalAmount) == 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Kết quả xử lý một thông báo thanh toán từ VNPay (Return URL hoặc IPN).
     */
    public enum VnPayOutcome {
        /**
         * Lần đầu xác nhận thành công: đơn Paid, đã cấp vé.
         */
        PAID,
        /**
         * Lần đầu nhận kết quả không thành công: Payment Failed.
         */
        FAILED,
        /**
         * Tiền về nhưng đơn đã hủy (hết giữ chỗ) hoặc sự kiện không còn ACTIVE:
         * không cấp vé, hoàn tiền thủ công.
         */
        REFUND_REQUIRED,
        /**
         * Giao dịch đã có kết quả từ trước (gọi lại / IPN gửi lặp).
         */
        ALREADY_PROCESSED,
        NOT_FOUND,
        AMOUNT_MISMATCH
    }

    public static final String PAYMENT_PENDING = "Pending";
    public static final String PAYMENT_SUCCESS = "Success";
    public static final String PAYMENT_FAILED = "Failed";
    public static final String PAYMENT_REFUND_PENDING = "RefundPending";

    private static final Logger LOGGER = Logger.getLogger(PaymentDAO.class.getName());

    /**
     * Xử lý kết quả VNPay trong MỘT transaction, khóa dòng Payments/Orders
     * (UPDLOCK) nên Return URL và IPN đến cùng lúc, hoặc IPN gửi lặp lại, chỉ
     * được xử lý đúng một lần. Chữ ký phải được kiểm tra ở controller trước khi
     * gọi.
     *
     * @param amount số tiền VNPay báo (VND, đã chia 100)
     * @param success vnp_ResponseCode = 00 và vnp_TransactionStatus = 00
     * @param vnpTransactionNo vnp_TransactionNo của VNPay (có thể null), để đối
     * soát khi hoàn tiền
     */
    public VnPayOutcome applyVnPayResult(String transactionCode, BigDecimal amount, boolean success,
            String vnpTransactionNo) throws SQLException {
        String lockSql = """
            SELECT p.payment_id, p.order_id, p.amount, p.payment_status,
                   o.status AS order_status, o.final_amount,
                   (SELECT COUNT(*) FROM Order_Details od
                      JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id
                      JOIN Events e ON e.event_id = et.event_id
                     WHERE od.order_id = o.order_id AND UPPER(e.status) <> 'ACTIVE') AS inactive_events
            FROM Payments p WITH (UPDLOCK, ROWLOCK)
            JOIN Orders o WITH (UPDLOCK, ROWLOCK) ON o.order_id = p.order_id
            WHERE p.transaction_code = ?
            """;

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int paymentId;
                int orderId;
                String paymentStatus;
                String orderStatus;
                boolean eventInactive;
                try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                    ps.setString(1, transactionCode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return VnPayOutcome.NOT_FOUND;
                        }
                        paymentId = rs.getInt("payment_id");
                        orderId = rs.getInt("order_id");
                        paymentStatus = rs.getString("payment_status");
                        orderStatus = rs.getString("order_status");
                        eventInactive = rs.getInt("inactive_events") > 0;
                        BigDecimal paymentAmount = rs.getBigDecimal("amount");
                        BigDecimal orderAmount = rs.getBigDecimal("final_amount");
                        if (amount == null || paymentAmount == null || orderAmount == null
                                || amount.compareTo(paymentAmount) != 0
                                || amount.compareTo(orderAmount) != 0) {
                            conn.rollback();
                            LOGGER.warning("VNPay amount mismatch, txnRef=" + transactionCode + ", amount=" + amount);
                            return VnPayOutcome.AMOUNT_MISMATCH;
                        }
                    }
                }

                // Payment chỉ còn xử lý được khi Pending; riêng "Failed do hết giữ chỗ" vẫn nhận tin
                // thành công đến muộn để đánh dấu hoàn tiền.
                boolean pending = PAYMENT_PENDING.equalsIgnoreCase(paymentStatus);
                boolean failed = PAYMENT_FAILED.equalsIgnoreCase(paymentStatus);
                if (!pending && !(success && failed)) {
                    conn.rollback();
                    return VnPayOutcome.ALREADY_PROCESSED;
                }

                if (!success) {
                    updatePaymentStatus(conn, paymentId, PAYMENT_FAILED, false);
                    conn.commit();
                    return VnPayOutcome.FAILED;
                }

                if (!"Pending".equalsIgnoreCase(orderStatus) || eventInactive) {
                    updatePaymentStatus(conn, paymentId, PAYMENT_REFUND_PENDING, true);
                    conn.commit();
                    LOGGER.severe("VNPay paid after order closed -> REFUND MANUALLY. orderId=" + orderId
                            + ", txnRef=" + transactionCode + ", vnpTransactionNo=" + vnpTransactionNo
                            + ", orderStatus=" + orderStatus + ", eventInactive=" + eventInactive);
                    return VnPayOutcome.REFUND_REQUIRED;
                }

                updatePaymentStatus(conn, paymentId, PAYMENT_SUCCESS, true);
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Orders SET status = 'Paid', updated_at = GETDATE() WHERE order_id = ? AND status = 'Pending'")) {
                    ps.setInt(1, orderId);
                    if (ps.executeUpdate() != 1) {
                        throw new SQLException("Order " + orderId + " is no longer Pending");
                    }
                }
                createTicketsForOrder(conn, orderId);
                try (PreparedStatement ps = conn.prepareStatement("""
                        UPDATE es SET es.status = 'Sold'
                        FROM Event_Seats es
                        JOIN Order_Seats os ON os.event_seat_id = es.event_seat_id
                        WHERE os.order_id = ? AND es.status = 'Held'
                        """)) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }
                conn.commit();
                return VnPayOutcome.PAID;
            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /**
     * order_id của giao dịch, -1 nếu không có.
     */
    public int findOrderIdByTransactionCode(String transactionCode) throws SQLException {
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(
                "SELECT order_id FROM Payments WHERE transaction_code = ?")) {
            ps.setString(1, transactionCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    /**
     * Thông tin đơn để hiển thị trang kết quả thanh toán: [order_id,
     * order_code, final_amount, status], null nếu không tìm thấy giao dịch.
     */
    public Object[] findOrderSummaryByTransactionCode(String transactionCode) throws SQLException {
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(
                "SELECT o.order_id, o.order_code, o.final_amount, o.status FROM Payments p "
                + "JOIN Orders o ON o.order_id = p.order_id WHERE p.transaction_code = ?")) {
            ps.setString(1, transactionCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? new Object[]{rs.getInt(1), rs.getString(2), rs.getBigDecimal(3), rs.getString(4)}
                        : null;
            }
        }
    }

    private void updatePaymentStatus(Connection conn, int paymentId, String status, boolean paid) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Payments SET payment_status = ?" + (paid ? ", paid_at = GETDATE()" : "")
                + " WHERE payment_id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, paymentId);
            ps.executeUpdate();
        }
    }

    private void createTicketsForOrder(Connection conn, int orderId)
            throws SQLException {

        String detailSql = """
        SELECT od.order_detail_id,
               od.quantity,
               od.event_ticket_id,
               et.event_id
        FROM Order_Details od
        JOIN Event_Tickets et
            ON et.event_ticket_id = od.event_ticket_id
        WHERE od.order_id = ?
        ORDER BY od.order_detail_id
        """;

        String seatSql = """
        SELECT os.event_seat_id, z.event_ticket_id
        FROM Order_Seats os
        JOIN Event_Seats es ON es.event_seat_id = os.event_seat_id
        LEFT JOIN Event_Zones z ON z.zone_id = es.zone_id
        WHERE os.order_id = ?
        ORDER BY os.order_seat_id
        """;

        String insertSql = """
        INSERT INTO Tickets
            (order_detail_id, event_id, event_seat_id,
             ticket_code, qr_code, ticket_status, created_at)
        VALUES (?, ?, ?, ?, ?, 'Valid', GETDATE())
        """;

        // Lấy danh sách ghế đã đặt, nếu đơn hàng có chọn ghế, nhóm theo hạng vé của khu.
        // Ghế chưa gắn khu/hạng vé nằm ở nhóm null và dùng được cho mọi hạng.
        java.util.Map<Integer, java.util.Deque<Integer>> seatsByTicket = new java.util.HashMap<>();
        int totalSeats = 0;

        try (PreparedStatement ps = conn.prepareStatement(seatSql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int ticketTypeId = rs.getInt("event_ticket_id");
                    Integer key = rs.wasNull() ? null : ticketTypeId;
                    seatsByTicket.computeIfAbsent(key, k -> new java.util.ArrayDeque<>())
                            .add(rs.getInt("event_seat_id"));
                    totalSeats++;
                }
            }
        }

        int assignedSeats = 0;
        int totalTickets = 0;

        try (PreparedStatement ps = conn.prepareStatement(detailSql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int detailId = rs.getInt("order_detail_id");
                    int quantity = rs.getInt("quantity");
                    int eventId = rs.getInt("event_id");
                    int ticketTypeId = rs.getInt("event_ticket_id");

                    for (int i = 0; i < quantity; i++) {
                        Integer seatId = pollSeat(seatsByTicket, ticketTypeId);

                        if (seatId == null) {
                            seatId = pollSeat(seatsByTicket, null);
                        }
                        if (seatId != null) {
                            assignedSeats++;
                        }

                        String ticketCode = "TKT-"
                                + UUID.randomUUID()
                                        .toString()
                                        .replace("-", "")
                                        .toUpperCase();

                        try (PreparedStatement insert
                                = conn.prepareStatement(insertSql)) {

                            insert.setInt(1, detailId);
                            insert.setInt(2, eventId);

                            if (seatId == null) {
                                insert.setNull(
                                        3, java.sql.Types.INTEGER
                                );
                            } else {
                                insert.setInt(3, seatId);
                            }

                            insert.setString(4, ticketCode);

                            // Payload tạm thời; chưa phải ảnh QR.
                            insert.setString(5, ticketCode);

                            insert.executeUpdate();
                        }

                        totalTickets++;
                    }
                }
            }
        }

        if (totalTickets == 0) {
            throw new SQLException(
                    "Cannot issue tickets: order has no order details."
            );
        }

        if (assignedSeats != totalSeats) {
            throw new SQLException(
                    "Number of assigned seats does not match order."
            );
        }
    }

    private static Integer pollSeat(java.util.Map<Integer, java.util.Deque<Integer>> seatsByTicket,
            Integer ticketTypeId) {
        java.util.Deque<Integer> seats = seatsByTicket.get(ticketTypeId);
        return seats == null ? null : seats.poll();
    }

    public Payment getPaymentByTransactionCode(String transactionCode) {
        String sql = """
        SELECT TOP 1 payment_id, order_id, payment_method,
               transaction_code, amount, payment_status,
               paid_at, created_at
        FROM Payments
        WHERE transaction_code = ?
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, transactionCode);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                Payment payment = new Payment();
                payment.setPaymentId(rs.getInt("payment_id"));
                payment.setOrderId(rs.getInt("order_id"));
                payment.setPaymentMethod(rs.getString("payment_method"));
                payment.setTransactionCode(rs.getString("transaction_code"));
                payment.setAmount(rs.getBigDecimal("amount"));
                payment.setPaymentStatus(rs.getString("payment_status"));

                return payment;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }
}
