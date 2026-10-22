package dao;

import model.StaffCustomer;
import model.StaffCustomerTicket;
import utils.Constants;
import utils.DBContext;

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

/**
 * Khách hàng / vé / lịch sử check-in cho trang "Thông tin khách hàng" của Staff.
 * Mọi truy vấn đều giới hạn trong các sự kiện mà staff được phân công (Event_Staff ACTIVE,
 * sự kiện ACTIVE hoặc CANCELLED), nên đổi customerId / eventId trên URL không lấy được dữ liệu ngoài phạm vi.
 *
 * Lịch sử check-in lấy từ Tickets.check_in_time vì database chưa có bảng log check-in riêng
 * (không có nhân viên thực hiện hay lượt check-in thất bại).
 */
public class StaffCustomerDAO {

    public static final String TAB_ALL = "all";
    public static final String TAB_CHECKED = "checked";
    public static final String TAB_UNCHECKED = "unchecked";

    private static final String ASSIGNED_EVENT_IDS
            = "(SELECT e.event_id FROM Events e JOIN Event_Staff es ON es.event_id = e.event_id "
            + "WHERE es.staff_id = ? AND UPPER(es.status) = '" + Constants.EVENT_STAFF_ACTIVE + "' "
            + "AND UPPER(e.status) IN ('" + Constants.EVENT_ACTIVE + "', '" + Constants.EVENT_CANCELLED + "'))";

    private static final String FROM_SCOPE
            = "FROM Tickets tk JOIN Order_Details od ON od.order_detail_id = tk.order_detail_id "
            + "JOIN Orders o ON o.order_id = od.order_id JOIN Users u ON u.user_id = o.customer_id "
            + "WHERE tk.event_id IN " + ASSIGNED_EVENT_IDS + " ";

    private static final String ACTIVE_SUM
            = "SUM(CASE WHEN tk.ticket_status <> '" + Constants.TICKET_CANCELLED + "' THEN 1 ELSE 0 END)";
    private static final String CHECKED_SUM
            = "SUM(CASE WHEN tk.ticket_status = '" + Constants.TICKET_CHECKED_IN + "' THEN 1 ELSE 0 END)";
    private static final String CANCELLED_SUM
            = "SUM(CASE WHEN tk.ticket_status = '" + Constants.TICKET_CANCELLED + "' THEN 1 ELSE 0 END)";

