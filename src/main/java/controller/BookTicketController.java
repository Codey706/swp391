package controller;

import dao.BookingDAO;
import dao.TicketBookingDAO;
import dao.TicketBookingDAO.BookingException;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Booking;
import model.Event;
import model.EventSeat;
import model.EventTicket;
import model.User;
import utils.Constants;
import utils.SessionUtils;
import utils.ValidationUtils;
import utils.VnPayConfig;

/** Đặt vé 3 bước: chọn vé -> thông tin khách hàng -> thanh toán VNPay. */
@WebServlet(name = "BookTicketController", urlPatterns = {
    "/booking/select-ticket", "/booking/customer-info", "/booking/payment"
})
public class BookTicketController extends HttpServlet {

    private static final String PATH_SELECT_TICKET = "/booking/select-ticket";
    private static final String PATH_CUSTOMER_INFO = "/booking/customer-info";
    private static final String PATH_PAYMENT = "/booking/payment";

    private static final String SELECT_VIEW = "/WEB-INF/views/customer/select-ticket.jsp";
    private static final String CUSTOMER_VIEW = "/WEB-INF/views/customer/customer-info.jsp";
    private static final String PAYMENT_VIEW = "/WEB-INF/views/customer/payment.jsp";

    /** SQL Server: giao dịch bị chọn làm nạn nhân deadlock (đã rollback, có thể thử lại). */
    private static final int SQL_ERROR_DEADLOCK = 1205;

