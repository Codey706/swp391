package controller.Event;

import model.Auth;
import model.Event;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.Map;

/**
 * Update Event (Organizer): chỉ sửa được sự kiện nháp hoặc bị từ chối.
 */
@WebServlet(name = "EventUpdateController", urlPatterns = {"/organizer/event/update"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class EventUpdateController extends EventController {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

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
        } catch (IllegalStateException e) { // vượt giới hạn @MultipartConfig
            imageError = "Ảnh vượt quá dung lượng tối đa 5MB.";
        }
        if (imageError != null) {
            errors.put("eventImage", imageError);
        }

        if (errors.isEmpty() && !eventDAO.updateEvent(event)) {
            errors.put("general", "Không thể cập nhật sự kiện. Vui lòng thử lại sau.");
        }

        if (!errors.isEmpty()) {
            // Dựng lại các trường chỉ để hiển thị (mã sự kiện, ngày tạo, số liệu vé, trạng thái hiện tại)
            event.setStatus(existing.getStatus());
            event.setCancellationReason(existing.getCancellationReason());
            event.setCreatedAt(existing.getCreatedAt());
            event.setUpdatedAt(existing.getUpdatedAt());
            event.setTicketTotal(existing.getTicketTotal());
            event.setTicketSold(existing.getTicketSold());
            event.setRevenue(existing.getRevenue());
            request.setAttribute("errors", errors);
            request.setAttribute("event", event);
            loadFormOptions(request);
            request.getRequestDispatcher(EDIT_EVENT_VIEW).forward(request, response);
            return;
        }

        if (hasFile(imagePart)) {
            saveEventImage(imagePart, event.getEventId());
            // Đổi đuôi ảnh (png -> jpg...) thì xóa file cũ để không bị sót
            String newPath = relativePath(event.getEventId(), imagePart.getSubmittedFileName());
            if (existing.getEventImage() != null && !existing.getEventImage().equals(newPath)) {
                deleteEventImageFile(existing.getEventImage());
            }
        }
        redirectToList(request, response, "successMessage", "Cập nhật sự kiện thành công.");
    }
}
