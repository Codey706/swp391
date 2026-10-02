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
import model.Payment;
import utils.DBcontext;

/**
 *
 * @author BT
 */
public class PaymentDAO {

    public boolean createPayment(Payment payment) {

        String sql = """
            INSERT INTO Payments
            (order_id, payment_method, transaction_code,
             amount, payment_status, paid_at, created_at)
            VALUES (?, ?, ?, ?, ?, ?, GETDATE())
            """;

        try (Connection conn = DBcontext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, payment.getOrderId());
            ps.setString(2, payment.getPaymentMethod());
            ps.setString(3, payment.getTransactionCode());
            ps.setBigDecimal(4, payment.getAmount());
            ps.setString(5, payment.getPaymentStatus());
            ps.setTimestamp(6, null);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    public boolean validatePaymentRequest(int orderId, BigDecimal amount) {

    String sql = """
        SELECT final_amount, status
        FROM Orders
        WHERE order_id = ?
        """;

    try (Connection conn = DBcontext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, orderId);

        try (ResultSet rs = ps.executeQuery()) {

            //Order does not exist
            if (!rs.next()) {
                return false;
            }

            BigDecimal finalAmount = rs.getBigDecimal("final_amount");
            String status = rs.getString("status");

            // Order must be Pending
            if (!"Pending".equalsIgnoreCase(status)) {
                return false;
            }

            // Amount must be valid
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                return false;
            }

            // Amount must match the Order amount
            return amount.compareTo(finalAmount) == 0;
        }

    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
}
