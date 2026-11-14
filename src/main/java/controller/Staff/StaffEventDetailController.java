package controller.Staff;

import utils.ValidationUtils;
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

/**
 * GET /staff/event-detail?eventId=... : chi tiết một sự kiện được phân công. Sự kiện
 * không tồn tại hoặc không được phân công cho staff đang đăng nhập đều trả 403,
 * nên sửa eventId trên URL không xem được sự kiện của người khác.
 */
@WebServlet(name = "StaffEventDetailController", urlPatterns = {"/staff/event-detail"})
public class StaffEventDetailController extends StaffController {

    private static final String DETAIL_VIEW = "/WEB-INF/views/staff/event-detail.jsp";

    private final StaffEventDAO staffEventDAO = new StaffEventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth staff = currentStaff(request);

            int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), 0);
            if (eventId <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            StaffAssignment assignment = staffEventDAO.findAssignedEvent(
                    staff.getUserId(), eventId, LocalDateTime.now());
            if (assignment == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            request.setAttribute("event", assignment);
            request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
