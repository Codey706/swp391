package controller.Event;

import dao.EventDAO;
import model.Auth;
import model.Event;
import model.EventTicket;
import utils.Constants;
import utils.DateTimeUtils;
import utils.ValidationUtils;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * Lớp cha của các controller quản lý sự kiện (Organizer): Create / List /
 * Update / Delete. Chứa phần dùng chung: kiểm tra đăng nhập/role, flash message,
 * đọc form, validate thông tin sự kiện + hạng vé + ảnh, lưu/xóa file ảnh.
 * Không tự map URL; các controller con khai báo @WebServlet riêng.
 */
public abstract class EventController extends HttpServlet {


    protected static final String CREATE_EVENT_VIEW = "/WEB-INF/views/organizer/create-event.jsp";
    protected static final String EDIT_EVENT_VIEW = "/WEB-INF/views/organizer/edit-event.jsp";
    protected static final String EVENT_LIST_VIEW = "/WEB-INF/views/organizer/event-list.jsp";
    protected static final String PATH_LIST = "/organizer/event/list";

    // Chỉ cho sửa/xóa khi sự kiện chưa được gửi duyệt hoặc đã bị từ chối
    protected static final List<String> MODIFIABLE_STATUSES
            = Arrays.asList(Constants.EVENT_DRAFT, Constants.EVENT_REJECTED);

    protected final EventDAO eventDAO = new EventDAO();

    /**
     * Yêu cầu đã đăng nhập và có role Organizer.
     *
     * @return Auth hợp lệ (luôn khác null ở giai đoạn test, xem TODO).
     */
    protected Auth getAuthenticatedOrganizer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // Đã đăng nhập bằng tài khoản Organizer thì dùng đúng tài khoản đó
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(Constants.SESSION_USER);
        if (sessionUser instanceof Auth) {
            Auth loggedIn = (Auth) sessionUser;
            if (Constants.ROLE_ORGANIZER.equalsIgnoreCase(loggedIn.getRole())) {
                return loggedIn;
            }
        }

