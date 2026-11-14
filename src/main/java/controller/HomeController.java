
package controller;

import dao.HomeEventDAO;
import dao.WishlistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Collections;
import java.util.Set;
import model.Auth;
import utils.Constants;
import utils.CsrfUtils;
import utils.SessionUtils;
import utils.ValidationUtils;

/**
 * Trang chủ: danh sách sự kiện công khai với tìm kiếm, bộ lọc, sắp xếp, phân
 * trang.
 */
@WebServlet("/home")
public class HomeController extends HttpServlet {

    private static final int PAGE_SIZE = 8;
    private static final long PRICE_MAX = 1_000_000_000L;
    private static final Set<String> SORTS = Set.of(
            "nearest", "newest", "price-asc", "price-desc");

    private final HomeEventDAO homeEventDAO = new HomeEventDAO();
    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HomeEventDAO.Filter filter = new HomeEventDAO.Filter();

        filter.keyword = request.getParameter("keyword");
        filter.categoryId = positiveInt(request.getParameter("categoryId"));
        filter.venueId = positiveInt(request.getParameter("venueId"));
        filter.dateFrom = date(request.getParameter("dateFrom"));
        filter.dateTo = date(request.getParameter("dateTo"));

        if (filter.dateFrom != null && filter.dateTo != null
                && filter.dateFrom.isAfter(filter.dateTo)) {
            LocalDate tmp = filter.dateFrom;
            filter.dateFrom = filter.dateTo;
            filter.dateTo = tmp;
        }

        filter.priceMin = price(request.getParameter("priceMin"));
        filter.priceMax = price(request.getParameter("priceMax"));

        // Dropdown "Mức giá" gửi tham số dạng "min-max".
        String priceRange = request.getParameter("price");

        if (priceRange != null && priceRange.contains("-")) {
            int dash = priceRange.indexOf('-');
            filter.priceMin = price(priceRange.substring(0, dash));
            filter.priceMax = price(priceRange.substring(dash + 1));
        }

        if (filter.priceMin != null && filter.priceMax != null
                && filter.priceMin.compareTo(filter.priceMax) > 0) {
            BigDecimal tmp = filter.priceMin;
            filter.priceMin = filter.priceMax;
            filter.priceMax = tmp;
        }

        String sort = request.getParameter("sort");

        if (sort == null || !SORTS.contains(sort)) {
            sort = "nearest";
        }

        try {
            int total = homeEventDAO.count(filter);

            int totalPages = Math.max(
                    1, (total + PAGE_SIZE - 1) / PAGE_SIZE);

            int page = Math.min(
                    Math.max(1, ValidationUtils.parseIntOrDefault(
                            request.getParameter("page"), 1)),
                    totalPages);

            request.setAttribute(
                    "events",
                    homeEventDAO.list(filter, sort, page, PAGE_SIZE));

            // Lấy danh sách sự kiện yêu thích của Customer.
            Auth customer = SessionUtils.currentUser(request);

            if (customer != null
                    && Constants.ROLE_CUSTOMER.equalsIgnoreCase(customer.getRole())) {

                request.setAttribute(
                        "favoriteIds",
                        wishlistDAO.getFavoriteIds(customer.getUserId()));

                CsrfUtils.expose(request);

            } else {
                request.setAttribute(
                        "favoriteIds",
                        Collections.emptySet());
            }

            // Sự kiện nổi bật và sự kiện đã diễn ra.
            request.setAttribute("featuredEvents", homeEventDAO.featured(5));
            request.setAttribute("pastEvents", homeEventDAO.pastEvents(4));

            request.setAttribute("categories", homeEventDAO.categories());
            request.setAttribute("venues", homeEventDAO.venues());
            request.setAttribute("priceRanges", homeEventDAO.priceRanges());
            request.setAttribute(
                    "priceRange",
                    plain(filter.priceMin) + "-" + plain(filter.priceMax));

            request.setAttribute("totalEvents", total);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("page", page);
            request.setAttribute("pageSize", PAGE_SIZE);

            request.setAttribute(
                    "keyword",
                    filter.keyword == null ? "" : filter.keyword);

            request.setAttribute("categoryId", filter.categoryId);
            request.setAttribute("venueId", filter.venueId);

            request.setAttribute(
                    "dateFrom",
                    filter.dateFrom == null ? "" : filter.dateFrom.toString());

            request.setAttribute(
                    "dateTo",
                    filter.dateTo == null ? "" : filter.dateTo.toString());

            request.setAttribute("priceMin", plain(filter.priceMin));
            request.setAttribute("priceMax", plain(filter.priceMax));
            request.setAttribute("sort", sort);

            request.getRequestDispatcher(
                    "/WEB-INF/views/home/home.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /**
     * Số nguyên dương; null nếu trống hoặc không hợp lệ.
     */
    private static Integer positiveInt(String value) {
        int n = ValidationUtils.parseIntOrDefault(value, 0);
        return n > 0 ? n : null;
    }

    /**
     * yyyy-MM-dd (input type="date"); null nếu trống hoặc sai định dạng.
     */
    private static LocalDate date(String value) {
        if (ValidationUtils.isNullOrBlank(value)) {
            return null;
        }

        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    /**
     * Giá (VND) không âm; null nếu trống hoặc không hợp lệ.
     */
    private static BigDecimal price(String value) {
        if (ValidationUtils.isNullOrBlank(value)) {
            return null;
        }

        try {
            long n = Long.parseLong(value.trim());
            return n >= 0 && n <= PRICE_MAX
                    ? BigDecimal.valueOf(n)
                    : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String plain(BigDecimal value) {
        return value == null ? "" : value.toPlainString();
    }
}
