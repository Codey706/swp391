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
 * Read-only order list and detail drilldown for administrators.
 */
@WebServlet("/admin/orders")
public class AdminOrdersController extends HttpServlet {

    private final AdminDashboardDAO dao = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String idText = request.getParameter("id");
            if (idText != null) {
                int id;
                try {
                    id = Integer.parseInt(idText);
                } catch (NumberFormatException ex) {
                    response.sendError(400, "Invalid order ID");
                    return;
                }
                if (id <= 0) {
                    response.sendError(400, "Invalid order ID");
                    return;
                }
                Map<String, Object> order = dao.orderDetail(id);
                if (order == null) {
                    response.sendError(404, "Order not found");
                    return;
                }
                request.setAttribute("selectedOrder", order);
                request.setAttribute("orderItems", dao.orderItems(id));
            } else {
                String status = request.getParameter("status");
                if (status == null || !(status.equals("Paid") || status.equals("Pending") || status.equals("Cancelled"))) {
                    status = "All";
                }
                request.setAttribute("selectedStatus", status);
                request.setAttribute("orders", dao.orderList(status, 100));
            }
            request.getRequestDispatcher("/WEB-INF/views/admin/orders.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }
}
