package controller;

import dao.CategoryDAO;
import model.Category;
import utils.AdminListFilter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/admin/categories")
public class CategoryController extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Category> all = categoryDAO.getAllCategories();
            String keyword = AdminListFilter.param(request, "keyword");
            String status = AdminListFilter.param(request, "status");
            List<Category> filtered = all.stream().filter(c
                    -> (AdminListFilter.contains(c.getCategoryName(), keyword)
                    || AdminListFilter.contains(c.getDescription(), keyword)
                    || Integer.toString(c.getCategoryId()).contains(keyword))
                    && AdminListFilter.matches(c.getStatus(), status))
                    .collect(Collectors.toList());
            request.setAttribute("allCategories", all);
            request.setAttribute("categories", AdminListFilter.page(request, filtered,
                    AdminListFilter.query("keyword", keyword, "status", status)));
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedStatus", status);
            request.getRequestDispatcher("/WEB-INF/views/admin/category-list.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
