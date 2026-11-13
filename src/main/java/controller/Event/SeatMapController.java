package controller.Event;

import dao.SeatMapDAO;
import controller.Event.SeatMapSupport.LayoutRequest;
import controller.Event.SeatMapSupport.TicketDraft;
import dao.SeatMapDAO.TicketChange;
import model.Auth;
import model.Event;
import model.EventTicket;
import model.EventZone;
import utils.SessionUtils;
import utils.CsrfUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
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

    private final SeatMapDAO seatMapDAO = new SeatMapDAO();

    // ------------------------------------------------------------------ GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth organizer = currentOrganizer(request);
            Event event = loadOwnedEvent(request, organizer);
            if (event == null) {
                redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
                return;
            }
            SessionUtils.moveFlash(request, "successMessage", "errorMessage");
            showDesigner(request, response, event, seatMapDAO.getZones(event.getEventId()), null, new ArrayList<>());
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ------------------------------------------------------------------ POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth organizer = currentOrganizer(request);
            Event event = loadOwnedEvent(request, organizer);
            if (event == null) {
                redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
                return;
            }
            if (!CsrfUtils.isValid(request)) {
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
                seatMapDAO.clearLayout(event.getEventId());
                redirectBack(request, response, event, "successMessage", "Đã xóa sơ đồ ghế của sự kiện.");
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

            if (!errors.isEmpty()) {
                // Giữ nguyên bản vẽ người dùng đang làm để họ sửa tiếp
                showDesigner(request, response, event, layout.zones, layout.tickets, errors);
                return;
            }
            seatMapDAO.saveLayout(event.getEventId(), layout.zones, changes);
            int seats = 0;
            for (EventZone z : layout.zones) {
                seats += z.getCapacity();
            }
            redirectBack(request, response, event, "successMessage",
                    "Đã lưu sơ đồ ghế: " + layout.zones.size() + " khu, tổng " + seats
                    + " chỗ. Số lượng vé của các hạng vé đã được đồng bộ theo sơ đồ.");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // ------------------------------------------------------------------ Quyền chỉnh sửa
    /** @return lý do không cho sửa sơ đồ, hoặc null nếu được phép sửa. */
    private String lockedReason(Event event) throws SQLException {
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
            throws ServletException, IOException, SQLException {
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
        CsrfUtils.expose(request);
        request.getRequestDispatcher(SEATMAP_VIEW).forward(request, response);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, Event event,
            String attribute, String message) throws IOException {
        request.getSession().setAttribute(attribute, message);
        response.sendRedirect(request.getContextPath() + PATH_SEATMAP + "?eventId=" + event.getEventId());
    }
}
