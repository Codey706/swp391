package controller;

import dao.AdminDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

/**
 * UC-35 View System Dashboard.
 */
@WebServlet("/admin")
public class AdminDashboardController extends HttpServlet {

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int days = 30;
            try {
                days = Integer.parseInt(request.getParameter("days"));
            } catch (NumberFormatException ignored) {
            }
            if (days != 7 && days != 30 && days != 90) {
                days = 30;
            }
            request.setAttribute("selectedDays", days);
            request.setAttribute("revenueTrend", dashboardDAO.revenueTrend(days));
            Map<String, Integer> orderStatuses = dashboardDAO.orderStatusCounts();
            request.setAttribute("orderStatuses", orderStatuses);
            request.setAttribute("orderTotal", orderStatuses.values().stream().mapToInt(Integer::intValue).sum());
            request.setAttribute("recentOrders", dashboardDAO.recentOrders(6));
            request.setAttribute("pendingEventPreview", dashboardDAO.pendingEventPreview(5));
            Map<String, Integer> users = dashboardDAO.countUsersByRole();
            Map<String, Integer> events = dashboardDAO.countEventsByStatus();
            Object[] sales = dashboardDAO.getSalesSummary();
            request.setAttribute("usersByRole", users);
            request.setAttribute("userTotal", users.values().stream().mapToInt(Integer::intValue).sum());
            request.setAttribute("eventsByStatus", events);
            request.setAttribute("eventTotal", events.values().stream().mapToInt(Integer::intValue).sum());
            request.setAttribute("pendingEvents", events.get("PENDING_APPROVAL"));
            request.setAttribute("paidOrders", sales[0]);
            request.setAttribute("revenue", sales[1]);
            request.setAttribute("refundPending", sales[2]);
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }
}
