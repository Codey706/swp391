package controller;

import dao.VenueDAO;
import utils.AdminListFilter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import model.Venue;

@WebServlet(name = "VenueController", urlPatterns = {"/admin/venues"})
public class VenueController extends HttpServlet {

    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = AdminListFilter.param(request, "keyword");
        String status = AdminListFilter.param(request, "status");
        if (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status)) {
            status = "ALL";
        }
        try {
            List<Venue> all = venueDAO.getAllVenues("", "ALL");
            List<Venue> filtered = venueDAO.getAllVenues(keyword, status);
            request.setAttribute("allVenues", all);
            request.setAttribute("venues", AdminListFilter.page(request, filtered,
                    AdminListFilter.query("keyword", keyword, "status", status)));
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedStatus", status);
            request.getRequestDispatcher("/WEB-INF/views/admin/venue-list.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
