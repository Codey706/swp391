package dao;

import model.Event;
import model.RecentOrder;
import utils.Constants;
import utils.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Truy vấn số liệu cho trang tổng quan Organizer. Doanh thu / vé chỉ tính đơn
 * Paid, cùng cách tính với EventDAO (Order_Details -> Event_Tickets -> Events).
 */
public class OrganizerDashboardDAO {

    private static final String FROM_SALES
            = "FROM Order_Details od "
            + "JOIN Event_Tickets t ON t.event_ticket_id = od.event_ticket_id "
            + "JOIN Events e ON e.event_id = t.event_id "
            + "JOIN Orders o ON o.order_id = od.order_id ";

    /**
     * Doanh thu từng ngày trong {@code days} ngày gần nhất (ngày không có đơn = 0),
     * sắp xếp từ cũ đến mới.
     */
    public Map<LocalDate, BigDecimal> getDailyRevenue(int organizerId, int days) throws SQLException {
        Map<LocalDate, BigDecimal> result = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        for (int i = days - 1; i >= 0; i--) {
            result.put(today.minusDays(i), BigDecimal.ZERO);
        }
        String sql = "SELECT CAST(o.created_at AS DATE), SUM(od.subtotal) " + FROM_SALES
                + "WHERE e.organizer_id = ? AND o.status = 'Paid' "
                + "AND o.created_at >= DATEADD(DAY, ?, CAST(GETDATE() AS DATE)) "
                + "GROUP BY CAST(o.created_at AS DATE)";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, organizerId);
            statement.setInt(2, -(days - 1));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    LocalDate day = rs.getDate(1).toLocalDate();
                    if (result.containsKey(day)) {
                        result.put(day, rs.getBigDecimal(2));
                    }
                }
            }
        }
        return result;
    }

    /**
     * So sánh kỳ hiện tại (PERIOD_DAYS ngày gần nhất) với kỳ liền trước: doanh
     * thu và số vé. Các khóa: revenueCurrent, revenuePrevious, soldCurrent, soldPrevious.
     */
    public Map<String, BigDecimal> getPeriodComparison(int organizerId) throws SQLException {
        int p = Constants.DASHBOARD_PERIOD_DAYS;
        String cut = "DATEADD(DAY, " + (-(p - 1)) + ", CAST(GETDATE() AS DATE))";
        String sql = "SELECT "
                + "ISNULL(SUM(CASE WHEN o.created_at >= " + cut + " THEN od.subtotal ELSE 0 END), 0), "
                + "ISNULL(SUM(CASE WHEN o.created_at <  " + cut + " THEN od.subtotal ELSE 0 END), 0), "
                + "ISNULL(SUM(CASE WHEN o.created_at >= " + cut + " THEN od.quantity ELSE 0 END), 0), "
                + "ISNULL(SUM(CASE WHEN o.created_at <  " + cut + " THEN od.quantity ELSE 0 END), 0) "
                + FROM_SALES + "WHERE e.organizer_id = ? AND o.status = 'Paid' "
                + "AND o.created_at >= DATEADD(DAY, " + (-(2 * p - 1)) + ", CAST(GETDATE() AS DATE))";
        Map<String, BigDecimal> map = new LinkedHashMap<>();
        map.put("revenueCurrent", BigDecimal.ZERO);
        map.put("revenuePrevious", BigDecimal.ZERO);
        map.put("soldCurrent", BigDecimal.ZERO);
        map.put("soldPrevious", BigDecimal.ZERO);
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    map.put("revenueCurrent", rs.getBigDecimal(1));
                    map.put("revenuePrevious", rs.getBigDecimal(2));
                    map.put("soldCurrent", rs.getBigDecimal(3));
                    map.put("soldPrevious", rs.getBigDecimal(4));
                }
            }
        }
        return map;
    }

    /**
     * Tổng số đơn và số đơn đang chờ (Pending) có vé thuộc sự kiện của organizer.
     *
     * @return {total, pending}
     */
    public int[] getOrderCounts(int organizerId) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT o.order_id), "
                + "COUNT(DISTINCT CASE WHEN o.status = 'Pending' THEN o.order_id END) "
                + FROM_SALES + "WHERE e.organizer_id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                rs.next(); // COUNT luôn trả 1 dòng
                return new int[]{rs.getInt(1), rs.getInt(2)};
            }
        }
    }

    public List<RecentOrder> getRecentOrders(int organizerId, int limit) throws SQLException {
        List<RecentOrder> orders = new ArrayList<>();
        String sql = "SELECT TOP (?) o.order_id, o.order_code, u.full_name, e.event_name, "
                + "SUM(od.quantity), SUM(od.subtotal), o.status, o.created_at "
                + FROM_SALES + "JOIN Users u ON u.user_id = o.customer_id "
                + "WHERE e.organizer_id = ? "
                + "GROUP BY o.order_id, o.order_code, u.full_name, e.event_name, o.status, o.created_at "
                + "ORDER BY o.created_at DESC, o.order_id DESC";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, limit);
            statement.setInt(2, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    RecentOrder order = new RecentOrder();
                    order.setOrderId(rs.getInt(1));
                    order.setOrderCode(rs.getString(2));
                    order.setCustomerName(rs.getString(3));
                    order.setEventName(rs.getString(4));
                    order.setQuantity(rs.getInt(5));
                    order.setAmount(rs.getBigDecimal(6));
                    order.setStatus(rs.getString(7));
                    Timestamp created = rs.getTimestamp(8);
                    order.setCreatedAt(created == null ? null : created.toLocalDateTime());
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    /**
     * Các sự kiện vừa thay đổi (mới tạo / đổi trạng thái) để hiển thị "Hoạt động gần đây".
     * Chỉ điền eventId, eventName, status, updatedAt.
     */
    public List<Event> getRecentlyUpdatedEvents(int organizerId, int limit) throws SQLException {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT TOP (?) event_id, event_name, status, updated_at FROM Events "
                + "WHERE organizer_id = ? ORDER BY updated_at DESC, event_id DESC";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, limit);
            statement.setInt(2, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Event event = new Event();
                    event.setEventId(rs.getInt(1));
                    event.setEventName(rs.getString(2));
                    String status = rs.getString(3);
                    event.setStatus(status == null ? null : status.trim().toUpperCase(Locale.ROOT));
                    Timestamp updated = rs.getTimestamp(4);
                    event.setUpdatedAt(updated == null ? null : updated.toLocalDateTime());
                    events.add(event);
                }
            }
        }
        return events;
    }

    // ------------------------------------------------------------ UC-24: check-in & báo cáo từng sự kiện

    /** {số vé đã check-in, số vé đã phát hành (không tính vé hủy)} trên mọi sự kiện của organizer. */
    public int[] getCheckInStats(int organizerId) throws SQLException {
        String sql = "SELECT ISNULL(SUM(CASE WHEN t.ticket_status = 'CheckedIn' THEN 1 ELSE 0 END), 0), "
                + "COUNT(*) FROM Tickets t JOIN Events e ON e.event_id = t.event_id "
                + "WHERE e.organizer_id = ? AND t.ticket_status <> 'Cancelled'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, organizerId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next(); // SUM/COUNT luôn trả 1 dòng
                return new int[]{rs.getInt(1), rs.getInt(2)};
            }
        }
    }

    /**
     * Báo cáo theo hạng vé của một sự kiện: ticketName, price, quantity, available, held (giữ chỗ
     * trong đơn Pending), sold (vé trong đơn Paid), revenue (Paid), checkedIn.
     */
    public List<Map<String, Object>> getEventTicketReport(int eventId) throws SQLException {
        String sql = """
            SELECT et.event_ticket_id, et.ticket_name, et.price, et.quantity, et.available_quantity, et.status,
                   ISNULL((SELECT SUM(od.quantity) FROM Order_Details od JOIN Orders o ON o.order_id = od.order_id
                           WHERE od.event_ticket_id = et.event_ticket_id AND o.status = 'Pending'), 0) AS held,
                   ISNULL((SELECT SUM(od.quantity) FROM Order_Details od JOIN Orders o ON o.order_id = od.order_id
                           WHERE od.event_ticket_id = et.event_ticket_id AND o.status = 'Paid'), 0) AS sold,
                   ISNULL((SELECT SUM(od.subtotal) FROM Order_Details od JOIN Orders o ON o.order_id = od.order_id
                           WHERE od.event_ticket_id = et.event_ticket_id AND o.status = 'Paid'), 0) AS revenue,
                   (SELECT COUNT(*) FROM Tickets t JOIN Order_Details od ON od.order_detail_id = t.order_detail_id
                     WHERE od.event_ticket_id = et.event_ticket_id AND t.ticket_status = 'CheckedIn') AS checked_in
            FROM Event_Tickets et
            WHERE et.event_id = ?
            ORDER BY et.price DESC, et.event_ticket_id
            """;
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("ticketName", rs.getString("ticket_name"));
                    row.put("price", rs.getBigDecimal("price"));
                    row.put("quantity", rs.getInt("quantity"));
                    row.put("available", rs.getInt("available_quantity"));
                    row.put("status", rs.getString("status"));
                    row.put("held", rs.getInt("held"));
                    row.put("sold", rs.getInt("sold"));
                    row.put("revenue", rs.getBigDecimal("revenue"));
                    row.put("checkedIn", rs.getInt("checked_in"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    /** Số đơn của sự kiện theo trạng thái (Pending / Paid / Cancelled). */
    public Map<String, Integer> getEventOrderCounts(int eventId) throws SQLException {
        String sql = "SELECT o.status, COUNT(DISTINCT o.order_id) FROM Orders o "
                + "JOIN Order_Details od ON od.order_id = o.order_id "
                + "JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id "
                + "WHERE et.event_id = ? GROUP BY o.status";
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put(Constants.ORDER_PAID, 0);
        counts.put(Constants.ORDER_PENDING, 0);
        counts.put(Constants.ORDER_CANCELLED, 0);
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getString(1), rs.getInt(2));
                }
            }
        }
        return counts;
    }
}
