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
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Event Management (Organizer): Create / Update / Delete / View Event List + Validate Event Information.
 * Sự kiện mới luôn ở trạng thái DRAFT; gửi duyệt là task "Submit Event for Approval" (I6).
 */
@WebServlet(name = "EventController", urlPatterns = {
    "/organizer/event/create", "/organizer/event/list",
    "/organizer/event/update", "/organizer/event/delete"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class EventController extends HttpServlet {

    private static final String CREATE_EVENT_VIEW = "/WEB-INF/views/organizer/create-event.jsp";
    private static final String EDIT_EVENT_VIEW = "/WEB-INF/views/organizer/edit-event.jsp";
    private static final String EVENT_LIST_VIEW = "/WEB-INF/views/organizer/event-list.jsp";
    private static final String PATH_LIST = "/organizer/event/list";
    private static final String PATH_UPDATE = "/organizer/event/update";
    private static final String PATH_DELETE = "/organizer/event/delete";
    private static final List<String> ALLOWED_IMAGE_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "webp");
    // Chỉ cho sửa/xóa khi sự kiện chưa được gửi duyệt hoặc đã bị từ chối
    private static final List<String> MODIFIABLE_STATUSES =
            Arrays.asList(Constants.EVENT_DRAFT, Constants.EVENT_REJECTED);
    private static final List<String> LIST_STATUSES = Arrays.asList(
            Constants.EVENT_DRAFT, Constants.EVENT_PENDING_APPROVAL, Constants.EVENT_ACTIVE,
            Constants.EVENT_REJECTED, Constants.EVENT_CANCELLED);

    private final EventDAO eventDAO = new EventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        switch (request.getServletPath()) {
            case PATH_LIST:
                showEventList(request, response, organizer);
                break;
            case PATH_UPDATE:
                showEditForm(request, response, organizer);
                break;
            case PATH_DELETE: // xóa chỉ nhận POST
                response.sendRedirect(request.getContextPath() + PATH_LIST);
                break;
            default:
                loadFormOptions(request);
                request.getRequestDispatcher(CREATE_EVENT_VIEW).forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        switch (request.getServletPath()) {
            case PATH_UPDATE:
                updateEvent(request, response, organizer);
                return;
            case PATH_DELETE:
                deleteEvent(request, response, organizer);
                return;
            case PATH_LIST:
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                return;
            default:
                break; // create
        }

        Event event = buildEventFromRequest(request, organizer.getUserId());
        Map<String, String> errors = validateEventInformation(event, 0);

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

    // ---------------------------------------------------------------- View Event List

    private void showEventList(HttpServletRequest request, HttpServletResponse response, User organizer)
            throws ServletException, IOException {
        String keyword = trimToNull(request.getParameter("keyword"));
        String status = trimToNull(request.getParameter("status"));
        if (status != null) {
            status = status.toUpperCase(Locale.ROOT);
            if (!LIST_STATUSES.contains(status)) {
                status = null; // không tin dữ liệu từ browser
            }
        }
        if (keyword != null && keyword.length() > Constants.EVENT_NAME_MAX_LENGTH) {
            keyword = keyword.substring(0, Constants.EVENT_NAME_MAX_LENGTH);
        }

        int total = eventDAO.countEventsByOrganizer(organizer.getUserId(), keyword, status);
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) Constants.EVENT_PAGE_SIZE));
        int page = Math.min(Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1)), totalPages);

        request.setAttribute("events", eventDAO.getEventsByOrganizer(
                organizer.getUserId(), keyword, status, page, Constants.EVENT_PAGE_SIZE));
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("statuses", LIST_STATUSES);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalEvents", total);
        request.setAttribute("modifiableStatuses", MODIFIABLE_STATUSES);
        moveFlashMessages(request);
        request.getRequestDispatcher(EVENT_LIST_VIEW).forward(request, response);
    }

    // ---------------------------------------------------------------- Update Event

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User organizer)
            throws ServletException, IOException {
        Event event = loadOwnedEvent(request, organizer);
        if (event == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
            return;
        }
        if (!isModifiable(event)) {
            redirectToList(request, response, "errorMessage", notModifiableMessage("chỉnh sửa", event));
            return;
        }
        request.setAttribute("event", event);
        loadFormOptions(request);
        request.getRequestDispatcher(EDIT_EVENT_VIEW).forward(request, response);
    }

    private void updateEvent(HttpServletRequest request, HttpServletResponse response, User organizer)
            throws ServletException, IOException {
        Event existing = loadOwnedEvent(request, organizer);
        if (existing == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
            return;
        }
        if (!isModifiable(existing)) {
            redirectToList(request, response, "errorMessage", notModifiableMessage("chỉnh sửa", existing));
            return;
        }

        // organizerId và eventId lấy từ DB/session, không nhận từ form
        Event event = buildEventFromRequest(request, organizer.getUserId());
        event.setEventId(existing.getEventId());
        event.setEventImage(existing.getEventImage());
        // Sự kiện bị từ chối được sửa xong sẽ quay về nháp để gửi duyệt lại
        event.setStatus(Constants.EVENT_DRAFT);

        Map<String, String> errors = validateEventInformation(event, existing.getEventId());

        Part imagePart = null;
        String imageError;
        try {
            imagePart = request.getPart("eventImage");
            imageError = validateEventImage(imagePart);
        } catch (IllegalStateException e) {
            imageError = "Ảnh vượt quá dung lượng tối đa 5MB.";
        }
        if (imageError != null) {
            errors.put("eventImage", imageError);
        }

        if (errors.isEmpty() && !eventDAO.updateEvent(event)) {
            errors.put("general", "Không thể cập nhật sự kiện. Vui lòng thử lại sau.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("event", event);
            loadFormOptions(request);
            request.getRequestDispatcher(EDIT_EVENT_VIEW).forward(request, response);
            return;
        }

        if (hasFile(imagePart)) {
            saveEventImage(imagePart, event.getEventId());
            // Đổi đuôi ảnh (png -> jpg...) thì xóa file cũ để không bị sót
            String newPath = "assets/uploads/event-" + event.getEventId() + "-banner."
                    + getExtension(imagePart.getSubmittedFileName());
            if (existing.getEventImage() != null && !existing.getEventImage().equals(newPath)) {
                deleteEventImageFile(existing.getEventImage());
            }
        }
        redirectToList(request, response, "successMessage", "Cập nhật sự kiện thành công.");
    }

    // ---------------------------------------------------------------- Delete Event

    private void deleteEvent(HttpServletRequest request, HttpServletResponse response, User organizer)
            throws IOException {
        Event event = loadOwnedEvent(request, organizer);
        if (event == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện.");
            return;
        }
        if (!isModifiable(event)) {
            redirectToList(request, response, "errorMessage", notModifiableMessage("xóa", event));
            return;
        }
        if (eventDAO.hasSalesData(event.getEventId())) {
            redirectToList(request, response, "errorMessage",
                    "Sự kiện đã phát sinh đơn hàng/vé/đánh giá nên không thể xóa.");
            return;
        }
        if (!eventDAO.deleteEvent(event.getEventId(), organizer.getUserId())) {
            redirectToList(request, response, "errorMessage", "Không thể xóa sự kiện. Vui lòng thử lại sau.");
            return;
        }
        deleteEventImageFile(event.getEventImage());
        redirectToList(request, response, "successMessage", "Đã xóa sự kiện \"" + event.getEventName() + "\".");
    }

    // ---------------------------------------------------------------- Validate Event Information

    /**
     * Kiểm tra toàn bộ thông tin sự kiện ở backend.
     * @param excludeEventId id sự kiện đang sửa để bỏ qua khi kiểm tra trùng (0 khi tạo mới)
     * @return map field -> thông báo lỗi; rỗng nếu hợp lệ.
     */
    private Map<String, String> validateEventInformation(Event event, int excludeEventId) {
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
                        Timestamp.valueOf(event.getStartTime()), excludeEventId)) {
            errors.put("eventName", "Bạn đã có sự kiện cùng tên và cùng thời gian bắt đầu.");
        }

        // Địa điểm bị trùng lịch với sự kiện khác
        if (!errors.containsKey("venueId") && !errors.containsKey("startTime") && !errors.containsKey("endTime")
                && eventDAO.existsVenueConflict(event.getVenueId(),
                        Timestamp.valueOf(event.getStartTime()), Timestamp.valueOf(event.getEndTime()),
                        Constants.EVENT_CANCELLED, Constants.EVENT_REJECTED, excludeEventId)) {
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
            response.sendRedirect(request.getContextPath() + "/login"); // TODO: đổi theo URL của LoginController
            return null;
        }
        if (!Constants.ROLE_ORGANIZER.equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    /** Lấy sự kiện theo tham số eventId, chỉ trả về nếu thuộc organizer đang đăng nhập. */
    private Event loadOwnedEvent(HttpServletRequest request, User organizer) {
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), 0);
        return eventId <= 0 ? null : eventDAO.getEventByIdAndOrganizer(eventId, organizer.getUserId());
    }

    private boolean isModifiable(Event event) {
        for (String status : MODIFIABLE_STATUSES) {
            if (status.equalsIgnoreCase(event.getStatus())) {
                return true;
            }
        }
        return false;
    }

    private String notModifiableMessage(String action, Event event) {
        return "Không thể " + action + " sự kiện ở trạng thái " + event.getStatus()
                + ". Chỉ sự kiện nháp hoặc bị từ chối mới được " + action + ".";
    }

    private void redirectToList(HttpServletRequest request, HttpServletResponse response,
                                String attribute, String message) throws IOException {
        request.getSession().setAttribute(attribute, message);
        response.sendRedirect(request.getContextPath() + PATH_LIST);
    }

    private void moveFlashMessages(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        for (String key : new String[]{"successMessage", "errorMessage"}) {
            if (session.getAttribute(key) != null) {
                request.setAttribute(key, session.getAttribute(key));
                session.removeAttribute(key);
            }
        }
    }

    /** Xóa file ảnh trong assets/uploads; chỉ xóa file nằm trong thư mục upload. */
    private void deleteEventImageFile(String imagePath) {
        if (ValidationUtils.isNullOrBlank(imagePath) || !imagePath.startsWith("assets/uploads/")) {
            return;
        }
        String uploadDir = getServletContext().getRealPath(Constants.UPLOAD_DIR);
        if (uploadDir == null) {
            return;
        }
        try {
            Path directory = Paths.get(uploadDir).toAbsolutePath().normalize();
            Path file = directory.resolve(Paths.get(imagePath).getFileName().toString()).normalize();
            if (file.startsWith(directory)) {
                Files.deleteIfExists(file);
            }
        } catch (IOException e) {
            e.printStackTrace(); // sự kiện đã xóa, chỉ còn sót file ảnh
        }
    }

    private String trimToNull(String value) {
        return ValidationUtils.isNullOrBlank(value) ? null : value.trim();
    }
}