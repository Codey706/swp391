package controller;

import dao.PaymentDAO;
import dao.PaymentDAO.VnPayOutcome;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import utils.VnPayConfig;
import utils.VnPayUtil;

/**
 * IPN (Instant Payment Notification): VNPay gọi server-to-server tới /vnpay-ipn
 * để báo kết quả giao dịch, kể cả khi khách đóng trình duyệt không quay về
 * Return URL. URL này phải được khai báo trong trang quản trị merchant VNPay.
 *
 * Phản hồi JSON theo tài liệu VNPay: 00 Confirm Success · 01 Order not found ·
 * 02 Order already confirmed · 04 Invalid amount · 97 Invalid signature · 99
 * Unknown error. VNPay sẽ gửi lại IPN cho tới khi nhận 00 hoặc 02, nên xử lý
 * phải idempotent (PaymentDAO.applyVnPayResult khóa dòng và chỉ xử lý giao dịch
 * còn Pending).
 */
@WebServlet(name = "VNPayIpnServlet", urlPatterns = {"/vnpay-ipn"})
public class VNPayIpnServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(VNPayIpnServlet.class.getName());

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, String> params = VnPayUtil.paramsFrom(request);
        String transactionCode = params.get("vnp_TxnRef");
        try {
            if (!VnPayUtil.verifySignature(params)
                    || !VnPayConfig.getTmnCode().equals(params.get("vnp_TmnCode"))) {
                reply(response, "97", "Invalid signature");
                return;
            }
            BigDecimal amount = VnPayUtil.parseAmount(params.get("vnp_Amount"));
            if (transactionCode == null || transactionCode.isBlank()) {
                reply(response, "01", "Order not found");
                return;
            }
            if (amount == null) {
                reply(response, "04", "Invalid amount");
                return;
            }
            boolean success = "00".equals(params.get("vnp_ResponseCode"))
                    && "00".equals(params.get("vnp_TransactionStatus"));

            VnPayOutcome outcome = paymentDAO.applyVnPayResult(
                    transactionCode, amount, success, params.get("vnp_TransactionNo"));
            LOGGER.info("VNPay IPN txnRef=" + transactionCode + ", success=" + success + " -> " + outcome);

            switch (outcome) {
                case PAID -> {
                    PaymentNotifier.orderPaid(paymentDAO.findOrderIdByTransactionCode(transactionCode));
                    reply(response, "00", "Confirm Success");
                }
                case FAILED, REFUND_REQUIRED ->
                    reply(response, "00", "Confirm Success");
                case ALREADY_PROCESSED ->
                    reply(response, "02", "Order already confirmed");
                case NOT_FOUND ->
                    reply(response, "01", "Order not found");
                case AMOUNT_MISMATCH ->
                    reply(response, "04", "Invalid amount");
                default ->
                    reply(response, "99", "Unknown error");
            }
        } catch (Exception e) {
            // Lỗi tạm thời (DB...): trả 99 để VNPay gửi lại IPN sau
            LOGGER.log(Level.SEVERE, "VNPay IPN failed, txnRef=" + transactionCode, e);
            reply(response, "99", "Unknown error");
        }
    }

    private static void reply(HttpServletResponse response, String code, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"RspCode\":\"" + code + "\",\"Message\":\"" + message + "\"}");
    }
}
