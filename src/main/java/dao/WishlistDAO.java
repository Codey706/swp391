package dao;

import java.sql.*;
import java.util.*;
import utils.DBContext;

public class WishlistDAO {

    // Lấy ID các sự kiện đã yêu thích
    public Set<Integer> getFavoriteIds(int customerId)
            throws SQLException {

        Set<Integer> ids = new HashSet<>();

        String sql = """
            SELECT event_id
            FROM Wishlists
            WHERE customer_id = ?
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("event_id"));
                }
            }
        }

        return ids;
    }

    // Kiểm tra sự kiện đã được yêu thích chưa
    public boolean isFavorite(int customerId, int eventId)
            throws SQLException {

        String sql = """
            SELECT 1 FROM Wishlists
            WHERE customer_id = ? AND event_id = ?
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Thêm sự kiện vào Wishlist
    public void add(int customerId, int eventId)
            throws SQLException {

        String sql = """
            INSERT INTO Wishlists (customer_id, event_id)
            SELECT ?, e.event_id
            FROM Events e
            WHERE e.event_id = ?
              AND e.status = 'ACTIVE'
              AND NOT EXISTS (
                  SELECT 1 FROM Wishlists w
                  WHERE w.customer_id = ?
                    AND w.event_id = e.event_id
              )
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, eventId);
            ps.setInt(3, customerId);
            ps.executeUpdate();
        }
    }

    // Xóa sự kiện khỏi Wishlist
    public void remove(int customerId, int eventId)
            throws SQLException {

        String sql = """
            DELETE FROM Wishlists
            WHERE customer_id = ? AND event_id = ?
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, eventId);
            ps.executeUpdate();
        }
    }

    // Lấy danh sách sự kiện đã yêu thích
    public List<Map<String, Object>> getWishlist(int customerId)
            throws SQLException {

        List<Map<String, Object>> events = new ArrayList<>();

        String sql = """
            SELECT e.event_id,
                   e.event_name,
                   e.event_image,
                   e.start_time,
                   e.end_time,
                   e.status,
                   v.venue_name,
                   c.category_name,
                   (SELECT MIN(t.price)
                    FROM Event_Tickets t
                    WHERE t.event_id = e.event_id
                      AND t.status = 'ACTIVE') AS min_price
            FROM Wishlists w
            JOIN Events e ON w.event_id = e.event_id
            JOIN Venues v ON e.venue_id = v.venue_id
            JOIN Categories c ON e.category_id = c.category_id
            WHERE w.customer_id = ?
            ORDER BY w.created_at DESC, w.wishlist_id DESC
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {

                    Map<String, Object> event = new HashMap<>();

                    event.put("eventId", rs.getInt("event_id"));
                    event.put("eventName", rs.getString("event_name"));
                    event.put("eventImage", rs.getString("event_image"));
                    event.put("venueName", rs.getString("venue_name"));
                    event.put("categoryName", rs.getString("category_name"));
                    event.put("minPrice", rs.getBigDecimal("min_price"));
                    event.put("status", rs.getString("status"));

                    Timestamp start = rs.getTimestamp("start_time");
                    Timestamp end = rs.getTimestamp("end_time");

                    event.put("startTime",
                            start == null ? null : start.toLocalDateTime());
                    event.put("endTime",
                            end == null ? null : end.toLocalDateTime());

                    events.add(event);
                }
            }
        }

        return events;
    }
}
