package controller;

import dao.WishlistDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.Auth;
import utils.CsrfUtils;
import utils.SessionUtils;
import utils.ValidationUtils;

@WebServlet("/customer/wishlist")
public class WishlistController extends HttpServlet {

    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Auth customer = SessionUtils.currentUser(request);

        if (customer == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            request.setAttribute(
                    "wishlist",
                    wishlistDAO.getWishlist(customer.getUserId())
            );

            CsrfUtils.expose(request);

            request.getRequestDispatcher(
                    "/WEB-INF/views/customer/wishlist.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Auth customer = SessionUtils.currentUser(request);

        if (customer == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int eventId = ValidationUtils.parseIntOrDefault(
                request.getParameter("eventId"), 0
        );

        String action = request.getParameter("action");

        if (eventId <= 0
                || (!"add".equals(action) && !"remove".equals(action))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            if ("add".equals(action)) {
                wishlistDAO.add(customer.getUserId(), eventId);
            } else {
                wishlistDAO.remove(customer.getUserId(), eventId);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        String redirect = request.getParameter("redirect");

        if ("home".equals(redirect)) {
            response.sendRedirect(request.getContextPath() + "/home");
        } else if ("detail".equals(redirect)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/event/detail?id=" + eventId
            );
        } else {
            response.sendRedirect(
                    request.getContextPath() + "/customer/wishlist"
            );
        }
    }
}
