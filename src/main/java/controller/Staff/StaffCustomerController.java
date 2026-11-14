package controller.Staff;

import dao.StaffCustomerDAO;
import dao.StaffEventDAO;
import model.Auth;
import model.StaffAssignment;
import model.StaffCustomer;
import utils.Constants;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * GET /staff/customers : thông tin khách hàng có vé trong các sự kiện được phân công cho Staff.
 * Tham số: tab (all|checked|unchecked), keyword, page, customerId, eventId.
 *
 * customerId / eventId chỉ là gợi ý chọn: server luôn kiểm tra lại với phạm vi sự kiện của staff
 * (lấy từ session) và trả 403 nếu nằm ngoài phạm vi.
 */
@WebServlet(name = "StaffCustomerController", urlPatterns = {"/staff/customers"})
public class StaffCustomerController extends StaffController {

    private static final String VIEW = "/WEB-INF/views/staff/customers.jsp";
    private static final int KEYWORD_MAX_LENGTH = 100;

    private static final Map<String, String> TAB_LABELS = new LinkedHashMap<>();

    static {
        TAB_LABELS.put(StaffCustomerDAO.TAB_ALL, "Tất cả");
        TAB_LABELS.put(StaffCustomerDAO.TAB_CHECKED, "Đã check-in");
        TAB_LABELS.put(StaffCustomerDAO.TAB_UNCHECKED, "Chưa check-in");
    }

    private final StaffCustomerDAO customerDAO = new StaffCustomerDAO();
    private final StaffEventDAO eventDAO = new StaffEventDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Auth staff = currentStaff(request);
            int staffId = staff.getUserId();

            String tabParam = request.getParameter("tab");
            String tab = tabParam != null && TAB_LABELS.containsKey(tabParam) ? tabParam : StaffCustomerDAO.TAB_ALL;
            String keyword = request.getParameter("keyword") == null ? "" : request.getParameter("keyword").trim();
            if (keyword.length() > KEYWORD_MAX_LENGTH) {
                keyword = keyword.substring(0, KEYWORD_MAX_LENGTH);
            }
            Integer requestedCustomer = parseId(request.getParameter("customerId"));
            Integer requestedEvent = parseId(request.getParameter("eventId"));
            if ((request.getParameter("customerId") != null && requestedCustomer == null)
                    || (request.getParameter("eventId") != null && requestedEvent == null)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            int pageSize = Constants.STAFF_CUSTOMER_PAGE_SIZE;
            LocalDateTime now = LocalDateTime.now();

            // ----- Danh sách khách hàng (bên trái)
            Map<String, Integer> tabCounts = customerDAO.countByTab(staffId);
            int totalResults = customerDAO.countCustomers(staffId, tab, keyword);
            int totalPages = Math.max(1, (int) Math.ceil(totalResults / (double) pageSize));
            int currentPage = Math.min(Math.max(ValidationUtils.parseIntOrDefault(request.getParameter("page"), 1), 1), totalPages);
            List<StaffCustomer> customers = customerDAO.findCustomers(staffId, tab, keyword, currentPage, pageSize);

            request.setAttribute("customers", customers);
            request.setAttribute("tabCounts", tabCounts);
            request.setAttribute("totalAll", tabCounts.get(StaffCustomerDAO.TAB_ALL));
            request.setAttribute("totalResults", totalResults);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);

            // ----- Khách hàng đang chọn (mặc định: người đầu tiên của trang hiện tại)
            Integer customerId = requestedCustomer;
            if (customerId == null && !customers.isEmpty()) {
                customerId = customers.get(0).getUserId();
            }
            if (customerId != null) {
                StaffCustomer customer = customerDAO.findCustomer(staffId, customerId);
                if (customer == null) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                // Các sự kiện được phân công mà khách có vé; sự kiện mặc định: mới nhất
                List<StaffAssignment> customerEvents = eventDAO.findEventsOfCustomer(staffId, customerId, now);
                StaffAssignment selectedEvent = null;
                for (StaffAssignment e : customerEvents) {
                    if (requestedEvent == null ? selectedEvent == null : e.getEventId() == requestedEvent) {
                        selectedEvent = e;
                        break;
                    }
                }
                if (selectedEvent == null) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                int eventId = selectedEvent.getEventId();
                int[] stats = customerDAO.getTicketStats(staffId, customerId, eventId);
                request.setAttribute("customer", customer);
                request.setAttribute("customerEvents", customerEvents);
                request.setAttribute("selectedEvent", selectedEvent);
                request.setAttribute("ticketActive", stats[0]);
                request.setAttribute("ticketChecked", stats[1]);
                request.setAttribute("ticketNotChecked", stats[0] - stats[1]);
                request.setAttribute("ticketCancelled", stats[2]);
                request.setAttribute("contextStatus", StaffCustomer.statusOf(stats[0], stats[1]));
                request.setAttribute("tickets", customerDAO.findTickets(staffId, customerId, eventId));
                request.setAttribute("history", customerDAO.findCheckInHistory(staffId, customerId, eventId));
            }

            request.setAttribute("tabLabels", TAB_LABELS);
            request.setAttribute("selectedTab", tab);
            request.setAttribute("keyword", keyword);
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private static Integer parseId(String value) {
        int id = ValidationUtils.parseIntOrDefault(value, 0);
        return id > 0 ? id : null;
    }
}
