package controller;

import dao.HomeEventDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/home")
public class HomeController extends HttpServlet {
    private static final int PAGE_SIZE = 6;

    private Integer positiveInt(String value) {
        try { int n=Integer.parseInt(value); return n>0 ? n : null; }
        catch(Exception ex) { return null; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String keyword=request.getParameter("keyword");
        Integer categoryId=positiveInt(request.getParameter("categoryId"));
        Integer venueId=positiveInt(request.getParameter("venueId"));
        String sort=request.getParameter("sort");
        if (!"newest".equals(sort) && !"price-asc".equals(sort) && !"price-desc".equals(sort)) sort="nearest";
        Integer requestedPage=positiveInt(request.getParameter("page"));
        int page=requestedPage==null ? 1 : requestedPage;
        HomeEventDAO dao=new HomeEventDAO();
        try {
            int total=dao.count(keyword,categoryId,venueId);
            int totalPages=Math.max(1,(total+PAGE_SIZE-1)/PAGE_SIZE);
            page=Math.min(page,totalPages);
            request.setAttribute("events",dao.list(keyword,categoryId,venueId,sort,page,PAGE_SIZE));
            request.setAttribute("featuredEvents",dao.featured(5));
            request.setAttribute("categories",dao.categories());
            request.setAttribute("venues",dao.venues());
            request.setAttribute("totalEvents",total);
            request.setAttribute("totalPages",totalPages);
            request.setAttribute("page",page);
            request.setAttribute("pageSize",PAGE_SIZE);
            request.setAttribute("keyword",keyword==null ? "" : keyword);
            request.setAttribute("categoryId",categoryId);
            request.setAttribute("venueId",venueId);
            request.setAttribute("sort",sort);
        } catch(SQLException ex) {
            throw new ServletException("Cannot load homepage events from database",ex);
        }
        request.getRequestDispatcher("/WEB-INF/views/home/home.jsp").forward(request,response);
    }
}
