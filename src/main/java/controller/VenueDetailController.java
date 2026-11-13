package controller;

import dao.VenueDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Venue;
import utils.CsrfUtils;
import utils.ValidationUtils;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/venue-detail")
public class VenueDetailController extends HttpServlet {

    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int venueId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        if (venueId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid venue ID.");
            return;
        }
        try {
            Venue venue = venueDAO.getVenueById(venueId);
            if (venue == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Venue not found.");
                return;
            }
            request.setAttribute("venue", venue);
            CsrfUtils.expose(request);
            request.getRequestDispatcher("/WEB-INF/views/admin/venue-detail.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
