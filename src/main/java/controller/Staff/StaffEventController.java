package controller.Staff;

import dao.StaffEventDAO;
import model.Auth;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * GET /staff : danh sách sự kiện được phân công cho Staff đang đăng nhập, có tab
 * trạng thái, tìm kiếm theo tên, lọc thời gian và phân trang.
 */
@WebServlet(name = "StaffEventController", urlPatterns = {"/staff"})
public class StaffEventController extends StaffController {

    private static final Logger LOGGER = Logger.getLogger(StaffEventController.class.getName());
    private static final String LIST_VIEW = "/WEB-INF/views/staff/assigned-events.jsp";
    private static final int KEYWORD_MAX_LENGTH = 200;

    private static final Map<String, String> TAB_LABELS = new LinkedHashMap<>();
    private static final Map<String, String> RANGE_LABELS = new LinkedHashMap<>();

    static {
        TAB_LABELS.put(StaffEventDAO.TAB_ALL, "Tất cả");
        TAB_LABELS.put(StaffEventDAO.TAB_UPCOMING, "Sắp diễn ra");
        TAB_LABELS.put(StaffEventDAO.TAB_ONGOING, "Đang diễn ra");
        TAB_LABELS.put(StaffEventDAO.TAB_ENDED, "Đã kết thúc");

        RANGE_LABELS.put(StaffEventDAO.RANGE_ALL, "Tất cả thời gian");
        RANGE_LABELS.put(StaffEventDAO.RANGE_TODAY, "Hôm nay");
        RANGE_LABELS.put(StaffEventDAO.RANGE_WEEK, "7 ngày tới");
        RANGE_LABELS.put(StaffEventDAO.RANGE_MONTH, "Tháng này");
        RANGE_LABELS.put(StaffEventDAO.RANGE_PAST, "Đã qua");
    }

    private final StaffEventDAO staffEventDAO = new StaffEventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Auth staff = getAuthenticatedStaff(request, response);
        if (staff == null) {
            return;
        }

        String tab = whitelist(request.getParameter("tab"), TAB_LABELS, StaffEventDAO.TAB_ALL);
        String range = whitelist(request.getParameter("range"), RANGE_LABELS, StaffEventDAO.RANGE_ALL);
        String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
        if (keyword.length() > KEYWORD_MAX_LENGTH) {
            keyword = keyword.substring(0, KEYWORD_MAX_LENGTH);
        }

        int staffId = staff.getUserId();
        int pageSize = Constants.STAFF_EVENT_PAGE_SIZE;
        LocalDateTime now = LocalDateTime.now();

        try {
            Map<String, Integer> tabCounts = staffEventDAO.countByTab(staffId, now);
            int totalResults = staffEventDAO.countAssigned(staffId, tab, keyword, range, now);
            int totalPages = Math.max(1, (int) Math.ceil(totalResults / (double) pageSize));
            int currentPage = Math.min(Math.max(parseInt(request.getParameter("page"), 1), 1), totalPages);

            request.setAttribute("events", staffEventDAO.findAssigned(
                    staffId, tab, keyword, range, now, currentPage, pageSize));
            request.setAttribute("tabCounts", tabCounts);
            request.setAttribute("totalAssigned", tabCounts.get(StaffEventDAO.TAB_ALL));
            request.setAttribute("totalResults", totalResults);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("fromItem", totalResults == 0 ? 0 : (currentPage - 1) * pageSize + 1);
            request.setAttribute("toItem", Math.min(currentPage * pageSize, totalResults));
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot load assigned events, staffId=" + staffId, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ERROR_GENERIC);
            return;
        }

        request.setAttribute("tabLabels", TAB_LABELS);
        request.setAttribute("rangeLabels", RANGE_LABELS);
        request.setAttribute("selectedTab", tab);
        request.setAttribute("selectedRange", range);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private static String whitelist(String value, Map<String, String> allowed, String fallback) {
        return value != null && allowed.containsKey(value) ? value : fallback;
    }

    private static int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value == null ? "" : value.trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
