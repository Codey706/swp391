package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import utils.Constants;
import utils.ValidationUtils;

import java.io.IOException;
import java.sql.SQLException;

/** Admin sửa thông tin, role, trạng thái của tài khoản (tài khoản Admin chỉ sửa thông tin cá nhân). */
@WebServlet("/admin/user-edit")
public class UserEditController extends HttpServlet {

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
            request.getRequestDispatcher("/WEB-INF/views/admin/user-edit.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int userId = ValidationUtils.parseIntOrDefault(request.getParameter("userId"), 0);
        String fullName = request.getParameter("fullName") == null ? "" : request.getParameter("fullName").trim();
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        if (userId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
            return;
        }
        if (!ValidationUtils.isLengthBetween(fullName,
                Constants.PROFILE_FULL_NAME_MIN_LENGTH, Constants.PROFILE_FULL_NAME_MAX_LENGTH)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Full name must be "
                    + Constants.PROFILE_FULL_NAME_MIN_LENGTH + "-" + Constants.PROFILE_FULL_NAME_MAX_LENGTH + " characters");
            return;
        }

        try {
            User existing = userDAO.getUserById(userId);
            if (existing == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }
            // Tài khoản Admin: không cho đổi role / status
            boolean isAdmin = Constants.ROLE_ADMIN.equalsIgnoreCase(existing.getRole());
            if (!isAdmin && canonicalRole(role) == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid role");
                return;
            }
            if (!isAdmin && !("ACTIVE".equalsIgnoreCase(status) || "INACTIVE".equalsIgnoreCase(status))) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid status");
                return;
            }

            User user = new User();
            user.setUserId(userId);
            user.setFullName(fullName);
            user.setPhone(request.getParameter("phone"));
            user.setAddress(request.getParameter("address"));
            boolean updated = userDAO.updateUser(user)
                    && (isAdmin || userDAO.updateUserRole(userId, canonicalRole(role))
                    && userDAO.updateUserStatus(userId, status.toUpperCase()));
            if (!updated) {
                response.sendError(HttpServletResponse.SC_CONFLICT, "Cannot update user");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + userId);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** Role theo đúng dạng toàn hệ thống dùng (Customer/Organizer/Staff); null nếu không hợp lệ. */
    private static String canonicalRole(String role) {
        for (String valid : new String[]{Constants.ROLE_ORGANIZER, Constants.ROLE_STAFF, Constants.ROLE_CUSTOMER}) {
            if (valid.equalsIgnoreCase(role)) {
                return valid;
            }
        }
        return null;
    }
}
