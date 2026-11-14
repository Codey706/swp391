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

@WebServlet("/admin/category-detail")
public class CategoryDetailController extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int categoryId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        if (categoryId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid category ID.");
            return;
        }
        try {
            Category category = categoryDAO.getCategoryById(categoryId);
            if (category == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Category not found.");
                return;
            }
            request.setAttribute("category", category);
            request.getRequestDispatcher("/WEB-INF/views/admin/category-detail.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
