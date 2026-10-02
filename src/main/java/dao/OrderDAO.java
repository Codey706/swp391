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
import utils.DBcontext;

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

        try (Connection conn = DBcontext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
 // Store order information
    public static class OrderInfo {

        private int orderId;
        private BigDecimal finalAmount;
        private String status;

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
