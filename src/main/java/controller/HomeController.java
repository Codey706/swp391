package controller;

import dao.HomeEventDAO;
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

@WebServlet("/home")
public class HomeController extends HttpServlet {
    private static final int PAGE_SIZE = 6;
    private static final long PRICE_MAX = 1_000_000_000L;

    private Integer positiveInt(String value) {
        try { int n=Integer.parseInt(value); return n>0 ? n : null; }
        catch(Exception ex) { return null; }
    }

    /** yyyy-MM-dd (input type="date"); null nếu trống hoặc sai định dạng. */
    private LocalDate date(String value) {
        if (value == null || value.isBlank()) return null;
        try { return LocalDate.parse(value.trim()); }
        catch (DateTimeParseException ex) { return null; }
    }

    /** Giá (VND) không âm; null nếu trống hoặc không hợp lệ. */
    private BigDecimal price(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            long n = Long.parseLong(value.trim());
            return n >= 0 && n <= PRICE_MAX ? BigDecimal.valueOf(n) : null;
        } catch (NumberFormatException ex) { return null; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HomeEventDAO.Filter filter = new HomeEventDAO.Filter();
        filter.keyword = request.getParameter("keyword");
        filter.categoryId = positiveInt(request.getParameter("categoryId"));
        filter.venueId = positiveInt(request.getParameter("venueId"));
        filter.dateFrom = date(request.getParameter("dateFrom"));
        filter.dateTo = date(request.getParameter("dateTo"));
        if (filter.dateFrom != null && filter.dateTo != null && filter.dateFrom.isAfter(filter.dateTo)) {
            LocalDate tmp = filter.dateFrom; filter.dateFrom = filter.dateTo; filter.dateTo = tmp;
        }
        filter.priceMin = price(request.getParameter("priceMin"));
        filter.priceMax = price(request.getParameter("priceMax"));
        // Dropdown "Mức giá" gửi một tham số dạng "min-max" (vế trống = không giới hạn)
        String priceRange = request.getParameter("price");
        if (priceRange != null && priceRange.contains("-")) {
            int dash = priceRange.indexOf('-');
            filter.priceMin = price(priceRange.substring(0, dash));
            filter.priceMax = price(priceRange.substring(dash + 1));
        }
        if (filter.priceMin != null && filter.priceMax != null && filter.priceMin.compareTo(filter.priceMax) > 0) {
            BigDecimal tmp = filter.priceMin; filter.priceMin = filter.priceMax; filter.priceMax = tmp;
        }
        String sort=request.getParameter("sort");
        if (!"newest".equals(sort) && !"price-asc".equals(sort) && !"price-desc".equals(sort)) sort="nearest";
        Integer requestedPage=positiveInt(request.getParameter("page"));
        int page=requestedPage==null ? 1 : requestedPage;
        HomeEventDAO dao=new HomeEventDAO();
        try {
            int total=dao.count(filter);
            int totalPages=Math.max(1,(total+PAGE_SIZE-1)/PAGE_SIZE);
            page=Math.min(page,totalPages);
            request.setAttribute("events",dao.list(filter,sort,page,PAGE_SIZE));
            request.setAttribute("featuredEvents",dao.featured(5));
            request.setAttribute("categories",dao.categories());
            request.setAttribute("venues",dao.venues());
            request.setAttribute("priceRanges",dao.priceRanges());
            request.setAttribute("priceRange",
                (filter.priceMin==null ? "" : filter.priceMin.toPlainString()) + "-" +
                (filter.priceMax==null ? "" : filter.priceMax.toPlainString()));
            request.setAttribute("totalEvents",total);
            request.setAttribute("totalPages",totalPages);
            request.setAttribute("page",page);
            request.setAttribute("pageSize",PAGE_SIZE);
            request.setAttribute("keyword",filter.keyword==null ? "" : filter.keyword);
            request.setAttribute("categoryId",filter.categoryId);
            request.setAttribute("venueId",filter.venueId);
            request.setAttribute("dateFrom",filter.dateFrom==null ? "" : filter.dateFrom.toString());
            request.setAttribute("dateTo",filter.dateTo==null ? "" : filter.dateTo.toString());
            request.setAttribute("priceMin",filter.priceMin==null ? "" : filter.priceMin.toPlainString());
            request.setAttribute("priceMax",filter.priceMax==null ? "" : filter.priceMax.toPlainString());
            request.setAttribute("sort",sort);
        } catch(SQLException ex) {
            throw new ServletException("Cannot load homepage events from database",ex);
        }
        request.getRequestDispatcher("/WEB-INF/views/home/home.jsp").forward(request,response);
    }
}
