package controller.Staff;

import dao.StaffCheckInDAO;
import dao.StaffEventDAO;
import model.Auth;
import model.StaffAssignment;
import utils.Constants;
import utils.CsrfUtils;
import utils.SessionUtils;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

/**
 * GET  /staff/checkin[?eventId=...] : trang soát vé của sự kiện được phân công diễn ra hôm nay.
 * POST /staff/checkin               : soát một vé theo mã (nội dung QR), rồi redirect về GET (PRG).
 *
 * Chỉ soát vé cho sự kiện ACTIVE, Staff này được phân công, diễn ra trong hôm nay và chưa kết thúc
 * (cho phép soát trước giờ bắt đầu). Mọi eventId ngoài danh sách đó đều nhận 403.
 */
@WebServlet(name = "StaffCheckInController", urlPatterns = {"/staff/checkin"})
public class StaffCheckInController extends StaffController {

    private static final String VIEW = "/WEB-INF/views/staff/checkin.jsp";
    private static final String PATH = "/staff/checkin";

    private final StaffEventDAO staffEventDAO = new StaffEventDAO();
    private final StaffCheckInDAO checkInDAO = new StaffCheckInDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth staff = currentStaff(request);
            response.setHeader("Cache-Control", "no-store");

            Integer requestedId = parseEventId(request.getParameter("eventId"));
            if (requestedId != null && requestedId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            SessionUtils.moveFlash(request, "result");
            CsrfUtils.expose(request);
            request.setAttribute("maxCodeLength", Constants.TICKET_CODE_MAX_LENGTH);

            List<StaffAssignment> events = checkInEvents(staff.getUserId());
            request.setAttribute("events", events);
            if (!events.isEmpty()) {
                StaffAssignment selected = requestedId == null ? events.get(0) : find(events, requestedId);
                if (selected == null) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                request.setAttribute("event", selected);
                request.setAttribute("recent",
                        checkInDAO.findRecentCheckIns(selected.getEventId(), Constants.STAFF_CHECKIN_RECENT));
            } else if (requestedId != null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth staff = currentStaff(request);
            HttpSession session = request.getSession();
            if (!CsrfUtils.isValid(request)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            Integer eventId = parseEventId(request.getParameter("eventId"));
            if (eventId == null || eventId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            String redirect = request.getContextPath() + PATH + "?eventId=" + eventId;

            String code = request.getParameter("ticketCode");
            code = code == null ? "" : code.trim();
            if (code.isEmpty() || code.length() > Constants.TICKET_CODE_MAX_LENGTH) {
                session.setAttribute("result", "INVALID_CODE");
                response.sendRedirect(redirect);
                return;
            }

            if (find(checkInEvents(staff.getUserId()), eventId) == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            session.setAttribute("result", checkInDAO.checkIn(eventId, code));
            response.sendRedirect(redirect);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** Sự kiện được phân công, ACTIVE, diễn ra trong hôm nay và chưa kết thúc. */
    private List<StaffAssignment> checkInEvents(int staffId) throws SQLException {
        LocalDateTime now = LocalDateTime.now(ZoneId.of(Constants.BUSINESS_ZONE_ID));
        List<StaffAssignment> today = staffEventDAO.findAssigned(staffId, StaffEventDAO.TAB_ALL, "",
                StaffEventDAO.RANGE_TODAY, now, 1, Constants.STAFF_SEAT_MAX_EVENTS);
        List<StaffAssignment> open = new ArrayList<>();
        for (StaffAssignment e : today) {
            if (Constants.EVENT_ACTIVE.equals(e.getStatus())
                    && !StaffEventDAO.ENDED.equals(e.getTimeStatus())) {
                open.add(e);
            }
        }
        return open;
    }

    private static StaffAssignment find(List<StaffAssignment> events, int eventId) {
        for (StaffAssignment e : events) {
            if (e.getEventId() == eventId) {
                return e;
            }
        }
        return null;
    }

    /** @return null nếu không truyền, -1 nếu sai định dạng */
    private static Integer parseEventId(String raw) {
        return ValidationUtils.isNullOrBlank(raw) ? null : ValidationUtils.parseIntOrDefault(raw, -1);
    }
}
