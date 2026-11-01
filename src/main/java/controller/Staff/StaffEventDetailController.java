package controller.Staff;

import dao.StaffEventDAO;
import model.Auth;
import model.StaffAssignment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /staff/event-detail?eventId=... : chi tiết một sự kiện được phân công. Sự kiện
 * không tồn tại hoặc không được phân công cho staff đang đăng nhập đều trả 403,
 * nên sửa eventId trên URL không xem được sự kiện của người khác.
 */
@WebServlet(name = "StaffEventDetailController", urlPatterns = {"/staff/event-detail"})
public class StaffEventDetailController extends StaffController {

    private static final Logger LOGGER = Logger.getLogger(StaffEventDetailController.class.getName());
    private static final String DETAIL_VIEW = "/WEB-INF/views/staff/event-detail.jsp";

    private final StaffEventDAO staffEventDAO = new StaffEventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth staff = getAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }

        int eventId;
        try {
            eventId = Integer.parseInt(request.getParameter("eventId").trim());
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            StaffAssignment assignment = staffEventDAO.findAssignedEvent(
                    staff.getUserId(), eventId, LocalDateTime.now());
            if (assignment == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            request.setAttribute("event", assignment);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load assigned event, staffId=" + staff.getUserId()
                    + ", eventId=" + eventId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return;
        }
        request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
    }
}
