package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/category-create")
public class CategoryCreateController extends HttpServlet {

    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher(
                "/WEB-INF/views/admin/category-create.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String categoryName = request.getParameter("categoryName");
        String description = request.getParameter("description");
        String status = request.getParameter("status");

        // Check Category Name
        if (categoryName == null || categoryName.trim().isEmpty()) {

            request.setAttribute(
                    "error",
                    "Category name cannot be empty."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/category-create.jsp"
            ).forward(request, response);

            return;
        }

        // Check Description
        if (description == null || description.trim().isEmpty()) {

            request.setAttribute(
                    "error",
                    "Description cannot be empty."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/category-create.jsp"
            ).forward(request, response);

            return;
        }

        // Check Status
        if (!"ACTIVE".equalsIgnoreCase(status)
                && !"INACTIVE".equalsIgnoreCase(status)) {

            request.setAttribute(
                    "error",
                    "Invalid category status."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/category-create.jsp"
            ).forward(request, response);

            return;
        }

        Category category = new Category();

        category.setCategoryName(categoryName.trim());
        category.setDescription(description.trim());
        category.setStatus(status.toUpperCase());

        try {

            categoryDAO.createCategory(category);

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/categories"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot create category",
                    e
            );
        }
    }
}
