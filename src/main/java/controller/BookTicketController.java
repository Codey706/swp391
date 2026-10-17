package controller;

import dao.BookingDAO;
import dao.TicketBookingDAO;
import dao.TicketBookingDAO.BookingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Auth;
import model.Booking;
import model.Event;
import model.EventSeat;
import model.EventTicket;
import model.User;
import utils.Constants;
import utils.ValidationUtils;

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

    private final TicketBookingDAO ticketDao = new TicketBookingDAO();
    private final BookingDAO bookingDao = new BookingDAO();
    private final PaymentController paymentController = new PaymentController();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User customer = authenticatedCustomer(request, response);
        if (customer == null) return;

        String path = request.getServletPath();
        try {
            ticketDao.releaseExpiredHolds();
            if (PATH_SELECT_TICKET.equals(path)) {
                showSelectTicket(request, response);
            } else {
                int orderId = ValidationUtils.parseIntOrDefault(request.getParameter("orderId"), -1);
                Booking booking = orderId > 0 ? bookingDao.getBookingDetail(orderId, customer.getUserId()) : null;
                if (booking == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
                    return;
                }
                if (!Constants.ORDER_PENDING.equalsIgnoreCase(booking.getStatus())) {
                    request.setAttribute("errorMessage", "Đơn này không còn ở trạng thái chờ thanh toán.");
                }
                request.setAttribute("booking", booking);
                request.setAttribute("customer", customer);
                if (PATH_CUSTOMER_INFO.equals(path)) {
                    request.getRequestDispatcher(CUSTOMER_VIEW).forward(request, response);
                } else {
                    request.getRequestDispatcher(PAYMENT_VIEW).forward(request, response);
                }
            }
        } catch (SQLException e) {
            getServletContext().log("Cannot load ticket booking page", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tải thông tin đặt vé.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User customer = authenticatedCustomer(request, response);
        if (customer == null) return;

        String path = request.getServletPath();
        if (PATH_SELECT_TICKET.equals(path)) {
            createBooking(request, response, customer);
        } else if (PATH_PAYMENT.equals(path)) {
            preparePayment(request, response, customer);
        } else {
            // Bước 2 (thông tin lấy từ tài khoản) -> chuyển sang bước thanh toán
            response.sendRedirect(request.getContextPath() + PATH_PAYMENT + "?orderId="
                    + ValidationUtils.parseIntOrDefault(request.getParameter("orderId"), -1));
        }
    }

    /** Lưu lại lựa chọn của người dùng để hiển thị lại form khi có lỗi. */
    private void keepSelection(HttpServletRequest request, Map<Integer, Integer> quantities, List<Integer> seatIds) {
        request.setAttribute("selectedQty", quantities);
        request.setAttribute("selectedSeatIds", seatIds);
        request.setAttribute("voucherValue", request.getParameter("voucherCode"));
    }

    private void showSelectTicket(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), -1);
        Event event = eventId > 0 ? ticketDao.getBookableEvent(eventId) : null;
        if (event == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sự kiện không tồn tại hoặc đã ngừng mở bán.");
            return;
        }
        request.setAttribute("event", event);
        request.setAttribute("maxTickets", Constants.BOOKING_MAX_TICKETS_PER_ORDER);
        request.setAttribute("tickets", ticketDao.getActiveTickets(eventId));
        List<EventSeat> seats = ticketDao.getSeats(eventId);
        request.setAttribute("seats", seats);
        request.setAttribute("hasSeats", !seats.isEmpty());
        request.getRequestDispatcher(SELECT_VIEW).forward(request, response);
    }

    private void createBooking(HttpServletRequest request, HttpServletResponse response, User customer)
            throws ServletException, IOException {
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), -1);
        Map<Integer, Integer> quantities = new LinkedHashMap<>();
        int total = 0;
        try {
            List<EventTicket> tickets = ticketDao.getActiveTickets(eventId);
            boolean invalidQty = false;
            for (EventTicket ticket : tickets) {
                String raw = request.getParameter("quantity_" + ticket.getEventTicketId());
                int qty = 0;
                if (raw != null && !raw.isBlank()) {
                    try { qty = Integer.parseInt(raw.trim()); }
                    catch (NumberFormatException e) { qty = -1; }
                }
                if (qty < 0 || qty > Constants.BOOKING_MAX_TICKETS_PER_ORDER) {
                    invalidQty = true;
                } else if (qty > 0) {
                    quantities.put(ticket.getEventTicketId(), qty);
                    total += qty;
                }
            }
            if (invalidQty) {
                request.setAttribute("errorMessage", "Số lượng vé không hợp lệ (0 - "
                        + Constants.BOOKING_MAX_TICKETS_PER_ORDER + " mỗi loại).");
                keepSelection(request, quantities, seatIdsForRetry(request));
                showSelectTicket(request, response);
                return;
            }
            if (total < 1 || total > Constants.BOOKING_MAX_TICKETS_PER_ORDER) {
                request.setAttribute("errorMessage", "Vui lòng chọn từ 1 đến "
                        + Constants.BOOKING_MAX_TICKETS_PER_ORDER + " vé.");
                keepSelection(request, quantities, new ArrayList<>());
                showSelectTicket(request, response);
                return;
            }
            List<Integer> seatIds = new ArrayList<>();
            String[] selectedSeats = request.getParameterValues("seatIds");
            if (selectedSeats != null) {
                for (String selected : selectedSeats) {
                    try { seatIds.add(Integer.parseInt(selected.trim())); }
                    catch (NumberFormatException e) {
                        request.setAttribute("errorMessage", "Ghế đã chọn không hợp lệ.");
                        keepSelection(request, quantities, seatIdsForRetry(request));
                        showSelectTicket(request, response);
                        return;
                    }
                }
            }
            if (!seatIds.isEmpty() && seatIds.size() != total) {
                request.setAttribute("errorMessage", "Số ghế chọn phải bằng tổng số vé.");
                keepSelection(request, quantities, seatIds);
                showSelectTicket(request, response);
                return;
            }
            int orderId = ticketDao.createBooking(customer.getUserId(), eventId, quantities,
                    seatIds, request.getParameter("voucherCode"));
            response.sendRedirect(request.getContextPath() + PATH_CUSTOMER_INFO + "?orderId=" + orderId);
        } catch (BookingException e) {
            request.setAttribute("errorMessage", e.getMessage());
            keepSelection(request, quantities, seatIdsForRetry(request));
            try { showSelectTicket(request, response); }
            catch (SQLException ex) { throw new ServletException(ex); }
        } catch (SQLException e) {
            getServletContext().log("Cannot create ticket booking", e);
            if (e.getErrorCode() == 1205) { // deadlock victim: giao dịch đã rollback, cho thử lại
                request.setAttribute("errorMessage", "Hệ thống đang bận, vui lòng thử lại.");
                keepSelection(request, quantities, seatIdsForRetry(request));
                try { showSelectTicket(request, response); }
                catch (SQLException ex) { response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); }
                return;
            }
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tạo đơn đặt vé.");
        }
    }

    private List<Integer> seatIdsForRetry(HttpServletRequest request) {
        List<Integer> ids = new ArrayList<>();
        String[] values = request.getParameterValues("seatIds");
        if (values != null) {
            for (String v : values) {
                try { ids.add(Integer.parseInt(v)); } catch (NumberFormatException ignored) { /* bỏ qua */ }
            }
        }
        return ids;
    }

    private void preparePayment(HttpServletRequest request, HttpServletResponse response, User customer)
            throws ServletException, IOException {
        int orderId = ValidationUtils.parseIntOrDefault(request.getParameter("orderId"), -1);
        try {
            Booking booking = orderId > 0 ? bookingDao.getBookingDetail(orderId, customer.getUserId()) : null;
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt vé.");
                return;
            }
            if (!Constants.ORDER_PENDING.equalsIgnoreCase(booking.getStatus())
                    || booking.getHoldExpiredAt() == null
                    || !booking.getHoldExpiredAt().isAfter(java.time.LocalDateTime.now())) {
                request.setAttribute("errorMessage", "Thời gian giữ vé đã hết. Vui lòng chọn vé lại.");
                request.setAttribute("booking", booking);
                request.setAttribute("customer", customer);
                request.getRequestDispatcher(PAYMENT_VIEW).forward(request, response);
                return;
            }
            boolean created;
            if (booking.getPayment() != null
                    && "Pending".equalsIgnoreCase(booking.getPayment().getPaymentStatus())) {
                created = true; // Tránh tạo thêm giao dịch Pending khi người dùng bấm nhiều lần.
            } else {
                created = paymentController.createPayment(orderId, booking.getFinalAmount());
            }
            request.setAttribute("booking", booking);
            request.setAttribute("customer", customer);
            request.setAttribute("paymentMessage", created
                    ? "Yêu cầu thanh toán đang ở trạng thái chờ xử lý. Đơn chưa được xác nhận thanh toán."
                    : "Không thể khởi tạo thanh toán. Vui lòng kiểm tra đơn hàng và thử lại.");
            request.getRequestDispatcher(PAYMENT_VIEW).forward(request, response);
        } catch (SQLException e) {
            getServletContext().log("Cannot prepare ticket payment", e);
            throw new ServletException("Không thể chuẩn bị thanh toán.", e);
        }
    }

    private User authenticatedCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        User user = null;
        if (value instanceof User) user = (User) value;
        else if (value instanceof Auth) {
            Auth auth = (Auth) value;
            user = new User(); user.setUserId(auth.getUserId()); user.setUsername(auth.getUsername());
            user.setFullName(auth.getFullName()); user.setEmail(auth.getEmail()); user.setPhone(auth.getPhone());
            user.setAddress(auth.getAddress()); user.setRole(auth.getRole()); user.setStatus(auth.getStatus());
        }
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
}
