package controller;

import dao.VoucherDAO;
import model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/voucher-detail")
public class VoucherDetailController extends HttpServlet {

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

        String idText = request.getParameter("id");

        try {

            if (idText == null || idText.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            int voucherId = Integer.parseInt(idText);

            Voucher voucher = voucherDAO.getVoucherById(voucherId);

            if (voucher == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Voucher not found"
                );
                return;
            }

            request.setAttribute("voucher", voucher);

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/voucher-detail.jsp"
            ).forward(request, response);

        } catch (NumberFormatException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid voucher ID"
            );

        } catch (SQLException e) {

            throw new ServletException(
                    "Cannot load voucher detail",
                    e
            );
        }
    }
}
