package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import utils.DBContext;

/**
 * UC-19 Review Event (Customer) và UC-33 Moderate Reviews (Admin).
 * Reviews.status: ACTIVE hiển thị công khai, HIDDEN bị Admin ẩn. Mỗi khách 1
 * đánh giá / sự kiện (UNIQUE customer_id, event_id).
 */
public class ReviewDAO {

    public static final String ACTIVE = "ACTIVE";
    public static final String HIDDEN = "HIDDEN";
    public static final int COMMENT_MAX_LENGTH = 1000;

    private static final String SELECT = "SELECT r.review_id, r.customer_id, r.event_id, r.rating, r.comment, r.status, "
            + "r.created_at, u.full_name, u.username, e.event_name "
            + "FROM Reviews r JOIN Users u ON u.user_id = r.customer_id JOIN Events e ON e.event_id = r.event_id ";

    /**
     * Vé đã check-in (đơn Paid) của khách cho sự kiện, dùng làm
     * Reviews.ticket_id; -1 nếu không có.
     */
    public int findCheckedInTicket(int customerId, int eventId)
            throws SQLException {

        String sql = """
        SELECT TOP 1 t.ticket_id
        FROM Tickets t
        JOIN Order_Details od
            ON od.order_detail_id = t.order_detail_id
        JOIN Orders o
            ON o.order_id = od.order_id
        JOIN Events e
            ON e.event_id = t.event_id
        WHERE o.customer_id = ?
          AND t.event_id = ?
          AND o.status = 'Paid'
          AND t.ticket_status = 'CheckedIn'
          AND e.status = 'ACTIVE'
          AND e.end_time <= GETDATE()
        ORDER BY t.check_in_time, t.ticket_id
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    public int findEventIdByOrder(int customerId, int orderId)
            throws SQLException {

        String sql = """
        SELECT TOP 1 e.event_id
        FROM Orders o
        JOIN Order_Details od
            ON od.order_id = o.order_id
        JOIN Event_Tickets et
            ON et.event_ticket_id = od.event_ticket_id
        JOIN Events e
            ON e.event_id = et.event_id
        WHERE o.customer_id = ?
          AND o.order_id = ?
        ORDER BY od.order_detail_id
        """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    /**
     * Đánh giá của khách cho sự kiện (bất kể trạng thái), null nếu chưa có.
     */
    public Map<String, Object> findByCustomerAndEvent(int customerId, int eventId) throws SQLException {
        List<Map<String, Object>> list = query(SELECT + "WHERE r.customer_id = ? AND r.event_id = ?", customerId, eventId);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * @return false nếu khách đã đánh giá sự kiện này (vi phạm UNIQUE)
     */
    public boolean insert(int customerId, int eventId, int ticketId, int rating, String comment) throws SQLException {
        String sql = "INSERT INTO Reviews (customer_id, event_id, ticket_id, rating, comment, status) VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, eventId);
            ps.setInt(3, ticketId);
            ps.setInt(4, rating);
            if (comment == null || comment.isEmpty()) {
                ps.setNull(5, java.sql.Types.NVARCHAR);
            } else {
                ps.setString(5, comment);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            if (DBContext.isDuplicateKey(e)) {
                return false;
            }
            throw e;
        }
    }

    /**
     * Đánh giá công khai (ACTIVE) của sự kiện, mới nhất trước.
     */
    public List<Map<String, Object>> findPublic(int eventId, int limit) throws SQLException {
        return query(SELECT.replace("SELECT ", "SELECT TOP (" + Math.max(1, limit) + ") ")
                + "WHERE r.event_id = ? AND r.status = 'ACTIVE' ORDER BY r.created_at DESC, r.review_id DESC", eventId);
    }

    /**
     * {điểm trung bình, số đánh giá} của các đánh giá công khai.
     */
    public double[] summary(int eventId) throws SQLException {
        String sql = "SELECT ISNULL(AVG(CAST(rating AS FLOAT)), 0), COUNT(*) FROM Reviews WHERE event_id = ? AND status = 'ACTIVE'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return new double[]{rs.getDouble(1), rs.getInt(2)};
            }
        }
    }

    // ------------------------------------------------------------ UC-33 (Admin)
    public int countForAdmin(String status, Integer rating, String keyword) throws SQLException {
        List<Object> params = new ArrayList<>();
        String where = adminWhere(status, rating, keyword, params);
        String sql = "SELECT COUNT(*) FROM Reviews r JOIN Users u ON u.user_id = r.customer_id "
                + "JOIN Events e ON e.event_id = r.event_id " + where;
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    public List<Map<String, Object>> findForAdmin(String status, Integer rating, String keyword, int page, int pageSize)
            throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = SELECT + adminWhere(status, rating, keyword, params)
                + "ORDER BY r.created_at DESC, r.review_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        return query(sql, params.toArray());
    }

    public boolean setStatus(int reviewId, String status) throws SQLException {
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(
                "UPDATE Reviews SET status = ?, updated_at = GETDATE() WHERE review_id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() > 0;
        }
    }

    private String adminWhere(String status, Integer rating, String keyword, List<Object> params) {
        StringBuilder where = new StringBuilder("WHERE 1 = 1 ");
        if (status != null) {
            where.append("AND r.status = ? ");
            params.add(status);
        }
        if (rating != null) {
            where.append("AND r.rating = ? ");
            params.add(rating);
        }
        if (keyword != null && !keyword.isEmpty()) {
            String escaped = keyword.toLowerCase(Locale.ROOT)
                    .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_").replace("[", "\\[");
            where.append("AND (LOWER(e.event_name) LIKE ? ESCAPE '\\' OR LOWER(u.full_name) LIKE ? ESCAPE '\\' "
                    + "OR LOWER(r.comment) LIKE ? ESCAPE '\\') ");
            String like = "%" + escaped + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        return where.toString();
    }

    private List<Map<String, Object>> query(String sql, Object... params) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, java.util.Arrays.asList(params));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("reviewId", rs.getInt("review_id"));
                    row.put("customerId", rs.getInt("customer_id"));
                    row.put("eventId", rs.getInt("event_id"));
                    row.put("rating", rs.getInt("rating"));
                    row.put("comment", rs.getString("comment"));
                    row.put("status", rs.getString("status"));
                    Timestamp created = rs.getTimestamp("created_at");
                    row.put("createdAt", created == null ? null : created.toLocalDateTime());
                    row.put("customerName", rs.getString("full_name"));
                    row.put("username", rs.getString("username"));
                    row.put("eventName", rs.getString("event_name"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                ps.setInt(i + 1, (Integer) value);
            } else {
                ps.setString(i + 1, String.valueOf(value));
            }
        }
    }
}
