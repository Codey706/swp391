/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.Ticket;
import utils.DBContext;

/**
 *
 * @author ADMIN
 */
public class TicketDAO {
    public List<Ticket> getTicketsByCustomerId(int customerId)
        throws SQLException {

    String sql = """
        SELECT
            t.ticket_id,
            o.order_id,
            t.ticket_code,
            t.qr_code,
            t.ticket_status,
            e.event_name,
            e.start_time,
            v.venue_name,
            et.ticket_name,
            es.seat_label
        FROM Tickets t
        JOIN Order_Details od
            ON od.order_detail_id = t.order_detail_id
        JOIN Orders o
            ON o.order_id = od.order_id
        JOIN Events e
            ON e.event_id = t.event_id
        JOIN Venues v
            ON v.venue_id = e.venue_id
        JOIN Event_Tickets et
            ON et.event_ticket_id = od.event_ticket_id
        LEFT JOIN Event_Seats es
            ON es.event_seat_id = t.event_seat_id
        WHERE o.customer_id = ?
          AND o.status = 'Paid'
          AND t.ticket_status IN ('Valid', 'CheckedIn')
        ORDER BY e.start_time, t.ticket_id
        """;

    List<Ticket> tickets = new ArrayList<>();

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, customerId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Ticket ticket = new Ticket();

                ticket.setTicketId(rs.getInt("ticket_id"));
                ticket.setOrderId(rs.getInt("order_id"));
                ticket.setTicketCode(rs.getString("ticket_code"));
                ticket.setQrCode(rs.getString("qr_code"));
                ticket.setTicketStatus(
                    rs.getString("ticket_status")
                );
                ticket.setEventName(rs.getString("event_name"));
                ticket.setVenueName(rs.getString("venue_name"));
                ticket.setTicketName(rs.getString("ticket_name"));
                ticket.setSeatLabel(rs.getString("seat_label"));

                Timestamp startTime = rs.getTimestamp("start_time");
                if (startTime != null) {
                    ticket.setEventStartTime(
                        startTime.toLocalDateTime()
                    );
                }

                tickets.add(ticket);
            }
        }
    }

    return tickets;
}
}
