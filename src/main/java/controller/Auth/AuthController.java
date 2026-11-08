package controller.Auth;

import dao.AuthDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import model.Auth;
import org.mindrot.jbcrypt.BCrypt;
import utils.EmailService;
import utils.ValidationUtils;
import utils.GoogleUtils;
import utils.GoogleUtils.GoogleProfile;
import utils.AuthFilter;
import utils.Constants;

@WebServlet(name = "AuthServlet", urlPatterns = {"/Auth"})
public class AuthController extends HttpServlet {

    private static final long OTP_RESEND_COOLDOWN_MS = 60 * 1000;
    private static final String FORGOT_NOTICE = "Nếu email này đã được đăng ký, mã OTP đã được gửi tới hộp thư của bạn.";

    private final AuthDAO authDAO = new AuthDAO();
    private final Map<String, Integer> otpFail = new ConcurrentHashMap<>();
    private final Map<String, Long> otpLock = new ConcurrentHashMap<>();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "login";
        }

        switch (action) {
            case "register":
                showRegister(request, response);
                break;
            case "forgot":
                forward(request, response, "forgot.jsp");
                break;
            case "otp":
                showOtp(request, response);
                break;
            case "resendOtp":
                resendOtp(request, response);
                break;
            case "changePassword":
                showChangePassword(request, response);
                break;
            default:
                showLogin(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "login";
        }

        switch (action) {
            case "register":
                register(request, response);
                break;
            case "otp":
                verifyOtp(request, response);
                break;
            case "forgot":
                forgot(request, response);
                break;
            case "changePassword":
                changePassword(request, response);
                break;
            case "googleLogin":
                googleLogin(request, response);
                break;     
            default:
                login(request, response);
                break;
        }
    }

    private void showLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (currentUser(request) != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("success") != null) {
            request.setAttribute("success", session.getAttribute("success"));
            session.removeAttribute("success");
        }
        if ("inactive".equals(request.getParameter("reason")) && request.getAttribute("error") == null) {
            request.setAttribute("error", "Tài khoản của bạn đã bị khóa hoặc ngừng hoạt động. Vui lòng liên hệ quản trị viên.");
        }
        if (request.getAttribute("identifier") == null) {
            String remembered = cookieValue(request, "rememberId");
            if (remembered != null) {
                request.setAttribute("identifier", remembered);
            }
        }
        forward(request, response, "login.jsp");
    }

    private void showRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (currentUser(request) != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        forward(request, response, "register.jsp");
    }

    private void showOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("otpCode") == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }
        forward(request, response, "otp.jsp");
    }

    private void showChangePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        boolean resetFlow = session != null && session.getAttribute("resetUserId") != null;
        if (currentUser(request) == null && !resetFlow) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }
        boolean requireOld = false;
        if (!resetFlow) {
            try {
                requireOld = needsOldPassword(currentUser(request));
            } catch (SQLException e) {
                e.printStackTrace();
                requireOld = true; // không đọc được DB thì giữ mặc định an toàn
            }
        }
        request.setAttribute("requireOld", requireOld);
        if (!resetFlow && currentUser(request) != null && currentUser(request).isMustChangePassword()) {
            request.setAttribute("error", "Bạn đang dùng mật khẩu tạm do quản trị viên cấp. Vui lòng đổi mật khẩu để tiếp tục.");
        }
        forward(request, response, "change-password.jsp");
    }


    private void googleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String credential = request.getParameter("credential");
        if (credential == null || credential.isEmpty()) {
            request.setAttribute("error", "Không nhận được thông tin xác thực từ Google.");
            forward(request, response, "login.jsp");
            return;
        }

        GoogleProfile profile = GoogleUtils.verifyToken(credential);
        if (profile == null || profile.getEmail() == null) {
            request.setAttribute("error", "Xác thực Google thất bại. Vui lòng thử lại.");
            forward(request, response, "login.jsp");
            return;
        }

        try {
            Auth user = authDAO.findByEmail(profile.getEmail());
            
            // Nếu người dùng chưa tồn tại, tự động tạo tài khoản Customer mới
            if (user == null) {
                user = new Auth();
                user.setEmail(profile.getEmail());
                // Tự động tạo username từ email (phần trước @)
                String generatedUsername = profile.getEmail().split("@")[0];
                
                // Đảm bảo username không trùng lặp
                int counter = 1;
                String finalUsername = generatedUsername;
                while (authDAO.usernameExists(finalUsername)) {
                    finalUsername = generatedUsername + counter;
                    counter++;
                }
                
                user.setUsername(finalUsername);
                user.setFullName(profile.getName());
                user.setPhone(""); // Trống do Google không trả về phone
                // Cột password NOT NULL nên vẫn lưu một chuỗi ngẫu nhiên không ai biết (không đoán được);
                // password_set = 0 để lần đầu người dùng vào "Thiết lập mật khẩu" mà không cần mật khẩu cũ.
                String randomPassword = java.util.UUID.randomUUID() + "G@" + EmailService.createOtp();
                user.setPassword(BCrypt.hashpw(randomPassword, BCrypt.gensalt()));
                user.setPasswordSet(false);
                
                if (!authDAO.insertCustomer(user)) {
                    request.setAttribute("error", "Lỗi tạo tài khoản từ Google.");
                    forward(request, response, "login.jsp");
                    return;
                }
                // Lấy lại thông tin user từ DB để có userId
                user = authDAO.findByEmail(profile.getEmail());
            }

            if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
                request.setAttribute("error", "Tài khoản không thể sử dụng.");
                forward(request, response, "login.jsp");
                return;
            }

            // Reset failed attempts if any
            if (user.getFailedAttempts() > 0 || user.getLockedUntil() != null) {
                authDAO.resetFailedAttempts(user.getUserId());
            }

            HttpSession old = request.getSession(false);
            if (old != null) {
                old.invalidate();
            }
            HttpSession session = request.getSession(true);
            user.setPassword(null);
            session.setAttribute("user", user);

            response.sendRedirect(request.getContextPath() + (user.isMustChangePassword()
                    ? "/Auth?action=changePassword" : AuthFilter.homeFor(user.getRole())));
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống đang lỗi. Vui lòng thử lại sau.");
            forward(request, response, "login.jsp");
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identifier = trim(request.getParameter("identifier"));
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");
        request.setAttribute("identifier", identifier);

        if (ValidationUtils.isNullOrBlank(identifier) || ValidationUtils.isNullOrBlank(password)) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            forward(request, response, "login.jsp");
            return;
        }

        try {
            Auth user = authDAO.findByUsernameOrEmail(identifier);
            if (user == null) {
                request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
                forward(request, response, "login.jsp");
                return;
            }

            if (user.getLockedUntil() != null && user.getLockedUntil().getTime() > System.currentTimeMillis()) {
                request.setAttribute("error", "Tài khoản tạm khóa 15 phút do nhập sai quá 5 lần.");
                forward(request, response, "login.jsp");
                return;
            }

            // Hết thời gian khóa: bắt đầu đếm lại số lần sai từ 0
            if (user.getLockedUntil() != null) {
                authDAO.resetFailedAttempts(user.getUserId());
                user.setFailedAttempts(0);
                user.setLockedUntil(null);
            }

            if (!BCrypt.checkpw(password, user.getPassword())) {
                int fail = user.getFailedAttempts() + 1;
                Timestamp lock = null;
                if (fail >= 5) {
                    lock = new Timestamp(System.currentTimeMillis() + 15 * 60 * 1000);
                    request.setAttribute("error", "Tài khoản tạm khóa 15 phút do nhập sai quá 5 lần.");
                } else {
                    request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
                }
                authDAO.recordFailedAttempt(user.getUserId(), fail, lock);
                forward(request, response, "login.jsp");
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
                request.setAttribute("error", "Tài khoản không thể sử dụng.");
                forward(request, response, "login.jsp");
                return;
            }

            if (user.getFailedAttempts() > 0 || user.getLockedUntil() != null) {
                authDAO.resetFailedAttempts(user.getUserId());
            }

            HttpSession old = request.getSession(false);
            if (old != null) {
                old.invalidate();
            }
            HttpSession session = request.getSession(true);
            user.setPassword(null);
            session.setAttribute("user", user);

            Cookie cookie = new Cookie("rememberId", identifier);
            cookie.setMaxAge("on".equals(rememberMe) ? 7 * 24 * 60 * 60 : 0);
            cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            response.addCookie(cookie);

            response.sendRedirect(request.getContextPath() + (user.isMustChangePassword()
                    ? "/Auth?action=changePassword" : AuthFilter.homeFor(user.getRole())));
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống không thể xác thực. Vui lòng thử lại sau.");
            forward(request, response, "login.jsp");
        }
    }

    private void register(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = trim(request.getParameter("fullName"));
        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");
        String terms = request.getParameter("terms");

        request.setAttribute("fullName", fullName);
        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        if (ValidationUtils.isNullOrBlank(fullName) || ValidationUtils.isNullOrBlank(username) || ValidationUtils.isNullOrBlank(email)
                || ValidationUtils.isNullOrBlank(phone) || ValidationUtils.isNullOrBlank(password) || ValidationUtils.isNullOrBlank(confirm)) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin đăng ký.");
            forward(request, response, "register.jsp");
            return;
        }
        if (!ValidationUtils.isUsername(username)) {
            request.setAttribute("error", "Username chỉ gồm chữ, số, dấu chấm hoặc gạch dưới (4-50 ký tự).");
            forward(request, response, "register.jsp");
            return;
        }
        if (!ValidationUtils.isEmail(email)) {
            request.setAttribute("error", "Email không đúng định dạng.");
            forward(request, response, "register.jsp");
            return;
        }
        if (!ValidationUtils.isPhone(phone)) {
            request.setAttribute("error", "Số điện thoại không hợp lệ.");
            forward(request, response, "register.jsp");
            return;
        }
        if (!ValidationUtils.isStrongPassword(password)) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.");
            forward(request, response, "register.jsp");
            return;
        }
        if (!password.equals(confirm)) {
            request.setAttribute("error", "Xác nhận mật khẩu không khớp.");
            forward(request, response, "register.jsp");
            return;
        }
        if (!"on".equals(terms)) {
            request.setAttribute("error", "Vui lòng đồng ý Điều khoản và Chính sách bảo mật.");
            forward(request, response, "register.jsp");
            return;
        }

        try {
            if (authDAO.usernameExists(username) || authDAO.emailExists(email) || authDAO.phoneExists(phone)) {
                request.setAttribute("error", "Email hoặc số điện thoại đã được đăng ký. Hãy đăng nhập hoặc dùng Quên mật khẩu.");
                forward(request, response, "register.jsp");
                return;
            }

            Auth pending = new Auth();
            pending.setFullName(fullName);
            pending.setUsername(username);
            pending.setEmail(email);
            pending.setPhone(phone);
            pending.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
            pending.setRole("Customer");
            pending.setStatus("ACTIVE");

            if (!startOtp(request, "register", pending, email, true)) {
                request.setAttribute("error", "Không gửi được OTP. Vui lòng thử lại sau.");
                forward(request, response, "register.jsp");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/Auth?action=otp");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Không lưu được thông tin. Vui lòng thử lại sau.");
            forward(request, response, "register.jsp");
        }
    }

    private void forgot(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = trim(request.getParameter("email"));
        request.setAttribute("email", email);

        if (!ValidationUtils.isEmail(email)) {
            request.setAttribute("error", "Vui lòng nhập email đã đăng ký.");
            forward(request, response, "forgot.jsp");
            return;
        }

        try {
            // Không tiết lộ email có tồn tại hay không: luôn chuyển sang trang nhập OTP với
            // cùng một thông báo. Email chưa đăng ký thì không gửi mail và OTP không bao giờ khớp.
            Auth user = authDAO.findByEmail(email);
            boolean exists = user != null;
            if (!exists) {
                user = new Auth();
                user.setEmail(email);
            }
            if (!startOtp(request, "forgot", user, email, exists)) {
                request.setAttribute("error", "Không gửi được OTP. Vui lòng thử lại sau.");
                forward(request, response, "forgot.jsp");
                return;
            }
            request.getSession().setAttribute("otpNotice", FORGOT_NOTICE);
            response.sendRedirect(request.getContextPath() + "/Auth?action=otp");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống đang lỗi. Vui lòng thử lại sau.");
            forward(request, response, "forgot.jsp");
        }
    }

    private void verifyOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("otpCode") == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }

        String email = (String) session.getAttribute("otpEmail");
        String key = email == null ? "otp" : email.toLowerCase();
        if (isLocked(otpLock, key)) {
            request.setAttribute("error", "Chức năng OTP bị khóa 1 giờ do nhập sai quá 5 lần.");
            forward(request, response, "otp.jsp");
            return;
        }

        String input = trim(request.getParameter("otp"));
        Long expireAt = (Long) session.getAttribute("otpExpire");

        if (input == null || !input.matches("\\d{6}")) {
            request.setAttribute("error", "OTP gồm 6 chữ số.");
            forward(request, response, "otp.jsp");
            return;
        }
        if (expireAt == null || System.currentTimeMillis() > expireAt) {
            request.setAttribute("error", "OTP đã hết hạn. Vui lòng gửi lại mã mới.");
            forward(request, response, "otp.jsp");
            return;
        }
        boolean fakeOtp = Boolean.TRUE.equals(session.getAttribute("otpFake"));
        if (fakeOtp || !input.equals(session.getAttribute("otpCode"))) {
            int fail = otpFail.getOrDefault(key, 0) + 1;
            otpFail.put(key, fail);
            if (fail > 5) {
                otpLock.put(key, System.currentTimeMillis() + 60 * 60 * 1000);
                request.setAttribute("error", "Chức năng OTP bị khóa 1 giờ do nhập sai quá 5 lần.");
            } else {
                request.setAttribute("error", "OTP không đúng.");
            }
            forward(request, response, "otp.jsp");
            return;
        }

        otpFail.remove(key);
        otpLock.remove(key);
        String purpose = (String) session.getAttribute("otpPurpose");
        try {
            if ("register".equals(purpose)) {
                Auth pending = (Auth) session.getAttribute("pendingUser");
                if (pending == null || !authDAO.insertCustomer(pending)) {
                    request.setAttribute("error", "Không tạo được tài khoản. Vui lòng thử lại.");
                    forward(request, response, "otp.jsp");
                    return;
                }
                clearOtp(session);
                request.getSession(true).setAttribute("success", "Đăng ký thành công. Vui lòng đăng nhập.");
                response.sendRedirect(request.getContextPath() + "/Auth?action=login");
                return;
            }
            if ("forgot".equals(purpose)) {
                Auth user = (Auth) session.getAttribute("pendingUser");
                session.setAttribute("resetUserId", user.getUserId());
                clearOtp(session);
                response.sendRedirect(request.getContextPath() + "/Auth?action=changePassword");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Không lưu được thông tin. Vui lòng thử lại sau.");
            forward(request, response, "otp.jsp");
        }
    }

    private void resendOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pendingUser") == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }
        // Chỉ cho gửi lại sau 60 giây để tránh spam email
        Long sentAt = (Long) session.getAttribute("otpSentAt");
        if (sentAt == null || System.currentTimeMillis() - sentAt >= OTP_RESEND_COOLDOWN_MS) {
            Auth pending = (Auth) session.getAttribute("pendingUser");
            String purpose = (String) session.getAttribute("otpPurpose");
            startOtp(request, purpose, pending, pending.getEmail(),
                    !Boolean.TRUE.equals(session.getAttribute("otpFake")));
        }
        response.sendRedirect(request.getContextPath() + "/Auth?action=otp");
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Auth loginUser = currentUser(request);
        Integer resetUserId = session == null ? null : (Integer) session.getAttribute("resetUserId");
        boolean resetFlow = resetUserId != null;

        if (loginUser == null && !resetFlow) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return;
        }

        // Tài khoản Google chưa tự đặt mật khẩu: thiết lập lần đầu, không hỏi mật khẩu hiện tại
        boolean requireOld;
        try {
            requireOld = !resetFlow && needsOldPassword(loginUser);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("requireOld", true);
            request.setAttribute("error", "Hệ thống đang lỗi. Vui lòng thử lại sau.");
            forward(request, response, "change-password.jsp");
            return;
        }
        request.setAttribute("requireOld", requireOld);
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        if (ValidationUtils.isNullOrBlank(newPassword) || ValidationUtils.isNullOrBlank(confirm) || (requireOld && ValidationUtils.isNullOrBlank(oldPassword))) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin mật khẩu.");
            forward(request, response, "change-password.jsp");
            return;
        }
        if (!ValidationUtils.isStrongPassword(newPassword)) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.");
            forward(request, response, "change-password.jsp");
            return;
        }
        if (!newPassword.equals(confirm)) {
            request.setAttribute("error", "Xác nhận mật khẩu không khớp.");
            forward(request, response, "change-password.jsp");
            return;
        }

        try {
            int userId = resetFlow ? resetUserId : loginUser.getUserId();
            Auth dbUser = authDAO.findById(userId);
            if (dbUser == null) {
                request.setAttribute("error", "Không tìm thấy tài khoản.");
                forward(request, response, "change-password.jsp");
                return;
            }
            if (requireOld && !BCrypt.checkpw(oldPassword, dbUser.getPassword())) {
                request.setAttribute("error", "Mật khẩu hiện tại không đúng.");
                forward(request, response, "change-password.jsp");
                return;
            }
            if (dbUser.isPasswordSet() && BCrypt.checkpw(newPassword, dbUser.getPassword())) {
                request.setAttribute("error", "Mật khẩu mới không được trùng mật khẩu hiện tại.");
                forward(request, response, "change-password.jsp");
                return;
            }
            if (!authDAO.updatePassword(userId, BCrypt.hashpw(newPassword, BCrypt.gensalt()))) {
                request.setAttribute("error", "Không cập nhật được mật khẩu. Vui lòng thử lại.");
                forward(request, response, "change-password.jsp");
                return;
            }
            if (resetFlow) {
                session.removeAttribute("resetUserId");
                session.setAttribute("success", "Đổi mật khẩu thành công. Vui lòng đăng nhập.");
                response.sendRedirect(request.getContextPath() + "/Auth?action=login");
                return;
            }
            boolean firstTime = !dbUser.isPasswordSet();
            loginUser.setPasswordSet(true);
            if (loginUser.isMustChangePassword()) {
                loginUser.setMustChangePassword(false);
                response.sendRedirect(request.getContextPath() + AuthFilter.homeFor(loginUser.getRole()));
                return;
            }
            // Từ giờ trang hiển thị dạng "Đổi mật khẩu" (có ô mật khẩu hiện tại)
            request.setAttribute("requireOld", true);
            request.setAttribute("success", firstTime
                    ? "Thiết lập mật khẩu thành công. Từ giờ bạn có thể đăng nhập bằng email hoặc username và mật khẩu này, ngoài đăng nhập Google."
                    : "Đổi mật khẩu thành công.");
            forward(request, response, "change-password.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Hệ thống đang lỗi. Vui lòng thử lại sau.");
            forward(request, response, "change-password.jsp");
        }
    } 
    /** @param send false: tạo phiên OTP giả cho email chưa đăng ký (không gửi mail, không bao giờ khớp) */
    private boolean startOtp(HttpServletRequest request, String purpose, Auth pending, String email, boolean send) {
        String key = email.toLowerCase();
        if (isLocked(otpLock, key)) {
            return false;
        }
        String otp = EmailService.createOtp();
        if (send && !EmailService.sendOtp(email, otp)) {
            return false;
        }
        HttpSession session = request.getSession(true);
        session.setAttribute("otpCode", otp);
        session.setAttribute("otpExpire", System.currentTimeMillis() + 3 * 60 * 1000);
        session.setAttribute("otpSentAt", System.currentTimeMillis());
        session.setAttribute("otpPurpose", purpose);
        session.setAttribute("otpEmail", email);
        session.setAttribute("pendingUser", pending);
        session.setAttribute("otpFake", !send);
        return true;
    }

    private void clearOtp(HttpSession session) {
        session.removeAttribute("otpCode");
        session.removeAttribute("otpExpire");
        session.removeAttribute("otpPurpose");
        session.removeAttribute("otpEmail");
        session.removeAttribute("pendingUser");
        session.removeAttribute("otpSentAt");
        session.removeAttribute("otpFake");
        session.removeAttribute("otpNotice");
    }

    /**
     * Đổi mật khẩu khi đang đăng nhập thì phải nhập mật khẩu hiện tại, trừ tài khoản
     * Google chưa từng tự đặt mật khẩu (đọc từ DB, không tin giá trị cũ trong session).
     */
    private boolean needsOldPassword(Auth loginUser) throws SQLException {
        if (loginUser == null) {
            return false;
        }
        Auth dbUser = authDAO.findById(loginUser.getUserId());
        boolean passwordSet = dbUser == null || dbUser.isPasswordSet();
        loginUser.setPasswordSet(passwordSet);
        return passwordSet;
    }

    private Auth currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (Auth) session.getAttribute("user");
    }

    private boolean isLocked(Map<String, Long> lockMap, String key) {
        Long until = lockMap.get(key);
        if (until == null) {
            return false;
        }
        if (System.currentTimeMillis() > until) {
            lockMap.remove(key);
            return false;
        }
        return true;
    }

    private String cookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return null;
        }
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String page)
            throws ServletException, IOException {
        String folder = "login/";
        if ("change-password.jsp".equals(page)) {
            // Đổi mật khẩu khi đã đăng nhập dùng giao diện riêng của Customer/Organizer/Staff;
            // luồng quên mật khẩu và các role khác dùng trang chung ở login/
            HttpSession session = request.getSession(false);
            boolean resetFlow = session != null && session.getAttribute("resetUserId") != null;
            Auth user = currentUser(request);
            if (!resetFlow && user != null) {
                if (Constants.ROLE_CUSTOMER.equalsIgnoreCase(user.getRole())) {
                    folder = "customer/";
                } else if (Constants.ROLE_ORGANIZER.equalsIgnoreCase(user.getRole())) {
                    folder = "organizer/";
                } else if (Constants.ROLE_STAFF.equalsIgnoreCase(user.getRole())) {
                    folder = "staff/";
                }
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/" + folder + page).forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Auth Controller";
    }
}
