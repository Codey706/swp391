package controller.Event;

import dao.OrganizerDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import model.Auth;
import model.Event;

/**
 * UC-24 View Sales Report: GET /organizer/event/report?eventId= — vé bán, doanh thu,
 * số check-in theo từng hạng vé của một sự kiện thuộc organizer đang đăng nhập.
 */
@WebServlet(name = "EventReportController", urlPatterns = {"/organizer/event/report"})
public class EventReportController extends EventController {

    private static final String VIEW = "/WEB-INF/views/organizer/event-report.jsp";

    private final OrganizerDashboardDAO dashboardDAO = new OrganizerDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth organizer = currentOrganizer(request);
            Event event = loadOwnedEvent(request, organizer);
            if (event == null) {
                redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện của bạn.");
                return;
            }
            List<Map<String, Object>> rows = dashboardDAO.getEventTicketReport(event.getEventId());
            int quantity = 0;
            int sold = 0;
            int held = 0;
            int checkedIn = 0;
            BigDecimal revenue = BigDecimal.ZERO;
            for (Map<String, Object> row : rows) {
                quantity += (Integer) row.get("quantity");
                sold += (Integer) row.get("sold");
                held += (Integer) row.get("held");
                checkedIn += (Integer) row.get("checkedIn");
                revenue = revenue.add((BigDecimal) row.get("revenue"));
            }
            request.setAttribute("event", event);
            request.setAttribute("rows", rows);
            request.setAttribute("totalQuantity", quantity);
            request.setAttribute("totalSold", sold);
            request.setAttribute("totalHeld", held);
            request.setAttribute("totalCheckedIn", checkedIn);
            request.setAttribute("totalRevenue", revenue);
            request.setAttribute("soldPercent", quantity == 0 ? 0 : sold * 100 / quantity);
            request.setAttribute("checkInPercent", sold == 0 ? 0 : checkedIn * 100 / sold);
            request.setAttribute("orderCounts", dashboardDAO.getEventOrderCounts(event.getEventId()));
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
