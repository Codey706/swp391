package controller.Event;

import static controller.Event.EventController.EVENT_LIST_VIEW;
import static controller.Event.EventController.MODIFIABLE_STATUSES;
import static controller.Event.EventController.trimToNull;
import model.Auth;
import utils.Constants;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * View Event List (Organizer): tìm theo tên, lọc theo trạng thái, phân trang.
 */
@WebServlet(name = "EventListController", urlPatterns = {"/organizer/event/list"})
public class EventListController extends EventController {

    private static final List<String> LIST_STATUSES = Arrays.asList(
            Constants.EVENT_DRAFT, Constants.EVENT_PENDING_APPROVAL, Constants.EVENT_ACTIVE,
            Constants.EVENT_REJECTED, Constants.EVENT_CANCELLED);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }

        String keyword = trimToNull(request.getParameter("keyword"));
        String status = trimToNull(request.getParameter("status"));
        if (status != null) {
            status = status.toUpperCase(Locale.ROOT);
            if (!LIST_STATUSES.contains(status)) {
                status = null; // không tin dữ liệu từ browser
            }
        }
        if (keyword != null && keyword.length() > Constants.EVENT_NAME_MAX_LENGTH) {
            keyword = keyword.substring(0, Constants.EVENT_NAME_MAX_LENGTH);
        }

        int total = eventDAO.countEventsByOrganizer(organizer.getUserId(), keyword, status);
        int totalPages = Math.max(1, (int) Math.ceil(total / (double) Constants.EVENT_PAGE_SIZE));
        int page = Math.min(Math.max(1, ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1)), totalPages);

        request.setAttribute("events", eventDAO.getEventsByOrganizer(
                organizer.getUserId(), keyword, status, page, Constants.EVENT_PAGE_SIZE));
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("statuses", LIST_STATUSES);
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalEvents", total);
        request.setAttribute("modifiableStatuses", MODIFIABLE_STATUSES);
        request.setAttribute("statusCounts", eventDAO.countEventsByStatus(organizer.getUserId()));
        request.setAttribute("salesSummary", eventDAO.getOrganizerSalesSummary(organizer.getUserId()));
        request.setAttribute("pageSize", Constants.EVENT_PAGE_SIZE);
        moveFlashMessage(request, "successMessage", "errorMessage");
        request.getRequestDispatcher(EVENT_LIST_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
