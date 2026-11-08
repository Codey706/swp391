package controller;

import dao.TicketDAO;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Ticket;
import utils.EmailService;
import utils.HtmlUtils;
import utils.QrCodes;

/**
 * Việc cần làm sau khi một đơn vừa chuyển sang Paid. Chỉ được gọi khi
 * PaymentDAO.applyVnPayResult() trả về PAID, tức đúng một lần cho mỗi đơn dù cả
 * Return URL và IPN cùng về — nên email e-ticket chỉ gửi một lần.
 */
final class PaymentNotifier {

    private static final Logger LOGGER = Logger.getLogger(PaymentNotifier.class.getName());
    private static final DateTimeFormatter TIME = DateTimeFormatter.ofPattern("HH:mm, dd/MM/yyyy");

    private PaymentNotifier() {
    }

    static void orderPaid(int orderId) {
        if (orderId <= 0) {
            return;
        }
        LOGGER.info("Order paid, orderId=" + orderId);
        EmailService.sendAsync(() -> sendETickets(orderId));
    }

    /**
     * UC-18: email vé điện tử, mỗi vé một ảnh QR (PNG nhúng cid:qrN).
     */
    private static void sendETickets(int orderId) {
        try {
            TicketDAO ticketDAO = new TicketDAO();
            String[] recipient = ticketDAO.getOrderRecipient(orderId);
            List<Ticket> tickets = ticketDAO.getTicketsByOrderId(orderId);
            if (recipient == null || tickets.isEmpty()) {
                return;
            }
            Map<String, byte[]> images = new LinkedHashMap<>();
            StringBuilder html = new StringBuilder();
            html.append("<div style=\"font-family:Arial,sans-serif;color:#151c27\">")
                    .append("<h2 style=\"color:#ff5722\">Vé điện tử Light Ticket</h2>")
                    .append("<p>Xin chào ").append(HtmlUtils.escape(recipient[1])).append(",</p>")
                    .append("<p>Đơn hàng <b>").append(HtmlUtils.escape(recipient[2]))
                    .append("</b> đã thanh toán thành công. Vui lòng xuất trình mã QR dưới đây tại cổng soát vé.</p>");
            int index = 0;
            for (Ticket ticket : tickets) {
                String cid = "qr" + (++index);
                images.put(cid, QrCodes.png(ticket.getTicketCode(), 240));
                html.append("<table style=\"border:1px solid #e7eaf0;border-radius:12px;margin:14px 0;padding:12px\"><tr>")
                        .append("<td><img src=\"cid:").append(cid).append("\" width=\"160\" height=\"160\" alt=\"QR\"></td>")
                        .append("<td style=\"padding-left:14px;vertical-align:top\">")
                        .append("<b>").append(HtmlUtils.escape(ticket.getEventName())).append("</b><br>")
                        .append(HtmlUtils.escape(ticket.getVenueName())).append("<br>")
                        .append(ticket.getEventStartTime() == null ? "" : ticket.getEventStartTime().format(TIME)).append("<br>")
                        .append(HtmlUtils.escape(ticket.getTicketName()))
                        .append(ticket.getSeatLabel() == null ? "" : " · Ghế " + HtmlUtils.escape(ticket.getSeatLabel()))
                        .append("<br><span style=\"font-family:monospace\">").append(HtmlUtils.escape(ticket.getTicketCode()))
                        .append("</span></td></tr></table>");
            }
            html.append("<p style=\"color:#687386;font-size:12px\">Bạn cũng có thể xem vé trong mục Vé điện tử trên Light Ticket.</p></div>");
            EmailService.sendHtml(recipient[0], "Vé điện tử - Đơn " + recipient[2], html.toString(), images);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Cannot send e-tickets for order " + orderId, e);
        }
    }
}
