package controller.Staff;

import dao.SeatMapDAO;
import dao.StaffEventDAO;
import dao.StaffSeatStatusDAO;
import model.Auth;
import model.EventZone;
import model.StaffAssignment;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /staff/seats[?eventId=...] : trạng thái chỗ ngồi (chỉ xem) của sự kiện được phân công
 * đang diễn ra hôm nay. Chỉ có doGet nên mọi POST/PUT/DELETE đều bị Tomcat trả 405.
 *
 * Quyền xem được kiểm tra lại ở server cho mọi request: eventId chỉ hợp lệ khi nằm trong
 * danh sách sự kiện ACTIVE, Staff này được phân công và đang diễn ra tại thời điểm hiện tại
 * (múi giờ nghiệp vụ). Sửa eventId trên URL sang sự kiện khác đều nhận 403.
 */
@WebServlet(name = "StaffSeatStatusController", urlPatterns = {"/staff/seats"})
public class StaffSeatStatusController extends StaffController {

    private static final Logger LOGGER = Logger.getLogger(StaffSeatStatusController.class.getName());
    private static final String VIEW = "/WEB-INF/views/staff/seat-status.jsp";
    private static final DateTimeFormatter TIME = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final StaffEventDAO staffEventDAO = new StaffEventDAO();
    private final SeatMapDAO seatMapDAO = new SeatMapDAO();
    private final StaffSeatStatusDAO seatStatusDAO = new StaffSeatStatusDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth staff = getAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }
        // Dữ liệu thay đổi theo từng lượt check-in/đặt vé nên không cho cache
        response.setHeader("Cache-Control", "no-store");

        Integer requestedId = null;
        String raw = request.getParameter("eventId");
        if (raw != null && !raw.trim().isEmpty()) {
            try {
                requestedId = Integer.valueOf(raw.trim());
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }

        int staffId = staff.getUserId();
        LocalDateTime now = LocalDateTime.now(ZoneId.of(Constants.BUSINESS_ZONE_ID));

        try {
            // Tab ONGOING = sự kiện ACTIVE, đang trong [start_time, end_time) => diễn ra trong hôm nay
            List<StaffAssignment> events = staffEventDAO.findAssigned(staffId, StaffEventDAO.TAB_ONGOING,
                    "", StaffEventDAO.RANGE_ALL, now, 1, Constants.STAFF_SEAT_MAX_EVENTS);
            request.setAttribute("events", events);

            if (events.isEmpty()) {
                if (requestedId != null) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            StaffAssignment selected = null;
            if (requestedId == null) {
                selected = events.get(0);
            } else {
                for (StaffAssignment e : events) {
                    if (e.getEventId() == requestedId) {
                        selected = e;
                        break;
                    }
                }
                if (selected == null) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            }

            List<EventZone> zones = seatMapDAO.getZones(selected.getEventId());
            SeatStatusSupport.View view = SeatStatusSupport.build(zones,
                    seatStatusDAO.findSeats(selected.getEventId()),
                    seatStatusDAO.findStandingTickets(selected.getEventId()));

            request.setAttribute("event", selected);
            request.setAttribute("timeText", timeText(selected));
            request.setAttribute("assignedText", selected.getAssignedAt() == null
                    ? "" : selected.getAssignedAt().format(DATE));
            request.setAttribute("seatedZones", view.seated);
            request.setAttribute("standingZones", view.standing);
            request.setAttribute("hasSeated", !view.seated.isEmpty());
            request.setAttribute("hasStanding", !view.standing.isEmpty());
            request.setAttribute("noLayout", view.noLayout);
            request.setAttribute("unassignedSeats", view.unassignedSeats);
            request.setAttribute("unmappedSeats", view.unmappedSeats);
            request.setAttribute("seatedTotal", view.seatedTotal);
            request.setAttribute("seatedAvailable", view.seatedAvailable);
            request.setAttribute("seatedHeld", view.seatedHeld);
            request.setAttribute("seatedSold", view.seatedSold);
            request.setAttribute("standingUnknown", view.standingUnknown);
            request.setAttribute("mapJson", view.mapJson);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load seat status, staffId=" + staffId, e);
            request.setAttribute("loadError", ERROR_GENERIC);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private static String timeText(StaffAssignment e) {
        if (e.getStartTime() == null || e.getEndTime() == null) {
            return "";
        }
        if (e.getStartTime().toLocalDate().equals(e.getEndTime().toLocalDate())) {
            return e.getStartTime().format(TIME) + " - " + e.getEndTime().format(TIME)
                    + " (" + e.getStartTime().format(DATE) + ")";
        }
        return e.getStartTime().format(TIME) + " " + e.getStartTime().format(DATE)
                + " - " + e.getEndTime().format(TIME) + " " + e.getEndTime().format(DATE);
    }
}