    private final TicketBookingDAO ticketDao = new TicketBookingDAO();
    private final BookingDAO bookingDao = new BookingDAO();
    private final PaymentController paymentController = new PaymentController();
    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            ticketDao.releaseExpiredHolds();
            String path = request.getServletPath();
            if (PATH_SELECT_TICKET.equals(path)) {
                showSelectTicket(request, response);
                return;
            }
            User customer = currentCustomer(request);
            Booking booking = loadBooking(request, customer);
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
                return;
            }
            if (!Constants.ORDER_PENDING.equalsIgnoreCase(booking.getStatus())) {
                request.setAttribute("errorMessage", "Đơn này không còn ở trạng thái chờ thanh toán.");
            }
            forwardWithBooking(request, response, PATH_CUSTOMER_INFO.equals(path) ? CUSTOMER_VIEW : PAYMENT_VIEW,
                    booking, customer);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User customer = currentCustomer(request);
            switch (request.getServletPath()) {
                case PATH_SELECT_TICKET -> createBooking(request, response, customer);
                case PATH_CUSTOMER_INFO -> saveCustomerInfo(request, response, customer);
                default -> preparePayment(request, response, customer);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ------------------------------------------------------------------ Bước 1: chọn vé

    private void showSelectTicket(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), -1);
        Event event = eventId > 0 ? ticketDao.getBookableEvent(eventId) : null;
        if (event == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sự kiện không tồn tại hoặc đã ngừng mở bán.");
            return;
        }
        List<EventSeat> seats = ticketDao.getSeats(eventId);
        request.setAttribute("event", event);
        request.setAttribute("maxTickets", Constants.BOOKING_MAX_TICKETS_PER_ORDER);
        request.setAttribute("tickets", ticketDao.getActiveTickets(eventId));
        request.setAttribute("seats", seats);
        request.setAttribute("hasSeats", !seats.isEmpty());
        request.getRequestDispatcher(SELECT_VIEW).forward(request, response);
    }

    /** Hiển thị lại trang chọn vé kèm lỗi, giữ nguyên lựa chọn của người dùng. */
    private void showSelectTicketError(HttpServletRequest request, HttpServletResponse response, String message,
            Map<Integer, Integer> quantities, List<Integer> seatIds) throws ServletException, IOException, SQLException {
        request.setAttribute("errorMessage", message);
        request.setAttribute("selectedQty", quantities);
        request.setAttribute("selectedSeatIds", seatIds);
        request.setAttribute("voucherValue", request.getParameter("voucherCode"));
        showSelectTicket(request, response);
    }

    private void createBooking(HttpServletRequest request, HttpServletResponse response, User customer)
            throws ServletException, IOException, SQLException {
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), -1);
        int max = Constants.BOOKING_MAX_TICKETS_PER_ORDER;
        Map<Integer, Integer> quantities = new LinkedHashMap<>();
        List<Integer> seatIds = parseSeatIds(request);
        int total = 0;
        boolean invalidQty = false;
        for (EventTicket ticket : ticketDao.getActiveTickets(eventId)) {
            String raw = request.getParameter("quantity_" + ticket.getEventTicketId());
            int qty = ValidationUtils.isNullOrBlank(raw) ? 0 : ValidationUtils.parseIntOrDefault(raw, -1);
            if (qty < 0 || qty > max) {
                invalidQty = true;
            } else if (qty > 0) {
                quantities.put(ticket.getEventTicketId(), qty);
                total += qty;
            }
        }

        String error = null;
        if (invalidQty) {
            error = "Số lượng vé không hợp lệ (0 - " + max + " mỗi loại).";
        } else if (total < 1 || total > max) {
            error = "Vui lòng chọn từ 1 đến " + max + " vé.";
        } else if (seatIds == null) {
            error = "Ghế đã chọn không hợp lệ.";
        }
        if (error != null) {
            showSelectTicketError(request, response, error, quantities, seatIds == null ? new ArrayList<>() : seatIds);
            return;
        }

        try {
            int orderId = ticketDao.createBooking(customer.getUserId(), eventId, quantities,
                    seatIds, request.getParameter("voucherCode"));
            response.sendRedirect(request.getContextPath() + PATH_CUSTOMER_INFO + "?orderId=" + orderId);
        } catch (BookingException e) {
            showSelectTicketError(request, response, e.getMessage(), quantities, seatIds);
        } catch (SQLException e) {
            if (e.getErrorCode() != SQL_ERROR_DEADLOCK) {
                throw e;
            }
            log("Booking deadlock, eventId=" + eventId, e);
            showSelectTicketError(request, response, "Hệ thống đang bận, vui lòng thử lại.", quantities, seatIds);
        }
    }

    /** @return danh sách ghế đã chọn, hoặc null nếu có giá trị không phải số. */
    private static List<Integer> parseSeatIds(HttpServletRequest request) {
        List<Integer> ids = new ArrayList<>();
        String[] values = request.getParameterValues("seatIds");
        if (values != null) {
            for (String value : values) {
                int id = ValidationUtils.parseIntOrDefault(value, -1);
                if (id < 0) {
                    return null;
                }
                ids.add(id);
            }
        }
        return ids;
    }

    // ------------------------------------------------------------------ Bước 2: thông tin khách hàng

    /**
     * Khách xác nhận thông tin. Số điện thoại bắt buộc (tài khoản Google chưa có),
     * nếu nhập mới hoặc thay đổi thì lưu luôn vào hồ sơ rồi chuyển sang bước thanh toán.
     */
    private void saveCustomerInfo(HttpServletRequest request, HttpServletResponse response, User customer)
            throws ServletException, IOException, SQLException {
        Booking booking = loadBooking(request, customer);
        if (booking == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
            return;
        }
        String phone = request.getParameter("phone") == null ? "" : request.getParameter("phone").trim();

        String error = null;
        if (phone.isEmpty()) {
            error = "Vui lòng nhập số điện thoại để nhận thông tin vé.";
        } else if (!ValidationUtils.isPhone(phone)) {
            error = "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).";
        } else if (!phone.equals(customer.getPhone())) {
            if (userDao.existsPhoneOfOtherUser(phone, customer.getUserId())) {
                error = "Số điện thoại này đã được sử dụng bởi tài khoản khác.";
            } else if (userDao.updateCustomerPhone(customer.getUserId(), phone)) {
                SessionUtils.currentUser(request).setPhone(phone);
            } else {
                error = "Không lưu được số điện thoại. Vui lòng thử lại.";
            }
        }
        if (error != null) {
            customer.setPhone(phone);
            request.setAttribute("errorMessage", error);
            forwardWithBooking(request, response, CUSTOMER_VIEW, booking, customer);
            return;
        }
        response.sendRedirect(request.getContextPath() + PATH_PAYMENT + "?orderId=" + booking.getBookingId());
    }

    // ------------------------------------------------------------------ Bước 3: thanh toán

    private void preparePayment(HttpServletRequest request, HttpServletResponse response, User customer)
            throws ServletException, IOException, SQLException {
        Booking booking = loadBooking(request, customer);
        if (booking == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
            return;
        }
        if (!Constants.ORDER_PENDING.equalsIgnoreCase(booking.getStatus())
                || booking.getHoldExpiredAt() == null
                || !booking.getHoldExpiredAt().isAfter(LocalDateTime.now())) {
            request.setAttribute("errorMessage", "Thời gian giữ vé đã hết. Vui lòng chọn vé lại.");
            forwardWithBooking(request, response, PAYMENT_VIEW, booking, customer);
            return;
        }
        // Chưa có số điện thoại (vd. tài khoản Google) thì quay lại bước "Thông tin" để nhập
        if (ValidationUtils.isNullOrBlank(customer.getPhone())) {
            response.sendRedirect(request.getContextPath() + PATH_CUSTOMER_INFO + "?orderId=" + booking.getBookingId());
            return;
        }
        try {
            response.sendRedirect(paymentController.createVNPayUrl(
                    booking.getBookingId(), booking.getFinalAmount(), booking.getHoldExpiredAt(), request));
        } catch (IllegalArgumentException | IllegalStateException e) {
            log("Cannot create VNPay URL for order " + booking.getBookingId(), e);
            request.setAttribute("errorMessage", VnPayConfig.isConfigured()
                    ? "Không thể khởi tạo thanh toán VNPay. Vui lòng thử lại."
                    : "Chưa cấu hình VNPay: điền vnpay.tmnCode và vnpay.hashSecret trong "
                    + "src/main/resources/vnpay.properties (hoặc biến môi trường "
                    + "VNPAY_TMN_CODE / VNPAY_HASH_SECRET) rồi chạy lại.");
            forwardWithBooking(request, response, PAYMENT_VIEW, booking, customer);
        }
    }

    // ------------------------------------------------------------------ Tiện ích

    /** Khách hàng đang đăng nhập, đọc từ database để có số điện thoại mới nhất. */
    private User currentCustomer(HttpServletRequest request) throws SQLException {
        return userDao.getUserById(SessionUtils.currentUser(request).getUserId());
    }

    /** Đơn của chính khách hàng theo tham số orderId; null nếu không có. */
    private Booking loadBooking(HttpServletRequest request, User customer) throws SQLException {
        int orderId = ValidationUtils.parseIntOrDefault(request.getParameter("orderId"), -1);
        return orderId > 0 ? bookingDao.getBookingDetail(orderId, customer.getUserId()) : null;
    }

    private void forwardWithBooking(HttpServletRequest request, HttpServletResponse response, String view,
            Booking booking, User customer) throws ServletException, IOException {
        request.setAttribute("booking", booking);
        request.setAttribute("customer", customer);
        request.getRequestDispatcher(view).forward(request, response);
    }
}
