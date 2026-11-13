package controller;

import dao.CategoryDAO;
import model.Category;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/category-edit")
public class CategoryEditController extends HttpServlet {

    private static final String EDIT_VIEW = "/WEB-INF/views/admin/category-edit.jsp";

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Category category = loadCategory(request);
            if (category == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            request.setAttribute("category", category);
            request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("categoryName") == null ? "" : request.getParameter("categoryName").trim();
        String description = request.getParameter("description") == null ? "" : request.getParameter("description").trim();
        String status = request.getParameter("status");
        try {
            Category category = loadCategory(request);
            if (category == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            category.setCategoryName(name);
            category.setDescription(description);
            category.setStatus(status);

            boolean valid = !name.isEmpty() && name.length() <= 100
                    && !description.isEmpty() && description.length() <= 500
                    && ("ACTIVE".equals(status) || "INACTIVE".equals(status));
            if (!valid) {
                request.setAttribute("errorMessage", "Vui lòng nhập tên hợp lệ, mô tả không quá 500 ký tự "
                        + "và chọn trạng thái hợp lệ.");
                request.setAttribute("category", category);
                request.getRequestDispatcher(EDIT_VIEW).forward(request, response);
                return;
            }
            if (!categoryDAO.updateCategory(category)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/category-detail?id=" + category.getCategoryId());
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** Danh mục theo tham số id; null nếu id sai hoặc không tồn tại. */
    private Category loadCategory(HttpServletRequest request) throws SQLException {
        int id = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        return id > 0 ? categoryDAO.getCategoryById(id) : null;
    }
}
