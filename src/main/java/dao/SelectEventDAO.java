package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.BookableEvent;
import utils.DBContext;

public class SelectEventDAO {

    // Sự kiện đặt được: đang ACTIVE (DB mẫu cũ có 'Active') và chưa kết thúc
    private static final String BOOKABLE_EVENT_FILTER
            = "WHERE UPPER(e.status) = 'ACTIVE' AND e.end_time > GETDATE() ";

    private static final String SELECT_BOOKABLE_EVENT
            = "SELECT e.event_id, e.organizer_id, e.category_id, e.venue_id, e.event_name, e.description, "
            + "e.event_image, e.start_time, e.end_time, e.status, c.category_name, v.venue_name, "
            + "(SELECT MIN(t.price) FROM Event_Tickets t WHERE t.event_id = e.event_id "
            + "   AND UPPER(t.status) = 'ACTIVE' AND t.available_quantity > 0) AS min_price, "
            + "(SELECT ISNULL(SUM(t.available_quantity), 0) FROM Event_Tickets t WHERE t.event_id = e.event_id "
            + "   AND UPPER(t.status) = 'ACTIVE') AS available_tickets "
            + "FROM Events e JOIN Categories c ON c.category_id = e.category_id "
            + "JOIN Venues v ON v.venue_id = e.venue_id ";

    /**
     * Danh sách sự kiện đang mở bán, sớm nhất trước.
     *
     * @param keyword null/rỗng = không lọc theo tên
     */
    public List<BookableEvent> searchBookableEvents(String keyword, int page, int pageSize) throws SQLException {
        boolean hasKeyword = keyword != null && !keyword.isBlank();
        String sql = SELECT_BOOKABLE_EVENT + BOOKABLE_EVENT_FILTER
                + (hasKeyword ? "AND e.event_name LIKE ? ESCAPE '\\' " : "")
                + "ORDER BY e.start_time ASC, e.event_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        List<BookableEvent> events = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int index = 1;
            if (hasKeyword) {
                ps.setString(index++, likePattern(keyword));
            }
            ps.setInt(index++, (page - 1) * pageSize);
            ps.setInt(index, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    events.add(mapBookableEvent(rs));
                }
            }
        }
        return events;
    }

    public int countBookableEvents(String keyword) throws SQLException {
        boolean hasKeyword = keyword != null && !keyword.isBlank();
        String sql = "SELECT COUNT(*) FROM Events e " + BOOKABLE_EVENT_FILTER
                + (hasKeyword ? "AND e.event_name LIKE ? ESCAPE '\\'" : "");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (hasKeyword) {
                ps.setString(1, likePattern(keyword));
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private String likePattern(String keyword) {
        String escaped = keyword.trim().replace("\\", "\\\\").replace("%", "\\%")
                .replace("_", "\\_").replace("[", "\\[");
        return "%" + escaped + "%";
    }

    private BookableEvent mapBookableEvent(ResultSet rs) throws SQLException {
        BookableEvent event = new BookableEvent();
        event.setEventId(rs.getInt("event_id"));
        event.setOrganizerId(rs.getInt("organizer_id"));
        event.setCategoryId(rs.getInt("category_id"));
        event.setVenueId(rs.getInt("venue_id"));
        event.setEventName(rs.getString("event_name"));
        event.setDescription(rs.getString("description"));
        event.setEventImage(rs.getString("event_image"));
        event.setStatus(rs.getString("status"));
        event.setCategoryName(rs.getString("category_name"));
        event.setVenueName(rs.getString("venue_name"));
        Timestamp start = rs.getTimestamp("start_time");
        Timestamp end = rs.getTimestamp("end_time");
        event.setStartTime(start == null ? null : start.toLocalDateTime());
        event.setEndTime(end == null ? null : end.toLocalDateTime());
        event.setMinPrice(rs.getBigDecimal("min_price")); // null nếu hết vé
        event.setAvailableTickets(rs.getInt("available_tickets"));
        return event;
    }
}
