package controller;

import dao.VoucherDAO;
import model.Voucher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.CsrfUtils;
import utils.ValidationUtils;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/voucher-detail")
public class VoucherDetailController extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int voucherId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
        if (voucherId <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid voucher ID");
            return;
        }
        try {
            Voucher voucher = voucherDAO.getVoucherById(voucherId);
            if (voucher == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Voucher not found");
                return;
            }
            request.setAttribute("voucher", voucher);
            CsrfUtils.expose(request);
            request.getRequestDispatcher("/WEB-INF/views/admin/voucher-detail.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
