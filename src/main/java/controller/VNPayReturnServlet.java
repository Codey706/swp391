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
import java.sql.SQLException;
import java.util.Map;
import model.Payment;
import utils.VnPayUtil;

/**
 * Return URL: trình duyệt của khách được VNPay chuyển về sau khi thanh toán.
 * Cập nhật đơn hàng qua PaymentDAO.applyVnPayResult() (cùng logic với IPN, xử lý
 * đúng một lần dù Return và IPN đến theo thứ tự nào), rồi hiển thị kết quả.
 *
 * @author BT
 */
@WebServlet(name = "VNPayReturnServlet", urlPatterns = {"/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, String> params = VnPayUtil.paramsFrom(request);

        try {
            // Bước 1: Xác minh chữ ký VNPay.
            if (!VnPayUtil.verifySignature(params)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Chữ ký VNPay không hợp lệ.");
                return;
            }

            String transactionCode = params.get("vnp_TxnRef");
            BigDecimal amount = VnPayUtil.parseAmount(params.get("vnp_Amount"));
            if (transactionCode == null || transactionCode.isBlank() || amount == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu hoặc sai thông tin giao dịch VNPay.");
                return;
            }
            boolean success = "00".equals(params.get("vnp_ResponseCode"))
                    && "00".equals(params.get("vnp_TransactionStatus"));

            // Bước 2: Đối chiếu và cập nhật database (idempotent).
            VnPayOutcome outcome = paymentDAO.applyVnPayResult(
                    transactionCode, amount, success, params.get("vnp_TransactionNo"));
            if (outcome == VnPayOutcome.PAID) {
                PaymentNotifier.orderPaid(paymentDAO.findOrderIdByTransactionCode(transactionCode));
            }

            // Bước 3: Hiển thị kết quả kèm thông tin đơn hàng.
            Object[] order = paymentDAO.findOrderSummaryByTransactionCode(transactionCode);
            if (order != null) {
                request.setAttribute("orderId", order[0]);
                request.setAttribute("orderCode", order[1]);
                request.setAttribute("finalAmount", order[2]);
                request.setAttribute("orderStatus", order[3]);
            } else {
                request.setAttribute("finalAmount", amount);
            }
            String vnpTransactionNo = params.get("vnp_TransactionNo");
            request.setAttribute("transactionCode",
                    vnpTransactionNo != null && !vnpTransactionNo.isBlank() && !"0".equals(vnpTransactionNo)
                    ? vnpTransactionNo : null);
            request.setAttribute("bankCode", params.get("vnp_BankCode"));
            switch (outcome) {
                case PAID ->
                    showResult(request, response, true,
                            "Thanh toán thành công! Vé điện tử đã được phát hành.");
                case FAILED ->
                    showResult(request, response, false,
                            "Giao dịch chưa thành công hoặc đã bị hủy.");
                case REFUND_REQUIRED ->
                    showResult(request, response, false, REFUND_MESSAGE);
                case NOT_FOUND ->
                    showResult(request, response, false,
                            "Không tìm thấy giao dịch trong hệ thống.");
                case AMOUNT_MISMATCH ->
                    showResult(request, response, false,
                            "Thông tin giao dịch không khớp với đơn hàng.");
                default ->
                    showAlreadyProcessed(request, response, transactionCode);
            }
        } catch (IllegalStateException e) {
            log("VNPay configuration error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể xác minh giao dịch VNPay.");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    static final String REFUND_MESSAGE = "Thanh toán đến sau khi đơn hàng đã hết thời gian giữ vé (hoặc sự kiện đã hủy) "
            + "nên vé không được phát hành. Chúng tôi sẽ liên hệ để hoàn tiền.";

    /** IPN đã xử lý trước khi khách quay về: hiển thị theo trạng thái đã lưu. */
    private void showAlreadyProcessed(HttpServletRequest request, HttpServletResponse response,
            String transactionCode) throws ServletException, IOException, SQLException {
        Payment payment = paymentDAO.getPaymentByTransactionCode(transactionCode);
        String status = payment == null ? "" : payment.getPaymentStatus();
        if (PaymentDAO.PAYMENT_SUCCESS.equalsIgnoreCase(status)) {
            showResult(request, response, true, "Thanh toán thành công! Vé điện tử đã được phát hành.");
        } else if (PaymentDAO.PAYMENT_REFUND_PENDING.equalsIgnoreCase(status)) {
            showResult(request, response, false, REFUND_MESSAGE);
        } else {
            showResult(request, response, false, "Giao dịch chưa thành công hoặc đã bị hủy.");
        }
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response, boolean success, String message)
            throws ServletException, IOException {
        request.setAttribute("paymentSuccess", success);
        request.setAttribute("paymentMessage", message);

        request.getRequestDispatcher("/WEB-INF/views/customer/payment-result.jsp").forward(request, response);
    }
}
