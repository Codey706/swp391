package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/category-delete")
public class CategoryDeleteController extends HttpServlet {

    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        try {
            int id = Integer.parseInt(idParam);

            if (id <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            boolean deleted = categoryDAO.deleteCategory(id);

            if (deleted) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/categories?deleted=success"
                );
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            throw new ServletException("Unable to delete category.", e);
        }
    }
}
