package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import model.Event;
import utils.Constants;
import utils.DBContext;

public class EventStaffDAO {

    // ==========================================
    // OLD FUNCTION: Staff xem danh sách sự kiện
    // ==========================================
    public List<Event> getAssignedEvents(int staffId) {
        List<Event> events = new ArrayList<>();

        String sql = """
            SELECT
                e.event_id,
                e.organizer_id,
                e.category_id,
                e.venue_id,
                e.event_name,
                e.description,
                e.event_image,
                e.start_time,
                e.end_time,
                e.status,
                e.cancellation_reason,
                e.created_at,
                e.updated_at,
                v.venue_name
            FROM Event_Staff es
            INNER JOIN Events e ON es.event_id = e.event_id
            INNER JOIN Venues v ON e.venue_id = v.venue_id
            INNER JOIN Users u ON es.staff_id = u.user_id
            WHERE es.staff_id = ?
              AND UPPER(es.status) = ?
              AND UPPER(u.role) = 'STAFF'
              AND UPPER(u.status) = 'ACTIVE'
            ORDER BY e.start_time ASC
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setString(2, Constants.EVENT_STAFF_ACTIVE);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event event = new Event();

                    event.setEventId(rs.getInt("event_id"));
                    event.setOrganizerId(rs.getInt("organizer_id"));
                    event.setCategoryId(rs.getInt("category_id"));
                    event.setVenueId(rs.getInt("venue_id"));
                    event.setEventName(rs.getString("event_name"));
                    event.setDescription(rs.getString("description"));
                    event.setEventImage(rs.getString("event_image"));
                    event.setStatus(rs.getString("status"));
                    event.setCancellationReason(
                            rs.getString("cancellation_reason")
                    );
                    event.setVenueName(rs.getString("venue_name"));

                    Timestamp start = rs.getTimestamp("start_time");
                    if (start != null) {
                        event.setStartTime(start.toLocalDateTime());
                    }

                    Timestamp end = rs.getTimestamp("end_time");
                    if (end != null) {
                        event.setEndTime(end.toLocalDateTime());
                    }

                    Timestamp created = rs.getTimestamp("created_at");
                    if (created != null) {
                        event.setCreatedAt(created.toLocalDateTime());
                    }

                    Timestamp updated = rs.getTimestamp("updated_at");
                    if (updated != null) {
                        event.setUpdatedAt(updated.toLocalDateTime());
                    }

                    events.add(event);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return events;
    }

    // ==========================================
    // UC-23: Get assigned staff
    // ==========================================
    public List<Map<String, Object>> getAssignedStaff(int eventId)
            throws SQLException {

        String sql = """
            SELECT u.user_id, u.username, u.full_name,
                   u.email, u.phone, es.assigned_at
            FROM Event_Staff es
            JOIN Users u ON u.user_id = es.staff_id
            WHERE es.event_id = ?
              AND UPPER(es.status) = ?
            ORDER BY u.full_name
            """;

        return query(sql, eventId, Constants.EVENT_STAFF_ACTIVE);
    }

    // ==========================================
    // UC-23: Get available staff
    // ==========================================
    public List<Map<String, Object>> getAvailableStaff(int eventId)
            throws SQLException {

        String sql = """
            SELECT u.user_id, u.username, u.full_name,
                   u.email, u.phone, NULL AS assigned_at
            FROM Users u
            WHERE UPPER(u.role) = 'STAFF'
              AND UPPER(u.status) = 'ACTIVE'
              AND NOT EXISTS (
                  SELECT 1
                  FROM Event_Staff es
                  WHERE es.staff_id = u.user_id
                    AND es.event_id = ?
                    AND UPPER(es.status) = ?
              )
            ORDER BY u.full_name
            """;

        return query(sql, eventId, Constants.EVENT_STAFF_ACTIVE);
    }

    // ==========================================
    // UC-23: Assign staff
    // ==========================================
    public boolean assign(int eventId, int staffId) throws SQLException {

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // Check staff account
                String checkSql = """
                    SELECT 1 FROM Users
                    WHERE user_id = ?
                      AND UPPER(role) = 'STAFF'
                      AND UPPER(status) = 'ACTIVE'
                    """;

                try (PreparedStatement ps
                        = conn.prepareStatement(checkSql)) {

                    ps.setInt(1, staffId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                // Reactivate previous assignment
                String updateSql = """
                    UPDATE Event_Staff
                    SET status = ?, assigned_at = GETDATE()
                    WHERE event_id = ?
                      AND staff_id = ?
                      AND UPPER(status) <> ?
                    """;

                int updated;

                try (PreparedStatement ps
                        = conn.prepareStatement(updateSql)) {

                    ps.setString(1, Constants.EVENT_STAFF_ACTIVE);
                    ps.setInt(2, eventId);
                    ps.setInt(3, staffId);
                    ps.setString(4, Constants.EVENT_STAFF_ACTIVE);

                    updated = ps.executeUpdate();
                }

                // Insert new assignment if no old row exists
                if (updated == 0) {

                    String insertSql = """
                        INSERT INTO Event_Staff
                            (event_id, staff_id, status)
                        SELECT ?, ?, ?
                        WHERE NOT EXISTS (
                            SELECT 1 FROM Event_Staff
                            WHERE event_id = ?
                              AND staff_id = ?
                        )
                        """;

                    try (PreparedStatement ps
                            = conn.prepareStatement(insertSql)) {

                        ps.setInt(1, eventId);
                        ps.setInt(2, staffId);
                        ps.setString(3, Constants.EVENT_STAFF_ACTIVE);
                        ps.setInt(4, eventId);
                        ps.setInt(5, staffId);

                        ps.executeUpdate();
                    }
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ==========================================
    // UC-23: Unassign staff
    // ==========================================
    public boolean unassign(int eventId, int staffId)
            throws SQLException {

        String sql = """
            UPDATE Event_Staff
            SET status = 'INACTIVE'
            WHERE event_id = ?
              AND staff_id = ?
              AND UPPER(status) = ?
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eventId);
            ps.setInt(2, staffId);
            ps.setString(3, Constants.EVENT_STAFF_ACTIVE);

            return ps.executeUpdate() > 0;
        }
    }

    // ==========================================
    // Helper query
    // ==========================================
    private List<Map<String, Object>> query(
            String sql, int eventId, String status)
            throws SQLException {

        List<Map<String, Object>> list = new ArrayList<>();

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, eventId);
            ps.setString(2, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {

                    Map<String, Object> row = new LinkedHashMap<>();

                    row.put("userId", rs.getInt("user_id"));
                    row.put("username", rs.getString("username"));
                    row.put("fullName", rs.getString("full_name"));
                    row.put("email", rs.getString("email"));
                    row.put("phone", rs.getString("phone"));

                    Timestamp assigned
                            = rs.getTimestamp("assigned_at");

                    row.put("assignedAt",
                            assigned == null
                                    ? null
                                    : assigned.toLocalDateTime());

                    list.add(row);
                }
            }
        }

        return list;
    }
}
