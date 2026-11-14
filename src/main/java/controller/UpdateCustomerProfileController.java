package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Auth;
import model.User;
import utils.Constants;
import utils.SessionUtils;
import utils.ValidationUtils;

/** Customer sửa hồ sơ của chính mình. */
@WebServlet(name = "UpdateCustomerProfileController", urlPatterns = {"/UpdateCustomerProfileController"})
public class UpdateCustomerProfileController extends HttpServlet {

    private static final String EDIT_VIEW = "/WEB-INF/views/customer/edit.jsp";

    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("user", userDao.getUserById(SessionUtils.currentUser(request).getUserId()));
            request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth sessionUser = SessionUtils.currentUser(request);
        int userId = sessionUser.getUserId();
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        User user = new User();
        user.setUserId(userId);
        user.setUsername(sessionUser.getUsername());
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone.isEmpty() ? null : phone);
        user.setAddress(address.isEmpty() ? null : address);

        try {
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
            } else if (!userDao.updateCustomerProfile(user)) {
                error = "Không thể cập nhật hồ sơ. Tài khoản của bạn có thể không còn hoạt động.";
            }

            if (error != null) {
                // Hiển thị lại form kèm dữ liệu đã nhập
                request.setAttribute("errorMessage", error);
                request.setAttribute("user", user);
                request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
                return;
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        // Đồng bộ thông tin mới vào session để Header cập nhật ngay
        sessionUser.setFullName(user.getFullName());
        sessionUser.setEmail(user.getEmail());
        sessionUser.setPhone(user.getPhone());
        sessionUser.setAddress(user.getAddress());
        response.sendRedirect(request.getContextPath() + "/CustomerProfileController");
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
