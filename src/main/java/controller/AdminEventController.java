package controller;

import dao.EventDAO;
import dao.SeatMapDAO;
import model.Event;
import utils.Constants;
import utils.EmailService;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Admin duyệt / từ chối sự kiện đang chờ duyệt.
 */
@WebServlet("/admin/events")
public class AdminEventController extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/admin/event-list.jsp";
    private static final String DETAIL_VIEW = "/WEB-INF/views/admin/event-detail.jsp";
    private static final int REASON_MAX_LENGTH = 1000;

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String eventIdRaw = request.getParameter("id");
            if (eventIdRaw != null) {
                int eventId = ValidationUtils.parseIntOrDefault(eventIdRaw, 0);
                if (eventId <= 0) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid event ID.");
                    return;
                }
                Event event = eventDAO.getEventForAdmin(eventId);
                if (event == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Event not found.");
                    return;
                }
                request.setAttribute("event", event);
                request.setAttribute("tickets", new SeatMapDAO().getTickets(eventId));
                request.setAttribute("organizer", eventDAO.getOrganizerContact(eventId));
                request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
                return;
            }
            int pageSize = Constants.EVENT_PAGE_SIZE;
            int totalEvents = eventDAO.countEventsPendingApproval();
            int totalPages = (int) Math.ceil((double) totalEvents / pageSize);
            int page = Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1));
            if (totalPages > 0 && page > totalPages) {
                page = totalPages;
            }

            request.setAttribute("events", eventDAO.getEventsPendingApproval(page, pageSize));
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalEvents", totalEvents);
            request.getRequestDispatcher(LIST_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), 0);
        if (eventId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid event ID.");
            return;
        }

        String reason = request.getParameter("reason") == null ? "" : request.getParameter("reason").trim();
        String result;
        try {
            if ("approve".equals(action)) {
                result = eventDAO.approveEvent(eventId) ? "success=approved" : "error=action_failed";
            } else if ("reject".equals(action)) {
                if (reason.isEmpty()) {
                    result = "error=reason_required";
                } else if (reason.length() > REASON_MAX_LENGTH) {
                    result = "error=reason_too_long";
                } else {
                    result = eventDAO.rejectEvent(eventId, reason) ? "success=rejected" : "error=action_failed";
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action.");
                return;
            }
            if (result.startsWith("success")) {
                notifyOrganizer(eventId, "approve".equals(action), reason);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        boolean returnToDetail = "detail".equals(request.getParameter("returnTo"));
        response.sendRedirect(request.getContextPath() + "/admin/events" + (returnToDetail ? "?id=" + eventId + "&" : "?") + result);
    }

    /**
     * UC-29: gửi email kết quả duyệt cho Organizer (chạy nền, lỗi gửi mail
     * không ảnh hưởng việc duyệt).
     */
    private void notifyOrganizer(int eventId, boolean approved, String reason) throws SQLException {
        String[] contact = eventDAO.getOrganizerContact(eventId);
        if (contact == null || contact[0] == null) {
            return;
        }
        String subject = (approved ? "Sự kiện đã được duyệt: " : "Sự kiện bị từ chối: ") + contact[2];
        String body = "Xin chào " + contact[1] + ",\n\n"
                + (approved
                        ? "Sự kiện \"" + contact[2] + "\" đã được quản trị viên phê duyệt và đang mở bán trên Light Ticket."
                        : "Sự kiện \"" + contact[2] + "\" chưa được phê duyệt.\nLý do: " + reason
                        + "\n\nBạn có thể chỉnh sửa sự kiện và gửi duyệt lại.")
                + "\n\nLight Ticket";
        EmailService.sendAsync(() -> EmailService.sendText(contact[0], subject, body));
    }
}
