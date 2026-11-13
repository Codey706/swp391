package utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.Auth;

public final class SessionUtils {

    private SessionUtils() {
    }

    /**
     * Người dùng đang đăng nhập, hoặc null. Với các URL nằm trong AuthFilter
     * (/admin, /organizer, /staff, /customer, /booking) luôn khác null và đúng role.
     */
    public static Auth currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object user = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        return user instanceof Auth ? (Auth) user : null;
    }

    /** Chuyển flash message (lưu trong session qua một lần redirect) sang request để JSP hiển thị một lần. */
    public static void moveFlash(HttpServletRequest request, String... keys) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        for (String key : keys) {
            Object value = session.getAttribute(key);
            if (value != null) {
                request.setAttribute(key, value);
                session.removeAttribute(key);
            }
        }
    }
}
