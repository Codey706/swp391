/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;
import java.util.TreeMap;
import model.Payment;
import model.PaymentResponse;
import utils.VnPayUtil;

/**
 *
 * @author BT
 */
@WebServlet(name = "VNPayReturnServlet", urlPatterns = {"/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        Map<String, String> params = new TreeMap<>();

        for (Map.Entry<String, String[]> entry
                : request.getParameterMap().entrySet()) {

            String[] values = entry.getValue();

            if (values != null && values.length > 0) {
                params.put(entry.getKey(), values[0]);
            }
        }

        try {
            // Bước 1: Xác minh chữ ký VNPay.
            if (!VnPayUtil.verifySignature(params)) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Chữ ký VNPay không hợp lệ."
                );
                return;
            }

            String transactionCode = params.get("vnp_TxnRef");
            String responseCode = params.get("vnp_ResponseCode");
            String transactionStatus = params.get("vnp_TransactionStatus");
            String amountText = params.get("vnp_Amount");

            // Bước 2: Chỉ tiếp tục nếu giao dịch thành công.
            if (!"00".equals(responseCode)
                    || !"00".equals(transactionStatus)) {
                showResult(request, response, false,
                        "Giao dịch chưa thành công hoặc đã bị hủy.");
                return;
            }

            if (transactionCode == null || transactionCode.isBlank()
                    || amountText == null || !amountText.matches("\\d+")) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Thiếu hoặc sai thông tin giao dịch VNPay."
                );
                return;
            }

            // VNPay gửi số tiền theo đơn vị VND x 100.
            BigDecimal amount = new BigDecimal(amountText)
                    .movePointLeft(2);

            // Bước 3: Tìm đúng bản ghi thanh toán bằng mã giao dịch.
            Payment payment
                    = paymentDAO.getPaymentByTransactionCode(transactionCode);

            if (payment == null) {
                showResult(request, response, false,
                        "Không tìm thấy giao dịch trong hệ thống.");
                return;
            }

            // Bước 4: Tạo dữ liệu để đối chiếu với database.
            PaymentResponse paymentResponse = new PaymentResponse();
            paymentResponse.setOrderId(payment.getOrderId());
            paymentResponse.setTransactionCode(transactionCode);
            paymentResponse.setAmount(amount);
            paymentResponse.setResponseCode(responseCode);
            paymentResponse.setPaymentStatus(transactionStatus);

            // Bước 5: Đối chiếu dữ liệu và cập nhật database.
            if (!paymentDAO.verifyPaymentResult(paymentResponse)) {
                showResult(request, response, false,
                        "Thông tin giao dịch không khớp với đơn hàng.");
                return;
            }

            boolean processed
                    = paymentDAO.processPaymentResponse(paymentResponse);

            if (!processed) {
                showResult(request, response, false,
                        "Chưa thể cập nhật thanh toán. Vui lòng liên hệ hỗ trợ.");
                return;
            }

            showResult(request, response, true,
                    "Thanh toán thành công! Đơn hàng đã được cập nhật.");

        } catch (IllegalStateException e) {
            getServletContext().log("VNPay configuration error", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể xác minh giao dịch VNPay."
            );
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Số tiền giao dịch không hợp lệ."
            );
        } catch (Exception e) {
            getServletContext().log("Error processing VNPay return", e);
            throw new ServletException(
                    "Không thể xử lý kết quả thanh toán.", e
            );
        }
    }

    private void showResult(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean success,
            String message
    ) throws ServletException, IOException {

        request.setAttribute("paymentSuccess", success);
        request.setAttribute("paymentMessage", message);

        request.getRequestDispatcher(
                "/WEB-INF/views/customer/payment-result.jsp"
        ).forward(request, response);
    }
}
