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

@WebServlet("/admin/category-detail")
public class CategoryDetailController extends HttpServlet {

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

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Category ID is required."
            );
            return;
        }

        int categoryId;

        try {
            categoryId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid category ID."
            );
            return;
        }

        if (categoryId <= 0) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid category ID."
            );
            return;
        }

        try {
            Category category = categoryDAO.getCategoryById(categoryId);

            if (category == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Category not found."
                );
                return;
            }

            request.setAttribute("category", category);

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/category-detail.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot retrieve category details.",
                    e
            );
        }
    }
}
