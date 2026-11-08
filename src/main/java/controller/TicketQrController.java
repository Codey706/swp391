package controller;

import dao.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Auth;
import utils.Constants;
import utils.QrCodes;

/**
 * UC-18: ảnh QR (PNG) của một vé, sinh tại server. GET
 * /customer/ticket-qr?code=... Chỉ trả về cho chủ vé (đơn Paid); mã vé không
 * rời khỏi hệ thống như khi dùng dịch vụ QR bên ngoài.
 */
@WebServlet("/customer/ticket-qr")
public class TicketQrController extends HttpServlet {

    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String code = request.getParameter("code");
        Auth customer = (Auth) request.getSession().getAttribute(Constants.SESSION_USER);
        if (code == null || code.isBlank() || code.length() > Constants.TICKET_CODE_MAX_LENGTH) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            if (!ticketDAO.isTicketOwnedBy(code, customer.getUserId())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        } catch (SQLException e) {
            throw new ServletException("Cannot verify ticket owner", e);
        }
        byte[] png = QrCodes.png(code, 360);
        response.setContentType("image/png");
        response.setContentLength(png.length);
        response.setHeader("Cache-Control", "private, max-age=3600");
        response.getOutputStream().write(png);
    }
}
