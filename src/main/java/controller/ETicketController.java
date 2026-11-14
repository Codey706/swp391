package controller;

import dao.BookingDAO;
import dao.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import utils.SessionUtils;
import utils.ValidationUtils;

/** Danh sách vé điện tử của Customer đang đăng nhập. */
@WebServlet("/customer/e-tickets")
public class ETicketController extends HttpServlet {

        private final TicketDAO ticketDAO = new TicketDAO();
        private final BookingDAO bookingDAO = new BookingDAO();

        @Override
        protected void doGet(HttpServletRequest request,
                        HttpServletResponse response)
                        throws ServletException, IOException {

                try {
                        int customerId = SessionUtils.currentUser(request).getUserId();

                        String orderIdParam = request.getParameter("orderId");

                        if (orderIdParam != null) {
                                int orderId = ValidationUtils.parseIntOrDefault(
                                                orderIdParam, -1);

                                if (orderId <= 0) {
                                        response.sendError(
                                                        HttpServletResponse.SC_BAD_REQUEST,
                                                        "Mã đơn hàng không hợp lệ.");
                                        return;
                                }

                                // Kiểm tra đơn hàng thuộc Customer đang đăng nhập.
                                if (bookingDAO.getBookingDetail(orderId, customerId) == null) {
                                        response.sendError(
                                                        HttpServletResponse.SC_NOT_FOUND,
                                                        "Không tìm thấy đơn đặt vé.");
                                        return;
                                }

                                // Chỉ lấy vé của đúng đơn hàng.
                                request.setAttribute(
                                                "tickets",
                                                ticketDAO.getTicketsByOrderId(orderId));

                        } else {
                                // Truy cập từ menu Vé điện tử: hiển thị tất cả vé.
                                request.setAttribute(
                                                "tickets",
                                                ticketDAO.getTicketsByCustomerId(customerId));
                        }

                        request.getRequestDispatcher(
                                        "/WEB-INF/views/customer/e-tickets.jsp")
                                        .forward(request, response);

                } catch (SQLException e) {
                        throw new ServletException(e);
                }
        }
}