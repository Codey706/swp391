
package controller;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Auth;
import utils.CsrfUtils;
import utils.SessionUtils;
import utils.ValidationUtils;

/**
 * UC-19 Review Event.
 * Chỉ khách có vé đã check-in mới được đánh giá.
 * Mỗi khách chỉ được đánh giá một lần cho mỗi sự kiện.
 */
@WebServlet("/customer/review")
public class ReviewController extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Auth customer = SessionUtils.currentUser(request);

        int eventId = ValidationUtils.parseIntOrDefault(
                request.getParameter("eventId"), -1);

        int orderId = ValidationUtils.parseIntOrDefault(
                request.getParameter("orderId"), -1);

        if (eventId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int rating = ValidationUtils.parseIntOrDefault(
                request.getParameter("rating"), 0);

        String comment = request.getParameter("comment");
        comment = comment == null ? "" : comment.trim();

        String message;
        boolean ok = false;

        try {
            // Kiểm tra khách có vé đã check-in của sự kiện không.
            int ticketId = reviewDAO.findCheckedInTicket(
                    customer.getUserId(), eventId);

            // Nếu gửi từ Booking Detail, kiểm tra đơn hàng thuộc khách
            // và đúng sự kiện đang được đánh giá.
            if (orderId > 0
                    && reviewDAO.findEventIdByOrder(
                            customer.getUserId(), orderId) != eventId) {

                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            if (rating < 1 || rating > 5) {
                message = "Vui lòng chọn số sao từ 1 đến 5.";

            } else if (comment.length() > ReviewDAO.COMMENT_MAX_LENGTH) {
                message = "Nhận xét tối đa "
                        + ReviewDAO.COMMENT_MAX_LENGTH + " ký tự.";

            } else if (ticketId <= 0) {
                message = "Chỉ khách đã check-in sự kiện mới có thể đánh giá.";

            } else if (!reviewDAO.insert(
                    customer.getUserId(), eventId, ticketId, rating, comment)) {

                message = "Bạn đã đánh giá sự kiện này rồi.";

            } else {
                message = "Cảm ơn bạn đã đánh giá sự kiện!";
                ok = true;
            }

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.getSession().setAttribute("reviewMessage", message);
        request.getSession().setAttribute("reviewOk", ok);

        // Quay lại trang phù hợp với nơi gửi đánh giá.
        if (orderId > 0) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/customer/booking-detail?orderId="
                            + orderId + "#booking-review");

        } else {
            response.sendRedirect(
                    request.getContextPath()
                            + "/event/detail?id="
                            + eventId + "#reviews");
        }
    }
}
