package controller.Event;

import dao.SeatMapDAO;
import controller.Event.SeatMapSupport.LayoutRequest;
import controller.Event.SeatMapSupport.TicketDraft;
import dao.SeatMapDAO.TicketChange;
import model.Auth;
import model.Event;
import model.EventTicket;
import model.EventZone;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Seat Map Designer (Organizer): thiết kế sơ đồ ghế riêng cho từng sự kiện
 * (sân khấu, khu ngồi theo hàng x ghế, khu đứng; mỗi khu gắn một hạng vé).
 * GET  /organizer/event/seatmap?eventId=  : mở trình thiết kế (chỉ xem nếu sự kiện đã khóa).
 * POST /organizer/event/seatmap           : action=save (layoutJson) | action=clear.
 * Chỉ sửa được khi sự kiện là nháp/bị từ chối và chưa có dữ liệu bán hàng.
 */
@WebServlet(name = "SeatMapController", urlPatterns = {"/organizer/event/seatmap"})
public class SeatMapController extends EventController {

    private static final String SEATMAP_VIEW = "/WEB-INF/views/organizer/seat-map.jsp";
    private static final String PATH_SEATMAP = "/organizer/event/seatmap";
    private static final String GENERIC_ERROR = "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.";

    private final SeatMapDAO seatMapDAO = new SeatMapDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    // ------------------------------------------------------------------ GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        Event event = loadOwnedEvent(request, organizer);
        if (event == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
            return;
        }
        moveFlashMessage(request, "successMessage", "errorMessage");

        List<EventZone> zones;
        try {
            zones = seatMapDAO.getZones(event.getEventId());
        } catch (SQLException e) {
            e.printStackTrace();
            redirectToList(request, response, "errorMessage",
                    "Không đọc được sơ đồ ghế. Hãy chắc chắn database đã có phần Seat Map (bảng Event_Zones) trong db.sql.");
            return;
        }
        showDesigner(request, response, event, zones, null, new ArrayList<>());
    }

    // ------------------------------------------------------------------ POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        Event event = loadOwnedEvent(request, organizer);
        if (event == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
            return;
        }
        if (!isValidCsrfToken(request, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String lockedReason = lockedReason(event);
        if (lockedReason != null) {
            redirectBack(request, response, event, "errorMessage", lockedReason);
            return;
        }

        String action = request.getParameter("action");
        if ("clear".equals(action)) {
            if (seatMapDAO.clearLayout(event.getEventId())) {
                redirectBack(request, response, event, "successMessage", "Đã xóa sơ đồ ghế của sự kiện.");
            } else {
                redirectBack(request, response, event, "errorMessage", GENERIC_ERROR);
            }
            return;
        }

        // action = save
        LayoutRequest layout = SeatMapSupport.parse(request.getParameter("layoutJson"));
        List<String> errors = new ArrayList<>();
        if (layout == null) {
            errors.add("Dữ liệu sơ đồ không hợp lệ. Vui lòng tải lại trang và thử lại.");
            showDesigner(request, response, event, new ArrayList<>(), null, errors);
            return;
        }

        List<EventTicket> existingTickets = seatMapDAO.getTickets(event.getEventId());
        List<TicketChange> changes = new ArrayList<>();
        SeatMapSupport.validate(layout, existingTickets, eventDAO.getVenueCapacity(event.getVenueId()),
                this::validateTicket, errors, changes);

        if (errors.isEmpty()) {
            if (seatMapDAO.saveLayout(event.getEventId(), layout.zones, changes)) {
                int seats = 0;
                for (EventZone z : layout.zones) {
                    seats += z.getCapacity();
                }
                redirectBack(request, response, event, "successMessage",
                        "Đã lưu sơ đồ ghế: " + layout.zones.size() + " khu, tổng " + seats
                        + " chỗ. Số lượng vé của các hạng vé đã được đồng bộ theo sơ đồ.");
                return;
            }
            errors.add("Không thể lưu sơ đồ ghế. Vui lòng thử lại sau.");
        }
        // Có lỗi: giữ nguyên bản vẽ người dùng đang làm để họ sửa tiếp
        showDesigner(request, response, event, layout.zones, layout.tickets, errors);
    }

    // ------------------------------------------------------------------ Quyền chỉnh sửa
    /** @return lý do không cho sửa sơ đồ, hoặc null nếu được phép sửa. */
    private String lockedReason(Event event) {
        if (!isModifiable(event)) {
            return "Sự kiện đang ở trạng thái " + event.getStatus()
                    + " nên không thể sửa sơ đồ ghế. Chỉ sự kiện nháp hoặc bị từ chối mới được sửa.";
        }
        if (eventDAO.hasSalesData(event.getEventId())) {
            return "Sự kiện đã phát sinh đơn hàng/vé nên không thể thay đổi sơ đồ ghế.";
        }
        return null;
    }

    // ------------------------------------------------------------------ Hiển thị
    /**
     * @param ticketDrafts hạng vé đang vẽ (khi hiển thị lại sau lỗi); null thì đọc từ database
     */
    private void showDesigner(HttpServletRequest request, HttpServletResponse response, Event event,
            List<EventZone> zones, List<TicketDraft> ticketDrafts, List<String> errors)
            throws ServletException, IOException {
        String lockedReason = lockedReason(event);
        List<Map<String, Object>> ticketData = ticketDrafts == null
                ? SeatMapSupport.ticketData(seatMapDAO.getTickets(event.getEventId()))
                : SeatMapSupport.draftData(ticketDrafts);

        request.setAttribute("event", event);
        request.setAttribute("dataJson", SeatMapSupport.buildDataJson(event.getEventId(), lockedReason != null,
                eventDAO.getVenueCapacity(event.getVenueId()), null, ticketData, zones));
        request.setAttribute("readOnly", lockedReason != null);
        request.setAttribute("lockedReason", lockedReason);
        request.setAttribute("errorList", errors);
        request.setAttribute("csrfToken", getOrCreateCsrfToken(request));
        request.getRequestDispatcher(SEATMAP_VIEW).forward(request, response);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, Event event,
            String attribute, String message) throws IOException {
        request.getSession().setAttribute(attribute, message);
        response.sendRedirect(request.getContextPath() + PATH_SEATMAP + "?eventId=" + event.getEventId());
    }

    // ------------------------------------------------------------------ CSRF
    private String getOrCreateCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object token = session.getAttribute(Constants.SESSION_SEATMAP_CSRF);
        if (token instanceof String) {
            return (String) token;
        }
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        String newToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(Constants.SESSION_SEATMAP_CSRF, newToken);
        return newToken;
    }

    private boolean isValidCsrfToken(HttpServletRequest request, String actual) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(Constants.SESSION_SEATMAP_CSRF);
        if (!(expected instanceof String) || actual == null) {
            return false;
        }
        return MessageDigest.isEqual(((String) expected).getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8));
    }
}
