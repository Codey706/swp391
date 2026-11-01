package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

import model.Auth;

@WebServlet("/admin/users")
public class UserController extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession(false);
            Auth currentUser = session == null
                    ? null
                    : (Auth) session.getAttribute("user");

            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/Auth?action=login");
                return;
            }

            request.setAttribute(
                    "users",
                    userDAO.getAllUsers(currentUser.getUserId())
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/user-list.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Cannot load user list", e);
        }
    }
}
