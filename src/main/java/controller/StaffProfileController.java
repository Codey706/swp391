package controller;

import dao.StaffProfileDAO;
import dao.UserDAO;
import model.Auth;
import model.User;
import utils.Constants;
import utils.DateTimeUtils;
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

/**
 * Manage My Staff Profile.
 * GET  /staff/profile : xem hồ sơ của chính Staff đang đăng nhập.
 * POST /staff/profile : cập nhật họ tên, email, số điện thoại, địa chỉ.
 *
 * Staff ID luôn lấy từ session, không nhận từ browser. Không cho sửa
 * username, role, status, password.
 */
@WebServlet(name = "StaffProfileController", urlPatterns = {"/staff/profile"})
public class StaffProfileController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StaffProfileController.class.getName());

    private static final String PROFILE_VIEW = "/WEB-INF/views/staff/profile.jsp";
    private static final String PATH_PROFILE = "/staff/profile";
    private static final String PATH_LOGIN = "/Auth?action=login";

    // Mã lỗi SQL Server khi vi phạm UNIQUE constraint / unique index
    private static final int SQL_ERROR_UNIQUE_CONSTRAINT = 2627;
    private static final int SQL_ERROR_UNIQUE_INDEX = 2601;

    private static final String ERROR_GENERIC = "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.";
    private static final String ERROR_CHECK_FIELDS = "Vui lòng kiểm tra lại các thông tin được đánh dấu.";

    private final UserDAO userDAO = new UserDAO();
    private final StaffProfileDAO staffProfileDAO = new StaffProfileDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    // ------------------------------------------------------------------ GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User staff = loadAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }

        moveFlashMessage(request);
        showProfile(request, response, staff, staff, new LinkedHashMap<>());
    }

    // ------------------------------------------------------------------ POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User staff = loadAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }

        if (!isValidCsrfToken(request, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        User submitted = buildSubmittedUser(request, staff.getUserId());
        Map<String, String> errors = validate(submitted);

        if (!errors.isEmpty()) {
            request.setAttribute("errorMessage", errors.containsKey("system") ? ERROR_GENERIC : ERROR_CHECK_FIELDS);
            showProfile(request, response, staff, submitted, errors);
            return;
        }

        try {
            if (!userDAO.updateStaffProfile(submitted)) {
                request.setAttribute("errorMessage", "Không thể cập nhật hồ sơ. Tài khoản của bạn có thể không còn hoạt động.");
                showProfile(request, response, staff, submitted, errors);
                return;
            }
        } catch (SQLException e) {
            if (isDuplicateKeyError(e)) {
                // Có người khác vừa dùng giá trị này giữa lúc kiểm tra và lúc lưu
                errors.put("email", "Email hoặc số điện thoại đã được sử dụng bởi tài khoản khác.");
                request.setAttribute("errorMessage", ERROR_CHECK_FIELDS);
            } else {
                LOGGER.log(Level.SEVERE, "Cannot update staff profile, userId=" + staff.getUserId(), e);
                request.setAttribute("errorMessage", ERROR_GENERIC);
            }
            showProfile(request, response, staff, submitted, errors);
            return;
        }

        refreshSessionUser(request, submitted);

        // Post/Redirect/Get: tránh gửi lại form khi người dùng F5
        request.getSession().setAttribute(Constants.SESSION_STAFF_PROFILE_SUCCESS, "Cập nhật hồ sơ thành công.");
        response.sendRedirect(request.getContextPath() + PATH_PROFILE);
    }

    // ------------------------------------------------------------------ Xác thực / phân quyền
    /**
     * Yêu cầu đã đăng nhập, đúng role Staff và tài khoản còn ACTIVE. Dữ liệu
     * luôn được đọc lại từ database bằng userId trong session.
     *
     * @return hồ sơ Staff từ database, hoặc null nếu đã redirect/gửi lỗi.
     */
    private User loadAuthenticatedStaff(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);

        if (!(sessionUser instanceof Auth)) {
            response.sendRedirect(request.getContextPath() + PATH_LOGIN);
            return null;
        }

        Auth authUser = (Auth) sessionUser;
        if (!Constants.ROLE_STAFF.equalsIgnoreCase(authUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        try {
            User staff = userDAO.getUserById(authUser.getUserId());
            if (staff == null
                    || !Constants.ROLE_STAFF.equalsIgnoreCase(staff.getRole())
                    || !Constants.STATUS_ACTIVE.equalsIgnoreCase(staff.getStatus())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return null;
            }
            return staff;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load staff profile, userId=" + authUser.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return null;
        }
    }

    // ------------------------------------------------------------------ CSRF
    private String getOrCreateCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object token = session.getAttribute(Constants.SESSION_STAFF_PROFILE_CSRF);
        if (token instanceof String) {
            return (String) token;
        }
        byte[] randomBytes = new byte[32];
        secureRandom.nextBytes(randomBytes);
        String newToken = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        session.setAttribute(Constants.SESSION_STAFF_PROFILE_CSRF, newToken);
        return newToken;
    }

    private boolean isValidCsrfToken(HttpServletRequest request, String actual) {
        HttpSession session = request.getSession(false);
        Object expected = session == null ? null : session.getAttribute(Constants.SESSION_STAFF_PROFILE_CSRF);
        if (!(expected instanceof String) || actual == null) {
            return false;
        }
        return MessageDigest.isEqual(
                ((String) expected).getBytes(StandardCharsets.UTF_8),
                actual.getBytes(StandardCharsets.UTF_8));
    }

    // ------------------------------------------------------------------ Đọc form
    /**
     * Chỉ đọc các trường được phép sửa. userId lấy từ session (qua hồ sơ đã
     * nạp); username/role/status/password không bao giờ đọc từ form.
     */
    private User buildSubmittedUser(HttpServletRequest request, int staffId) {
        User submitted = new User();
        submitted.setUserId(staffId);
        submitted.setFullName(trimToEmpty(request.getParameter("fullName")));
        submitted.setEmail(trimToEmpty(request.getParameter("email")));
        // Chấp nhận "0909 123 456", "0909.123.456", "0909-123-456" -> lưu dạng chỉ có số
        submitted.setPhone(trimToEmpty(request.getParameter("phone")).replaceAll("[\\s.\\-]", ""));
        String address = trimToEmpty(request.getParameter("address"));
        submitted.setAddress(address.isEmpty() ? null : address);
        return submitted;
    }

    // ------------------------------------------------------------------ Kiểm tra form
    /**
     * @return map field -> thông báo lỗi; rỗng nếu hợp lệ.
     */
    private Map<String, String> validate(User user) {
        Map<String, String> errors = new LinkedHashMap<>();

        // Họ và tên
        if (ValidationUtils.isNullOrBlank(user.getFullName())) {
            errors.put("fullName", "Họ và tên không được để trống.");
        } else if (!ValidationUtils.isLengthBetween(user.getFullName(),
                Constants.PROFILE_FULL_NAME_MIN_LENGTH, Constants.PROFILE_FULL_NAME_MAX_LENGTH)) {
            errors.put("fullName", "Họ và tên phải từ " + Constants.PROFILE_FULL_NAME_MIN_LENGTH
                    + " đến " + Constants.PROFILE_FULL_NAME_MAX_LENGTH + " ký tự.");
        }

        // Email
        if (ValidationUtils.isNullOrBlank(user.getEmail())) {
            errors.put("email", "Email không được để trống.");
        } else if (user.getEmail().length() > Constants.PROFILE_EMAIL_MAX_LENGTH) {
            errors.put("email", "Email tối đa " + Constants.PROFILE_EMAIL_MAX_LENGTH + " ký tự.");
        } else if (!ValidationUtils.isEmail(user.getEmail())) {
            errors.put("email", "Email không đúng định dạng.");
        }

        // Số điện thoại
        if (ValidationUtils.isNullOrBlank(user.getPhone())) {
            errors.put("phone", "Số điện thoại không được để trống.");
        } else if (!ValidationUtils.isPhone(user.getPhone())) {
            errors.put("phone", "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).");
        }

        // Địa chỉ (không bắt buộc)
        if (user.getAddress() != null && user.getAddress().length() > Constants.PROFILE_ADDRESS_MAX_LENGTH) {
            errors.put("address", "Địa chỉ tối đa " + Constants.PROFILE_ADDRESS_MAX_LENGTH + " ký tự.");
        }

        // Trùng email / số điện thoại với tài khoản khác - chỉ kiểm tra khi định dạng đã hợp lệ
        try {
            if (!errors.containsKey("email") && userDAO.existsEmailOfOtherUser(user.getEmail(), user.getUserId())) {
                errors.put("email", "Email đã được sử dụng bởi tài khoản khác.");
            }
            if (!errors.containsKey("phone") && userDAO.existsPhoneOfOtherUser(user.getPhone(), user.getUserId())) {
                errors.put("phone", "Số điện thoại đã được sử dụng bởi tài khoản khác.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot check duplicate profile data, userId=" + user.getUserId(), e);
            errors.put("system", ERROR_GENERIC);
        }

        return errors;
    }

    private boolean isDuplicateKeyError(SQLException e) {
        return e.getErrorCode() == SQL_ERROR_UNIQUE_CONSTRAINT || e.getErrorCode() == SQL_ERROR_UNIQUE_INDEX;
    }

    // ------------------------------------------------------------------ Hiển thị
    /**
     * @param staff hồ sơ đã lưu trong database (nguồn của username, role, status)
     * @param form giá trị hiển thị trong form (bằng staff khi mở trang)
     */
    private void showProfile(HttpServletRequest request, HttpServletResponse response,
            User staff, User form, Map<String, String> errors) throws ServletException, IOException {
        try {
            int[] assignments = staffProfileDAO.getAssignmentSummary(staff.getUserId());
            int checkedIn = staffProfileDAO.countCheckedInTickets(staff.getUserId());

            request.setAttribute("staff", staff);
            request.setAttribute("form", form);
            request.setAttribute("errors", errors);
            request.setAttribute("assignedEvents", assignments[0]);
            request.setAttribute("upcomingEvents", assignments[1]);
            request.setAttribute("checkedInTickets", checkedIn);
            request.setAttribute("memberSince", formatDate(staff));
            request.setAttribute("csrfToken", getOrCreateCsrfToken(request));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load staff profile page data, userId=" + staff.getUserId(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return;
        }
        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    // Ngày tạo tài khoản dạng dd/MM/yyyy ("" nếu chưa có dữ liệu)
    private String formatDate(User staff) {
        String dateTime = DateTimeUtils.formatDateTime(staff.getCreatedAt());
        return dateTime.length() >= 10 ? dateTime.substring(0, 10) : dateTime;
    }

    // ------------------------------------------------------------------ Tiện ích
    /**
     * Đồng bộ tên/email/điện thoại/địa chỉ trong session để sidebar hiển thị
     * đúng ngay sau khi lưu. Không đụng tới role, status, password.
     */
    private void refreshSessionUser(HttpServletRequest request, User updated) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        if (sessionUser instanceof Auth) {
            Auth authUser = (Auth) sessionUser;
            authUser.setFullName(updated.getFullName());
            authUser.setEmail(updated.getEmail());
            authUser.setPhone(updated.getPhone());
            authUser.setAddress(updated.getAddress());
        }
    }

    // Chuyển thông báo flash trong session sang request để JSP hiển thị một lần
    private void moveFlashMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(Constants.SESSION_STAFF_PROFILE_SUCCESS);
        if (message != null) {
            request.setAttribute("successMessage", message);
            session.removeAttribute(Constants.SESSION_STAFF_PROFILE_SUCCESS);
        }
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
