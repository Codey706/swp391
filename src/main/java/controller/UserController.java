package controller;

import dao.UserDAO;
import model.Auth;
import model.User;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/users")
public class UserController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserController.class.getName());
    private static final String VIEW = "/WEB-INF/views/admin/user-list.jsp";

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Object userObj = session == null ? null : session.getAttribute(Constants.SESSION_USER);

        if (!(userObj instanceof Auth)) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }

        Auth currentUser = (Auth) userObj;
        if (!Constants.ROLE_ADMIN.equalsIgnoreCase(currentUser.getRole())
                || !Constants.STATUS_ACTIVE.equalsIgnoreCase(currentUser.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Kiểm tra flash messages từ session (nếu có sau thao tác chuyển hướng)
        Object flashSuccess = session.getAttribute("userSuccessMessage");
        if (flashSuccess != null) {
            request.setAttribute("successMessage", flashSuccess);
            session.removeAttribute("userSuccessMessage");
        }

        Object flashError = session.getAttribute("userErrorMessage");
        if (flashError != null) {
            request.setAttribute("errorMessage", flashError);
            session.removeAttribute("userErrorMessage");
        }

        String keyword = request.getParameter("keyword");
        String role = request.getParameter("role");
        String status = request.getParameter("status");

        if (role == null || role.trim().isEmpty()) {
            role = "ALL";
        }
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        try {
            List<User> users = userDAO.getAllUsers(currentUser.getUserId(), keyword, role, status);
            Map<String, Integer> stats = userDAO.getUserStatistics();

            request.setAttribute("users", users);
            request.setAttribute("stats", stats);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load user list", e);
            request.setAttribute("errorMessage", "Unable to retrieve user records from database. Please try again.");
        }

        request.setAttribute("keyword", keyword == null ? "" : keyword.trim());
        request.setAttribute("selectedRole", role);
        request.setAttribute("selectedStatus", status);

        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
