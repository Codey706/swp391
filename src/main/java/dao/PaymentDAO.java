/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author BT
 */
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Payment;
import model.PaymentResponse;
import utils.DBContext;

public class PaymentDAO {

    public boolean createPayment(Payment payment) {

        String sql = """
            INSERT INTO Payments
            (order_id, payment_method, transaction_code,
             amount, payment_status, paid_at, created_at)
            VALUES (?, ?, ?, ?, ?, ?, GETDATE())
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return false;
                }

                BigDecimal finalAmount = rs.getBigDecimal("final_amount");
                String status = rs.getString("status");

                if (!"Pending".equalsIgnoreCase(status)) {
                    return false;
                }

                if (amount == null
                        || amount.compareTo(BigDecimal.ZERO) <= 0) {
                    return false;
                }

                return amount.compareTo(finalAmount) == 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean verifyPaymentResult(PaymentResponse response) {

        if (response == null
                || response.getOrderId() <= 0
                || response.getAmount() == null
                || response.getAmount().compareTo(BigDecimal.ZERO) <= 0
                || response.getTransactionCode() == null
                || response.getTransactionCode().isBlank()
                || response.getResponseCode() == null) {

            return false;
        }

        String sql = """
            SELECT p.transaction_code,
                   p.amount,
                   p.payment_status,
                   o.final_amount,
                   o.status
            FROM Payments p
            INNER JOIN Orders o
                ON p.order_id = o.order_id
            WHERE p.order_id = ?
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, response.getOrderId());

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return false;
                }

                String transactionCode
                        = rs.getString("transaction_code");

                BigDecimal paymentAmount
                        = rs.getBigDecimal("amount");

                BigDecimal orderAmount
                        = rs.getBigDecimal("final_amount");

                String paymentStatus
                        = rs.getString("payment_status");

                String orderStatus
                        = rs.getString("status");

                if (!"Pending".equalsIgnoreCase(paymentStatus)) {
                    return false;
                }

                if (!"Pending".equalsIgnoreCase(orderStatus)) {
                    return false;
                }

                if (paymentAmount == null || orderAmount == null) {
                    return false;
                }

                if (response.getAmount()
                        .compareTo(paymentAmount) != 0) {
                    return false;
                }

                if (response.getAmount()
                        .compareTo(orderAmount) != 0) {
                    return false;
                }

                if (transactionCode == null
                        || !response.getTransactionCode()
                                .equals(transactionCode)) {
                    return false;
                }

                if (!"00".equals(response.getResponseCode())) {
                    return false;
                }

                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean processPaymentResponse(PaymentResponse response) {

        if (response == null
                || response.getOrderId() <= 0
                || response.getTransactionCode() == null
                || response.getTransactionCode().isBlank()) {

            return false;
        }

        String sql = """
            UPDATE Payments
            SET transaction_code = ?,
                payment_status = ?,
                paid_at = GETDATE()
            WHERE order_id = ?
              AND payment_status = 'Pending'
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, response.getTransactionCode());
            ps.setString(2, "Success");
            ps.setInt(3, response.getOrderId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
