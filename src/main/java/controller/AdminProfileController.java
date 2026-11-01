package controller;

import dao.AuthDAO;
import dao.UserDAO;
import model.Auth;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import utils.Constants;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AdminProfileController", urlPatterns = {"/admin/profile"})
public class AdminProfileController extends HttpServlet {

    private static final Logger LOGGER
            = Logger.getLogger(AdminProfileController.class.getName());

    private static final String VIEW
            = "/WEB-INF/views/admin/profile.jsp";

    private static final String PATH = "/admin/profile";
    private static final String LOGIN = "/Auth?action=login";
    private static final String CSRF_KEY = "adminProfileCsrf";
    private static final String FLASH_KEY = "adminProfileSuccess";

    private final UserDAO userDAO = new UserDAO();
    private final AuthDAO authDAO = new AuthDAO();
    private final SecureRandom random = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User admin = loadAdmin(request, response);
        if (admin == null) {
            return;
        }

        HttpSession session = request.getSession();

        Object flash = session.getAttribute(FLASH_KEY);
        if (flash != null) {
            request.setAttribute("successMessage", flash);
            session.removeAttribute(FLASH_KEY);
        }

        request.setAttribute("admin", admin);
        request.setAttribute("csrfToken", csrfToken(request));

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User admin = loadAdmin(request, response);
        if (admin == null) {
            return;
        }

