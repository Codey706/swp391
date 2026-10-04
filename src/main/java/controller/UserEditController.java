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

            int userId = Integer.parseInt(
                    request.getParameter("userId")
            );

            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String role = request.getParameter("role");
            String status = request.getParameter("status");

            if (!"ADMIN".equalsIgnoreCase(role)
                    && !"ORGANIZER".equalsIgnoreCase(role)
                    && !"STAFF".equalsIgnoreCase(role)
                    && !"CUSTOMER".equalsIgnoreCase(role)) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid role"
                );
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(status)
                    && !"INACTIVE".equalsIgnoreCase(status)) {

                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid status"
                );
                return;
            }

            User user = new User();

            user.setUserId(userId);
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setAddress(address);
            user.setRole(role.toUpperCase());
            user.setStatus(status.toUpperCase());

            userDAO.updateUser(user);

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

            throw new ServletException(
                    "Cannot update user",
                    e
            );
        }
    }
}
