package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/categories")
public class CategoryController extends HttpServlet {

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

        try {

            request.setAttribute(
                    "categories",
                    categoryDAO.getAllCategories()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/category-list.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot load category list",
                    e
            );
        }
    }
}
