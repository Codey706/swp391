package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import utils.ValidationUtils;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/category-create")
public class CategoryCreateController extends HttpServlet {

    private static final String CREATE_VIEW = "/WEB-INF/views/admin/category-create.jsp";

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String categoryName = request.getParameter("categoryName");
        String description = request.getParameter("description");
        String status = request.getParameter("status");

        String error = null;
        if (ValidationUtils.isNullOrBlank(categoryName)) {
            error = "Category name cannot be empty.";
        } else if (ValidationUtils.isNullOrBlank(description)) {
            error = "Description cannot be empty.";
        } else if (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status)) {
            error = "Invalid category status.";
        }
        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
            return;
        }

        Category category = new Category();
        category.setCategoryName(categoryName.trim());
        category.setDescription(description.trim());
        category.setStatus(status.toUpperCase());
        try {
            categoryDAO.createCategory(category);
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
