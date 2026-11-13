package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.ValidationUtils;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/category-delete")
public class CategoryDeleteController extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        if (id <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            if (categoryDAO.isCategoryUsedByEvents(id)) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?deleted=in_use");
            } else if (categoryDAO.deleteCategory(id)) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?deleted=success");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
