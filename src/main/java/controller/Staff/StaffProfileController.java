package controller.Staff;

import dao.StaffProfileDAO;
import dao.UserDAO;
import model.Auth;
import model.User;
import utils.Constants;
import utils.CsrfUtils;
import utils.DBContext;
import utils.DateTimeUtils;
import utils.SessionUtils;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Manage My Staff Profile.
 * GET  /staff/profile : xem hồ sơ của chính Staff đang đăng nhập.
 * POST /staff/profile : cập nhật họ tên, email, số điện thoại, địa chỉ.
 *
 * Staff ID luôn lấy từ session, không nhận từ browser. Không cho sửa
 * username, role, status, password.
 */
@WebServlet(name = "StaffProfileController", urlPatterns = {"/staff/profile"})
public class StaffProfileController extends StaffController {

    private static final String PROFILE_VIEW = "/WEB-INF/views/staff/profile.jsp";
    private static final String PATH_PROFILE = "/staff/profile";
    private static final String ERROR_CHECK_FIELDS = "Vui lòng kiểm tra lại các thông tin được đánh dấu.";

    private final UserDAO userDAO = new UserDAO();
    private final StaffProfileDAO staffProfileDAO = new StaffProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            User staff = userDAO.getUserById(currentStaff(request).getUserId());
            SessionUtils.moveFlash(request, "successMessage");
            showProfile(request, response, staff, staff, new LinkedHashMap<>());
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
            User staff = userDAO.getUserById(currentStaff(request).getUserId());
            User submitted = buildSubmittedUser(request, staff.getUserId());
            Map<String, String> errors = validate(submitted);
            if (errors.isEmpty() && !save(submitted, errors)) {
                request.setAttribute("errorMessage", "Không thể cập nhật hồ sơ. Tài khoản của bạn có thể không còn hoạt động.");
                showProfile(request, response, staff, submitted, errors);
                return;
            }
            if (!errors.isEmpty()) {
                request.setAttribute("errorMessage", ERROR_CHECK_FIELDS);
                showProfile(request, response, staff, submitted, errors);
                return;
            }
            refreshSessionUser(request, submitted);
            // Post/Redirect/Get: tránh gửi lại form khi người dùng F5
            request.getSession().setAttribute("successMessage", "Cập nhật hồ sơ thành công.");
            response.sendRedirect(request.getContextPath() + PATH_PROFILE);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /**
     * @return false nếu tài khoản không còn hoạt động. Email/SĐT vừa bị người khác dùng
     * (giữa lúc kiểm tra và lúc lưu) thì đưa lỗi vào errors.
     */
    private boolean save(User submitted, Map<String, String> errors) throws SQLException {
        try {
            return userDAO.updateStaffProfile(submitted);
        } catch (SQLException e) {
            if (!DBContext.isDuplicateKey(e)) {
                throw e;
            }
            errors.put("email", "Email hoặc số điện thoại đã được sử dụng bởi tài khoản khác.");
            return true;
        }
    }

    // ------------------------------------------------------------------ Đọc form
    /**
     * Chỉ đọc các trường được phép sửa. userId lấy từ session;
     * username/role/status/password không bao giờ đọc từ form.
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
    /** @return map field -> thông báo lỗi; rỗng nếu hợp lệ. */
    private Map<String, String> validate(User user) throws SQLException {
        Map<String, String> errors = new LinkedHashMap<>();

        if (ValidationUtils.isNullOrBlank(user.getFullName())) {
            errors.put("fullName", "Họ và tên không được để trống.");
        } else if (!ValidationUtils.isLengthBetween(user.getFullName(),
                Constants.PROFILE_FULL_NAME_MIN_LENGTH, Constants.PROFILE_FULL_NAME_MAX_LENGTH)) {
            errors.put("fullName", "Họ và tên phải từ " + Constants.PROFILE_FULL_NAME_MIN_LENGTH
                    + " đến " + Constants.PROFILE_FULL_NAME_MAX_LENGTH + " ký tự.");
        }

        if (ValidationUtils.isNullOrBlank(user.getEmail())) {
            errors.put("email", "Email không được để trống.");
        } else if (user.getEmail().length() > Constants.PROFILE_EMAIL_MAX_LENGTH) {
            errors.put("email", "Email tối đa " + Constants.PROFILE_EMAIL_MAX_LENGTH + " ký tự.");
        } else if (!ValidationUtils.isEmail(user.getEmail())) {
            errors.put("email", "Email không đúng định dạng.");
        }

        if (ValidationUtils.isNullOrBlank(user.getPhone())) {
            errors.put("phone", "Số điện thoại không được để trống.");
        } else if (!ValidationUtils.isPhone(user.getPhone())) {
            errors.put("phone", "Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).");
        }

        // Địa chỉ không bắt buộc
        if (user.getAddress() != null && user.getAddress().length() > Constants.PROFILE_ADDRESS_MAX_LENGTH) {
            errors.put("address", "Địa chỉ tối đa " + Constants.PROFILE_ADDRESS_MAX_LENGTH + " ký tự.");
        }

        // Trùng email / số điện thoại với tài khoản khác - chỉ kiểm tra khi định dạng đã hợp lệ
        if (!errors.containsKey("email") && userDAO.existsEmailOfOtherUser(user.getEmail(), user.getUserId())) {
            errors.put("email", "Email đã được sử dụng bởi tài khoản khác.");
        }
        if (!errors.containsKey("phone") && userDAO.existsPhoneOfOtherUser(user.getPhone(), user.getUserId())) {
            errors.put("phone", "Số điện thoại đã được sử dụng bởi tài khoản khác.");
        }
        return errors;
    }

    // ------------------------------------------------------------------ Hiển thị
    /**
     * @param staff hồ sơ đã lưu trong database (nguồn của username, role, status)
     * @param form giá trị hiển thị trong form (bằng staff khi mở trang)
     */
    private void showProfile(HttpServletRequest request, HttpServletResponse response,
            User staff, User form, Map<String, String> errors) throws ServletException, IOException, SQLException {
        int[] assignments = staffProfileDAO.getAssignmentSummary(staff.getUserId());
        String createdAt = DateTimeUtils.formatDateTime(staff.getCreatedAt());

        request.setAttribute("staff", staff);
        request.setAttribute("form", form);
        request.setAttribute("errors", errors);
        request.setAttribute("assignedEvents", assignments[0]);
        request.setAttribute("upcomingEvents", assignments[1]);
        request.setAttribute("checkedInTickets", staffProfileDAO.countCheckedInTickets(staff.getUserId()));
        request.setAttribute("memberSince", createdAt.length() >= 10 ? createdAt.substring(0, 10) : createdAt);
        CsrfUtils.expose(request);
        request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
    }

    /** Đồng bộ thông tin trong session để sidebar hiển thị đúng ngay sau khi lưu. */
    private void refreshSessionUser(HttpServletRequest request, User updated) {
        Auth authUser = SessionUtils.currentUser(request);
        authUser.setFullName(updated.getFullName());
        authUser.setEmail(updated.getEmail());
        authUser.setPhone(updated.getPhone());
        authUser.setAddress(updated.getAddress());
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
