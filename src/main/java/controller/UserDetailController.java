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

@WebServlet("/admin/user-detail")
public class UserDetailController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserDetailController.class.getName());
    private static final String VIEW = "/WEB-INF/views/admin/user-detail.jsp";

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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
        }

        HttpSession session = request.getSession();
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

        String id = request.getParameter("id");

        try {
            int userId = Integer.parseInt(id);

            User user = userDAO.getUserById(userId);

            if (user == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "User not found"
                );
                return;
            }

            request.setAttribute("user", user);

            request.getRequestDispatcher(VIEW).forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user ID"
            );

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load user detail for id=" + id, e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while loading user details"
            );
        }
    }

    // Đổi status nhanh
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
        }

        HttpSession session = request.getSession();
        String id = request.getParameter("id");
        String status = request.getParameter("status");

        try {
            int userId = Integer.parseInt(id);

            User targetUser = userDAO.getUserById(userId);
            if (targetUser == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }

            // Không cho phép đổi trạng thái của Admin
            if (Constants.ROLE_ADMIN.equalsIgnoreCase(targetUser.getRole())) {
                session.setAttribute("userErrorMessage", "Cannot change account status of an Administrator.");
                response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(status)
                    && !"INACTIVE".equalsIgnoreCase(status)) {
                session.setAttribute("userErrorMessage", "Invalid account status provided.");
                response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
                return;
            }

            boolean updated = userDAO.updateUserStatus(userId, status.toUpperCase());
            if (updated) {
                session.setAttribute("userSuccessMessage", "User status updated successfully to " + status.toUpperCase() + ".");
            } else {
                session.setAttribute("userErrorMessage", "Failed to update user status.");
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/user-detail?id="
                    + userId
            );

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user ID"
            );

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot update user status for id=" + id, e);
            session.setAttribute("userErrorMessage", "Database error occurred while updating status.");
            response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + id);
        }
    }
}
