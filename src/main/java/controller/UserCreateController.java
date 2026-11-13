package controller;

import dao.AuthDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import model.Auth;
import org.mindrot.jbcrypt.BCrypt;
import utils.Constants;
import utils.CsrfUtils;
import utils.EmailService;
import utils.ValidationUtils;

/**
 * UC-34: Admin tạo tài khoản Organizer / Staff.
 * Hệ thống sinh mật khẩu tạm, gửi email cho người dùng và hiển thị một lần cho Admin;
 * người dùng bắt buộc đổi mật khẩu ở lần đăng nhập đầu (Users.must_change_password).
 */
@WebServlet("/admin/user-create")
public class UserCreateController extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/user-create.jsp";
    private static final String UPPER = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    private static final String LOWER = "abcdefghijkmnopqrstuvwxyz";
    private static final String DIGITS = "23456789";
    private static final String SPECIAL = "@#$%&*!";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final AuthDAO authDAO = new AuthDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CsrfUtils.expose(request);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String role = Constants.ROLE_STAFF.equals(request.getParameter("role")) ? Constants.ROLE_STAFF
                : Constants.ROLE_ORGANIZER.equals(request.getParameter("role")) ? Constants.ROLE_ORGANIZER : null;

        String error = null;
        try {
            if (role == null) {
                error = "Vui lòng chọn vai trò Organizer hoặc Staff.";
            } else if (!ValidationUtils.isUsername(username)) {
                error = "Username chỉ gồm chữ, số, dấu chấm hoặc gạch dưới (4-50 ký tự).";
            } else if (email.length() > Constants.PROFILE_EMAIL_MAX_LENGTH || !ValidationUtils.isEmail(email)) {
                error = "Email không đúng định dạng.";
            } else if (!ValidationUtils.isLengthBetween(fullName,
                    Constants.PROFILE_FULL_NAME_MIN_LENGTH, Constants.PROFILE_FULL_NAME_MAX_LENGTH)) {
                error = "Họ tên / tên đơn vị phải từ " + Constants.PROFILE_FULL_NAME_MIN_LENGTH
                        + " đến " + Constants.PROFILE_FULL_NAME_MAX_LENGTH + " ký tự.";
            } else if (!phone.isEmpty() && !ValidationUtils.isPhone(phone)) {
                error = "Số điện thoại không hợp lệ.";
            } else if (authDAO.usernameExists(username)) {
                error = "Username đã tồn tại.";
            } else if (authDAO.emailExists(email)) {
                error = "Email đã được sử dụng.";
            } else if (!phone.isEmpty() && authDAO.phoneExists(phone)) {
                error = "Số điện thoại đã được sử dụng.";
            }

            if (error != null) {
                request.setAttribute("error", error);
                request.setAttribute("form", new String[]{username, email, fullName, phone, role});
                doGet(request, response);
                return;
            }

            String tempPassword = generateTempPassword();
            Auth user = new Auth();
            user.setUsername(username);
            user.setEmail(email);
            user.setFullName(fullName);
            user.setPhone(phone.isEmpty() ? null : phone);
            user.setPassword(BCrypt.hashpw(tempPassword, BCrypt.gensalt()));
            authDAO.insertStaffAccount(user, role);
            Auth created = authDAO.findByEmail(email);

            String loginUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                    + request.getContextPath() + "/Auth?action=login";
            EmailService.sendAsync(() -> EmailService.sendText(email, "Tài khoản Light Ticket của bạn",
                    "Xin chào " + fullName + ",\n\n"
                    + "Quản trị viên đã tạo tài khoản " + role + " cho bạn trên Light Ticket.\n"
                    + "Tên đăng nhập: " + username + "\n"
                    + "Mật khẩu tạm: " + tempPassword + "\n\n"
                    + "Bạn sẽ được yêu cầu đổi mật khẩu ở lần đăng nhập đầu tiên: " + loginUrl));

            // Hiển thị mật khẩu tạm đúng một lần cho Admin (phòng khi email chưa cấu hình / bị chặn)
            request.getSession().setAttribute("createdTempPassword", tempPassword);
            response.sendRedirect(request.getContextPath() + "/admin/user-detail?id=" + created.getUserId());
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** 12 ký tự, luôn có chữ hoa, chữ thường, số và ký tự đặc biệt (thỏa isStrongPassword). */
    static String generateTempPassword() {
        String all = UPPER + LOWER + DIGITS + SPECIAL;
        char[] chars = new char[12];
        chars[0] = UPPER.charAt(RANDOM.nextInt(UPPER.length()));
        chars[1] = LOWER.charAt(RANDOM.nextInt(LOWER.length()));
        chars[2] = DIGITS.charAt(RANDOM.nextInt(DIGITS.length()));
        chars[3] = SPECIAL.charAt(RANDOM.nextInt(SPECIAL.length()));
        for (int i = 4; i < chars.length; i++) {
            chars[i] = all.charAt(RANDOM.nextInt(all.length()));
        }
        for (int i = chars.length - 1; i > 0; i--) {
            int j = RANDOM.nextInt(i + 1);
            char tmp = chars[i];
            chars[i] = chars[j];
            chars[j] = tmp;
        }
        return new String(chars);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
