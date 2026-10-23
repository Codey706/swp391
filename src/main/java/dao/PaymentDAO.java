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
import model.Payment;
import model.PaymentResponse;
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

    public boolean verifyPaymentResult(PaymentResponse response) {

        if (response == null
                || response.getOrderId() <= 0
                || response.getAmount() == null
                || response.getAmount().compareTo(BigDecimal.ZERO) <= 0
                || response.getTransactionCode() == null
                || response.getTransactionCode().isBlank()
                || response.getResponseCode() == null) {

            return false;
        }

        String sql = """
    SELECT p.transaction_code,
           p.amount,
           p.payment_status,
           o.final_amount,
           o.status
    FROM Payments p
    INNER JOIN Orders o
        ON p.order_id = o.order_id
    WHERE p.order_id = ?
      AND p.transaction_code = ?
    """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, response.getOrderId());
            ps.setString(2, response.getTransactionCode());

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return false;
                }

                String transactionCode
                        = rs.getString("transaction_code");

                BigDecimal paymentAmount
                        = rs.getBigDecimal("amount");

                BigDecimal orderAmount
                        = rs.getBigDecimal("final_amount");

                String paymentStatus
                        = rs.getString("payment_status");

                String orderStatus
                        = rs.getString("status");

                if (!"Pending".equalsIgnoreCase(paymentStatus)) {
                    return false;
                }

                if (!"Pending".equalsIgnoreCase(orderStatus)) {
                    return false;
                }

                if (paymentAmount == null || orderAmount == null) {
                    return false;
                }

                if (response.getAmount()
                        .compareTo(paymentAmount) != 0) {
                    return false;
                }

                if (response.getAmount()
                        .compareTo(orderAmount) != 0) {
                    return false;
                }

                if (transactionCode == null
                        || !response.getTransactionCode()
                                .equals(transactionCode)) {
                    return false;
                }

                if (!"00".equals(response.getResponseCode())) {
                    return false;
                }

                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean processPaymentResponse(PaymentResponse response) {

        if (response == null
                || response.getOrderId() <= 0
                || response.getTransactionCode() == null
                || response.getTransactionCode().isBlank()
                || !"00".equals(response.getResponseCode())) {
            return false;
        }

        String updatePayment = """
        UPDATE Payments
        SET payment_status = 'Success',
            paid_at = GETDATE()
        WHERE order_id = ?
          AND transaction_code = ?
          AND payment_status = 'Pending'
        """;

        String updateOrder = """
        UPDATE Orders
        SET status = 'Paid',
            updated_at = GETDATE()
        WHERE order_id = ?
          AND status = 'Pending'
        """;

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // Bước 1: Cập nhật trạng thái thanh toán.
                try (PreparedStatement ps
                        = conn.prepareStatement(updatePayment)) {
                    ps.setInt(1, response.getOrderId());
                    ps.setString(2, response.getTransactionCode());

                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                // Bước 2: Cập nhật trạng thái đơn hàng.
                try (PreparedStatement ps
                        = conn.prepareStatement(updateOrder)) {
                    ps.setInt(1, response.getOrderId());

                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                // Bước 3: Tạo vé điện tử trong cùng transaction.
                createTicketsForOrder(conn, response.getOrderId());
                String updateSeats = """
                UPDATE es
                SET es.status = 'Sold'
                FROM Event_Seats es
                INNER JOIN Order_Seats os
                ON os.event_seat_id = es.event_seat_id
                WHERE os.order_id = ?
                AND es.status = 'Held'
                """;

                try (PreparedStatement ps = conn.prepareStatement(updateSeats)) {
                    ps.setInt(1, response.getOrderId());
                    ps.executeUpdate();
                }

                // Bước 4: Chỉ commit khi cập nhật thanh toán,
                // cập nhật đơn hàng và tạo vé đều thành công.
                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void createTicketsForOrder(Connection conn, int orderId)
            throws SQLException {

        String detailSql = """
        SELECT od.order_detail_id,
               od.quantity,
               et.event_id
        FROM Order_Details od
        JOIN Event_Tickets et
            ON et.event_ticket_id = od.event_ticket_id
        WHERE od.order_id = ?
        ORDER BY od.order_detail_id
        """;

        String seatSql = """
        SELECT os.event_seat_id
        FROM Order_Seats os
        WHERE os.order_id = ?
        ORDER BY os.order_seat_id
        """;

        String insertSql = """
        INSERT INTO Tickets
            (order_detail_id, event_id, event_seat_id,
             ticket_code, qr_code, ticket_status, created_at)
        VALUES (?, ?, ?, ?, ?, 'Valid', GETDATE())
        """;

        // Lấy danh sách ghế đã đặt, nếu đơn hàng có chọn ghế.
        java.util.List<Integer> seatIds = new java.util.ArrayList<>();

        try (PreparedStatement ps = conn.prepareStatement(seatSql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    seatIds.add(rs.getInt("event_seat_id"));
                }
            }
        }

        int seatIndex = 0;
        int totalTickets = 0;

        try (PreparedStatement ps = conn.prepareStatement(detailSql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int detailId = rs.getInt("order_detail_id");
                    int quantity = rs.getInt("quantity");
                    int eventId = rs.getInt("event_id");

                    for (int i = 0; i < quantity; i++) {
                        Integer seatId = null;

                        if (seatIndex < seatIds.size()) {
                            seatId = seatIds.get(seatIndex++);
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

        if (seatIndex != seatIds.size()) {
            throw new SQLException(
                    "Number of assigned seats does not match order."
            );
        }
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

    public Payment getPendingPaymentForOrder(int orderId) {
        String sql = """
        SELECT TOP 1 payment_id, order_id, payment_method,
               transaction_code, amount, payment_status,
               paid_at, created_at
        FROM Payments
        WHERE order_id = ?
          AND payment_status = 'Pending'
        ORDER BY payment_id DESC
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

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
