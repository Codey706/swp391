package dao;

import model.StaffAssignment;
import utils.Constants;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Sự kiện được phân công cho Staff (bảng Event_Staff). Chỉ lấy phân công ACTIVE và
 * sự kiện ACTIVE hoặc CANCELLED (Draft / Pending / Rejected chưa công khai nên Staff
 * không thấy). Staff ID luôn do controller lấy từ session.
 */
public class StaffEventDAO {

    // Tab trạng thái theo thời gian
    public static final String TAB_ALL = "all";
    public static final String TAB_UPCOMING = "upcoming";
    public static final String TAB_ONGOING = "ongoing";
    public static final String TAB_ENDED = "ended";

    // Bộ lọc thời gian
    public static final String RANGE_ALL = "all";
    public static final String RANGE_TODAY = "today";
    public static final String RANGE_WEEK = "week";
    public static final String RANGE_MONTH = "month";
    public static final String RANGE_PAST = "past";

    // Trạng thái hiển thị của một sự kiện
    public static final String UPCOMING = "UPCOMING";
    public static final String ONGOING = "ONGOING";
    public static final String ENDED = "ENDED";
    public static final String CANCELLED = "CANCELLED";

    private static final String SELECT_COLUMNS
            = "SELECT e.event_id, e.event_name, e.event_image, e.description, e.start_time, e.end_time, e.status, "
            + "c.category_name, v.venue_name, v.address, "
            + "(SELECT MIN(es.assigned_at) FROM Event_Staff es WHERE es.event_id = e.event_id "
            + "AND es.staff_id = ? AND UPPER(es.status) = '" + Constants.EVENT_STAFF_ACTIVE + "') AS assigned_at, "
            + "(SELECT ISNULL(SUM(t.quantity), 0) FROM Event_Tickets t WHERE t.event_id = e.event_id) AS ticket_total, "
            + "(SELECT COUNT(*) FROM Tickets tk WHERE tk.event_id = e.event_id "
            + "AND tk.ticket_status <> '" + Constants.TICKET_CANCELLED + "') AS ticket_issued, "
            + "(SELECT COUNT(*) FROM Tickets tk WHERE tk.event_id = e.event_id "
            + "AND tk.ticket_status = '" + Constants.TICKET_CHECKED_IN + "') AS checked_in ";

    // Phần FROM/WHERE dùng chung: chỉ sự kiện mà staff này được phân công
    private static final String FROM_ASSIGNED
            = "FROM Events e JOIN Categories c ON c.category_id = e.category_id "
            + "JOIN Venues v ON v.venue_id = e.venue_id "
            + "WHERE EXISTS (SELECT 1 FROM Event_Staff es WHERE es.event_id = e.event_id "
            + "AND es.staff_id = ? AND UPPER(es.status) = '" + Constants.EVENT_STAFF_ACTIVE + "') "
            + "AND UPPER(e.status) IN ('" + Constants.EVENT_ACTIVE + "', '" + Constants.EVENT_CANCELLED + "') ";

    private static final String IS_ACTIVE = "UPPER(e.status) = '" + Constants.EVENT_ACTIVE + "'";

