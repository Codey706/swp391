package controller;

import dao.EventDAO;
import model.Event;
import model.User;
import utils.Constants;
import utils.DateTimeUtils;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Create Event + Validate Event Information (Organizer).
 * Sự kiện mới luôn ở trạng thái DRAFT; gửi duyệt là task "Submit Event for Approval" (I6).
 */
@WebServlet(name = "EventController", urlPatterns = {"/organizer/event/create"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class EventController extends HttpServlet {

    private static final String CREATE_EVENT_VIEW = "/WEB-INF/views/organizer/create-event.jsp";
    private static final List<String> ALLOWED_IMAGE_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "webp");

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (getAuthenticatedOrganizer(request, response) == null) {
            return;
        }
        loadFormOptions(request);
        request.getRequestDispatcher(CREATE_EVENT_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

        Event event = buildEventFromRequest(request, organizer.getUserId());
        Map<String, String> errors = validateEventInformation(event);

        // Ảnh sự kiện (không bắt buộc)
        Part imagePart = null;
        String imageError;
        try {
            imagePart = request.getPart("eventImage");
            imageError = validateEventImage(imagePart);
        } catch (IllegalStateException e) { // vượt giới hạn @MultipartConfig
            imageError = "Ảnh vượt quá dung lượng tối đa 5MB.";
        }
        if (imageError != null) {
            errors.put("eventImage", imageError);
        }

        if (errors.isEmpty() && !eventDAO.createEvent(event)) {
            errors.put("general", "Không thể tạo sự kiện. Vui lòng thử lại sau.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("event", event);
            loadFormOptions(request);
            request.getRequestDispatcher(CREATE_EVENT_VIEW).forward(request, response);
            return;
        }

        if (hasFile(imagePart)) {
            saveEventImage(imagePart, event.getEventId());
        }

        request.getSession().setAttribute("successMessage", "Tạo sự kiện thành công (trạng thái: nháp).");
        response.sendRedirect(request.getContextPath() + "/organizer/event/create");
    }

    // ---------------------------------------------------------------- Validate Event Information

    /**
     * Kiểm tra toàn bộ thông tin sự kiện ở backend.
     * @return map field -> thông báo lỗi; rỗng nếu hợp lệ.
     */
    private Map<String, String> validateEventInformation(Event event) {
        Map<String, String> errors = new LinkedHashMap<>();

        // Tên sự kiện
        if (ValidationUtils.isNullOrBlank(event.getEventName())) {
            errors.put("eventName", "Tên sự kiện không được để trống.");
        } else if (!ValidationUtils.isLengthBetween(event.getEventName(),
                Constants.EVENT_NAME_MIN_LENGTH, Constants.EVENT_NAME_MAX_LENGTH)) {
            errors.put("eventName", "Tên sự kiện phải từ " + Constants.EVENT_NAME_MIN_LENGTH
                    + " đến " + Constants.EVENT_NAME_MAX_LENGTH + " ký tự.");
        }

        // Mô tả
        if (ValidationUtils.isNullOrBlank(event.getDescription())) {
            errors.put("description", "Mô tả sự kiện không được để trống.");
        } else if (!ValidationUtils.isLengthBetween(event.getDescription(),
                Constants.EVENT_DESCRIPTION_MIN_LENGTH, Constants.EVENT_DESCRIPTION_MAX_LENGTH)) {
            errors.put("description", "Mô tả phải từ " + Constants.EVENT_DESCRIPTION_MIN_LENGTH
                    + " đến " + Constants.EVENT_DESCRIPTION_MAX_LENGTH + " ký tự.");
        }

        // Danh mục & địa điểm (phải tồn tại và status = ACTIVE)
        if (event.getCategoryId() <= 0) {
            errors.put("categoryId", "Vui lòng chọn danh mục sự kiện.");
        } else if (!eventDAO.existsActiveCategory(event.getCategoryId())) {
            errors.put("categoryId", "Danh mục không tồn tại hoặc đã ngừng hoạt động.");
        }

        if (event.getVenueId() <= 0) {
            errors.put("venueId", "Vui lòng chọn địa điểm tổ chức.");
        } else if (!eventDAO.existsActiveVenue(event.getVenueId())) {
            errors.put("venueId", "Địa điểm không tồn tại hoặc đã ngừng hoạt động.");
        }

        // Thời gian
        if (event.getStartTime() == null) {
            errors.put("startTime", "Thời gian bắt đầu không hợp lệ.");
        } else if (!event.getStartTime().isAfter(LocalDateTime.now())) {
            errors.put("startTime", "Thời gian bắt đầu phải sau thời điểm hiện tại.");
        }

        if (event.getEndTime() == null) {
            errors.put("endTime", "Thời gian kết thúc không hợp lệ.");
        } else if (event.getStartTime() != null && !event.getEndTime().isAfter(event.getStartTime())) {
            errors.put("endTime", "Thời gian kết thúc phải sau thời gian bắt đầu.");
        }

        // Trùng sự kiện của chính organizer
        if (!errors.containsKey("eventName") && !errors.containsKey("startTime")
                && eventDAO.existsDuplicateEvent(event.getOrganizerId(), event.getEventName(),
                        Timestamp.valueOf(event.getStartTime()))) {
            errors.put("eventName", "Bạn đã có sự kiện cùng tên và cùng thời gian bắt đầu.");
        }

        // Địa điểm bị trùng lịch với sự kiện khác
        if (!errors.containsKey("venueId") && !errors.containsKey("startTime") && !errors.containsKey("endTime")
                && eventDAO.existsVenueConflict(event.getVenueId(),
                        Timestamp.valueOf(event.getStartTime()), Timestamp.valueOf(event.getEndTime()),
                        Constants.EVENT_CANCELLED, Constants.EVENT_REJECTED)) {
            errors.put("venueId", "Địa điểm đã có sự kiện khác trong khoảng thời gian này.");
        }

        return errors;
    }

    /** @return thông báo lỗi, hoặc null nếu không có ảnh / ảnh hợp lệ. */
    private String validateEventImage(Part imagePart) {
        if (!hasFile(imagePart)) {
            return null;
        }
        if (imagePart.getSize() > Constants.EVENT_IMAGE_MAX_SIZE) {
            return "Ảnh vượt quá dung lượng tối đa 5MB.";
        }
        String extension = getExtension(imagePart.getSubmittedFileName());
        String contentType = imagePart.getContentType();
        if (!ALLOWED_IMAGE_EXTENSIONS.contains(extension)
                || contentType == null || !contentType.startsWith("image/")) {
            return "Ảnh chỉ chấp nhận định dạng JPG, PNG hoặc WEBP.";
        }
        return null;
    }

    // ---------------------------------------------------------------- Helpers

    private Event buildEventFromRequest(HttpServletRequest request, int organizerId) {
        Event event = new Event();
        event.setOrganizerId(organizerId); // lấy từ session, không nhận từ browser
        event.setEventName(trimToNull(request.getParameter("eventName")));
        event.setDescription(trimToNull(request.getParameter("description")));
        event.setCategoryId(ValidationUtils.parseIntOrDefault(request.getParameter("categoryId"), 0));
        event.setVenueId(ValidationUtils.parseIntOrDefault(request.getParameter("venueId"), 0));
        event.setStartTime(DateTimeUtils.parseDateTimeLocal(request.getParameter("startTime")));
        event.setEndTime(DateTimeUtils.parseDateTimeLocal(request.getParameter("endTime")));
        event.setStatus(Constants.EVENT_DRAFT); // không nhận status từ browser
        return event;
    }

    /** Lưu ảnh thành event-{id}-banner.{ext} trong assets/uploads rồi cập nhật Events.event_image. */
    private void saveEventImage(Part imagePart, int eventId) {
        String uploadDir = getServletContext().getRealPath(Constants.UPLOAD_DIR);
        if (uploadDir == null) {
            return; // ứng dụng chạy từ WAR chưa giải nén, không ghi được vào thư mục web
        }
        File directory = new File(uploadDir);
        if (!directory.exists() && !directory.mkdirs()) {
            return;
        }
        String fileName = "event-" + eventId + "-banner." + getExtension(imagePart.getSubmittedFileName());
        try {
            imagePart.write(new File(directory, fileName).getAbsolutePath());
            eventDAO.updateEventImage(eventId, "assets/uploads/" + fileName);
        } catch (IOException e) {
            e.printStackTrace(); // sự kiện đã tạo xong, chỉ thiếu ảnh
        }
    }

    private boolean hasFile(Part part) {
        return part != null && part.getSize() > 0
                && !ValidationUtils.isNullOrBlank(part.getSubmittedFileName());
    }

    private String getExtension(String submittedFileName) {
        if (submittedFileName == null) {
            return "";
        }
        String fileName = Paths.get(submittedFileName).getFileName().toString();
        int dotIndex = fileName.lastIndexOf('.');
        return dotIndex < 0 ? "" : fileName.substring(dotIndex + 1).toLowerCase(Locale.ROOT);
    }

    private void loadFormOptions(HttpServletRequest request) {
        request.setAttribute("categories", eventDAO.getActiveCategories());
        request.setAttribute("venues", eventDAO.getActiveVenues());
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
    }

    /**
     * Yêu cầu đã đăng nhập và có role Organizer.
     * Giả định: LoginController lưu User vào session với key Constants.SESSION_USER.
     * @return User hợp lệ, hoặc null nếu đã redirect/gửi lỗi.
     */
    private User getAuthenticatedOrganizer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute(Constants.SESSION_USER);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login"); // TODO: đổi theo URL của LoginController
            return null;
        }
        if (!Constants.ROLE_ORGANIZER.equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private String trimToNull(String value) {
        return ValidationUtils.isNullOrBlank(value) ? null : value.trim();
    }
}