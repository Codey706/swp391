package utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * CSRF token dùng chung cho các form POST mới: một token mỗi session,
 * JSP gửi lại qua input ẩn tên "csrfToken".
 */
public final class CsrfUtils {

    public static final String PARAM = "csrfToken";
    private static final String SESSION_KEY = "ltmCsrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();

    private CsrfUtils() {
    }

    /** Lấy (hoặc tạo) token và gán vào request attribute "csrfToken" cho JSP. */
    public static String expose(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object token = session.getAttribute(SESSION_KEY);
        if (!(token instanceof String)) {
            byte[] bytes = new byte[32];
            RANDOM.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(SESSION_KEY, token);
        }
        request.setAttribute(PARAM, token);
        return (String) token;
    }

    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(SESSION_KEY);
        String actual = request.getParameter(PARAM);
        return expected instanceof String && actual != null
                && MessageDigest.isEqual(((String) expected).getBytes(StandardCharsets.UTF_8),
                        actual.getBytes(StandardCharsets.UTF_8));
    }
}
