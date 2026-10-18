package controller;

import dao.BookingDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Auth;
import model.Booking;
import model.User;
import utils.Constants;
import utils.ValidationUtils;

/**
 * UC-07.1 View Order Detail: GET /customer/booking-detail?orderId=...
 * Chỉ Customer đã đăng nhập, và chỉ xem được đơn của chính mình.
 */
@WebServlet(name = "BookingDetailController", urlPatterns = {"/customer/booking-detail"})
public class BookingDetailController extends HttpServlet {

    private static final String BOOKING_DETAIL_VIEW = "/WEB-INF/views/customer/booking-detail.jsp";

    private final BookingDAO bookingDao = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User customer = getAuthenticatedCustomer(request, response);
        if (customer == null) {
            return;
        }

        int orderId = ValidationUtils.parseIntOrDefault(request.getParameter("orderId"), -1);
        if (orderId <= 0) {
            response.sendRedirect(request.getContextPath() + "/customer/booking-history");
            return;
        }

        try {
            // customerId luôn lấy từ session: đơn của người khác sẽ không tìm thấy
            Booking booking = bookingDao.getBookingDetail(orderId, customer.getUserId());
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
                return;
            }
            request.setAttribute("booking", booking);
        } catch (SQLException e) {
            // Không hiển thị thông tin DB cho người dùng
            getServletContext().log("Cannot load booking detail", e);
            request.setAttribute("errorMessage", "Không thể tải chi tiết đơn hàng. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher(BOOKING_DETAIL_VIEW).forward(request, response);
    }

    /**
     * Yêu cầu đã đăng nhập và có role Customer.
     *
     * @return User hợp lệ, hoặc null nếu đã redirect/gửi lỗi.
     */
    private User getAuthenticatedCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
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

    /** Đăng nhập thật lưu model.Auth vào session; chấp nhận cả model.User. */
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
