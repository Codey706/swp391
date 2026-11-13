package controller;

import dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Booking;
import utils.SessionUtils;
import utils.ValidationUtils;

/**
 * UC-07.1 View Order Detail: GET /customer/booking-detail?orderId=...
 * Customer chỉ xem được đơn của chính mình.
 */
@WebServlet(name = "BookingDetailController", urlPatterns = {"/customer/booking-detail"})
public class BookingDetailController extends HttpServlet {

    private static final String BOOKING_DETAIL_VIEW = "/WEB-INF/views/customer/booking-detail.jsp";

    private final BookingDAO bookingDao = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int orderId = ValidationUtils.parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-history");
            return;
        }
        try {
            // customerId luôn lấy từ session: đơn của người khác sẽ không tìm thấy
            Booking booking = bookingDao.getBookingDetail(orderId, SessionUtils.currentUser(request).getUserId());
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
                return;
            }
            request.setAttribute("booking", booking);
            request.getRequestDispatcher(BOOKING_DETAIL_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
