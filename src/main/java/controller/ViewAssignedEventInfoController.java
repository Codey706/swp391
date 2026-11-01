/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import model.Auth;
import model.Event;
import service.EventStaffService;

/**
 *
 * @author BT
 */
@WebServlet(name = "ViewAssignedEventInfoController",
        urlPatterns = {"/staff/assigned-events"})
public class ViewAssignedEventInfoController extends HttpServlet {

    private final EventStaffService eventStaffService
            = new EventStaffService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Lấy nhân viên đang đăng nhập từ session
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/Auth?action=login");
            return;
        }

        Object sessionUser = session.getAttribute("user");

        if (!(sessionUser instanceof Auth)) {
            response.sendRedirect(
                    request.getContextPath() + "/Auth?action=login");
            return;
        }

        Auth user = (Auth) sessionUser;

        // Chỉ cho phép tài khoản Staff truy cập
        if (!"Staff".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Lấy danh sách sự kiện được giao cho nhân viên hiện tại
        int staffId = user.getUserId();
        List<Event> events
                = eventStaffService.getAssignedEvents(staffId);

        request.setAttribute("events", events);

        // Chuyển đến trang hiển thị danh sách sự kiện
        request.getRequestDispatcher(
                "/WEB-INF/views/staff/assigned-events.jsp")
                .forward(request, response);
    }
}
