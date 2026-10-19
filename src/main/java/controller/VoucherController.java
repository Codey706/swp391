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
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

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

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/voucher-create.jsp"
            ).forward(request, response);
            return;
        }

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

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (!"create".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {

            String voucherCode = request.getParameter("voucherCode");
            String voucherName = request.getParameter("voucherName");
            String discountType = request.getParameter("discountType");
            String discountValueText = request.getParameter("discountValue");
            String minOrderAmountText = request.getParameter("minOrderAmount");
            String maxDiscountAmountText = request.getParameter("maxDiscountAmount");
            String startTimeText = request.getParameter("startTime");
            String endTimeText = request.getParameter("endTime");
            String usageLimitText = request.getParameter("usageLimit");
            String status = request.getParameter("status");

            if (voucherCode == null || voucherCode.trim().isEmpty()
                    || voucherName == null || voucherName.trim().isEmpty()
                    || discountType == null
                    || (!"Percentage".equals(discountType)
                    && !"Fixed".equals(discountType))
                    || discountValueText == null
                    || startTimeText == null
                    || endTimeText == null
                    || usageLimitText == null
                    || status == null
                    || (!"ACTIVE".equals(status)
                    && !"INACTIVE".equals(status))) {

                request.setAttribute(
                        "error",
                        "Please fill in all required fields correctly."
                );

                request.getRequestDispatcher(
                        "/WEB-INF/views/admin/voucher-create.jsp"
                ).forward(request, response);
                return;
            }

            BigDecimal discountValue = new BigDecimal(discountValueText);
            BigDecimal minOrderAmount
                    = minOrderAmountText == null || minOrderAmountText.trim().isEmpty()
                    ? BigDecimal.ZERO : new BigDecimal(minOrderAmountText);

            BigDecimal maxDiscountAmount
                    = maxDiscountAmountText == null || maxDiscountAmountText.trim().isEmpty()
                    ? null : new BigDecimal(maxDiscountAmountText);

            DateTimeFormatter formatter
                    = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

            LocalDateTime startTime
                    = LocalDateTime.parse(startTimeText, formatter);

            LocalDateTime endTime
                    = LocalDateTime.parse(endTimeText, formatter);

            int usageLimit = Integer.parseInt(usageLimitText);

            if (discountValue.compareTo(BigDecimal.ZERO) <= 0
                    || minOrderAmount.compareTo(BigDecimal.ZERO) < 0
                    || (maxDiscountAmount != null
                    && maxDiscountAmount.compareTo(BigDecimal.ZERO) < 0)
                    || usageLimit <= 0
                    || !endTime.isAfter(startTime)
                    || ("Percentage".equals(discountType)
                    && discountValue.compareTo(new BigDecimal("100")) > 0)) {

                request.setAttribute(
                        "error",
                        "Please check discount values, usage limit, and validity period."
                );

                request.getRequestDispatcher(
                        "/WEB-INF/views/admin/voucher-create.jsp"
                ).forward(request, response);
                return;
            }

            Voucher voucher = new Voucher();

            voucher.setVoucherCode(voucherCode.trim().toUpperCase());
            voucher.setVoucherName(voucherName.trim());
            voucher.setDiscountType(discountType);
            voucher.setDiscountValue(discountValue);
            voucher.setMinOrderAmount(minOrderAmount);
            voucher.setMaxDiscountAmount(maxDiscountAmount);
            voucher.setStartTime(startTime);
            voucher.setEndTime(endTime);
            voucher.setUsageLimit(usageLimit);
            voucher.setStatus(status);

            voucherDAO.createVoucher(voucher);

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/vouchers?success=created"
            );

        } catch (NumberFormatException | DateTimeParseException e) {

            request.setAttribute(
                    "error",
                    "Invalid number or date format."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/voucher-create.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            if (e.getMessage() != null
                    && e.getMessage().contains("UNIQUE")) {

                request.setAttribute(
                        "error",
                        "Voucher code already exists."
                );

                request.getRequestDispatcher(
                        "/WEB-INF/views/admin/voucher-create.jsp"
                ).forward(request, response);

            } else {
                throw new ServletException(
                        "Cannot create voucher",
                        e
                );
            }
        }
    }
}
