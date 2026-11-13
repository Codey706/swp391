package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import utils.ValidationUtils;
import java.io.IOException;
import java.sql.SQLException;

/** Admin xem chi tiết tài khoản và đổi nhanh trạng thái ACTIVE / INACTIVE. */
@WebServlet("/admin/user-detail")
public class UserDetailController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int userId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        if (userId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
            return;
        }
        try {
            User user = userDAO.getUserById(userId);
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }
            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/views/admin/user-detail.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int userId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        String status = request.getParameter("status");
        if (userId <= 0 || !("ACTIVE".equalsIgnoreCase(status) || "INACTIVE".equalsIgnoreCase(status))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            userDAO.updateUserStatus(userId, status.toUpperCase());
            response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
