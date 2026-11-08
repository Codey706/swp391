package controller.Event;

import dao.EventStaffDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Auth;
import model.Event;
import utils.Constants;
import utils.CsrfUtils;
import utils.ValidationUtils;

/**
 * UC-23 Assign Event Staff. GET /organizer/event/staff?eventId= : danh sách
 * staff đã phân công + staff có thể phân công. POST /organizer/event/staff :
 * action=assign|unassign, staffId. Chỉ thao tác trên sự kiện của chính
 * organizer (loadOwnedEvent) và chưa bị hủy.
 */
@WebServlet(name = "EventStaffController", urlPatterns = {"/organizer/event/staff"})
public class EventStaffController extends EventController {

    private static final Logger LOGGER = Logger.getLogger(EventStaffController.class.getName());
    private static final String VIEW = "/WEB-INF/views/organizer/event-staff.jsp";

    private final EventStaffDAO eventStaffDAO = new EventStaffDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        Event event = loadOwnedEvent(request, organizer);
        if (event == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện của bạn.");
            return;
        }
        moveFlashMessage(request, "successMessage", "errorMessage");
        try {
            request.setAttribute("event", event);
            request.setAttribute("assigned", eventStaffDAO.getAssignedStaff(event.getEventId()));
            request.setAttribute("available", eventStaffDAO.getAvailableStaff(event.getEventId()));
            request.setAttribute("editable", !Constants.EVENT_CANCELLED.equalsIgnoreCase(event.getStatus()));
            CsrfUtils.expose(request);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load event staff, eventId=" + event.getEventId(), e);
            throw new ServletException(e);
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Event event = loadOwnedEvent(request, organizer);
        if (event == null) {
            redirectToList(request, response, "errorMessage", "Không tìm thấy sự kiện của bạn.");
            return;
        }
        String back = request.getContextPath() + "/organizer/event/staff?eventId=" + event.getEventId();
        if (Constants.EVENT_CANCELLED.equalsIgnoreCase(event.getStatus())) {
            flash(request, "errorMessage", "Sự kiện đã hủy, không thể thay đổi phân công.");
            response.sendRedirect(back);
            return;
        }
        int staffId = ValidationUtils.parseIntOrDefault(request.getParameter("staffId"), 0);
        String action = request.getParameter("action");
        try {
            if (staffId <= 0) {
                flash(request, "errorMessage", "Vui lòng chọn nhân viên.");
            } else if ("assign".equals(action)) {
                if (eventStaffDAO.assign(event.getEventId(), staffId)) {
                    flash(request, "successMessage", "Đã phân công nhân viên cho sự kiện.");
                } else {
                    flash(request, "errorMessage", "Tài khoản không phải Staff đang hoạt động.");
                }
            } else if ("unassign".equals(action)) {
                eventStaffDAO.unassign(event.getEventId(), staffId);
                flash(request, "successMessage", "Đã gỡ phân công nhân viên.");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot change event staff, eventId=" + event.getEventId(), e);
            flash(request, "errorMessage", "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.");
        }
        response.sendRedirect(back);
    }

    private static void flash(HttpServletRequest request, String key, String message) {
        request.getSession().setAttribute(key, message);
    }
}
