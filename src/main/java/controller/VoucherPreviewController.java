package controller;

import com.google.gson.JsonObject;
import dao.TicketBookingDAO;
import dao.TicketBookingDAO.BookingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import model.EventTicket;
import utils.Constants;
import utils.ValidationUtils;

/**
 * UC-14: POST /booking/voucher-preview (eventId, voucherCode, quantity_{ticketId}) -> JSON
 * {ok, message, total, discount, finalAmount}. Chỉ tính thử, không tăng used_count;
 * voucher được kiểm tra lại khi tạo đơn.
 */
@WebServlet("/booking/voucher-preview")
public class VoucherPreviewController extends HttpServlet {

    private final TicketBookingDAO ticketDao = new TicketBookingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        JsonObject json = new JsonObject();
        int eventId = ValidationUtils.parseIntOrDefault(request.getParameter("eventId"), -1);
        String code = request.getParameter("voucherCode");
        code = code == null ? "" : code.trim();
        try {
            if (code.isEmpty() || code.length() > Constants.VOUCHER_CODE_MAX_LENGTH) {
                throw new BookingException("Vui lòng nhập mã giảm giá hợp lệ.");
            }
            Map<Integer, Integer> quantities = new LinkedHashMap<>();
            for (EventTicket ticket : ticketDao.getActiveTickets(eventId)) {
                int qty = ValidationUtils.parseIntOrDefault(
                        request.getParameter("quantity_" + ticket.getEventTicketId()), 0);
                if (qty > 0 && qty <= Constants.BOOKING_MAX_TICKETS_PER_ORDER) {
                    quantities.put(ticket.getEventTicketId(), qty);
                }
            }
            BigDecimal[] result = ticketDao.previewVoucher(eventId, quantities, code);
            json.addProperty("ok", true);
            json.addProperty("total", result[0]);
            json.addProperty("discount", result[1]);
            json.addProperty("finalAmount", result[0].subtract(result[1]));
            json.addProperty("message", "Áp dụng được mã giảm giá.");
        } catch (BookingException e) {
            json.addProperty("ok", false);
            json.addProperty("message", e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Cannot preview voucher", e);
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json.toString());
    }
}
