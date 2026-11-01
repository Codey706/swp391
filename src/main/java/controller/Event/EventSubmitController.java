package controller.Event;

import dao.SeatMapDAO;
import model.Auth;
import model.Event;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Submit Event for Approval (Organizer): chuyển sự kiện nháp/bị từ chối sang
 * PENDING_APPROVAL để Admin duyệt. Chỉ nhận POST. Sự kiện cần có thông tin hợp
 * lệ (đã được kiểm tra lúc tạo/sửa), ít nhất một hạng vé và ảnh poster.
 */
@WebServlet(name = "EventSubmitController", urlPatterns = {"/organizer/event/submit"})
public class EventSubmitController extends EventController {

    private final SeatMapDAO seatMapDAO = new SeatMapDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + PATH_LIST); // chỉ nhận POST
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
            redirectToList(request, response, "errorMessage", notModifiableMessage("gửi duyệt", event));
            return;
        }
        if (seatMapDAO.getTickets(event.getEventId()).isEmpty()) {
            redirectToList(request, response, "errorMessage",
                    "Sự kiện \"" + event.getEventName() + "\" chưa có hạng vé nào. "
                    + "Hãy thiết lập hạng vé (mục Sơ đồ ghế) trước khi gửi duyệt.");
            return;
        }
        if (ValidationUtils.isNullOrBlank(event.getEventImage())) {
            redirectToList(request, response, "errorMessage",
                    "Sự kiện \"" + event.getEventName() + "\" chưa có ảnh poster. "
                    + "Hãy tải ảnh trong mục chỉnh sửa trước khi gửi duyệt.");
            return;
        }
        if (!eventDAO.submitForApproval(event.getEventId(), organizer.getUserId())) {
            redirectToList(request, response, "errorMessage", "Không thể gửi duyệt. Vui lòng thử lại sau.");
            return;
        }
        redirectToList(request, response, "successMessage",
                "Đã gửi sự kiện \"" + event.getEventName() + "\" cho Admin duyệt.");
    }
}
