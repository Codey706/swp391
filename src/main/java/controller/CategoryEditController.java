package controller;

import dao.CategoryDAO;
import model.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/category-edit")
public class CategoryEditController extends HttpServlet {

    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        try {
            int id = Integer.parseInt(idParam);

            if (id <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            Category category = categoryDAO.getCategoryById(id);

            if (category == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            request.setAttribute("category", category);
            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/category-edit.jsp"
            ).forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            throw new ServletException("Unable to load category.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String idParam = request.getParameter("id");
        String name = request.getParameter("categoryName");
        String description = request.getParameter("description");
        String status = request.getParameter("status");

        int id;

        try {
            id = Integer.parseInt(idParam);

            if (id <= 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        name = name == null ? "" : name.trim();
        description = description == null ? "" : description.trim();

        if (name.isEmpty() || name.length() > 100
                || description.isEmpty()
                || description.length() > 500
                || !("ACTIVE".equals(status)
                || "INACTIVE".equals(status))) {

            request.setAttribute("errorMessage",
                    "Vui lòng nhập tên hợp lệ, mô tả không quá 500 ký tự "
                    + "và chọn trạng thái hợp lệ.");

            try {
                Category category = categoryDAO.getCategoryById(id);

                if (category == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }

                category.setCategoryName(name);
                category.setDescription(description);
                category.setStatus(status);

                request.setAttribute("category", category);
                request.getRequestDispatcher(
                        "/WEB-INF/views/admin/category-edit.jsp"
                ).forward(request, response);

            } catch (SQLException e) {
                throw new ServletException("Unable to load category.", e);
            }

            return;
        }

        try {
            Category existing = categoryDAO.getCategoryById(id);

            if (existing == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            existing.setCategoryName(name);
            existing.setDescription(description);
            existing.setStatus(status);

            if (categoryDAO.updateCategory(existing)) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/category-detail?id="
                        + existing.getCategoryId()
                );
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to update category.", e);
        }
    }
}
