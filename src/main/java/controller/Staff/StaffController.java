package controller.Staff;

import dao.UserDAO;
import model.Auth;
import model.User;
import utils.Constants;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Lớp cha cho các trang Staff: yêu cầu đã đăng nhập, đúng role Staff và tài khoản còn
 * ACTIVE (cùng quy tắc với StaffProfileController). Staff ID chỉ lấy từ session.
 */
public abstract class StaffController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StaffController.class.getName());
    protected static final String ERROR_GENERIC = "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.";

    private final UserDAO userDAO = new UserDAO();

    /**
     * @return Auth của staff đang đăng nhập, hoặc null nếu đã redirect / gửi lỗi.
     */
    protected Auth getAuthenticatedStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        if (!(sessionUser instanceof Auth)) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return null;
        }
        Auth auth = (Auth) sessionUser;
        if (!Constants.ROLE_STAFF.equalsIgnoreCase(auth.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        try {
            User staff = userDAO.getUserById(auth.getUserId());
            if (staff == null
                    || !Constants.ROLE_STAFF.equalsIgnoreCase(staff.getRole())
                    || !Constants.STATUS_ACTIVE.equalsIgnoreCase(staff.getStatus())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return null;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load staff, userId=" + auth.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return null;
        }
        return auth;
    }
}