        if (!validCsrf(request, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");

        if ("changePassword".equals(action)) {
            changePassword(request, response, admin);
            return;
        }

        updateProfile(request, response, admin);
    }

    private User loadAdmin(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        Object value = session == null
                ? null
                : session.getAttribute(Constants.SESSION_USER);

        if (!(value instanceof Auth)) {
            response.sendRedirect(
                    request.getContextPath() + LOGIN);
            return null;
        }

        Auth auth = (Auth) value;

        if (!Constants.ROLE_ADMIN.equalsIgnoreCase(auth.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        try {
            User admin = userDAO.getUserById(auth.getUserId());

            if (admin == null
                    || !Constants.ROLE_ADMIN.equalsIgnoreCase(admin.getRole())
                    || !Constants.STATUS_ACTIVE.equalsIgnoreCase(admin.getStatus())) {

                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return null;
            }

            return admin;

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load admin profile", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return null;
        }
    }

    private void updateProfile(HttpServletRequest request,
            HttpServletResponse response,
            User admin)
            throws ServletException, IOException {

        User form = new User();

        form.setUserId(admin.getUserId());
        form.setUsername(admin.getUsername());
        form.setRole(admin.getRole());
        form.setStatus(admin.getStatus());
        form.setCreatedAt(admin.getCreatedAt());

        form.setFullName(trim(request.getParameter("fullName")));
        form.setEmail(trim(request.getParameter("email")));

        form.setPhone(
                trim(request.getParameter("phone"))
                        .replaceAll("[\\s.\\-]", ""));

        String address = trim(request.getParameter("address"));
        form.setAddress(address.isEmpty() ? null : address);

        Map<String, String> errors = new LinkedHashMap<>();

        if (form.getFullName().length() < 2
                || form.getFullName().length() > 100) {

            errors.put("fullName",
                    "Họ và tên phải từ 2 đến 100 ký tự.");
        }

        if (form.getEmail().isEmpty()
                || form.getEmail().length() > 255
                || !ValidationUtils.isEmail(form.getEmail())) {

            errors.put("email",
                    "Vui lòng nhập email hợp lệ (tối đa 255 ký tự).");
        }

        if (form.getPhone().isEmpty()
                || !ValidationUtils.isPhone(form.getPhone())) {

            errors.put("phone",
                    "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).");
        }

        if (form.getAddress() != null
                && form.getAddress().length() > 255) {

            errors.put("address", "Địa chỉ tối đa 255 ký tự.");
        }

        try {
            if (!errors.containsKey("email")
                    && userDAO.existsEmailOfOtherUser(
                            form.getEmail(), admin.getUserId())) {

                errors.put("email",
                        "Email đã được sử dụng bởi tài khoản khác.");
            }

            if (!errors.containsKey("phone")
                    && userDAO.existsPhoneOfOtherUser(
                            form.getPhone(), admin.getUserId())) {

                errors.put("phone",
                        "Số điện thoại đã được sử dụng bởi tài khoản khác.");
            }

            if (!errors.isEmpty()) {
                showError(request, response, admin, form, errors,
                        "Vui lòng kiểm tra lại thông tin.");
                return;
            }

            if (!userDAO.updateAdminProfile(form)) {
                showError(request, response, admin, form, errors,
                        "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
                return;
            }

            HttpSession session = request.getSession(false);
            Object value = session == null
                    ? null
                    : session.getAttribute(Constants.SESSION_USER);

            if (value instanceof Auth) {
                Auth auth = (Auth) value;

                auth.setFullName(form.getFullName());
                auth.setEmail(form.getEmail());
                auth.setPhone(form.getPhone());
                auth.setAddress(form.getAddress());
            }

            request.getSession().setAttribute(
                    FLASH_KEY, "Cập nhật hồ sơ thành công.");

            response.sendRedirect(
                    request.getContextPath() + PATH);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Cannot update admin profile, userId="
                    + admin.getUserId(), e);

            showError(request, response, admin, form, errors,
                    "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
        }
    }

    private void changePassword(HttpServletRequest request,
            HttpServletResponse response,
            User admin)
            throws ServletException, IOException {

        String current = request.getParameter("currentPassword");
        String next = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        String error = null;

        try {
            Auth auth = authDAO.findById(admin.getUserId());

            if (current == null
                    || auth == null
                    || auth.getPassword() == null
                    || !BCrypt.checkpw(current, auth.getPassword())) {

                error = "Mật khẩu hiện tại không chính xác.";

            } else if (next == null
                    || next.length() < 8
                    || next.length() > 72) {

                error = "Mật khẩu mới phải từ 8 đến 72 ký tự.";

            } else if (!next.equals(confirm)) {
                error = "Xác nhận mật khẩu mới không khớp.";

            } else if (next.equals(current)) {
                error = "Mật khẩu mới phải khác mật khẩu hiện tại.";

            } else if (!authDAO.updatePassword(
                    admin.getUserId(),
                    BCrypt.hashpw(next, BCrypt.gensalt()))) {

                error = "Không thể đổi mật khẩu. Vui lòng thử lại.";
            }

            if (error != null) {
                request.setAttribute("passwordError", error);
                request.setAttribute("admin", admin);
                request.setAttribute("csrfToken", csrfToken(request));

                request.getRequestDispatcher(VIEW)
                        .forward(request, response);
                return;
            }

            request.getSession().setAttribute(
                    FLASH_KEY, "Đổi mật khẩu thành công.");

            response.sendRedirect(
                    request.getContextPath() + PATH);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE,
                    "Cannot change admin password, userId="
                    + admin.getUserId(), e);

            request.setAttribute("passwordError",
                    "Hệ thống đang gặp sự cố. Vui lòng thử lại.");

            request.setAttribute("admin", admin);
            request.setAttribute("csrfToken", csrfToken(request));

            request.getRequestDispatcher(VIEW)
                    .forward(request, response);
        }
    }

    private void showError(HttpServletRequest request,
            HttpServletResponse response,
            User admin,
            User form,
            Map<String, String> errors,
            String message)
            throws ServletException, IOException {

        request.setAttribute("admin", form);
        request.setAttribute("errors", errors);
        request.setAttribute("profileError", message);
        request.setAttribute("csrfToken", csrfToken(request));

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private String csrfToken(HttpServletRequest request) {

        HttpSession session = request.getSession();

        Object old = session.getAttribute(CSRF_KEY);
        if (old instanceof String) {
            return (String) old;
        }

        byte[] bytes = new byte[32];
        random.nextBytes(bytes);

        String token = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(bytes);

        session.setAttribute(CSRF_KEY, token);

        return token;
    }

    private boolean validCsrf(HttpServletRequest request,
            String actual) {

        HttpSession session = request.getSession(false);

        Object expected = session == null
                ? null
                : session.getAttribute(CSRF_KEY);

        return expected instanceof String
                && actual != null
                && MessageDigest.isEqual(
                        ((String) expected).getBytes(StandardCharsets.UTF_8),
                        actual.getBytes(StandardCharsets.UTF_8));
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
