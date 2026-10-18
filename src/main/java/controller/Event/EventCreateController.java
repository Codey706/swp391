package controller.Event;

import model.Auth;
import model.Event;
import model.EventTicket;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Create Event (Organizer): tạo sự kiện ở trạng thái DRAFT, có thể cấu hình
 * luôn hạng vé & giá. Gửi duyệt là task "Submit Event for Approval" (I6).
 */
@WebServlet(name = "EventCreateController", urlPatterns = {"/organizer/event/create"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class EventCreateController extends EventController {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
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
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

        Event event = buildEventFromRequest(request, organizer.getUserId());
        List<EventTicket> tickets = buildTicketsFromRequest(request);

        Map<String, String> errors = validateEventInformation(event, 0);
        validateTickets(tickets, event.getVenueId(), errors);

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

        // Sự kiện + hạng vé được lưu trong cùng một transaction
        if (errors.isEmpty() && !eventDAO.createEventWithTickets(event, tickets)) {
            errors.put("general", "Không thể tạo sự kiện. Vui lòng thử lại sau.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("event", event);
            request.setAttribute("tickets", tickets);
            loadFormOptions(request);
            request.getRequestDispatcher(CREATE_EVENT_VIEW).forward(request, response);
            return;
        }

        if (hasFile(imagePart)) {
            saveEventImage(imagePart, event.getEventId());
        }

        String message = "Tạo sự kiện thành công (trạng thái: nháp)."
                + (tickets.isEmpty() ? "" : " Đã cấu hình " + tickets.size() + " hạng vé.");
        redirectToList(request, response, "successMessage", message);
    }
}
