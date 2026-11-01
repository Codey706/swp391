package controller.Event;

import controller.Event.SeatMapSupport.LayoutRequest;
import dao.SeatMapDAO.TicketChange;
import model.Auth;
import model.Event;
import model.EventTicket;
import model.EventZone;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Create Event (Organizer). Bước 3 của form có hai cách bán vé:
 * <ul>
 * <li>GENERAL: hạng vé theo số lượng (ticketName/ticketPrice/ticketQuantity...).</li>
 * <li>SEATED: hạng vé + sơ đồ ghế do trình thiết kế gửi lên (layoutJson).</li>
 * </ul>
 * Sự kiện luôn được lưu ở trạng thái DRAFT (sự kiện + hạng vé + sơ đồ trong
 * cùng một transaction). Nếu Organizer chọn "Gửi duyệt" thì sau khi lưu xong
 * (kể cả ảnh) mới chuyển sang PENDING_APPROVAL; nếu bước đó không thành công
 * sự kiện vẫn là bản nháp và có thông báo rõ ràng.
 */
@WebServlet(name = "EventCreateController", urlPatterns = {"/organizer/event/create"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class EventCreateController extends EventController {

    private static final String MODE_SEATED = "SEATED";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (getAuthenticatedOrganizer(request, response) == null) {
            return;
        }
        showForm(request, response, null, null, new ArrayList<>(), "draft");
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
        boolean submitForApproval = isSubmitAction(request);
        boolean seated = MODE_SEATED.equals(request.getParameter("ticketMode"));

        Map<String, String> errors = validateEventInformation(event, 0);

        // ---- Hạng vé: theo số lượng hoặc theo sơ đồ ghế
        List<EventTicket> tickets = new ArrayList<>();
        LayoutRequest layout = null;
        List<TicketChange> changes = new ArrayList<>();
        List<String> seatErrors = new ArrayList<>();
        boolean hasTickets;

        if (seated) {
            layout = SeatMapSupport.parse(request.getParameter("layoutJson"));
            if (layout == null) {
                seatErrors.add("Dữ liệu sơ đồ ghế không hợp lệ. Vui lòng thử lại.");
            } else {
                int venueCapacity = event.getVenueId() > 0 && !errors.containsKey("venueId")
                        ? eventDAO.getVenueCapacity(event.getVenueId()) : -1;
                SeatMapSupport.validate(layout, new ArrayList<>(), venueCapacity,
                        this::validateTicket, seatErrors, changes);
            }
            if (!seatErrors.isEmpty()) {
                errors.put("tickets", "Vui lòng kiểm tra lại sơ đồ ghế và hạng vé.");
            }
            hasTickets = layout != null && seatErrors.isEmpty() && !layout.zones.isEmpty();
        } else {
            tickets = buildTicketsFromRequest(request);
            validateTickets(tickets, event.getVenueId(), errors);
            hasTickets = !tickets.isEmpty();
        }

        // ---- Ảnh sự kiện (bắt buộc khi gửi duyệt)
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

        // ---- Điều kiện để gửi duyệt
        if (submitForApproval) {
            if (!hasTickets && !errors.containsKey("tickets")) {
                errors.put("tickets", "Cần có ít nhất một hạng vé để gửi duyệt. "
                        + "Hãy cấu hình vé ở bước 3, hoặc chọn \"Lưu nháp\" để làm sau.");
            }
            if (!hasFile(imagePart) && !errors.containsKey("eventImage")) {
                errors.put("eventImage", "Cần có ảnh poster để gửi duyệt. "
                        + "Hãy chọn ảnh ở bước 1, hoặc chọn \"Lưu nháp\" để làm sau.");
            }
        }

        // ---- Lưu: sự kiện + hạng vé (+ sơ đồ) cùng một transaction, luôn ở trạng thái DRAFT
        if (errors.isEmpty()) {
            boolean created = seated
                    ? eventDAO.createEventWithSeatMap(event, layout.zones, changes)
                    : eventDAO.createEventWithTickets(event, tickets);
            if (!created) {
                errors.put("general", "Không thể tạo sự kiện. Vui lòng thử lại sau.");
            }
        }

        if (!errors.isEmpty()) {
            showForm(request, response, event, errors, seatErrors, submitForApproval ? "submit" : "draft",
                    tickets, layout, seated, request.getParameter("layoutJson"));
            return;
        }

        boolean imageSaved = !hasFile(imagePart) || saveEventImage(imagePart, event.getEventId());
        redirectToList(request, response, "successMessage",
                buildResultMessage(event, submitForApproval, imageSaved, seated, tickets, layout));
    }

    /**
     * Chuyển sang chờ duyệt (nếu được chọn) rồi tạo thông báo kết quả; sự kiện
     * đã tồn tại ở DRAFT nên mọi lỗi ở đây chỉ làm nó giữ nguyên là bản nháp.
     */
    private String buildResultMessage(Event event, boolean submitForApproval, boolean imageSaved,
            boolean seated, List<EventTicket> tickets, LayoutRequest layout) {
        StringBuilder detail = new StringBuilder();
        if (seated && layout != null) {
            int seats = 0;
            for (EventZone zone : layout.zones) {
                seats += zone.getCapacity();
            }
            detail.append(" Đã thiết lập sơ đồ ").append(layout.zones.size()).append(" khu (")
                    .append(seats).append(" chỗ) cùng ").append(layout.tickets.size()).append(" hạng vé.");
        } else if (!tickets.isEmpty()) {
            detail.append(" Đã cấu hình ").append(tickets.size()).append(" hạng vé.");
        }
        if (!imageSaved) {
            detail.append(" Tuy nhiên chưa lưu được ảnh poster, hãy tải lại ảnh trong mục chỉnh sửa.");
        }

        if (!submitForApproval) {
            return "Tạo sự kiện thành công (trạng thái: nháp)." + detail
                    + " Bạn có thể chỉnh sửa rồi gửi duyệt khi đã sẵn sàng.";
        }
        if (!imageSaved) {
            return "Đã lưu sự kiện ở trạng thái nháp nhưng chưa gửi duyệt được vì ảnh poster chưa được lưu."
                    + " Hãy tải lại ảnh rồi gửi duyệt từ danh sách sự kiện.";
        }
        if (!eventDAO.submitForApproval(event.getEventId(), event.getOrganizerId())) {
            return "Đã lưu sự kiện ở trạng thái nháp nhưng chưa gửi duyệt được."
                    + " Bạn có thể gửi duyệt lại từ danh sách sự kiện." + detail;
        }
        return "Đã tạo sự kiện và gửi Admin duyệt (trạng thái: chờ duyệt)." + detail;
    }

    /** "Gửi duyệt" khi bấm nút có submitAction=submit, hoặc chọn radio ở bước cuối. */
    private boolean isSubmitAction(HttpServletRequest request) {
        String action = trimToNull(request.getParameter("submitAction"));
        if (action == null) {
            action = trimToNull(request.getParameter("publishChoice"));
        }
        return "submit".equals(action);
    }

    // ---------------------------------------------------------------- Hiển thị form
    private void showForm(HttpServletRequest request, HttpServletResponse response, Event event,
            Map<String, String> errors, List<String> seatErrors, String publishChoice)
            throws ServletException, IOException {
        showForm(request, response, event, errors, seatErrors, publishChoice,
                new ArrayList<>(), null, false, null);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, Event event,
            Map<String, String> errors, List<String> seatErrors, String publishChoice,
            List<EventTicket> tickets, LayoutRequest layout, boolean seated, String layoutJson)
            throws ServletException, IOException {
        loadFormOptions(request);
        if (event != null) {
            request.setAttribute("event", event);
        }
        request.setAttribute("errors", errors == null ? new LinkedHashMap<String, String>() : errors);
        request.setAttribute("tickets", tickets);
        request.setAttribute("seatErrors", seatErrors);
        request.setAttribute("publishChoice", publishChoice);
        request.setAttribute("ticketMode", seated ? MODE_SEATED : "GENERAL");

        // Dữ liệu cho trình thiết kế sơ đồ ghế ở bước 3
        List<Map<String, Object>> ticketData = layout == null
                ? new ArrayList<>() : SeatMapSupport.draftData(layout.tickets);
        List<EventZone> zones = layout == null ? new ArrayList<>() : layout.zones;
        request.setAttribute("seatMapJson", SeatMapSupport.buildDataJson(0, false, -1,
                eventDAO.getVenueCapacities(), ticketData, zones));
        request.getRequestDispatcher(CREATE_EVENT_VIEW).forward(request, response);
    }
}
