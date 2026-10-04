package controller;

import dao.UserDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "CustomerProfileController", urlPatterns = {"/CustomerProfileController"})
public class CustomerProfileController extends HttpServlet {

    private UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Integer userId = (Integer) session.getAttribute("userId");

        // Chưa đăng nhập
        if (userId == null) {
            response.sendRedirect("login");
            return;
        }

        try {

            User user = userDao.getUserById(userId);

            // Không tìm thấy user
            if (user == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Customer not found"
                );
                return;
            }

            request.setAttribute("user", user);

            request.getRequestDispatcher(
                    "/WEB-INF/views/customer/profile.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot load customer profile", e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}