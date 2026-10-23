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
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/user-delete")
public class UserDeleteController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserDeleteController.class.getName());

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    private Auth getAuthenticatedAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object userObj = session == null ? null : session.getAttribute(Constants.SESSION_USER);

        if (!(userObj instanceof Auth)) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return null;
        }

        Auth currentUser = (Auth) userObj;
        if (!Constants.ROLE_ADMIN.equalsIgnoreCase(currentUser.getRole())
                || !Constants.STATUS_ACTIVE.equalsIgnoreCase(currentUser.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        return currentUser;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
        }

        HttpSession session = request.getSession();
        String idParam = request.getParameter("id");

        int userId;
        try {
            userId = Integer.parseInt(idParam);
            if (userId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
                return;
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
            return;
        }

        try {
            User target = userDAO.getUserById(userId);

            if (target == null) {
                session.setAttribute("userErrorMessage", "User not found.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            // Không cho phép xóa tài khoản Admin
            if (Constants.ROLE_ADMIN.equalsIgnoreCase(target.getRole())) {
                session.setAttribute("userErrorMessage", "Cannot delete an Administrator account.");
                response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
                return;
            }

            // Không cho phép tự xóa tài khoản của chính mình
            if (admin.getUserId() == target.getUserId()) {
                session.setAttribute("userErrorMessage", "You cannot delete your own account.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }

            // Kiểm tra ràng buộc dữ liệu liên quan (Orders, Events, Staff assignments, Reviews)
            if (userDAO.hasRelatedRecords(userId)) {
                session.setAttribute("userErrorMessage",
                        "Cannot delete user @" + target.getUsername()
                        + " because this account has existing orders, events, staff assignments, or reviews. You can deactivate (lock) the account instead.");
                response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
                return;
            }

            boolean deleted = userDAO.deleteUser(userId);

            if (deleted) {
                session.setAttribute("userSuccessMessage",
                        "User @" + target.getUsername() + " has been deleted successfully.");
            } else {
                session.setAttribute("userErrorMessage", "Failed to delete user.");
            }

            response.sendRedirect(request.getContextPath() + "/admin/users");

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot delete user id=" + userId, e);
            session.setAttribute("userErrorMessage", "Database error occurred while deleting user.");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }
}
