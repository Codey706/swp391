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
}
