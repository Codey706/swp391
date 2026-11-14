package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import utils.DBContext;

/**
 * UC-35 View System Dashboard: số liệu tổng quan cho Admin.
 */
public class AdminDashboardDAO {

    /**
     * Số tài khoản theo role (Customer, Organizer, Staff, Admin).
     */
    public Map<String, Integer> countUsersByRole() throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (String role : new String[]{"Customer", "Organizer", "Staff", "Admin"}) {
            counts.put(role, 0);
        }
        String sql = "SELECT UPPER(role), COUNT(*) FROM Users GROUP BY UPPER(role)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                for (String role : counts.keySet()) {
                    if (role.equalsIgnoreCase(rs.getString(1))) {
                        counts.put(role, rs.getInt(2));
                    }
                }
            }
        }
        return counts;
    }

    /**
     * Số sự kiện theo status (DRAFT, PENDING_APPROVAL, ACTIVE, REJECTED,
     * CANCELLED).
     */
    public Map<String, Integer> countEventsByStatus() throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (String status : new String[]{"PENDING_APPROVAL", "ACTIVE", "DRAFT", "REJECTED", "CANCELLED"}) {
            counts.put(status, 0);
        }
        String sql = "SELECT UPPER(status), COUNT(*) FROM Events GROUP BY UPPER(status)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString(1), rs.getInt(2));
            }
        }
        return counts;
    }

    /**
     * {số đơn Paid, doanh thu (final_amount của đơn Paid), số giao dịch cần
     * hoàn tiền thủ công}.
     */
    public Object[] getSalesSummary() throws SQLException {
        String sql = "SELECT (SELECT COUNT(*) FROM Orders WHERE status = 'Paid'), "
                + "(SELECT ISNULL(SUM(final_amount), 0) FROM Orders WHERE status = 'Paid'), "
                + "(SELECT COUNT(*) FROM Payments WHERE payment_status = ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, PaymentDAO.PAYMENT_REFUND_PENDING);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                BigDecimal revenue = rs.getBigDecimal(2);
                return new Object[]{rs.getInt(1), revenue == null ? BigDecimal.ZERO : revenue, rs.getInt(3)};
            }
        }
    }

    /**
     * Revenue by calendar day for a selected recent period; SQL Server.
     */
    public java.util.List<java.util.Map<String, Object>> revenueTrend(int days) throws SQLException {
        java.util.List<java.util.Map<String, Object>> points = new java.util.ArrayList<>();
        String sql = "SELECT CAST(created_at AS DATE) d, SUM(final_amount) amount "
                + "FROM Orders WHERE status='Paid' AND created_at >= DATEADD(day, ?, CAST(GETDATE() AS DATE)) "
                + "GROUP BY CAST(created_at AS DATE) ORDER BY d";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, 1 - days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> point = new LinkedHashMap<>();
                    point.put("day", rs.getDate("d").toString());
                    point.put("amount", rs.getBigDecimal("amount"));
                    points.add(point);
                }
            }
        }
        // Include zero-sales dates so the line does not skip calendar days.
        java.util.Map<String, java.math.BigDecimal> byDay = new LinkedHashMap<>();
        for (Map<String, Object> point : points) {
            byDay.put((String) point.get("day"), (java.math.BigDecimal) point.get("amount"));
        }
        java.util.List<Map<String, Object>> complete = new java.util.ArrayList<>();
        java.time.LocalDate today = java.time.LocalDate.now();
        for (int offset = days - 1; offset >= 0; offset--) {
            String day = today.minusDays(offset).toString();
            Map<String, Object> point = new LinkedHashMap<>();
            point.put("day", day);
            point.put("amount", byDay.getOrDefault(day, java.math.BigDecimal.ZERO));
            complete.add(point);
        }
        return complete;
    }

    public Map<String, Integer> orderStatusCounts() throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("Paid", 0);
        counts.put("Pending", 0);
        counts.put("Cancelled", 0);
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(
                "SELECT status, COUNT(*) cnt FROM Orders GROUP BY status"); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString("status");
                if (key != null) {
                    for (String known : counts.keySet()) {
                        if (known.equalsIgnoreCase(key)) {
                            counts.put(known, rs.getInt("cnt"));
                        }
                    }
                }
            }
        }
        return counts;
    }

    public java.util.List<java.util.Map<String, Object>> recentOrders(int limit) throws SQLException {
        java.util.List<java.util.Map<String, Object>> rows = new java.util.ArrayList<>();
        String sql = "SELECT TOP (?) o.order_id, o.order_code, o.final_amount, o.status, o.created_at, "
                + "u.full_name customer, "
                + "(SELECT TOP 1 e.event_name FROM Order_Details od "
                + "JOIN Event_Tickets et ON et.event_ticket_id=od.event_ticket_id "
                + "JOIN Events e ON e.event_id=et.event_id WHERE od.order_id=o.order_id ORDER BY od.order_detail_id) event_name "
                + "FROM Orders o JOIN Users u ON u.user_id=o.customer_id ORDER BY o.created_at DESC, o.order_id DESC";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", rs.getInt("order_id"));
                    row.put("code", rs.getString("order_code"));
                    row.put("customer", rs.getString("customer"));
                    row.put("event", rs.getString("event_name"));
                    row.put("amount", rs.getBigDecimal("final_amount"));
                    row.put("status", rs.getString("status"));
                    row.put("created", rs.getTimestamp("created_at"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    public java.util.List<java.util.Map<String, Object>> pendingEventPreview(int limit) throws SQLException {
        java.util.List<java.util.Map<String, Object>> rows = new java.util.ArrayList<>();
        String sql = "SELECT TOP (?) e.event_id, e.event_name, u.full_name organizer, e.created_at "
                + "FROM Events e JOIN Users u ON u.user_id=e.organizer_id "
                + "WHERE e.status='PENDING_APPROVAL' ORDER BY e.created_at DESC, e.event_id DESC";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", rs.getInt("event_id"));
                    row.put("name", rs.getString("event_name"));
                    row.put("organizer", rs.getString("organizer"));
                    row.put("created", rs.getTimestamp("created_at"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    public Map<String, Object> orderDetail(int id) throws SQLException {
        String sql = "SELECT o.order_id, o.order_code, o.final_amount, o.total_amount, o.discount_amount, "
                + "o.status, o.created_at, u.full_name customer, u.email, u.phone "
                + "FROM Orders o JOIN Users u ON u.user_id=o.customer_id WHERE o.order_id=?";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("order_id"));
                row.put("code", rs.getString("order_code"));
                row.put("amount", rs.getBigDecimal("final_amount"));
                row.put("subtotal", rs.getBigDecimal("total_amount"));
                row.put("discount", rs.getBigDecimal("discount_amount"));
                row.put("status", rs.getString("status"));
                row.put("created", rs.getTimestamp("created_at"));
                row.put("customer", rs.getString("customer"));
                row.put("email", rs.getString("email"));
                row.put("phone", rs.getString("phone"));
                return row;
            }
        }
    }

    public java.util.List<Map<String, Object>> orderItems(int id) throws SQLException {
        java.util.List<Map<String, Object>> rows = new java.util.ArrayList<>();
        String sql = "SELECT e.event_name, et.ticket_name, od.quantity, od.unit_price, od.subtotal "
                + "FROM Order_Details od JOIN Event_Tickets et ON od.event_ticket_id=et.event_ticket_id "
                + "JOIN Events e ON et.event_id=e.event_id WHERE od.order_id=? ORDER BY od.order_detail_id";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("event", rs.getString(1));
                    row.put("ticket", rs.getString(2));
                    row.put("quantity", rs.getInt(3));
                    row.put("price", rs.getBigDecimal(4));
                    row.put("subtotal", rs.getBigDecimal(5));
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    /**
     * Latest 100 orders, optionally filtered by status. The page is
     * intentionally read-only.
     */
    public java.util.List<Map<String, Object>> orderList(String status, int limit) throws SQLException {
        java.util.List<Map<String, Object>> rows = new java.util.ArrayList<>();
        String sql = "SELECT TOP (?) o.order_id, o.order_code, o.final_amount, o.status, o.created_at, "
                + "u.full_name customer FROM Orders o JOIN Users u ON o.customer_id=u.user_id "
                + ("All".equals(status) ? "" : "WHERE o.status=? ")
                + "ORDER BY o.created_at DESC, o.order_id DESC";
        try (Connection c = DBContext.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            if (!"All".equals(status)) {
                ps.setString(2, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", rs.getInt("order_id"));
                    row.put("code", rs.getString("order_code"));
                    row.put("amount", rs.getBigDecimal("final_amount"));
                    row.put("status", rs.getString("status"));
                    row.put("created", rs.getTimestamp("created_at"));
                    row.put("customer", rs.getString("customer"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }
}
