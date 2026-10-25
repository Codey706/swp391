package controller;

import dao.EventDAO;
import model.Auth;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import model.Event;

@WebServlet("/admin/events")
public class AdminEventController extends HttpServlet {

    private EventDAO eventDAO;

    private static final String LIST_VIEW
            = "/WEB-INF/views/admin/event-list.jsp";

    @Override
    public void init() {
        eventDAO = new EventDAO();
    }

    // Kiem tra tai khoan Admin dang dang nhap
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return false;
        }

        Object userObject = session.getAttribute(Constants.SESSION_USER);

        if (!(userObject instanceof Auth)) {
            return false;
        }

        Auth user = (Auth) userObject;

        return user.getRole() != null
                && Constants.ROLE_ADMIN.equalsIgnoreCase(user.getRole())
                && Constants.STATUS_ACTIVE.equalsIgnoreCase(user.getStatus());
    }

    // Hien thi danh sach su kien dang cho duyet
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to access this page."
            );
            return;
        }

        int page = 1;

        try {
            String pageText = request.getParameter("page");

            if (pageText != null && !pageText.trim().isEmpty()) {
                page = Integer.parseInt(pageText);
            }

            if (page < 1) {
                page = 1;
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        int pageSize = Constants.EVENT_PAGE_SIZE;
        int totalEvents = eventDAO.countEventsPendingApproval();
        int totalPages = (int) Math.ceil((double) totalEvents / pageSize);

        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        List<Event> events
                = eventDAO.getEventsPendingApproval(page, pageSize);

        request.setAttribute("events", events);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalEvents", totalEvents);

        request.getRequestDispatcher(LIST_VIEW)
                .forward(request, response);
    }

    // Xu ly duyet hoac tu choi su kien
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isAdmin(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to perform this action."
            );
            return;
        }

        String action = request.getParameter("action");
        String eventIdText = request.getParameter("eventId");

        int eventId;

        try {
            if (eventIdText == null || eventIdText.trim().isEmpty()) {
                throw new NumberFormatException();
            }

            eventId = Integer.parseInt(eventIdText);

            if (eventId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid event ID."
            );
            return;
        }

        if ("approve".equals(action)) {
            boolean success = eventDAO.approveEvent(eventId);

            if (success) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/events?success=approved"
                );
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/events?error=action_failed"
                );
            }

            return;
        }

        if ("reject".equals(action)) {
            String reason = request.getParameter("reason");

            if (reason == null || reason.trim().isEmpty()) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/events?error=reason_required"
                );
                return;
            }

            reason = reason.trim();

            if (reason.length() > 1000) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/events?error=reason_too_long"
                );
                return;
            }

            boolean success = eventDAO.rejectEvent(eventId, reason);

            if (success) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/events?success=rejected"
                );
            } else {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/events?error=action_failed"
                );
            }

            return;
        }

        response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid action."
        );
    }
}
