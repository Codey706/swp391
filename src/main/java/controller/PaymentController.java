package controller;

import dao.PaymentDAO;
import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;
import model.Payment;
import utils.Constants;

/**
 * Tạo URL thanh toán VNPay cho một đơn Pending. Kết quả thanh toán được xử lý
 * ở VNPayReturnServlet (/vnpay-return) và VNPayIpnServlet (/vnpay-ipn), cùng
 * dùng PaymentDAO.applyVnPayResult().
 *
 * @author BT
 */
public class PaymentController {

    private static final DateTimeFormatter VNP_DATE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private final PaymentDAO paymentDAO;

    public PaymentController() {
        paymentDAO = new PaymentDAO();
    }

    /**
     * @param holdExpiredAt Orders.hold_expired_at; link VNPay hết hạn đúng lúc hết giữ chỗ
     */
    public String createVNPayUrl(
            int orderId,
            BigDecimal amount,
            LocalDateTime holdExpiredAt,
            HttpServletRequest request) {

        if (!paymentDAO.validatePaymentRequest(orderId, amount)) {
            throw new IllegalArgumentException(
                    "Đơn hàng không hợp lệ hoặc không còn chờ thanh toán."
            );
        }

        // VNPay hiểu thời gian theo GMT+7; hold_expired_at do SQL Server (GETDATE) sinh ra theo giờ Việt Nam
        LocalDateTime now = LocalDateTime.now(ZoneId.of(Constants.BUSINESS_ZONE_ID));
        if (holdExpiredAt == null || !holdExpiredAt.isAfter(now.plusSeconds(30))) {
            throw new IllegalStateException("Thời gian giữ vé đã hết hoặc sắp hết.");
        }

        long amountVnp;
        try {
            amountVnp = amount.movePointRight(2).longValueExact();
        } catch (ArithmeticException e) {
            throw new IllegalArgumentException(
                    "Số tiền không hợp lệ cho VNPay.", e
            );
        }

        // Mỗi lần thanh toán là một giao dịch mới: VNPay không nhận lại vnp_TxnRef đã dùng.
        // Giao dịch Pending cũ (nếu có) vẫn được xử lý nếu VNPay báo kết quả muộn.
        Payment payment = new Payment();
        payment.setOrderId(orderId);
        payment.setPaymentMethod("VNPAY");
        payment.setTransactionCode("LT" + UUID.randomUUID().toString().replace("-", ""));
        payment.setAmount(amount);
        payment.setPaymentStatus(PaymentDAO.PAYMENT_PENDING);
        payment.setPaidAt(null);
        if (!paymentDAO.createPayment(payment)) {
            throw new IllegalStateException("Không thể tạo giao dịch thanh toán.");
        }

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
        params.put("vnp_CreateDate", now.format(VNP_DATE));
        params.put("vnp_ExpireDate", holdExpiredAt.format(VNP_DATE));

        return utils.VnPayUtil.createPaymentUrl(params);
    }
}
