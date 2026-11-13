package controller;

import dao.TicketDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import utils.SessionUtils;

/** Danh sách vé điện tử của Customer đang đăng nhập. */
@WebServlet("/customer/e-tickets")
public class ETicketController extends HttpServlet {

    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("tickets", ticketDAO.getTicketsByCustomerId(SessionUtils.currentUser(request).getUserId()));
            request.getRequestDispatcher("/WEB-INF/views/customer/e-tickets.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
