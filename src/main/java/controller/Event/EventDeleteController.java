package controller.Event;

import model.Auth;
import model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Delete Event (Organizer): chỉ nhận POST, chỉ xóa sự kiện nháp/bị từ chối và
 * chưa phát sinh dữ liệu bán hàng.
 */
@WebServlet(name = "EventDeleteController", urlPatterns = {"/organizer/event/delete"})
public class EventDeleteController extends EventController {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // xóa chỉ nhận POST
        response.sendRedirect(request.getContextPath() + PATH_LIST);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
}
