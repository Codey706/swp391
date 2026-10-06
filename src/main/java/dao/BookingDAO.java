package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Booking;
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
}
