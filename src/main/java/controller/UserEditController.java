package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/user-edit")
public class UserEditController extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    // Mở trang Edit User
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/user-edit.jsp"
            ).forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid user ID"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot load user for editing",
                    e
            );
        }
    }

    // Update User
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));

            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String role = request.getParameter("role");
            String status = request.getParameter("status");

            // Kiểm tra user tồn tại
            User existingUser = userDAO.getUserById(userId);

            if (existingUser == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }

            // Không cho chỉnh sửa Role hoặc Status của Admin
            if ("ADMIN".equalsIgnoreCase(existingUser.getRole())) {
                response.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Cannot modify an Admin account"
                );
                return;
            }

            // Kiểm tra Role
            if (role == null
                    || (!"ORGANIZER".equalsIgnoreCase(role)
                    && !"STAFF".equalsIgnoreCase(role)
                    && !"CUSTOMER".equalsIgnoreCase(role))) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid role"
                );
                return;
            }

            // Kiểm tra Status
            if (status == null
                    || (!"ACTIVE".equalsIgnoreCase(status)
                    && !"INACTIVE".equalsIgnoreCase(status))) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid status"
                );
                return;
            }

            // Cập nhật thông tin cá nhân
            User user = new User();
            user.setUserId(userId);
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setAddress(address);

            boolean infoUpdated = userDAO.updateUser(user);

            if (!infoUpdated) {
                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "Cannot update user information"
                );
                return;
            }

            // Cập nhật Role
            boolean roleUpdated = userDAO.updateUserRole(
                    userId, role.toUpperCase()
            );

            if (!roleUpdated) {
                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "Cannot update user role"
                );
                return;
            }

            // Cập nhật Status
            boolean statusUpdated = userDAO.updateUserStatus(
                    userId, status.toUpperCase()
            );

            if (!statusUpdated) {
                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "Cannot update user status"
                );
                return;
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
            throw new ServletException("Cannot update user", e);
        }
    }
}
