package controller.Event;

import dao.EventDAO.CancelResult;
import static dao.EventDAO.CancelResult.CANCELLED;
import static dao.EventDAO.CancelResult.HAS_PAID_ORDERS;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Auth;
import utils.CsrfUtils;
import utils.ValidationUtils;

/**
 * UC-20: Organizer hủy sự kiện. POST /organizer/event/cancel (eventId, reason).
 * Chỉ sự kiện ACTIVE của chính mình và chưa có đơn Paid; lý do bắt buộc, tối đa
 * 1000 ký tự (Events.cancellation_reason).
 */
@WebServlet(name = "EventCancelController", urlPatterns = {"/organizer/event/cancel"})
public class EventCancelController extends EventController {

    private static final int REASON_MAX_LENGTH = 1000;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), 0);
        String reason = request.getParameter("reason");
        reason = reason == null ? "" : reason.trim();
        if (eventId <= 0) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện của bạn.");
            return;
        }
        if (reason.isEmpty() || reason.length() > REASON_MAX_LENGTH) {
            redirectToList(request, response, "errorMessage",
                    "Vui lòng nhập lý do hủy sự kiện (tối đa " + REASON_MAX_LENGTH + " ký tự).");
            return;
        }
        try {
            CancelResult result = eventDAO.cancelEvent(eventId, organizer.getUserId(), reason);
            switch (result) {
                case CANCELLED ->
                    redirectToList(request, response, "successMessage", "Đã hủy sự kiện.");
                case HAS_PAID_ORDERS ->
                    redirectToList(request, response, "errorMessage",
                            "Không thể hủy: sự kiện đã có đơn hàng thanh toán. Vui lòng liên hệ quản trị viên để xử lý hoàn tiền.");
                default ->
                    redirectToList(request, response, "errorMessage", "Chỉ sự kiện đang mở bán (ACTIVE) của bạn mới có thể hủy.");
            }
        } catch (SQLException e) {
            throw new ServletException("Cannot cancel event", e);
        }
    }
}
