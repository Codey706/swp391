package controller;

import dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.Set;
import utils.Constants;
import utils.SessionUtils;
import utils.ValidationUtils;

/** Lịch sử đặt vé của Customer đang đăng nhập: lọc theo trạng thái, tìm theo từ khóa, phân trang. */
@WebServlet(name = "BookingHistoryController", urlPatterns = {"/customer/booking-history"})
public class BookingHistoryController extends HttpServlet {

    private static final String BOOKING_HISTORY_VIEW = "/WEB-INF/views/customer/booking-history.jsp";

    private static final Set<String> VALID_STATUSES = Set.of(
            Constants.ORDER_PENDING, Constants.ORDER_PAID, Constants.ORDER_CANCELLED);

    private final BookingDAO bookingDao = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Trạng thái không hợp lệ hoặc rỗng thì không lọc
        String status = request.getParameter("status") == null ? "" : request.getParameter("status").trim();
        status = VALID_STATUSES.contains(status) ? status : null;
        String keyword = ValidationUtils.isNullOrBlank(request.getParameter("keyword"))
                ? null : request.getParameter("keyword").trim();
        if (keyword != null && keyword.length() > Constants.BOOKING_KEYWORD_MAX_LENGTH) {
            keyword = keyword.substring(0, Constants.BOOKING_KEYWORD_MAX_LENGTH);
        }

        try {
            // Customer ID luôn lấy từ session, không nhận từ request
            int customerId = SessionUtils.currentUser(request).getUserId();
            int totalBookings = bookingDao.countBookingsByCustomerId(customerId, status, keyword);
            int totalPages = Math.max(1, (int) Math.ceil((double) totalBookings / Constants.BOOKING_PAGE_SIZE));
            int page = Math.min(Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1)), totalPages);
            Map<String, Integer> statusCounts = bookingDao.countBookingsByStatus(customerId);

            request.setAttribute("statusCounts", statusCounts);
            request.setAttribute("allCount", statusCounts.values().stream().mapToInt(Integer::intValue).sum());
            request.setAttribute("bookings", bookingDao.getBookingsByCustomerId(
                    customerId, status, keyword, page, Constants.BOOKING_PAGE_SIZE));
            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("status", status == null ? "" : status);
            request.setAttribute("keyword", keyword == null ? "" : keyword);
            request.getRequestDispatcher(BOOKING_HISTORY_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
