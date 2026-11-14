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
import utils.Constants;
import utils.DBContext;

/**
 * UC-23 Assign Event Staff: phân công / gỡ phân công Staff cho một sự kiện (bảng Event_Staff).
 * Gỡ phân công chuyển status sang INACTIVE (giữ lịch sử); phân công lại thì kích hoạt dòng cũ.
 */
public class EventStaffDAO {

    /** Staff đang được phân công cho sự kiện: mỗi phần tử gồm userId, username, fullName, email, phone, assignedAt. */
    public List<Map<String, Object>> getAssignedStaff(int eventId) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.email, u.phone, es.assigned_at "
                + "FROM Event_Staff es JOIN Users u ON u.user_id = es.staff_id "
                + "WHERE es.event_id = ? AND UPPER(es.status) = ? ORDER BY u.full_name";
        return query(sql, eventId, Constants.EVENT_STAFF_ACTIVE);
    }

    /** Tài khoản Staff đang ACTIVE chưa được phân công cho sự kiện. */
    public List<Map<String, Object>> getAvailableStaff(int eventId) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.email, u.phone, NULL AS assigned_at "
                + "FROM Users u WHERE UPPER(u.role) = 'STAFF' AND UPPER(u.status) = 'ACTIVE' "
                + "AND NOT EXISTS (SELECT 1 FROM Event_Staff es WHERE es.staff_id = u.user_id "
                + "AND es.event_id = ? AND UPPER(es.status) = ?) ORDER BY u.full_name";
        return query(sql, eventId, Constants.EVENT_STAFF_ACTIVE);
    }

    /** @return false nếu staffId không phải tài khoản Staff ACTIVE. */
    public boolean assign(int eventId, int staffId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT 1 FROM Users WHERE user_id = ? AND UPPER(role) = 'STAFF' AND UPPER(status) = 'ACTIVE'")) {
                    ps.setInt(1, staffId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Event_Staff WITH (HOLDLOCK) SET status = ?, assigned_at = GETDATE() "
                        + "WHERE event_id = ? AND staff_id = ? AND UPPER(status) <> ?")) {
                    ps.setString(1, Constants.EVENT_STAFF_ACTIVE);
                    ps.setInt(2, eventId);
                    ps.setInt(3, staffId);
                    ps.setString(4, Constants.EVENT_STAFF_ACTIVE);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Event_Staff (event_id, staff_id, status) "
                            + "SELECT ?, ?, ? WHERE NOT EXISTS (SELECT 1 FROM Event_Staff WITH (UPDLOCK, HOLDLOCK) "
                            + "WHERE event_id = ? AND staff_id = ?)")) {
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

    public boolean unassign(int eventId, int staffId) throws SQLException {
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Event_Staff SET status = 'INACTIVE' WHERE event_id = ? AND staff_id = ? AND UPPER(status) = ?")) {
            ps.setInt(1, eventId);
            ps.setInt(2, staffId);
            ps.setString(3, Constants.EVENT_STAFF_ACTIVE);
            return ps.executeUpdate() > 0;
        }
    }

    private List<Map<String, Object>> query(String sql, int eventId, String status) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
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
                    Timestamp assigned = rs.getTimestamp("assigned_at");
                    row.put("assignedAt", assigned == null ? null : assigned.toLocalDateTime());
                    list.add(row);
                }
            }
        }
        return list;
    }
}
