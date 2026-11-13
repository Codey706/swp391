package controller;

import dao.AuthDAO;
import dao.UserDAO;
import model.Auth;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import utils.CsrfUtils;
import utils.SessionUtils;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

/** Admin xem / sửa hồ sơ của chính mình và đổi mật khẩu. */
@WebServlet(name = "AdminProfileController", urlPatterns = {"/admin/profile"})
public class AdminProfileController extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/profile.jsp";
    private static final String PATH = "/admin/profile";

    private final UserDAO userDAO = new UserDAO();
    private final AuthDAO authDAO = new AuthDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            SessionUtils.moveFlash(request, "successMessage");
            request.setAttribute("admin", loadAdmin(request));
            CsrfUtils.expose(request);
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            User admin = loadAdmin(request);
            if ("changePassword".equals(request.getParameter("action"))) {
                changePassword(request, response, admin);
            } else {
                updateProfile(request, response, admin);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** Hồ sơ Admin đang đăng nhập, đọc lại từ database (AuthFilter đã kiểm tra role + ACTIVE). */
    private User loadAdmin(HttpServletRequest request) throws SQLException {
        return userDAO.getUserById(SessionUtils.currentUser(request).getUserId());
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User admin)
            throws ServletException, IOException, SQLException {
        User form = new User();
        form.setUserId(admin.getUserId());
        form.setUsername(admin.getUsername());
        form.setRole(admin.getRole());
        form.setStatus(admin.getStatus());
        form.setCreatedAt(admin.getCreatedAt());
        form.setFullName(trim(request.getParameter("fullName")));
        form.setEmail(trim(request.getParameter("email")));
        form.setPhone(trim(request.getParameter("phone")).replaceAll("[\\s.\\-]", ""));
        String address = trim(request.getParameter("address"));
        form.setAddress(address.isEmpty() ? null : address);

        Map<String, String> errors = new LinkedHashMap<>();
        if (!ValidationUtils.isLengthBetween(form.getFullName(), 2, 100)) {
            errors.put("fullName", "Họ và tên phải từ 2 đến 100 ký tự.");
        }
        if (form.getEmail().length() > 255 || !ValidationUtils.isEmail(form.getEmail())) {
            errors.put("email", "Vui lòng nhập email hợp lệ (tối đa 255 ký tự).");
        } else if (userDAO.existsEmailOfOtherUser(form.getEmail(), admin.getUserId())) {
            errors.put("email", "Email đã được sử dụng bởi tài khoản khác.");
        }
        if (!ValidationUtils.isPhone(form.getPhone())) {
            errors.put("phone", "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).");
        } else if (userDAO.existsPhoneOfOtherUser(form.getPhone(), admin.getUserId())) {
            errors.put("phone", "Số điện thoại đã được sử dụng bởi tài khoản khác.");
        }
        if (form.getAddress() != null && form.getAddress().length() > 255) {
            errors.put("address", "Địa chỉ tối đa 255 ký tự.");
        }

        if (!errors.isEmpty()) {
            showProfileError(request, response, form, errors, "Vui lòng kiểm tra lại thông tin.");
            return;
        }
        if (!userDAO.updateAdminProfile(form)) {
            showProfileError(request, response, form, errors, "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
            return;
        }

        Auth auth = SessionUtils.currentUser(request);
        auth.setFullName(form.getFullName());
        auth.setEmail(form.getEmail());
        auth.setPhone(form.getPhone());
        auth.setAddress(form.getAddress());
        redirectWithSuccess(request, response, "Cập nhật hồ sơ thành công.");
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response, User admin)
            throws ServletException, IOException, SQLException {
        String current = request.getParameter("currentPassword");
        String next = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");
        Auth auth = authDAO.findById(admin.getUserId());

        String error = null;
        if (current == null || auth == null || auth.getPassword() == null
                || !BCrypt.checkpw(current, auth.getPassword())) {
            error = "Mật khẩu hiện tại không chính xác.";
        } else if (next == null || next.length() < 8 || next.length() > 72) {
            error = "Mật khẩu mới phải từ 8 đến 72 ký tự.";
        } else if (!next.equals(confirm)) {
            error = "Xác nhận mật khẩu mới không khớp.";
        } else if (next.equals(current)) {
            error = "Mật khẩu mới phải khác mật khẩu hiện tại.";
        } else if (!authDAO.updatePassword(admin.getUserId(), BCrypt.hashpw(next, BCrypt.gensalt()))) {
            error = "Không thể đổi mật khẩu. Vui lòng thử lại.";
        }

        if (error != null) {
            request.setAttribute("passwordError", error);
            request.setAttribute("admin", admin);
            CsrfUtils.expose(request);
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }
        redirectWithSuccess(request, response, "Đổi mật khẩu thành công.");
    }

    private void showProfileError(HttpServletRequest request, HttpServletResponse response,
            User form, Map<String, String> errors, String message) throws ServletException, IOException {
        request.setAttribute("admin", form);
        request.setAttribute("errors", errors);
        request.setAttribute("profileError", message);
        CsrfUtils.expose(request);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /** Post/Redirect/Get: tránh gửi lại form khi người dùng F5. */
    private void redirectWithSuccess(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        request.getSession().setAttribute("successMessage", message);
        response.sendRedirect(request.getContextPath() + PATH);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
