package controller;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import utils.CsrfUtils;
import utils.ValidationUtils;

/**
 * UC-33 Moderate Reviews. GET /admin/reviews?status=&rating=&keyword=&page= :
 * danh sách đánh giá có lọc, phân trang. POST /admin/reviews :
 * action=hide|show, reviewId — ẩn/hiện (đổi Reviews.status), không xóa.
 */
@WebServlet("/admin/reviews")
public class AdminReviewController extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/review-list.jsp";
    private static final int PAGE_SIZE = 10;

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String status = request.getParameter("status");
        if (!ReviewDAO.ACTIVE.equals(status) && !ReviewDAO.HIDDEN.equals(status)) {
            status = null;
        }
        int ratingValue = ValidationUtils.parseIntOrDefault(request.getParameter("rating"), 0);
        Integer rating = ratingValue >= 1 && ratingValue <= 5 ? ratingValue : null;
        String keyword = request.getParameter("keyword");
        keyword = keyword == null ? "" : keyword.trim();
        if (keyword.length() > 100) {
            keyword = keyword.substring(0, 100);
        }
        try {
            int total = reviewDAO.countForAdmin(status, rating, keyword);
            int totalPages = Math.max(1, (total + PAGE_SIZE - 1) / PAGE_SIZE);
            int page = Math.min(Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1)), totalPages);
            request.setAttribute("reviews", reviewDAO.findForAdmin(status, rating, keyword, page, PAGE_SIZE));
            request.setAttribute("total", total);
            request.setAttribute("page", page);
            request.setAttribute("totalPages", totalPages);
        } catch (SQLException e) {
            throw new ServletException("Cannot load reviews", e);
        }
        request.setAttribute("status", status);
        request.setAttribute("rating", rating);
        request.setAttribute("keyword", keyword);
        request.setAttribute("filterQuery", "status=" + (status == null ? "" : status)
                + "&rating=" + (rating == null ? "" : rating)
                + "&keyword=" + URLEncoder.encode(keyword, StandardCharsets.UTF_8));
        CsrfUtils.expose(request);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int reviewId = ValidationUtils.parseIntOrDefault(request.getParameter("reviewId"), -1);
        String action = request.getParameter("action");
        String newStatus = "hide".equals(action) ? ReviewDAO.HIDDEN : "show".equals(action) ? ReviewDAO.ACTIVE : null;
        if (reviewId <= 0 || newStatus == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            reviewDAO.setStatus(reviewId, newStatus);
        } catch (SQLException e) {
            throw new ServletException("Cannot update review", e);
        }
        // Giữ nguyên bộ lọc / trang đang xem (chỉ nhận chuỗi query do chính trang gửi lên)
        String back = request.getParameter("back");
        if (back == null || !back.matches("[A-Za-z0-9=&%+._-]*")) {
            back = "";
        }
        response.sendRedirect(request.getContextPath() + "/admin/reviews?" + back);
    }
}
