package controller;

import dao.VoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/vouchers")
public class VoucherController extends HttpServlet {

    private VoucherDAO voucherDAO;

    @Override
    public void init() {
        voucherDAO = new VoucherDAO();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            request.setAttribute(
                    "vouchers",
                    voucherDAO.getAllVouchers()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/voucher-list.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot load voucher list",
                    e
            );
        }
    }
}
