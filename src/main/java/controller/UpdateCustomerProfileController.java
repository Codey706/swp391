/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

/**
 *
 * @author TRUC MAI
 */
@WebServlet(name = "UpdateCustomerProfileController", urlPatterns = {"/UpdateCustomerProfileController"})
public class UpdateCustomerProfileController extends HttpServlet {

    private UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
      
             // Lấy session
        HttpSession session =
                request.getSession();


        // Lấy userId của người đang đăng nhập
        Integer userId =
                (Integer) session.getAttribute("userId");


        // Nếu chưa đăng nhập
        if (userId == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }


        // Lấy thông tin Customer
        // từ database
        User user =
                userDao.getUserById(userId);


        // Không tìm thấy Customer
        if (user == null) {

            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Customer not found"
            );

            return;
        }


        // Gửi User sang edit.jsp
        request.setAttribute(
                "user",
                user
        );


        // Mở edit.jsp
        request.getRequestDispatcher(
                "/WEB-INF/views/customer/edit.jsp"
        ).forward(
                request,
                response
        );
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
          // Hỗ trợ tiếng Việt
        request.setCharacterEncoding(
                "UTF-8"
        );


        // Lấy session
        HttpSession session =
                request.getSession();


        // Lấy userId
        Integer userId =
                (Integer) session.getAttribute("userId");


        // Nếu chưa đăng nhập
        if (userId == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }


        // ==================================================
        // Lấy dữ liệu từ form
        // ==================================================

        String fullName =
                request.getParameter(
                        "fullName"
                );


        String email =
                request.getParameter(
                        "email"
                );


        String phone =
                request.getParameter(
                        "phone"
                );


        String address =
                request.getParameter(
                        "address"
                );


        // ==================================================
        // Validation cơ bản
        // ==================================================

        if (fullName == null
                || fullName.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Full Name is required"
            );

            return;
        }


        if (email == null
                || email.trim().isEmpty()) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Email is required"
            );

            return;
        }


        // ==================================================
        // Tạo User object
        // ==================================================

        User user =
                new User();


        user.setUserId(
                userId
        );


        user.setFullName(
                fullName.trim()
        );


        user.setEmail(
                email.trim()
        );


        // Phone có thể rỗng
        user.setPhone(
                phone == null
                ? ""
                : phone.trim()
        );


        // Address có thể rỗng
        user.setAddress(
                address == null
                ? ""
                : address.trim()
        );


        // ==================================================
        // Update Database
        // ==================================================

        boolean updated =
                userDao.updateUser(
                        user
                );


        // ==================================================
        // Update thành công
        // ==================================================

        if (updated) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/CustomerProfileController"
            );

            return;
        }


        // ==================================================
        // Update thất bại
        // ==================================================

        response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Update profile failed"
        );
    }
}