    /**
     * Số khách theo tab (không áp dụng ô tìm kiếm): all, checked (check-in đủ), unchecked (còn vé chưa check-in).
     */
    public Map<String, Integer> countByTab(int staffId) throws SQLException {
        String sql = "SELECT COUNT(*), "
                + "ISNULL(SUM(CASE WHEN x.a > 0 AND x.c = x.a THEN 1 ELSE 0 END), 0), "
                + "ISNULL(SUM(CASE WHEN x.a > x.c THEN 1 ELSE 0 END), 0) "
                + "FROM (SELECT u.user_id, " + ACTIVE_SUM + " AS a, " + CHECKED_SUM + " AS c "
                + FROM_SCOPE + "GROUP BY u.user_id) x";
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put(TAB_ALL, 0);
        counts.put(TAB_CHECKED, 0);
        counts.put(TAB_UNCHECKED, 0);
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, staffId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    counts.put(TAB_ALL, rs.getInt(1));
                    counts.put(TAB_CHECKED, rs.getInt(2));
                    counts.put(TAB_UNCHECKED, rs.getInt(3));
                }
            }
        }
        return counts;
    }

    public int countCustomers(int staffId, String tab, String keyword) throws SQLException {
        List<Object> params = new ArrayList<>();
        String grouped = customerGroupSql("u.user_id", staffId, tab, keyword, params);
        String sql = "SELECT COUNT(*) FROM (" + grouped + ") x";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<StaffCustomer> findCustomers(int staffId, String tab, String keyword, int page, int pageSize)
            throws SQLException {
        List<Object> params = new ArrayList<>();
        String columns = "u.user_id, u.full_name, u.phone, u.email, "
                + ACTIVE_SUM + " AS active_tickets, " + CHECKED_SUM + " AS checked_in, "
                + CANCELLED_SUM + " AS cancelled, COUNT(DISTINCT tk.event_id) AS event_count";
        String sql = customerGroupSql(columns, staffId, tab, keyword, params)
                + " ORDER BY u.full_name, u.user_id OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        List<StaffCustomer> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bind(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    StaffCustomer c = new StaffCustomer();
                    c.setUserId(rs.getInt("user_id"));
                    c.setFullName(rs.getString("full_name"));
                    c.setPhone(rs.getString("phone"));
                    c.setEmail(rs.getString("email"));
                    c.setActiveTickets(rs.getInt("active_tickets"));
                    c.setCheckedIn(rs.getInt("checked_in"));
                    c.setCancelled(rs.getInt("cancelled"));
                    c.setEventCount(rs.getInt("event_count"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    /**
     * Thông tin liên hệ của khách; null nếu khách không có vé nào trong sự kiện của staff
     * (không tồn tại hoặc ngoài phạm vi quyền).
     */
    public StaffCustomer findCustomer(int staffId, int customerId) throws SQLException {
        String sql = "SELECT u.user_id, u.full_name, u.phone, u.email, u.address FROM Users u "
                + "WHERE u.user_id = ? AND EXISTS (SELECT 1 FROM Tickets tk "
                + "JOIN Order_Details od ON od.order_detail_id = tk.order_detail_id "
                + "JOIN Orders o ON o.order_id = od.order_id "
                + "WHERE o.customer_id = u.user_id AND tk.event_id IN " + ASSIGNED_EVENT_IDS + ")";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            statement.setInt(2, staffId);
            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                StaffCustomer c = new StaffCustomer();
                c.setUserId(rs.getInt("user_id"));
                c.setFullName(rs.getString("full_name"));
                c.setPhone(rs.getString("phone"));
                c.setEmail(rs.getString("email"));
                c.setAddress(rs.getString("address"));
                return c;
            }
        }
    }

    /**
     * Số vé của khách trong một sự kiện được phân công.
     *
     * @return {vé hiệu lực, đã check-in, đã hủy}
     */
    public int[] getTicketStats(int staffId, int customerId, int eventId) throws SQLException {
        String sql = "SELECT ISNULL(" + ACTIVE_SUM + ", 0), ISNULL(" + CHECKED_SUM + ", 0), ISNULL(" + CANCELLED_SUM + ", 0) "
                + "FROM Tickets tk JOIN Order_Details od ON od.order_detail_id = tk.order_detail_id "
                + "JOIN Orders o ON o.order_id = od.order_id "
                + "WHERE o.customer_id = ? AND tk.event_id = ? AND tk.event_id IN " + ASSIGNED_EVENT_IDS;
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            statement.setInt(2, eventId);
            statement.setInt(3, staffId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1), rs.getInt(2), rs.getInt(3)};
                }
            }
        }
        return new int[]{0, 0, 0};
    }

    /** Vé của khách trong sự kiện (tối đa STAFF_CUSTOMER_TICKET_LIMIT), theo mã vé. */
    public List<StaffCustomerTicket> findTickets(int staffId, int customerId, int eventId) throws SQLException {
        return queryTickets(staffId, customerId, eventId, false);
    }

    /** Các lần check-in đã ghi nhận (Tickets.check_in_time), mới nhất trước. */
    public List<StaffCustomerTicket> findCheckInHistory(int staffId, int customerId, int eventId) throws SQLException {
        return queryTickets(staffId, customerId, eventId, true);
    }

    // ------------------------------------------------------------ nội bộ
    private List<StaffCustomerTicket> queryTickets(int staffId, int customerId, int eventId, boolean historyOnly)
            throws SQLException {
        String sql = "SELECT TOP (" + Constants.STAFF_CUSTOMER_TICKET_LIMIT + ") "
                + "tk.ticket_id, tk.ticket_code, tk.ticket_status, tk.check_in_time, o.order_code, "
                + "et.ticket_name, s.seat_label, ev.event_id, ev.event_name, ev.start_time, vn.venue_name "
                + "FROM Tickets tk JOIN Order_Details od ON od.order_detail_id = tk.order_detail_id "
                + "JOIN Orders o ON o.order_id = od.order_id "
                + "JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id "
                + "JOIN Events ev ON ev.event_id = tk.event_id "
                + "JOIN Venues vn ON vn.venue_id = ev.venue_id "
                + "LEFT JOIN Event_Seats s ON s.event_seat_id = tk.event_seat_id "
                + "WHERE o.customer_id = ? AND tk.event_id = ? AND tk.event_id IN " + ASSIGNED_EVENT_IDS + " "
                + (historyOnly
                        ? "AND tk.ticket_status = '" + Constants.TICKET_CHECKED_IN + "' AND tk.check_in_time IS NOT NULL "
                        + "ORDER BY tk.check_in_time DESC, tk.ticket_id DESC"
                        : "ORDER BY tk.ticket_code, tk.ticket_id");
        List<StaffCustomerTicket> list = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            statement.setInt(2, eventId);
            statement.setInt(3, staffId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    StaffCustomerTicket t = new StaffCustomerTicket();
                    t.setTicketId(rs.getInt("ticket_id"));
                    t.setTicketCode(rs.getString("ticket_code"));
                    t.setStatus(rs.getString("ticket_status"));
                    Timestamp checkIn = rs.getTimestamp("check_in_time");
                    t.setCheckInTime(checkIn == null ? null : checkIn.toLocalDateTime());
                    t.setOrderCode(rs.getString("order_code"));
                    t.setTicketName(rs.getString("ticket_name"));
                    t.setSeatLabel(rs.getString("seat_label"));
                    t.setEventId(rs.getInt("event_id"));
                    t.setEventName(rs.getString("event_name"));
                    t.setVenueName(rs.getString("venue_name"));
                    Timestamp start = rs.getTimestamp("start_time");
                    t.setEventStartTime(start == null ? null : start.toLocalDateTime());
                    list.add(t);
                }
            }
        }
        return list;
    }

    /**
     * SELECT ... GROUP BY khách hàng, đã gắn điều kiện tìm kiếm và tab. Thêm tham số tương ứng vào params.
     */
    private String customerGroupSql(String columns, int staffId, String tab, String keyword, List<Object> params) {
        StringBuilder sql = new StringBuilder("SELECT ").append(columns).append(' ').append(FROM_SCOPE);
        params.add(staffId);

        if (keyword != null && !keyword.isEmpty()) {
            String text = like(keyword);
            String digits = keyword.replaceAll("[\\s.\\-]", "");
            String phone = like(digits.isEmpty() ? keyword : digits);
            // Khớp tên / SĐT / email của khách, hoặc mã vé / mã đơn hàng của khách trong phạm vi staff
            sql.append("AND (LOWER(u.full_name) LIKE ? ESCAPE '\\' OR u.phone LIKE ? ESCAPE '\\' ")
                    .append("OR LOWER(u.email) LIKE ? ESCAPE '\\' OR EXISTS (SELECT 1 FROM Tickets t2 ")
                    .append("JOIN Order_Details od2 ON od2.order_detail_id = t2.order_detail_id ")
                    .append("JOIN Orders o2 ON o2.order_id = od2.order_id ")
                    .append("WHERE o2.customer_id = u.user_id AND t2.event_id IN ").append(ASSIGNED_EVENT_IDS)
                    .append(" AND (LOWER(t2.ticket_code) LIKE ? ESCAPE '\\' OR LOWER(o2.order_code) LIKE ? ESCAPE '\\'))) ");
            params.add(text);
            params.add(phone);
            params.add(text);
            params.add(staffId);
            params.add(text);
            params.add(text);
        }

        sql.append("GROUP BY u.user_id, u.full_name, u.phone, u.email ");
        if (TAB_CHECKED.equals(tab)) {
            sql.append("HAVING ").append(ACTIVE_SUM).append(" > 0 AND ").append(CHECKED_SUM).append(" = ").append(ACTIVE_SUM);
        } else if (TAB_UNCHECKED.equals(tab)) {
            sql.append("HAVING ").append(ACTIVE_SUM).append(" > ").append(CHECKED_SUM);
        }
        return sql.toString();
    }

    private static String like(String value) {
        return "%" + value.toLowerCase(Locale.ROOT)
                .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_").replace("[", "\\[") + "%";
    }

    private void bind(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                statement.setInt(i + 1, (Integer) value);
            } else {
                statement.setString(i + 1, String.valueOf(value));
            }
        }
    }
}
