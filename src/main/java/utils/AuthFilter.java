package utils;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import dao.AuthDAO;
import model.Auth;

/**
 * Bắt buộc đăng nhập và đúng role cho từng khu vực:
 * /admin -> Admin, /organizer -> Organizer, /staff -> Staff,
 * /customer, hồ sơ khách hàng và các bước đặt vé -> Customer.
 * Đăng nhập sai role thì chuyển về trang chủ của role đó.
 */
@WebFilter(urlPatterns = {
    "/admin", "/admin/*",
    "/organizer/*",
    "/staff", "/staff/*",
    "/customer/*",
    "/CustomerProfileController",
    "/UpdateCustomerProfileController",
    "/booking/select-ticket", "/booking/customer-info", "/booking/payment", "/booking/voucher-preview"
})
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());

    private final AuthDAO authDAO = new AuthDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);

        if (!(sessionUser instanceof Auth)) {
            resp.sendRedirect(req.getContextPath() + "/Auth?action=login");
            return;
        }

        Auth user = (Auth) sessionUser;

        // Đối chiếu DB mỗi request: tài khoản bị Admin khóa (INACTIVE) bị đăng xuất ngay,
        // role thay đổi cũng có hiệu lực ngay mà không cần đăng nhập lại.
        Auth current;
        try {
            current = authDAO.findById(user.getUserId());
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot verify account status, userId=" + user.getUserId(), e);
            resp.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            return;
        }
        if (current == null || !Constants.STATUS_ACTIVE.equalsIgnoreCase(current.getStatus())) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/Auth?action=login&reason=inactive");
            return;
        }
        user.setRole(current.getRole());
        user.setStatus(current.getStatus());
        user.setMustChangePassword(current.isMustChangePassword());

        // Tài khoản Admin tạo với mật khẩu tạm: phải đổi mật khẩu trước khi dùng hệ thống
        if (current.isMustChangePassword()) {
            resp.sendRedirect(req.getContextPath() + "/Auth?action=changePassword");
            return;
        }

        String requiredRole = requiredRole(req.getServletPath());
        if (requiredRole != null && !requiredRole.equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + homeFor(user.getRole()));
            return;
        }

        // Trang cần đăng nhập: không cho trình duyệt cache để nút Back sau khi logout không hiện lại dữ liệu
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        chain.doFilter(request, response);
    }

    private static String requiredRole(String path) {
        if (path.equals("/admin") || path.startsWith("/admin/")) {
            return Constants.ROLE_ADMIN;
        }
        if (path.startsWith("/organizer/")) {
            return Constants.ROLE_ORGANIZER;
        }
        if (path.equals("/staff") || path.startsWith("/staff/")) {
            return Constants.ROLE_STAFF;
        }
        if (path.startsWith("/customer/") || path.startsWith("/booking/")
                || path.equals("/CustomerProfileController")
                || path.equals("/UpdateCustomerProfileController")) {
            return Constants.ROLE_CUSTOMER;
        }
        return null;
    }

    /** Trang mặc định sau khi đăng nhập của từng role. */
    public static String homeFor(String role) {
        if (Constants.ROLE_ADMIN.equalsIgnoreCase(role)) {
            return "/admin";
        }
        if (Constants.ROLE_STAFF.equalsIgnoreCase(role)) {
            return "/staff";
        }
        if (Constants.ROLE_ORGANIZER.equalsIgnoreCase(role)) {
            return "/organizer/event/list";
        }
        return "/home";
    }
}