        // TODO: bỏ nhánh test này khi tích hợp xong đăng nhập (chuyển sang redirect /Auth?action=login)
        Auth testUser = new Auth();
        testUser.setUserId(1); // organizer01 trong db.sql
        testUser.setRole(Constants.ROLE_ORGANIZER);
        return testUser;
    }

    /**
     * Lấy sự kiện theo tham số eventId, chỉ trả về nếu thuộc organizer đang
     * đăng nhập.
     */
    protected Event loadOwnedEvent(HttpServletRequest request, Auth organizer) {
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), 0);
        return eventId <= 0 ? null : eventDAO.getEventByIdAndOrganizer(eventId, organizer.getUserId());
    }

    protected boolean isModifiable(Event event) {
        for (String status : MODIFIABLE_STATUSES) {
            if (status.equalsIgnoreCase(event.getStatus())) {
                return true;
            }
        }
        return false;
    }

    protected String notModifiableMessage(String action, Event event) {
        return "Không thể " + action + " sự kiện ở trạng thái " + event.getStatus()
                + ". Chỉ sự kiện nháp hoặc bị từ chối mới được " + action + ".";
    }

    /**
     * Nạp danh mục + địa điểm cho các dropdown của form tạo/sửa.
     */
    protected void loadFormOptions(HttpServletRequest request) {
        request.setAttribute("categories", eventDAO.getActiveCategories());
        request.setAttribute("venues", eventDAO.getActiveVenues());
        moveFlashMessage(request, "successMessage");
    }

    protected void redirectToList(HttpServletRequest request, HttpServletResponse response,
            String attribute, String message) throws IOException {
        request.getSession().setAttribute(attribute, message);
        response.sendRedirect(request.getContextPath() + PATH_LIST);
    }

    /**
     * Chuyển thông báo flash (lưu tạm trong session qua lần redirect) sang
     * request để JSP hiển thị một lần.
     */
    protected void moveFlashMessage(HttpServletRequest request, String... keys) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        for (String key : keys) {
            if (session.getAttribute(key) != null) {
                request.setAttribute(key, session.getAttribute(key));
                session.removeAttribute(key);
            }
        }
    }

    // ---------------------------------------------------------------- Đọc dữ liệu form

    protected static Event buildEventFromRequest(HttpServletRequest request, int organizerId) {
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

    /**
     * Đọc các hạng vé từ các input trùng tên (ticketName, ticketDescription,
     * ticketPrice, ticketQuantity). Dòng bỏ trống hoàn toàn sẽ bị bỏ qua; giá
     * không đọc được -> price = null, số lượng không đọc được -> 0 để
     * validateTickets báo lỗi.
     */
    protected static List<EventTicket> buildTicketsFromRequest(HttpServletRequest request) {
        String[] names = valuesOf(request, "ticketName");
        String[] descriptions = valuesOf(request, "ticketDescription");
        String[] prices = valuesOf(request, "ticketPrice");
        String[] quantities = valuesOf(request, "ticketQuantity");

        int rows = Math.max(Math.max(names.length, descriptions.length), Math.max(prices.length, quantities.length));
        List<EventTicket> tickets = new ArrayList<>();
        for (int i = 0; i < rows; i++) {
            String name = trimToNull(at(names, i));
            String description = trimToNull(at(descriptions, i));
            String price = trimToNull(at(prices, i));
            String quantity = trimToNull(at(quantities, i));
            if (name == null && description == null && price == null && quantity == null) {
                continue; // dòng trống
            }
            EventTicket ticket = new EventTicket();
            ticket.setTicketName(name);
            ticket.setDescription(description);
            ticket.setPrice(parsePrice(price));
            ticket.setQuantity(ValidationUtils.parseIntOrDefault(quantity, 0));
            tickets.add(ticket);
        }
        return tickets;
    }

    private static BigDecimal parsePrice(String value) {
        if (value == null) {
            return null;
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String[] valuesOf(HttpServletRequest request, String name) {
        String[] values = request.getParameterValues(name);
        return values == null ? new String[0] : values;
    }

    private static String at(String[] values, int index) {
        return index < values.length ? values[index] : null;
    }

    protected static String trimToNull(String value) {
        return ValidationUtils.isNullOrBlank(value) ? null : value.trim();
    }

    // ---------------------------------------------------------------- Validate Event Information

    /**
     * Kiểm tra toàn bộ thông tin sự kiện ở backend.
     *
     * @param excludeEventId id sự kiện đang sửa để bỏ qua khi kiểm tra trùng (0
     * khi tạo mới)
     * @return map field -> thông báo lỗi; rỗng nếu hợp lệ.
     */
    protected Map<String, String> validateEventInformation(Event event, int excludeEventId) {
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

    /**
     * Kiểm tra hạng vé (không bắt buộc có hạng vé nào, nhưng đã nhập thì phải
     * hợp lệ). Lỗi từng dòng gán vào ticket.error; lỗi chung (quá nhiều hạng,
     * vượt sức chứa) cho vào errors với key "tickets".
     *
     * @param venueId địa điểm đã chọn; &lt;= 0 hoặc không hợp lệ thì bỏ qua
     * kiểm tra sức chứa
     */
    protected void validateTickets(List<EventTicket> tickets, int venueId, Map<String, String> errors) {
        if (tickets.isEmpty()) {
            return;
        }
        if (tickets.size() > Constants.TICKET_MAX_TYPES) {
            errors.put("tickets", "Mỗi sự kiện tối đa " + Constants.TICKET_MAX_TYPES + " hạng vé.");
        }

        Set<String> seenNames = new HashSet<>();
        long totalQuantity = 0;
        boolean allRowsValid = true;

        for (EventTicket ticket : tickets) {
            String error = validateTicket(ticket);
            if (error == null && !seenNames.add(ticket.getTicketName().toLowerCase(Locale.ROOT))) {
                error = "Tên hạng vé bị trùng với hạng vé khác trong sự kiện.";
            }
            ticket.setError(error);
            if (error != null) {
                allRowsValid = false;
            } else {
                totalQuantity += ticket.getQuantity();
            }
        }
        if (!allRowsValid) {
            errors.put("tickets", errors.getOrDefault("tickets", "Vui lòng kiểm tra lại các hạng vé bên dưới."));
        }

        // Tổng số vé phát hành không vượt sức chứa địa điểm
        if (allRowsValid && !errors.containsKey("tickets") && venueId > 0 && !errors.containsKey("venueId")) {
            int capacity = eventDAO.getVenueCapacity(venueId);
            if (capacity > 0 && totalQuantity > capacity) {
                errors.put("tickets", "Tổng số vé (" + totalQuantity + ") vượt quá sức chứa của địa điểm ("
                        + capacity + " chỗ).");
            }
        }
    }

    private String validateTicket(EventTicket ticket) {
        if (ValidationUtils.isNullOrBlank(ticket.getTicketName())) {
            return "Vui lòng nhập tên hạng vé.";
        }
        if (ticket.getTicketName().length() > Constants.TICKET_NAME_MAX_LENGTH) {
            return "Tên hạng vé tối đa " + Constants.TICKET_NAME_MAX_LENGTH + " ký tự.";
        }
        if (ticket.getDescription() != null
                && ticket.getDescription().length() > Constants.TICKET_DESCRIPTION_MAX_LENGTH) {
            return "Mô tả hạng vé tối đa " + Constants.TICKET_DESCRIPTION_MAX_LENGTH + " ký tự.";
        }
        BigDecimal price = ticket.getPrice();
        if (price == null) {
            return "Vui lòng nhập giá vé hợp lệ (nhập 0 nếu miễn phí).";
        }
        if (price.signum() < 0) {
            return "Giá vé không được âm.";
        }
        if (price.stripTrailingZeros().scale() > 0) {
            return "Giá vé phải là số nguyên (đơn vị VNĐ).";
        }
        if (price.compareTo(BigDecimal.valueOf(Constants.TICKET_MAX_PRICE)) > 0) {
            return "Giá vé tối đa " + String.format(Locale.US, "%,d", Constants.TICKET_MAX_PRICE) + " VNĐ.";
        }
        if (ticket.getQuantity() <= 0) {
            return "Số lượng vé phải là số nguyên lớn hơn 0.";
        }
        if (ticket.getQuantity() > Constants.TICKET_MAX_QUANTITY) {
            return "Số lượng mỗi hạng vé tối đa "
                    + String.format(Locale.US, "%,d", Constants.TICKET_MAX_QUANTITY) + " vé.";
        }
        return null;
    }

    /**
     * @return thông báo lỗi, hoặc null nếu không có ảnh / ảnh hợp lệ.
     */
    protected String validateEventImage(Part imagePart) {
        if (!hasFile(imagePart)) {
            return null;
        }
        if (imagePart.getSize() > Constants.EVENT_IMAGE_MAX_SIZE) {
            return "Ảnh vượt quá dung lượng tối đa 5MB.";
        }
        String extension = getExtension(imagePart.getSubmittedFileName());
        String contentType = imagePart.getContentType();
        if (!ALLOWED_EXTENSIONS.contains(extension)
                || contentType == null || !contentType.startsWith("image/")) {
            return "Ảnh chỉ chấp nhận định dạng JPG, PNG hoặc WEBP.";
        }
        return null;
    }

    // ---------------------------------------------------------------- Ảnh sự kiện

    protected static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "webp");

    protected static boolean hasFile(Part part) {
        return part != null && part.getSize() > 0
                && !ValidationUtils.isNullOrBlank(part.getSubmittedFileName());
    }

    protected static String getExtension(String submittedFileName) {
        if (submittedFileName == null) {
            return "";
        }
        String fileName = Paths.get(submittedFileName).getFileName().toString();
        int dotIndex = fileName.lastIndexOf('.');
        return dotIndex < 0 ? "" : fileName.substring(dotIndex + 1).toLowerCase(Locale.ROOT);
    }

    /**
     * Đường dẫn tương đối lưu trong Events.event_image.
     */
    protected static String relativePath(int eventId, String submittedFileName) {
        return "assets/uploads/event-" + eventId + "-banner." + getExtension(submittedFileName);
    }

    /**
     * Lưu ảnh thành event-{id}-banner.{ext} trong assets/uploads rồi cập nhật
     * Events.event_image.
     */
    protected void saveEventImage(Part imagePart, int eventId) {
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

    /**
     * Xóa file ảnh trong assets/uploads; chỉ xóa file nằm trong thư mục upload.
     */
    protected void deleteEventImageFile(String imagePath) {
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
}
