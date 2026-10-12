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
@WebServlet("/staff")
public class StaffEventsServlet extends HttpServlet {

    private EventStaffService eventStaffService;

    @Override
    public void init() {
        eventStaffService = new EventStaffService();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/Auth"
            );
            return;
        }

        Object sessionUser = session.getAttribute("user");

        if (!(sessionUser instanceof Auth)) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED
            );
            return;
        }

        Auth user = (Auth) sessionUser;

        if (!"Staff".equalsIgnoreCase(user.getRole())) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN
            );
            return;
        }

        List<Event> events
                = eventStaffService.getAssignedEvents(user.getUserId());

        request.setAttribute("events", events);

        request.getRequestDispatcher("/WEB-INF/views/staff/assigned-events.jsp")
                .forward(request, response);
    }
}
