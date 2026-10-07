package controller;

import dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import model.Booking;
import model.User;
import model.Auth;
import utils.Constants;
import utils.ValidationUtils;

@WebServlet(name = "BookingHistoryController", urlPatterns = {"/customer/booking-history"})
public class BookingHistoryController extends HttpServlet {

    private static final String BOOKING_HISTORY_VIEW = "/WEB-INF/views/customer/booking-history.jsp";
    private static final Set<String> VALID_STATUSES = Set.of(
            Constants.ORDER_PENDING, Constants.ORDER_PAID, Constants.ORDER_CANCELLED);

    private final BookingDAO bookingDao = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User customer = getAuthenticatedCustomer(request, response);
        if (customer == null) {
            return;
        }

        String status = normalizeStatus(request.getParameter("status"));
        String keyword = normalizeKeyword(request.getParameter("keyword"));
        int page = Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1));

        try {
            // Luôn lấy customerId từ session, không nhận từ request để tránh xem đơn của người khác
            int totalBookings = bookingDao.countBookingsByCustomerId(customer.getUserId(), status, keyword);
            int totalPages = Math.max(1, (int) Math.ceil((double) totalBookings / Constants.BOOKING_PAGE_SIZE));
            page = Math.min(page, totalPages);

            List<Booking> bookings = bookingDao.getBookingsByCustomerId(
                    customer.getUserId(), status, keyword, page, Constants.BOOKING_PAGE_SIZE);

            Map<String, Integer> statusCounts = bookingDao.countBookingsByStatus(customer.getUserId());
            request.setAttribute("statusCounts", statusCounts);
            request.setAttribute("allCount", statusCounts.values().stream().mapToInt(Integer::intValue).sum());
            request.setAttribute("bookings", bookings);
            request.setAttribute("totalBookings", totalBookings);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("status", status == null ? "" : status);
            request.setAttribute("keyword", keyword == null ? "" : keyword);
        } catch (SQLException e) {
            // Không hiển thị thông tin DB cho người dùng
            getServletContext().log("Cannot load booking history", e);
            request.setAttribute("errorMessage", "Không thể tải lịch sử đặt vé. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher(BOOKING_HISTORY_VIEW).forward(request, response);
    }

    /** Whitelist trạng thái; giá trị lạ hoặc rỗng = không lọc. */
    private String normalizeStatus(String status) {
        if (status == null) {
            return null;
        }
        String trimmed = status.trim();
        return VALID_STATUSES.contains(trimmed) ? trimmed : null;
    }

    private String normalizeKeyword(String keyword) {
        if (ValidationUtils.isNullOrBlank(keyword)) {
            return null;
        }
        String trimmed = keyword.trim();
        return trimmed.length() > Constants.BOOKING_KEYWORD_MAX_LENGTH
                ? trimmed.substring(0, Constants.BOOKING_KEYWORD_MAX_LENGTH)
                : trimmed;
    }

        /**
     * Yêu cầu đã đăng nhập và có role Customer.
     *
     * @return User hợp lệ, hoặc null nếu đã redirect/gửi lỗi.
     */
    private User getAuthenticatedCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        // Đăng nhập thật (AuthController) lưu model.Auth vào session; chấp nhận cả model.User để tương thích code cũ
        User user = toUser(session == null ? null : session.getAttribute(Constants.SESSION_USER));       
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return null;
        }
        if (!Constants.ROLE_CUSTOMER.equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    /** Chuyển đối tượng trong session (Auth hoặc User) về User; kiểu khác/null trả về null. */
    private User toUser(Object sessionUser) {
        if (sessionUser instanceof User) {
            return (User) sessionUser;
        }
        if (sessionUser instanceof Auth) {
            Auth auth = (Auth) sessionUser;
            User user = new User();
            user.setUserId(auth.getUserId());
            user.setUsername(auth.getUsername());
            user.setFullName(auth.getFullName());
            user.setEmail(auth.getEmail());
            user.setPhone(auth.getPhone());
            user.setAddress(auth.getAddress());
            user.setRole(auth.getRole());
            user.setStatus(auth.getStatus());
            return user;
        }
        return null;
    }
}
