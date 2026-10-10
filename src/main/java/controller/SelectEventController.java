/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.SelectEventDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.BookableEvent;
import utils.Constants;
import utils.ValidationUtils;

/**
 *
 * @author TRUC MAI
 */
@WebServlet(name = "SelectEventController", urlPatterns = {"/booking/select-event"})
public class SelectEventController extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/booking/select-event.jsp";

    private final SelectEventDAO selectEventDao = new SelectEventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
         String keyword = normalizeKeyword(request.getParameter("keyword"));
        int page = Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1));

        try {
            int total = selectEventDao.countBookableEvents(keyword);
            int totalPages = Math.max(1, (int) Math.ceil((double) total / Constants.BOOKING_EVENT_PAGE_SIZE));
            page = Math.min(page, totalPages);

            List<BookableEvent> events = selectEventDao.searchBookableEvents(
                    keyword, page, Constants.BOOKING_EVENT_PAGE_SIZE);
            request.setAttribute("events", events);
            request.setAttribute("totalEvents", total);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
        } catch (SQLException e) {
            getServletContext().log("Cannot load bookable events", e);
            request.setAttribute("errorMessage", "Không thể tải danh sách sự kiện. Vui lòng thử lại sau.");
        }

        request.setAttribute("keyword", keyword == null ? "" : keyword);
        // Được chuyển từ trang chọn vé khi sự kiện không còn khả dụng
        if ("unavailable".equals(request.getParameter("msg"))) {
            request.setAttribute("errorMessage", "Sự kiện không tồn tại hoặc đã ngừng bán vé.");
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private String normalizeKeyword(String keyword) {
        if (ValidationUtils.isNullOrBlank(keyword)) {
            return null;
        }
        String trimmed = keyword.trim();
        return trimmed.length() > Constants.BOOKING_KEYWORD_MAX_LENGTH
                ? trimmed.substring(0, Constants.BOOKING_KEYWORD_MAX_LENGTH)
                : trimmed;
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }
}
