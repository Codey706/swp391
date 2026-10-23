package controller;

import dao.UserDAO;
import model.Auth;
import model.User;
import utils.Constants;
import utils.ValidationUtils;

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

@WebServlet("/admin/user-edit")
public class UserEditController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserEditController.class.getName());
    private static final String VIEW = "/WEB-INF/views/admin/user-edit.jsp";

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

    // Mở trang Edit User
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
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
            LOGGER.log(Level.SEVERE, "Cannot load user for editing, id=" + id, e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while loading user"
            );
        }
    }

    // Update User
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
        }

        String idParam = request.getParameter("userId");
        int userId;
        try {
            userId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
            return;
        }

        try {
            // Kiểm tra user tồn tại
            User existingUser = userDAO.getUserById(userId);
            if (existingUser == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }

            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String role = request.getParameter("role");
            String status = request.getParameter("status");

            boolean isAdmin = Constants.ROLE_ADMIN.equalsIgnoreCase(existingUser.getRole());

            // Nếu là Admin thì không cho đổi Role hoặc Status
            if (isAdmin) {
                role = existingUser.getRole();
                status = existingUser.getStatus();
            }

            // Backend Validation
            String trimmedName = fullName != null ? fullName.trim() : "";
            String trimmedPhone = phone != null ? phone.trim() : "";
            String trimmedAddress = address != null ? address.trim() : "";

            if (!ValidationUtils.isLengthBetween(trimmedName, 2, 100)) {
                forwardWithError(request, response, existingUser, trimmedName, trimmedPhone, trimmedAddress, role, status,
                        "Full name must be between 2 and 100 characters.");
                return;
            }

            if (!trimmedPhone.isEmpty() && !ValidationUtils.isPhone(trimmedPhone)) {
                forwardWithError(request, response, existingUser, trimmedName, trimmedPhone, trimmedAddress, role, status,
                        "Phone number is invalid (must be 10-11 digits starting with 0).");
                return;
            }

            if (trimmedAddress.length() > 255) {
                forwardWithError(request, response, existingUser, trimmedName, trimmedPhone, trimmedAddress, role, status,
                        "Address must not exceed 255 characters.");
                return;
            }

            // Kiểm tra Role nếu không phải Admin
            if (!isAdmin) {
                if (role == null
                        || (!"ORGANIZER".equalsIgnoreCase(role)
                        && !"STAFF".equalsIgnoreCase(role)
                        && !"CUSTOMER".equalsIgnoreCase(role))) {
                    forwardWithError(request, response, existingUser, trimmedName, trimmedPhone, trimmedAddress, role, status,
                            "Invalid role selected.");
                    return;
                }
            }

            // Kiểm tra Status nếu không phải Admin
            if (!isAdmin) {
                if (status == null
                        || (!"ACTIVE".equalsIgnoreCase(status)
                        && !"INACTIVE".equalsIgnoreCase(status))) {
                    forwardWithError(request, response, existingUser, trimmedName, trimmedPhone, trimmedAddress, role, status,
                            "Invalid status selected.");
                    return;
                }
            }

            // Cập nhật thông tin cá nhân
            User user = new User();
            user.setUserId(userId);
            user.setFullName(trimmedName);
            user.setPhone(trimmedPhone.isEmpty() ? null : trimmedPhone);
            user.setAddress(trimmedAddress.isEmpty() ? null : trimmedAddress);

            boolean infoUpdated = userDAO.updateUser(user);

            if (!infoUpdated) {
                forwardWithError(request, response, existingUser, trimmedName, trimmedPhone, trimmedAddress, role, status,
                        "Cannot update user information in database.");
                return;
            }

            // Cập nhật Role nếu không phải Admin
            if (!isAdmin) {
                userDAO.updateUserRole(userId, role.toUpperCase());
            }

            // Cập nhật Status nếu không phải Admin
            if (!isAdmin) {
                userDAO.updateUserStatus(userId, status.toUpperCase());
            }

            HttpSession session = request.getSession();
            session.setAttribute("userSuccessMessage", "User information updated successfully.");

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/user-detail?id="
                    + userId
            );

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot update user id=" + userId, e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error while updating user"
            );
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
            User existingUser, String fullName, String phone, String address, String role, String status,
            String errorMessage) throws ServletException, IOException {
        User user = new User();
        user.setUserId(existingUser.getUserId());
        user.setUsername(existingUser.getUsername());
        user.setEmail(existingUser.getEmail());
        user.setFullName(fullName);
        user.setPhone(phone);
        user.setAddress(address);
        user.setRole(role);
        user.setStatus(status);

        request.setAttribute("user", user);
        request.setAttribute("errorMessage", errorMessage);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
