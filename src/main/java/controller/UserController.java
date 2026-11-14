package controller;

import utils.SessionUtils;
import utils.AdminListFilter;
import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/admin/users")
public class UserController extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<User> all = userDAO.getAllUsers(SessionUtils.currentUser(request).getUserId());
            String keyword = AdminListFilter.param(request, "keyword");
            String role = AdminListFilter.param(request, "role");
            String status = AdminListFilter.param(request, "status");
            List<User> filtered = all.stream().filter(u
                    -> (AdminListFilter.contains(u.getUsername(), keyword)
                    || AdminListFilter.contains(u.getFullName(), keyword)
                    || AdminListFilter.contains(u.getEmail(), keyword)
                    || AdminListFilter.contains(u.getPhone(), keyword)
                    || Integer.toString(u.getUserId()).contains(keyword))
                    && AdminListFilter.matches(u.getRole(), role)
                    && AdminListFilter.matches(u.getStatus(), status))
                    .collect(Collectors.toList());
            request.setAttribute("allUsers", all);
            request.setAttribute("users", AdminListFilter.page(request, filtered,
                    AdminListFilter.query("keyword", keyword, "role", role, "status", status)));
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedRole", role);
            request.setAttribute("selectedStatus", status);
            request.getRequestDispatcher("/WEB-INF/views/admin/user-list.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
