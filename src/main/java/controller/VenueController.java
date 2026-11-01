package controller;

import dao.VenueDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Venue;

@WebServlet(name = "VenueController", urlPatterns = {"/admin/venues"})
public class VenueController extends HttpServlet {

    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        if (status == null || status.isEmpty()) {
            status = "ALL";
        }

        try {
            List<Venue> venues = venueDAO.getAllVenues(keyword, status);

            request.setAttribute("venues", venues);
            request.setAttribute("keyword", keyword == null ? "" : keyword);
            request.setAttribute("selectedStatus", status);

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/venue-list.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot load venue list", e);
        }
    }
}