    /**
     * Số sự kiện theo từng tab (không áp dụng ô tìm kiếm và bộ lọc thời gian).
     */
    public Map<String, Integer> countByTab(int staffId, LocalDateTime now) throws SQLException {
        String sql = "SELECT COUNT(*), "
                + "ISNULL(SUM(CASE WHEN " + IS_ACTIVE + " AND e.start_time > ? THEN 1 ELSE 0 END), 0), "
                + "ISNULL(SUM(CASE WHEN " + IS_ACTIVE + " AND e.start_time <= ? AND e.end_time > ? THEN 1 ELSE 0 END), 0), "
                + "ISNULL(SUM(CASE WHEN " + IS_ACTIVE + " AND e.end_time <= ? THEN 1 ELSE 0 END), 0) "
                + FROM_ASSIGNED;
        Timestamp ts = Timestamp.valueOf(now);
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put(TAB_ALL, 0);
        counts.put(TAB_UPCOMING, 0);
        counts.put(TAB_ONGOING, 0);
        counts.put(TAB_ENDED, 0);
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, List.of(ts, ts, ts, ts, staffId));
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    counts.put(TAB_ALL, rs.getInt(1));
                    counts.put(TAB_UPCOMING, rs.getInt(2));
                    counts.put(TAB_ONGOING, rs.getInt(3));
                    counts.put(TAB_ENDED, rs.getInt(4));
                }
            }
        }
        return counts;
    }

    public int countAssigned(int staffId, String tab, String keyword, String range, LocalDateTime now)
            throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) ").append(FROM_ASSIGNED);
        List<Object> params = new ArrayList<>();
        params.add(staffId);
        appendFilters(sql, params, tab, keyword, range, now);
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bind(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<StaffAssignment> findAssigned(int staffId, String tab, String keyword, String range,
            LocalDateTime now, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(SELECT_COLUMNS).append(FROM_ASSIGNED);
        List<Object> params = new ArrayList<>();
        params.add(staffId); // assigned_at
        params.add(staffId); // EXISTS
        appendFilters(sql, params, tab, keyword, range, now);
        sql.append("ORDER BY e.start_time DESC, e.event_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        List<StaffAssignment> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bind(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs, now));
                }
            }
        }
        return list;
    }

    /**
     * Một sự kiện nếu và chỉ nếu staff được phân công; null nếu không tồn tại hoặc không được phân công.
     */
    public StaffAssignment findAssignedEvent(int staffId, int eventId, LocalDateTime now) throws SQLException {
        String sql = SELECT_COLUMNS + FROM_ASSIGNED + "AND e.event_id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, List.of(staffId, staffId, eventId));
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? map(rs, now) : null;
            }
        }
    }

    /**
     * Các sự kiện được phân công mà khách hàng có vé, mới nhất trước.
     */
    public List<StaffAssignment> findEventsOfCustomer(int staffId, int customerId, LocalDateTime now)
            throws SQLException {
        String sql = SELECT_COLUMNS + FROM_ASSIGNED
                + "AND EXISTS (SELECT 1 FROM Tickets tk JOIN Order_Details od ON od.order_detail_id = tk.order_detail_id "
                + "JOIN Orders o ON o.order_id = od.order_id WHERE tk.event_id = e.event_id AND o.customer_id = ?) "
                + "ORDER BY e.start_time DESC, e.event_id DESC";
        List<StaffAssignment> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, List.of(staffId, staffId, customerId));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs, now));
                }
            }
        }
        return list;
    }

    // ------------------------------------------------------------ nội bộ
    private void appendFilters(StringBuilder sql, List<Object> params, String tab, String keyword,
            String range, LocalDateTime now) {
        Timestamp ts = Timestamp.valueOf(now);
        if (TAB_UPCOMING.equals(tab)) {
            sql.append("AND ").append(IS_ACTIVE).append(" AND e.start_time > ? ");
            params.add(ts);
        } else if (TAB_ONGOING.equals(tab)) {
            sql.append("AND ").append(IS_ACTIVE).append(" AND e.start_time <= ? AND e.end_time > ? ");
            params.add(ts);
            params.add(ts);
        } else if (TAB_ENDED.equals(tab)) {
            sql.append("AND ").append(IS_ACTIVE).append(" AND e.end_time <= ? ");
            params.add(ts);
        }

        if (keyword != null && !keyword.isEmpty()) {
            String escaped = keyword.toLowerCase(Locale.ROOT)
                    .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_").replace("[", "\\[");
            sql.append("AND LOWER(e.event_name) LIKE ? ESCAPE '\\' ");
            params.add("%" + escaped + "%");
        }

        // Sự kiện giao với khoảng [from, to)
        LocalDate today = now.toLocalDate();
        LocalDateTime from = null;
        LocalDateTime to = null;
        if (RANGE_TODAY.equals(range)) {
            from = today.atStartOfDay();
            to = today.plusDays(1).atStartOfDay();
        } else if (RANGE_WEEK.equals(range)) {
            from = today.atStartOfDay();
            to = today.plusDays(7).atStartOfDay();
        } else if (RANGE_MONTH.equals(range)) {
            from = today.withDayOfMonth(1).atStartOfDay();
            to = today.withDayOfMonth(1).plusMonths(1).atStartOfDay();
        } else if (RANGE_PAST.equals(range)) {
            sql.append("AND e.end_time < ? ");
            params.add(ts);
        }
        if (from != null) {
            sql.append("AND e.start_time < ? AND e.end_time >= ? ");
            params.add(Timestamp.valueOf(to));
            params.add(Timestamp.valueOf(from));
        }
    }

    private void bind(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                statement.setInt(i + 1, (Integer) value);
            } else if (value instanceof Timestamp) {
                statement.setTimestamp(i + 1, (Timestamp) value);
            } else {
                statement.setString(i + 1, String.valueOf(value));
            }
        }
    }

    private StaffAssignment map(ResultSet rs, LocalDateTime now) throws SQLException {
        StaffAssignment a = new StaffAssignment();
        a.setEventId(rs.getInt("event_id"));
        a.setEventName(rs.getString("event_name"));
        a.setEventImage(rs.getString("event_image"));
        a.setDescription(rs.getString("description"));
        a.setCategoryName(rs.getString("category_name"));
        a.setVenueName(rs.getString("venue_name"));
        a.setVenueAddress(rs.getString("address"));
        Timestamp start = rs.getTimestamp("start_time");
        Timestamp end = rs.getTimestamp("end_time");
        Timestamp assigned = rs.getTimestamp("assigned_at");
        a.setStartTime(start == null ? null : start.toLocalDateTime());
        a.setEndTime(end == null ? null : end.toLocalDateTime());
        a.setAssignedAt(assigned == null ? null : assigned.toLocalDateTime());
        String status = rs.getString("status");
        a.setStatus(status == null ? null : status.trim().toUpperCase(Locale.ROOT));
        a.setTimeStatus(resolveTimeStatus(a, now));
        a.setTicketTotal(rs.getInt("ticket_total"));
        a.setTicketIssued(rs.getInt("ticket_issued"));
        a.setCheckedIn(rs.getInt("checked_in"));
        return a;
    }

    // Cùng quy tắc với các điều kiện SQL ở trên
    private String resolveTimeStatus(StaffAssignment a, LocalDateTime now) {
        if (Constants.EVENT_CANCELLED.equals(a.getStatus())) {
            return CANCELLED;
        }
        if (a.getStartTime() != null && now.isBefore(a.getStartTime())) {
            return UPCOMING;
        }
        if (a.getEndTime() != null && now.isBefore(a.getEndTime())) {
            return ONGOING;
        }
        return ENDED;
    }
}
