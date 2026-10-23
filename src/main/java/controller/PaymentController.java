/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dao.PaymentDAO;
import java.math.BigDecimal;
import model.Payment;
import model.PaymentResponse;
import java.util.UUID;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.TreeMap;

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
        payment.setTransactionCode(
                "LT" + UUID.randomUUID().toString().replace("-", "")
        );
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

    public model.Payment getPaymentByTransactionCode(String transactionCode) {
        if (transactionCode == null || transactionCode.isBlank()) {
            return null;
        }

        return paymentDAO.getPaymentByTransactionCode(transactionCode);
    }

    public model.Payment getPendingPaymentForOrder(int orderId) {
        if (orderId <= 0) {
            return null;
        }

        return paymentDAO.getPendingPaymentForOrder(orderId);
    }

    public String createVNPayUrl(
            int orderId,
            BigDecimal amount,
            HttpServletRequest request) {

        if (!paymentDAO.validatePaymentRequest(orderId, amount)) {
            throw new IllegalArgumentException(
                    "Đơn hàng không hợp lệ hoặc không còn chờ thanh toán."
            );
        }

        // Tái sử dụng giao dịch Pending nếu đã tồn tại.
        Payment payment = paymentDAO.getPendingPaymentForOrder(orderId);

        if (payment == null) {
            Payment newPayment = new Payment();
            newPayment.setOrderId(orderId);
            newPayment.setPaymentMethod("VNPAY");

            // VNPay TxnRef nên dùng ký tự chữ và số.
            newPayment.setTransactionCode(
                    "LT" + UUID.randomUUID().toString().replace("-", "")
            );

            newPayment.setAmount(amount);
            newPayment.setPaymentStatus("Pending");
            newPayment.setPaidAt(null);

            if (!paymentDAO.createPayment(newPayment)) {
                throw new IllegalStateException(
                        "Không thể tạo giao dịch thanh toán."
                );
            }

            payment = paymentDAO.getPendingPaymentForOrder(orderId);
        }

        if (payment == null
                || payment.getTransactionCode() == null
                || payment.getAmount() == null
                || payment.getAmount().compareTo(amount) != 0) {
            throw new IllegalStateException(
                    "Không tìm thấy giao dịch Pending hợp lệ."
            );
        }

        long amountVnp;
        try {
            amountVnp = amount.movePointRight(2).longValueExact();
        } catch (ArithmeticException e) {
            throw new IllegalArgumentException(
                    "Số tiền không hợp lệ cho VNPay.", e
            );
        }

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter
                = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", utils.VnPayConfig.getTmnCode());
        params.put("vnp_Amount", String.valueOf(amountVnp));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", payment.getTransactionCode());
        params.put("vnp_OrderInfo", "Thanh toan don hang " + orderId);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");

        String baseUrl = request.getScheme() + "://"
                + request.getServerName()
                + ":" + request.getServerPort()
                + request.getContextPath();

        params.put("vnp_ReturnUrl", baseUrl + "/vnpay-return");
        params.put("vnp_IpAddr", request.getRemoteAddr());
        params.put("vnp_CreateDate", now.format(formatter));
        params.put("vnp_ExpireDate",
                now.plusMinutes(15).format(formatter));

        return utils.VnPayUtil.createPaymentUrl(params);
    }
}
