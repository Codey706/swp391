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

    private static final String CREATE_VIEW
            = "/WEB-INF/views/admin/voucher-create.jsp";

    private static final String UPDATE_VIEW
            = "/WEB-INF/views/admin/voucher-update.jsp";

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

        try {
            // Mo form tao voucher
            if ("create".equals(action)) {
                request.getRequestDispatcher(CREATE_VIEW)
                        .forward(request, response);
                return;
            }

            // Mo form cap nhat voucher
            if ("edit".equals(action)) {
                String idText = request.getParameter("id");

                if (idText == null || idText.trim().isEmpty()) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Missing voucher ID"
                    );
                    return;
                }

                int voucherId;

                try {
                    voucherId = Integer.parseInt(idText);
                } catch (NumberFormatException e) {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Invalid voucher ID"
                    );
                    return;
                }

                Voucher voucher = voucherDAO.getVoucherById(voucherId);

                if (voucher == null) {
                    response.sendError(
                            HttpServletResponse.SC_NOT_FOUND,
                            "Voucher not found"
                    );
                    return;
                }

                request.setAttribute("voucher", voucher);

                request.getRequestDispatcher(UPDATE_VIEW)
                        .forward(request, response);
                return;
            }

            // Mac dinh hien thi danh sach voucher
            request.setAttribute(
                    "vouchers",
                    voucherDAO.getAllVouchers()
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/voucher-list.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Cannot load voucher",
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

        // Giu nguyen chuc nang Create Voucher
        if ("create".equals(action)) {
            handleCreate(request, response);
            return;
        }

        // Xu ly Update Voucher
        if ("update".equals(action)) {
            handleUpdate(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    private void handleCreate(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Voucher voucher = readVoucherFromRequest(request);

            String error = validateVoucher(voucher);

            if (error != null) {
                request.setAttribute("error", error);
                request.getRequestDispatcher(CREATE_VIEW)
                        .forward(request, response);
                return;
            }

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

            request.getRequestDispatcher(CREATE_VIEW)
                    .forward(request, response);

        } catch (SQLException e) {
            if (isDuplicateVoucherCode(e)) {
                request.setAttribute(
                        "error",
                        "Voucher code already exists."
                );

                request.getRequestDispatcher(CREATE_VIEW)
                        .forward(request, response);
            } else {
                throw new ServletException(
                        "Cannot create voucher",
                        e
                );
            }
        }
    }

    private void handleUpdate(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Voucher voucher;

        // Doc ID va du lieu tu form
        try {
            String idText = request.getParameter("voucherId");

            if (idText == null || idText.trim().isEmpty()) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Missing voucher ID"
                );
                return;
            }

            int voucherId = Integer.parseInt(idText);

            // Kiem tra voucher co ton tai khong
            Voucher existingVoucher = voucherDAO.getVoucherById(voucherId);

            if (existingVoucher == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Voucher not found"
                );
                return;
            }

            voucher = readVoucherFromRequest(request);
            voucher.setVoucherId(voucherId);

            String error = validateVoucher(voucher);

            if (error != null) {
                request.setAttribute("error", error);
                request.setAttribute("voucher", voucher);

                request.getRequestDispatcher(UPDATE_VIEW)
                        .forward(request, response);
                return;
            }

            voucherDAO.updateVoucher(voucher);

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/voucher-detail?id=" + voucherId
                    + "&success=updated"
            );

        } catch (NumberFormatException | DateTimeParseException e) {
            request.setAttribute(
                    "error",
                    "Invalid number or date format."
            );

            // Neu ID hop le, nap lai voucher de hien thi form
            String idText = request.getParameter("voucherId");

            try {
                int voucherId = Integer.parseInt(idText);
                Voucher existingVoucher
                        = voucherDAO.getVoucherById(voucherId);

                if (existingVoucher != null) {
                    request.setAttribute("voucher", existingVoucher);
                }
            } catch (NumberFormatException | SQLException ignored) {
                // Khong lam gi neu ID khong hop le
            }

            request.getRequestDispatcher(UPDATE_VIEW)
                    .forward(request, response);

        } catch (SQLException e) {
            if (isDuplicateVoucherCode(e)) {
                request.setAttribute(
                        "error",
                        "Voucher code already exists."
                );

                String idText = request.getParameter("voucherId");

                try {
                    int voucherId = Integer.parseInt(idText);
                    Voucher existingVoucher
                            = voucherDAO.getVoucherById(voucherId);

                    if (existingVoucher != null) {
                        request.setAttribute("voucher", existingVoucher);
                    }
                } catch (NumberFormatException | SQLException ignored) {
                    // Khong lam gi neu khong the nap lai voucher
                }

                request.getRequestDispatcher(UPDATE_VIEW)
                        .forward(request, response);
            } else {
                throw new ServletException(
                        "Cannot update voucher",
                        e
                );
            }
        }
    }

    // Doc cac truong dung chung cho Create va Update
    private Voucher readVoucherFromRequest(
            HttpServletRequest request)
            throws NumberFormatException, DateTimeParseException {

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

        if (voucherCode == null || voucherName == null
                || discountValueText == null
                || startTimeText == null || endTimeText == null
                || usageLimitText == null) {
            throw new IllegalArgumentException(
                    "Missing required voucher fields"
            );
        }

        BigDecimal discountValue = new BigDecimal(discountValueText);

        BigDecimal minOrderAmount
                = minOrderAmountText == null
                || minOrderAmountText.trim().isEmpty()
                ? BigDecimal.ZERO
                : new BigDecimal(minOrderAmountText);

        BigDecimal maxDiscountAmount
                = maxDiscountAmountText == null
                || maxDiscountAmountText.trim().isEmpty()
                ? null
                : new BigDecimal(maxDiscountAmountText);

        DateTimeFormatter formatter
                = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

        LocalDateTime startTime
                = LocalDateTime.parse(startTimeText, formatter);

        LocalDateTime endTime
                = LocalDateTime.parse(endTimeText, formatter);

        int usageLimit = Integer.parseInt(usageLimitText);

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

        return voucher;
    }

    // Kiem tra du lieu voucher
    private String validateVoucher(Voucher voucher) {

        if (voucher.getVoucherCode() == null
                || voucher.getVoucherCode().trim().isEmpty()
                || voucher.getVoucherName() == null
                || voucher.getVoucherName().trim().isEmpty()
                || voucher.getDiscountType() == null
                || (!"Percentage".equals(voucher.getDiscountType())
                && !"Fixed".equals(voucher.getDiscountType()))
                || voucher.getStartTime() == null
                || voucher.getEndTime() == null
                || voucher.getStatus() == null
                || (!"ACTIVE".equals(voucher.getStatus())
                && !"INACTIVE".equals(voucher.getStatus()))) {

            return "Please fill in all required fields correctly.";
        }

        if (voucher.getDiscountValue() == null
                || voucher.getMinOrderAmount() == null
                || voucher.getUsageLimit() <= 0
                || voucher.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0
                || voucher.getMinOrderAmount().compareTo(BigDecimal.ZERO) < 0
                || (voucher.getMaxDiscountAmount() != null
                && voucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) < 0)
                || !voucher.getEndTime().isAfter(voucher.getStartTime())
                || ("Percentage".equals(voucher.getDiscountType())
                && voucher.getDiscountValue().compareTo(
                        new BigDecimal("100")) > 0)) {

            return "Please check discount values, usage limit, and validity period.";
        }

        return null;
    }

    private boolean isDuplicateVoucherCode(SQLException e) {
        String message = e.getMessage();

        return message != null
                && (message.contains("UNIQUE")
                || message.contains("duplicate")
                || message.contains("Duplicate")
                || message.contains("2627")
                || message.contains("2601"));
    }
}
