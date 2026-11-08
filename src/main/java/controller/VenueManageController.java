package controller;

import dao.VenueDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Venue;
import utils.Constants;
import utils.CsrfUtils;
import utils.ValidationUtils;

/**
 * UC-31 Manage Venues (sơ đồ ghế do Organizer vẽ theo từng sự kiện, không quản
 * lý ở đây). GET/POST /admin/venue-create, /admin/venue-edit?id= : form thêm /
 * sửa. POST /admin/venue-action : action=activate|deactivate|delete, id. Không
 * cho ngừng / xóa venue đang gắn với sự kiện ACTIVE hoặc PENDING_APPROVAL;
 * venue đã từng có sự kiện thì không xóa được (chỉ ngừng hoạt động).
 */
@WebServlet(urlPatterns = {"/admin/venue-create", "/admin/venue-edit", "/admin/venue-action"})
public class VenueManageController extends HttpServlet {

    private static final String FORM_VIEW = "/WEB-INF/views/admin/venue-form.jsp";
    private static final int NAME_MAX = 200;
    private static final int ADDRESS_MAX = 500;
    private static final int DESCRIPTION_MAX = 1000;
    private static final int CAPACITY_MAX = 1_000_000;

    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/admin/venue-action".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        try {
            if ("/admin/venue-edit".equals(request.getServletPath())) {
                Venue venue = venueDAO.getVenueById(ValidationUtils.parseIntOrDefault(request.getParameter("id"), -1));
                if (venue == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Venue not found.");
                    return;
                }
                request.setAttribute("venue", venue);
            }
        } catch (SQLException e) {
            throw new ServletException("Cannot load venue", e);
        }
        showForm(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            if ("/admin/venue-action".equals(request.getServletPath())) {
                handleAction(request, response);
                return;
            }
            boolean editing = "/admin/venue-edit".equals(request.getServletPath());
            Venue venue = new Venue();
            if (editing) {
                Venue existing = venueDAO.getVenueById(ValidationUtils.parseIntOrDefault(request.getParameter("id"), -1));
                if (existing == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Venue not found.");
                    return;
                }
                venue.setVenueId(existing.getVenueId());
                venue.setStatus(existing.getStatus());
            } else {
                venue.setStatus("INACTIVE".equals(request.getParameter("status")) ? "INACTIVE" : Constants.STATUS_ACTIVE);
            }
            venue.setVenueName(trim(request.getParameter("venueName")));
            venue.setAddress(trim(request.getParameter("address")));
            venue.setDescription(trim(request.getParameter("description")));
            String capacityText = trim(request.getParameter("capacity"));
            venue.setCapacity(ValidationUtils.parseIntOrDefault(capacityText, -1));

            String error = null;
            if (venue.getVenueName().isEmpty() || venue.getVenueName().length() > NAME_MAX) {
                error = "Tên địa điểm bắt buộc, tối đa " + NAME_MAX + " ký tự.";
            } else if (venue.getAddress().isEmpty() || venue.getAddress().length() > ADDRESS_MAX) {
                error = "Địa chỉ bắt buộc, tối đa " + ADDRESS_MAX + " ký tự.";
            } else if (venue.getDescription().length() > DESCRIPTION_MAX) {
                error = "Mô tả tối đa " + DESCRIPTION_MAX + " ký tự.";
            } else if (venue.getCapacity() < 1 || venue.getCapacity() > CAPACITY_MAX) {
                error = "Sức chứa phải là số nguyên từ 1 đến " + CAPACITY_MAX + ".";
            }
            if (error != null) {
                request.setAttribute("error", error);
                request.setAttribute("venue", venue);
                showForm(request, response);
                return;
            }

            int venueId = editing ? venue.getVenueId() : venueDAO.createVenue(venue);
            if (editing) {
                venueDAO.updateVenue(venue);
            }
            response.sendRedirect(request.getContextPath() + "/admin/venue-detail?id=" + venueId);
        } catch (SQLException e) {
            throw new ServletException("Cannot save venue", e);
        }
    }

    private void handleAction(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int venueId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), -1);
        Venue venue = venueDAO.getVenueById(venueId);
        if (venue == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Venue not found.");
            return;
        }
        String action = request.getParameter("action");
        String result;
        switch (action == null ? "" : action) {
            case "activate" -> {
                venueDAO.updateStatus(venueId, Constants.STATUS_ACTIVE);
                result = "activated";
            }
            case "deactivate" -> {
                if (venueDAO.countEvents(venueId, true) > 0) {
                    result = "in_use";
                } else {
                    venueDAO.updateStatus(venueId, "INACTIVE");
                    result = "deactivated";
                }
            }
            case "delete" -> {
                if (venueDAO.countEvents(venueId, true) > 0) {
                    result = "in_use";
                } else if (venueDAO.countEvents(venueId, false) > 0 || venueDAO.hasLegacySeatMaps(venueId)) {
                    result = "has_history";
                } else {
                    venueDAO.deleteVenue(venueId);
                    response.sendRedirect(request.getContextPath() + "/admin/venues?msg=deleted");
                    return;
                }
            }
            default -> {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/venue-detail?id=" + venueId + "&msg=" + result);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("editing", "/admin/venue-edit".equals(request.getServletPath()));
        CsrfUtils.expose(request);
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
