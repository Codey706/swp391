package controller;

import dao.VoucherDAO;
import model.Voucher;
import utils.CsrfUtils;
import utils.DBContext;
import utils.ValidationUtils;

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

    private static final String LIST_VIEW = "/WEB-INF/views/admin/voucher-list.jsp";
    private static final String CREATE_VIEW = "/WEB-INF/views/admin/voucher-create.jsp";
    private static final String UPDATE_VIEW = "/WEB-INF/views/admin/voucher-update.jsp";

    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("create".equals(action)) {
                request.getRequestDispatcher(CREATE_VIEW).forward(request, response);
            } else if ("edit".equals(action)) {
                int voucherId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), 0);
                Voucher voucher = voucherId > 0 ? voucherDAO.getVoucherById(voucherId) : null;
                if (voucher == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Voucher not found");
                    return;
                }
                request.setAttribute("voucher", voucher);
                request.getRequestDispatcher(UPDATE_VIEW).forward(request, response);
            } else {
                request.setAttribute("vouchers", voucherDAO.getAllVouchers());
                request.getRequestDispatcher(LIST_VIEW).forward(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            switch (action == null ? "" : action) {
                case "create" -> save(request, response, false);
                case "update" -> save(request, response, true);
                case "activate", "deactivate" -> changeStatus(request, response, "activate".equals(action));
                default -> response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    /** Tạo mới hoặc cập nhật voucher; lỗi dữ liệu thì hiển thị lại form. */
    private void save(HttpServletRequest request, HttpServletResponse response, boolean update)
            throws ServletException, IOException, SQLException {
        int voucherId = 0;
        if (update) {
            voucherId = ValidationUtils.parseIntOrDefault(request.getParameter("voucherId"), 0);
            Voucher existing = voucherId > 0 ? voucherDAO.getVoucherById(voucherId) : null;
            if (existing == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Voucher not found");
                return;
            }
            request.setAttribute("voucher", existing);
        }

        String error;
        try {
            Voucher voucher = readVoucherFromRequest(request);
            voucher.setVoucherId(voucherId);
            error = validateVoucher(voucher);
            if (error == null) {
                if (update) {
                    voucherDAO.updateVoucher(voucher);
                    response.sendRedirect(request.getContextPath() + "/admin/voucher-detail?id=" + voucherId
                            + "&success=updated");
                } else {
                    voucherDAO.createVoucher(voucher);
                    response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=created");
                }
                return;
            }
            if (update) {
                request.setAttribute("voucher", voucher);
            }
        } catch (IllegalArgumentException | DateTimeParseException e) {
            error = "Invalid number or date format.";
        } catch (SQLException e) {
            if (!DBContext.isDuplicateKey(e)) {
                throw e;
            }
            error = "Voucher code already exists.";
        }
        request.setAttribute("error", error);
        request.getRequestDispatcher(update ? UPDATE_VIEW : CREATE_VIEW).forward(request, response);
    }

    /** Ngừng / kích hoạt voucher (không xóa cứng). */
    private void changeStatus(HttpServletRequest request, HttpServletResponse response, boolean activate)
            throws IOException, SQLException {
        if (!CsrfUtils.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int voucherId = ValidationUtils.parseIntOrDefault(request.getParameter("id"), -1);
        if (voucherId <= 0 || !voucherDAO.updateStatus(voucherId, activate ? "ACTIVE" : "INACTIVE")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Voucher not found");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/admin/voucher-detail?id=" + voucherId
                + "&msg=" + (activate ? "activated" : "deactivated"));
    }

    // Doc cac truong dung chung cho Create va Update
    private Voucher readVoucherFromRequest(HttpServletRequest request) {
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
            throw new IllegalArgumentException("Missing required voucher fields");
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
}
