package controller;

import dao.VenueDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Venue;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/venue-detail")
public class VenueDetailController extends HttpServlet {

    private VenueDAO venueDAO;

    @Override
    public void init() {
        venueDAO = new VenueDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int venueId;

        try {
            venueId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid venue ID."
            );
            return;
        }

        if (venueId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid venue ID."
            );
            return;
        }

        try {
            Venue venue = venueDAO.getVenueById(venueId);

            if (venue == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Venue not found."
                );
                return;
            }

            request.setAttribute("venue", venue);
            utils.CsrfUtils.expose(request);

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/venue-detail.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot retrieve venue details.",
                    e
            );
        }
    }
}
