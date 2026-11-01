/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import utils.Constants;
import utils.DBContext;

/**
 *
 * @author ADMIN
 */
public class OrderDAO {
    // Get order information by order ID

    public OrderInfo getOrderForPayment(int orderId) {

        String sql = """
            SELECT order_id, final_amount, status
            FROM Orders
            WHERE order_id = ?
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            // Set the order ID
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                // Check if the order exists
                if (rs.next()) {
                    OrderInfo order = new OrderInfo();
                    // Get order information
                    order.setOrderId(rs.getInt("order_id"));
                    order.setFinalAmount(rs.getBigDecimal("final_amount"));
                    order.setStatus(rs.getString("status"));
                    // Return null if the order is not found
                    return order;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Khóa dòng Orders (UPDLOCK) trong transaction của caller để các request/callback
     * song song cho cùng một đơn phải xếp hàng. "holding" tính theo giờ DB.
     *
     * @return null nếu không có đơn
     */
    public OrderInfo lockOrder(Connection conn, int orderId) throws SQLException {
        String sql = """
            SELECT order_id, order_code, final_amount, status,
                   CASE WHEN hold_expired_at IS NOT NULL AND hold_expired_at > GETDATE()
                        THEN 1 ELSE 0 END AS holding
            FROM Orders WITH (UPDLOCK, ROWLOCK)
            WHERE order_id = ?
            """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                OrderInfo order = new OrderInfo();
                order.setOrderId(rs.getInt("order_id"));
                order.setOrderCode(rs.getString("order_code"));
                order.setFinalAmount(rs.getBigDecimal("final_amount"));
                order.setStatus(rs.getString("status"));
                order.setHolding(rs.getInt("holding") == 1);
                return order;
            }
        }
    }

    /** Pending -> Paid. @return false nếu đơn không còn Pending (đã xử lý/đã hủy). */
    public boolean markPaid(Connection conn, int orderId) throws SQLException {
        String sql = "UPDATE Orders SET status = ?, updated_at = GETDATE() WHERE order_id = ? AND status = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, Constants.ORDER_PAID);
            ps.setInt(2, orderId);
            ps.setString(3, Constants.ORDER_PENDING);
            return ps.executeUpdate() == 1;
        }
    }
 // Store order information
    public static class OrderInfo {

        private int orderId;
        private BigDecimal finalAmount;
        private String status;
        private String orderCode;
        private boolean holding;

        public String getOrderCode() {
            return orderCode;
        }

        public void setOrderCode(String orderCode) {
            this.orderCode = orderCode;
        }

        /** true nếu đơn còn trong thời gian giữ vé (theo giờ DB). */
        public boolean isHolding() {
            return holding;
        }

        public void setHolding(boolean holding) {
            this.holding = holding;
        }

        public int getOrderId() {
            return orderId;
        }

        public void setOrderId(int orderId) {
            this.orderId = orderId;
        }

        public BigDecimal getFinalAmount() {
            return finalAmount;
        }

        public void setFinalAmount(BigDecimal finalAmount) {
            this.finalAmount = finalAmount;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }
    }
}
