package controller;

import utils.SessionUtils;
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
import utils.ValidationUtils;

/**
 * UC-19 Review Event. POST /customer/review (eventId, rating 1-5, comment ≤ 1000 ký tự).
 * Chỉ khách có vé đã check-in (đơn Paid) của sự kiện, mỗi khách 1 đánh giá / sự kiện.
 * AuthFilter đã bắt buộc role Customer cho /customer/*.
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
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), -1);
        if (eventId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        int rating = ValidationUtils.parseIntOrDefault(request.getParameter("rating"), 0);
        String comment = request.getParameter("comment");
        comment = comment == null ? "" : comment.trim();

        String message;
        boolean ok = false;
        try {
            int ticketId = reviewDAO.findCheckedInTicket(customer.getUserId(), eventId);
            if (rating < 1 || rating > 5) {
                message = "Vui lòng chọn số sao từ 1 đến 5.";
            } else if (comment.length() > ReviewDAO.COMMENT_MAX_LENGTH) {
                message = "Nhận xét tối đa " + ReviewDAO.COMMENT_MAX_LENGTH + " ký tự.";
            } else if (ticketId <= 0) {
                message = "Chỉ khách đã check-in sự kiện mới có thể đánh giá.";
            } else if (!reviewDAO.insert(customer.getUserId(), eventId, ticketId, rating, comment)) {
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
        response.sendRedirect(request.getContextPath() + "/event/detail?id=" + eventId + "#reviews");
    }
}
