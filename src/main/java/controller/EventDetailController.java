package controller;

import dao.EventDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Event;
import java.io.IOException;

/**
 * Controller for displaying a public event's detail page.
 * URL pattern: /event/detail?id=123
 */
@WebServlet("/event/detail")
public class EventDetailController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        int eventId = 0;
        try {
            eventId = Integer.parseInt(idParam);
        } catch (NumberFormatException ignored) {
        }
        if (eventId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid event id");
            return;
        }
        EventDAO dao = new EventDAO();
        Event event = dao.getPublicEventById(eventId);
        if (event == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Event not found");
            return;
        }
        request.setAttribute("event", event);
        request.getRequestDispatcher("/WEB-INF/views/event/event-detail.jsp")
                .forward(request, response);
    }
}
