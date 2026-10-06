/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dao.PaymentDAO;
import java.math.BigDecimal;
import model.Payment;
import model.PaymentResponse;

/**
 *
 * @author BT
 */
public class PaymentController {

    private final PaymentDAO paymentDAO;

    public PaymentController() {
        paymentDAO = new PaymentDAO();
    }

    public boolean createPayment(int orderId, BigDecimal amount) {

        // 1. Validate payment request
        boolean valid = paymentDAO.validatePaymentRequest(orderId, amount);

        if (!valid) {
            return false;
        }

        // 2. Create payment
        Payment payment = new Payment();

        payment.setOrderId(orderId);
        payment.setPaymentMethod("VNPAY");
        payment.setTransactionCode(null);
        payment.setAmount(amount);
        payment.setPaymentStatus("Pending");
        payment.setPaidAt(null);

        return paymentDAO.createPayment(payment);
    }

    public boolean processPaymentResponse(PaymentResponse response) {

        // 1. Verify payment result
        boolean valid = paymentDAO.verifyPaymentResult(response);

        if (!valid) {
            return false;
        }

        // 2. Process valid payment response
        return paymentDAO.processPaymentResponse(response);
    }
}
