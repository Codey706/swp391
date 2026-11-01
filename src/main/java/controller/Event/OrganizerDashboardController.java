package controller.Event;

import dao.OrganizerDashboardDAO;
import model.Auth;
import utils.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Trang tổng quan (Organizer): thống kê nhanh, biểu đồ doanh thu, tình hình bán
 * vé, sự kiện / đơn hàng gần đây. Chỉ đọc dữ liệu.
 */
@WebServlet(name = "OrganizerDashboardController", urlPatterns = {"/organizer/dashboard"})
public class OrganizerDashboardController extends EventController {

    private static final String DASHBOARD_VIEW = "/WEB-INF/views/organizer/dashboard.jsp";

    private static final List<String> STATUSES = Arrays.asList(
            Constants.EVENT_ACTIVE, Constants.EVENT_PENDING_APPROVAL, Constants.EVENT_DRAFT,
            Constants.EVENT_REJECTED, Constants.EVENT_CANCELLED);

    private final OrganizerDashboardDAO dashboardDAO = new OrganizerDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Auth organizer = getAuthenticatedOrganizer(request, response);
        if (organizer == null) {
            return;
        }
        int organizerId = organizer.getUserId();

        // Thẻ thống kê + tình hình bán vé (dùng lại hàm có sẵn của EventDAO)
        request.setAttribute("statusCounts", eventDAO.countEventsByStatus(organizerId));
        request.setAttribute("salesSummary", eventDAO.getOrganizerSalesSummary(organizerId));
        request.setAttribute("statuses", STATUSES);

        int[] orderCounts = dashboardDAO.getOrderCounts(organizerId);
        request.setAttribute("orderTotal", orderCounts[0]);
        request.setAttribute("orderPending", orderCounts[1]);

        Map<String, BigDecimal> period = dashboardDAO.getPeriodComparison(organizerId);
        request.setAttribute("revenueChange", percentChange(period.get("revenueCurrent"), period.get("revenuePrevious")));
        request.setAttribute("soldChange", percentChange(period.get("soldCurrent"), period.get("soldPrevious")));
        request.setAttribute("periodDays", Constants.DASHBOARD_PERIOD_DAYS);

        // Biểu đồ doanh thu: truyền dạng JSON, JS tự cắt 7/30/90 ngày
        Map<LocalDate, BigDecimal> daily = dashboardDAO.getDailyRevenue(organizerId, Constants.DASHBOARD_CHART_DAYS);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd/MM");
        StringBuilder labels = new StringBuilder("[");
        StringBuilder values = new StringBuilder("[");
        for (Map.Entry<LocalDate, BigDecimal> entry : daily.entrySet()) {
            if (labels.length() > 1) {
                labels.append(',');
                values.append(',');
            }
            labels.append('"').append(entry.getKey().format(fmt)).append('"');
            values.append(entry.getValue().toPlainString());
        }
        request.setAttribute("chartLabels", labels.append(']').toString());
        request.setAttribute("chartValues", values.append(']').toString());

        request.setAttribute("recentEvents", eventDAO.getEventsByOrganizer(
                organizerId, null, null, 1, Constants.DASHBOARD_RECENT_EVENTS));
        request.setAttribute("recentOrders", dashboardDAO.getRecentOrders(organizerId, Constants.DASHBOARD_RECENT_ORDERS));
        request.setAttribute("activities", dashboardDAO.getRecentlyUpdatedEvents(organizerId, Constants.DASHBOARD_RECENT_EVENTS));
        request.getRequestDispatcher(DASHBOARD_VIEW).forward(request, response);
    }

    /** % thay đổi so với kỳ trước; null nếu kỳ trước = 0 (không có cơ sở so sánh). */
    private static Double percentChange(BigDecimal current, BigDecimal previous) {
        if (previous == null || previous.signum() <= 0) {
            return null;
        }
        return current.subtract(previous).multiply(BigDecimal.valueOf(100))
                .divide(previous, 1, RoundingMode.HALF_UP).doubleValue();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
