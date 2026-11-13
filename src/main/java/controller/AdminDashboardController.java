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

/** UC-35 View System Dashboard. */
@WebServlet("/admin")
public class AdminDashboardController extends HttpServlet {

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
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
