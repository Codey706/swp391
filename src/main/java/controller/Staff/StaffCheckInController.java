package controller.Staff;

import static controller.Staff.StaffController.ERROR_GENERIC;
import dao.StaffCheckInDAO;
import dao.StaffEventDAO;
import model.Auth;
import model.StaffAssignment;
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
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /staff/checkin[?eventId=...] : trang soát vé của sự kiện được phân công
 * diễn ra hôm nay. POST /staff/checkin : soát một vé theo mã (nội dung QR), rồi
 * redirect về GET (PRG).
 *
 * Chỉ soát vé cho sự kiện ACTIVE, Staff này được phân công, diễn ra trong hôm
 * nay và chưa kết thúc (cho phép soát trước giờ bắt đầu). Mọi eventId ngoài
 * danh sách đó đều nhận 403.
 */
@WebServlet(name = "StaffCheckInController", urlPatterns = {"/staff/checkin"})
public class StaffCheckInController extends StaffController {

    private static final Logger LOGGER = Logger.getLogger(StaffCheckInController.class.getName());
    private static final String VIEW = "/WEB-INF/views/staff/checkin.jsp";
    private static final String PATH = "/staff/checkin";

    private final StaffEventDAO staffEventDAO = new StaffEventDAO();
    private final StaffCheckInDAO checkInDAO = new StaffCheckInDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth staff = getAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }
        response.setHeader("Cache-Control", "no-store");

        Integer requestedId = parseEventId(request.getParameter("eventId"));
        if (requestedId != null && requestedId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        HttpSession session = request.getSession();
        Object flash = session.getAttribute(Constants.SESSION_STAFF_CHECKIN_RESULT);
        if (flash != null) {
            session.removeAttribute(Constants.SESSION_STAFF_CHECKIN_RESULT);
            request.setAttribute("result", flash);
        }
        request.setAttribute("csrfToken", getOrCreateCsrfToken(session));
        request.setAttribute("maxCodeLength", Constants.TICKET_CODE_MAX_LENGTH);

        try {
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
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load check-in page, staffId=" + staff.getUserId(), e);
            request.setAttribute("loadError", ERROR_GENERIC);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth staff = getAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }
        HttpSession session = request.getSession();
        if (!isValidCsrfToken(session, request.getParameter("csrfToken"))) {
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
            session.setAttribute(Constants.SESSION_STAFF_CHECKIN_RESULT, "INVALID_CODE");
            response.sendRedirect(redirect);
            return;
        }

        try {
            if (find(checkInEvents(staff.getUserId()), eventId) == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            session.setAttribute(Constants.SESSION_STAFF_CHECKIN_RESULT, checkInDAO.checkIn(eventId, code));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Check-in failed, staffId=" + staff.getUserId() + ", eventId=" + eventId, e);
            session.setAttribute(Constants.SESSION_STAFF_CHECKIN_RESULT, "ERROR");
        }
        response.sendRedirect(redirect);
    }

    /**
     * Sự kiện được phân công, ACTIVE, diễn ra trong hôm nay và chưa kết thúc.
     */
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

    /**
     * @return null nếu không truyền, -1 nếu sai định dạng
     */
    private static Integer parseEventId(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(raw.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    // ------------------------------------------------------------------ CSRF
    private String getOrCreateCsrfToken(HttpSession session) {
        Object token = session.getAttribute(Constants.SESSION_STAFF_CHECKIN_CSRF);
        if (token instanceof String) {
            return (String) token;
        }
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);
        String newToken = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        session.setAttribute(Constants.SESSION_STAFF_CHECKIN_CSRF, newToken);
        return newToken;
    }

    private boolean isValidCsrfToken(HttpSession session, String actual) {
        Object expected = session.getAttribute(Constants.SESSION_STAFF_CHECKIN_CSRF);
        if (!(expected instanceof String) || actual == null) {
            return false;
        }
        return MessageDigest.isEqual(
                ((String) expected).getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8));
    }
}
