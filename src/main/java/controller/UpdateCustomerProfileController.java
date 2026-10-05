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
import model.Auth;
import model.User;

@WebServlet(
        name = "UpdateCustomerProfileController",
        urlPatterns = {"/UpdateCustomerProfileController"}
)
public class UpdateCustomerProfileController extends HttpServlet {

    private UserDAO userDao = new UserDAO();

    // TẠM THỜI: user_id của customer01 trong db.sql (dùng khi chưa có login)
    private static final int TEST_USER_ID = 2;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Auth sessionUser = (Auth) session.getAttribute("user");
        Integer userId = (sessionUser == null) ? null : sessionUser.getUserId();

        //Chưa đăng nhập
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }

        try {

            // Lấy thông tin user từ database
            User user = userDao.getUserById(userId);

            // Không tìm thấy user
            if (user == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Customer not found"
                );
                return;
            }

            // Gửi user sang edit.jsp
            request.setAttribute("user", user);

            request.getRequestDispatcher(
                    "/WEB-INF/views/customer/edit.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot load customer information", e
            );
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Hỗ trợ tiếng Việt
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        // ===== TẠM THỜI TẮT LOGIN (bật lại: bỏ comment khối bên dưới, xoá dòng "int userId = TEST_USER_ID") =====
        // Auth sessionUser = (Auth) session.getAttribute("user");
        // Integer userId = (sessionUser == null) ? null : sessionUser.getUserId();
        //
        // // Chưa đăng nhập
        // if (userId == null) {
        //     response.sendRedirect(request.getContextPath() + "/Auth?action=login");
        //     return;
        // }
        int userId = TEST_USER_ID;

        // ==============================
        // Lấy dữ liệu từ form
        // ==============================
        String fullName
                = request.getParameter("fullName");

        String email
                = request.getParameter("email");

        String phone
                = request.getParameter("phone");

        String address
                = request.getParameter("address");

        // ==============================
        // Validation
        // ==============================
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

        // ==============================
        // Tạo User object
        // ==============================
        User user = new User();

        user.setUserId(userId);

        user.setFullName(
                fullName.trim()
        );

        user.setEmail(
                email.trim()
        );

        user.setPhone(
                phone == null
                        ? ""
                        : phone.trim()
        );

        user.setAddress(
                address == null
                        ? ""
                        : address.trim()
        );

        // ==============================
        // Update Database
        // ==============================
        try {

            boolean updated
                    = userDao.updateUser(user);

            if (updated) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/CustomerProfileController"
                );

                return;
            }

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Update profile failed"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot update customer profile", e
            );
        }
    }
}
