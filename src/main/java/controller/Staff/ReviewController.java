/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Staff;

import dao.ReviewDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;

/**
 *
 * @author BT
 */
/**
 * UC-25.1 View Reviews List and UC-25 Manage Reviews.
 */
@WebServlet("/admin/reviews")
public class ReviewController extends HttpServlet {

    private ReviewDAO reviewDAO;

    @Override
    public void init() {
        reviewDAO = new ReviewDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("reviews", reviewDAO.getAllReviews());
            request.getRequestDispatcher("/WEB-INF/views/admin/review-list.jsp")
                    .forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Cannot load review list", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String idText = request.getParameter("reviewId");
        String status = request.getParameter("status");

        if (!"changeStatus".equals(action) || idText == null
                || !("ACTIVE".equals(status) || "HIDDEN".equals(status))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int reviewId = Integer.parseInt(idText);
            boolean updated = reviewDAO.updateStatus(reviewId, status);
            response.sendRedirect(request.getContextPath() + "/admin/reviews?message="
                    + (updated ? "updated" : "notfound"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid review ID");
        } catch (SQLException e) {
            throw new ServletException("Cannot update review status", e);
        }
    }
}
