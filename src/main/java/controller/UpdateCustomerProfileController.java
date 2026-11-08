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
import utils.Constants;
import utils.ValidationUtils;

@WebServlet(
        name = "UpdateCustomerProfileController",
        urlPatterns = {"/UpdateCustomerProfileController"}
)
public class UpdateCustomerProfileController extends HttpServlet {

    private UserDAO userDao = new UserDAO();

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

        Auth sessionUser = (Auth) session.getAttribute("user");
        Integer userId = (sessionUser == null) ? null : sessionUser.getUserId();

        // Chưa đăng nhập
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        User user = new User();
        user.setUserId(userId);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone.isEmpty() ? null : phone);
        user.setAddress(address.isEmpty() ? null : address);

        try {
            // ==============================
            // Validation: lỗi thì hiển thị lại form kèm dữ liệu đã nhập
            // ==============================
            String error = null;
            if (!ValidationUtils.isLengthBetween(fullName,
                    Constants.PROFILE_FULL_NAME_MIN_LENGTH, Constants.PROFILE_FULL_NAME_MAX_LENGTH)) {
                error = "Họ và tên phải từ " + Constants.PROFILE_FULL_NAME_MIN_LENGTH
                        + " đến " + Constants.PROFILE_FULL_NAME_MAX_LENGTH + " ký tự.";
            } else if (email.length() > Constants.PROFILE_EMAIL_MAX_LENGTH || !ValidationUtils.isEmail(email)) {
                error = "Email không đúng định dạng.";
            } else if (!phone.isEmpty() && !ValidationUtils.isPhone(phone)) {
                error = "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).";
            } else if (address.length() > Constants.PROFILE_ADDRESS_MAX_LENGTH) {
                error = "Địa chỉ tối đa " + Constants.PROFILE_ADDRESS_MAX_LENGTH + " ký tự.";
            } else if (userDao.existsEmailOfOtherUser(email, userId)) {
                error = "Email này đã được sử dụng bởi tài khoản khác.";
            } else if (!phone.isEmpty() && userDao.existsPhoneOfOtherUser(phone, userId)) {
                error = "Số điện thoại này đã được sử dụng bởi tài khoản khác.";
            }

            if (error != null) {
                User current = userDao.getUserById(userId);
                if (current != null) {
                    user.setUsername(current.getUsername());
                }
                request.setAttribute("errorMessage", error);
                request.setAttribute("user", user);
                request.getRequestDispatcher(
                        "/WEB-INF/views/customer/edit.jsp"
                ).forward(request, response);
                return;
            }

            // ==============================
            // Update Database
            // ==============================
            if (userDao.updateCustomerProfile(user)) {
                // Đồng bộ thông tin mới vào session để Header cập nhật ngay lập tức
                sessionUser.setFullName(user.getFullName());
                sessionUser.setEmail(user.getEmail());
                sessionUser.setPhone(user.getPhone());
                sessionUser.setAddress(user.getAddress());
                session.setAttribute("user", sessionUser);

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

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
