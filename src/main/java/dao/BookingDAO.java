package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Booking;
import model.BookingItem;
import model.Payment;
import utils.DBContext;

public class BookingDAO {

    /**
     * Lấy một trang lịch sử booking của customer, mới nhất trước.
     *
     * @param status null = tất cả trạng thái
     * @param keyword null = không lọc theo mã đơn
     */
    public List<Booking> getBookingsByCustomerId(int customerId, String status, String keyword,
            int page, int pageSize) throws SQLException {
        String sql = """
                SELECT o.order_id, o.customer_id, o.order_code, o.total_amount, o.discount_amount,
                       o.final_amount, o.status, o.hold_expired_at, o.created_at,
                       (SELECT COALESCE(SUM(od.quantity), 0)
                          FROM Order_Details od WHERE od.order_id = o.order_id) AS ticket_quantity,
                       ev.event_name, ev.start_time, ev.event_image, ev.venue_name, ev.ticket_name
                FROM Orders o
                OUTER APPLY (
                    SELECT TOP 1 e.event_name, e.start_time, e.event_image, v.venue_name, et.ticket_name
                    FROM Order_Details od
                    JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id
                    JOIN Events e ON e.event_id = et.event_id
                    JOIN Venues v ON v.venue_id = e.venue_id
                    WHERE od.order_id = o.order_id
                    ORDER BY od.order_detail_id
                ) ev
                WHERE o.customer_id = ?
                """ + buildFilterClause(status, keyword) + """
                ORDER BY o.created_at DESC, o.order_id DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;

        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = bindFilter(ps, customerId, status, keyword);
            ps.setInt(index++, (page - 1) * pageSize);
            ps.setInt(index, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapBooking(rs));
                }
            }
        }
        return bookings;
    }

    public int countBookingsByCustomerId(int customerId, String status, String keyword) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Orders o WHERE o.customer_id = ? "
                + buildFilterClause(status, keyword);
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bindFilter(ps, customerId, status, keyword);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Đếm đơn của customer theo từng trạng thái (cho các thẻ thống kê). */
    public Map<String, Integer> countBookingsByStatus(int customerId) throws SQLException {
        String sql = "SELECT status, COUNT(*) AS total FROM Orders WHERE customer_id = ? GROUP BY status";
        Map<String, Integer> counts = new HashMap<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getString("status"), rs.getInt("total"));
                }
            }
        }
        return counts;
    }

    /** Chỉ nối các mẫu SQL cố định; giá trị người dùng luôn đi qua tham số "?". */
    private String buildFilterClause(String status, String keyword) {
        StringBuilder clause = new StringBuilder();
        if (status != null) {
            clause.append(" AND o.status = ? ");
        }
        if (keyword != null) {
            clause.append(" AND (o.order_code LIKE ? ESCAPE '\\' OR EXISTS (SELECT 1 FROM Order_Details od "
                    + "JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id "
                    + "JOIN Events e ON e.event_id = et.event_id "
                    + "WHERE od.order_id = o.order_id AND e.event_name LIKE ? ESCAPE '\\')) ");
        }
        return clause.toString();
    }

    /** @return chỉ số tham số kế tiếp cần bind. */
    private int bindFilter(PreparedStatement ps, int customerId, String status, String keyword)
            throws SQLException {
        int index = 1;
        ps.setInt(index++, customerId);
        if (status != null) {
            ps.setString(index++, status);
        }
        if (keyword != null) {
            String pattern = "%" + escapeLike(keyword) + "%";
            ps.setString(index++, pattern);
            ps.setString(index++, pattern);
        }
        return index;
    }

    private String escapeLike(String value) {
        return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_").replace("[", "\\[");
    }

    private Booking mapBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingId(rs.getInt("order_id"));
        booking.setCustomerId(rs.getInt("customer_id"));
        booking.setOrderCode(rs.getString("order_code"));
        booking.setTotalAmount(rs.getBigDecimal("total_amount"));
        booking.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        booking.setFinalAmount(rs.getBigDecimal("final_amount"));
        booking.setStatus(rs.getString("status"));
        booking.setTicketQuantity(rs.getInt("ticket_quantity"));
        booking.setEventName(rs.getString("event_name"));
        booking.setEventImage(rs.getString("event_image"));
        booking.setVenueName(rs.getString("venue_name"));
        booking.setTicketName(rs.getString("ticket_name"));

        Timestamp holdExpiredAt = rs.getTimestamp("hold_expired_at");
        booking.setHoldExpiredAt(holdExpiredAt == null ? null : holdExpiredAt.toLocalDateTime());
        Timestamp createdAt = rs.getTimestamp("created_at");
        booking.setCreatedAt(createdAt == null ? null : createdAt.toLocalDateTime());
        Timestamp startTime = rs.getTimestamp("start_time");
        booking.setEventStartTime(startTime == null ? null : startTime.toLocalDateTime());
        return booking;
    }
/**
     * Chi tiết một đơn (UC-07.1). Chỉ trả về nếu đơn thuộc customerId (kiểm tra ownership).
     *
     * @return null nếu không có đơn hoặc đơn của người khác
     */
    public Booking getBookingDetail(int orderId, int customerId) throws SQLException {
        String sql = """
                SELECT o.order_id, o.customer_id, o.order_code, o.total_amount, o.discount_amount,
                       o.final_amount, o.status, o.hold_expired_at, o.created_at,
                       vc.voucher_code, vc.voucher_name,
                       ev.event_name, ev.start_time, ev.end_time, ev.event_image,
                       ev.venue_name, ev.venue_address
                FROM Orders o
                LEFT JOIN Vouchers vc ON vc.voucher_id = o.voucher_id
                OUTER APPLY (
                    SELECT TOP 1 x.event_name, x.start_time, x.end_time, x.event_image,
                                 x.venue_name, x.venue_address
                    FROM (
                        SELECT e.event_name, e.start_time, e.end_time, e.event_image,
                               v.venue_name, v.address AS venue_address, od.order_detail_id AS sort_key
                        FROM Order_Details od
                        JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id
                        JOIN Events e ON e.event_id = et.event_id
                        JOIN Venues v ON v.venue_id = e.venue_id
                        WHERE od.order_id = o.order_id
                        UNION ALL
                        SELECT e.event_name, e.start_time, e.end_time, e.event_image,
                               v.venue_name, v.address AS venue_address, 1000000000 + os.order_seat_id AS sort_key
                        FROM Order_Seats os
                        JOIN Event_Seats es ON es.event_seat_id = os.event_seat_id
                        JOIN Events e ON e.event_id = es.event_id
                        JOIN Venues v ON v.venue_id = e.venue_id
                        WHERE os.order_id = o.order_id
                    ) x
                    ORDER BY x.sort_key
                ) ev
                WHERE o.order_id = ? AND o.customer_id = ?
                """;

        try (Connection conn = DBContext.getConnection()) {
            Booking booking;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, customerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    booking = mapBookingDetail(rs);
                }
            }
            booking.setItems(getBookingItems(conn, orderId));
            booking.setSeatLabels(getSeatLabels(conn, orderId));
            booking.setPayment(getLatestPayment(conn, orderId));
            booking.setTicketQuantity(booking.getItems().stream().mapToInt(BookingItem::getQuantity).sum());
            return booking;
        }
    }

    private List<BookingItem> getBookingItems(Connection conn, int orderId) throws SQLException {
        String sql = "SELECT et.ticket_name, od.quantity, od.unit_price, od.subtotal "
                + "FROM Order_Details od "
                + "JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id "
                + "WHERE od.order_id = ? ORDER BY od.order_detail_id";
        List<BookingItem> items = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookingItem item = new BookingItem();
                    item.setTicketName(rs.getString("ticket_name"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setSubtotal(rs.getBigDecimal("subtotal"));
                    items.add(item);
                }
            }
        }
        return items;
    }

    private List<String> getSeatLabels(Connection conn, int orderId) throws SQLException {
        String sql = "SELECT es.seat_label FROM Order_Seats os "
                + "JOIN Event_Seats es ON es.event_seat_id = os.event_seat_id "
                + "WHERE os.order_id = ? ORDER BY es.row_label, es.seat_number";
        List<String> seatLabels = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    seatLabels.add(rs.getString("seat_label"));
                }
            }
        }
        return seatLabels;
    }

    /** @return giao dịch thanh toán mới nhất của đơn, hoặc null nếu chưa có. */
    private Payment getLatestPayment(Connection conn, int orderId) throws SQLException {
        String sql = "SELECT TOP 1 payment_id, order_id, payment_method, transaction_code, amount, "
                + "payment_status, paid_at, created_at FROM Payments "
                + "WHERE order_id = ? ORDER BY created_at DESC, payment_id DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
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
                payment.setPaidAt(toLocalDateTime(rs.getTimestamp("paid_at")));
                payment.setCreatedAt(toLocalDateTime(rs.getTimestamp("created_at")));
                return payment;
            }
        }
    }

    private Booking mapBookingDetail(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setBookingId(rs.getInt("order_id"));
        booking.setCustomerId(rs.getInt("customer_id"));
        booking.setOrderCode(rs.getString("order_code"));
        booking.setTotalAmount(rs.getBigDecimal("total_amount"));
        booking.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        booking.setFinalAmount(rs.getBigDecimal("final_amount"));
        booking.setStatus(rs.getString("status"));
        booking.setHoldExpiredAt(toLocalDateTime(rs.getTimestamp("hold_expired_at")));
        booking.setCreatedAt(toLocalDateTime(rs.getTimestamp("created_at")));
        booking.setVoucherCode(rs.getString("voucher_code"));
        booking.setVoucherName(rs.getString("voucher_name"));
        booking.setEventName(rs.getString("event_name"));
        booking.setEventStartTime(toLocalDateTime(rs.getTimestamp("start_time")));
        booking.setEventEndTime(toLocalDateTime(rs.getTimestamp("end_time")));
        booking.setEventImage(rs.getString("event_image"));
        booking.setVenueName(rs.getString("venue_name"));
        booking.setVenueAddress(rs.getString("venue_address"));
        return booking;
    }

    private LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }
}
