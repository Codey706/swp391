/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.TicketDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.util.List;
import model.Ticket;
import model.User;
import utils.Constants;
import model.Auth;

/**
 *
 * @author BT
 */
@WebServlet("/customer/e-tickets")
public class ETicketController extends HttpServlet {

    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        Object account = session.getAttribute(Constants.SESSION_USER);

        int customerId;
        String role;

        if (account instanceof Auth) {
            Auth auth = (Auth) account;
            customerId = auth.getUserId();
            role = auth.getRole();
        } else if (account instanceof User) {
            User user = (User) account;
            customerId = user.getUserId();
            role = user.getRole();
        } else {
            response.sendRedirect(
                    request.getContextPath() + "/Auth?action=login"
            );
            return;
        }

        if (customerId <= 0
                || role == null
                || !Constants.ROLE_CUSTOMER.equalsIgnoreCase(role.trim())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            // Đổi getUserId() nếu model.User dùng tên getter khác.
            List<Ticket> tickets
                    = ticketDAO.getTicketsByCustomerId(customerId);

            request.setAttribute("tickets", tickets);

            request.getRequestDispatcher(
                    "/WEB-INF/views/customer/e-tickets.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot load e-tickets", e
            );
        }
    }

}
