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

import model.Event;
import utils.DBContext;

/**
 *
 * @author BT
 */
public class EventStaffDAO {

    public List<Event> getAssignedEvents(int staffId) {
        List<Event> events = new ArrayList<>();

        String sql = """
            SELECT
                e.event_id,
                e.organizer_id,
                e.category_id,
                e.venue_id,
                e.event_name,
                e.description,
                e.event_image,
                e.start_time,
                e.end_time,
                e.status,
                e.cancellation_reason,
                e.created_at,
                e.updated_at,
                v.venue_name
            FROM Event_Staff es
            INNER JOIN Events e
                ON es.event_id = e.event_id
            INNER JOIN Venues v
                ON e.venue_id = v.venue_id
            INNER JOIN Users u
                ON es.staff_id = u.user_id
            WHERE es.staff_id = ?
              AND es.status = 'ACTIVE'
              AND u.role = 'Staff'
              AND u.status = 'ACTIVE'
            ORDER BY e.start_time ASC
            """;

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event event = new Event();

                    event.setEventId(rs.getInt("event_id"));
                    event.setOrganizerId(rs.getInt("organizer_id"));
                    event.setCategoryId(rs.getInt("category_id"));
                    event.setVenueId(rs.getInt("venue_id"));
                    event.setEventName(rs.getString("event_name"));
                    event.setDescription(rs.getString("description"));
                    event.setEventImage(rs.getString("event_image"));
                    event.setStatus(rs.getString("status"));
                    event.setCancellationReason(
                            rs.getString("cancellation_reason")
                    );
                    event.setVenueName(rs.getString("venue_name"));

                    Timestamp startTime = rs.getTimestamp("start_time");
                    if (startTime != null) {
                        event.setStartTime(startTime.toLocalDateTime());
                    }

                    Timestamp endTime = rs.getTimestamp("end_time");
                    if (endTime != null) {
                        event.setEndTime(endTime.toLocalDateTime());
                    }

                    Timestamp createdAt = rs.getTimestamp("created_at");
                    if (createdAt != null) {
                        event.setCreatedAt(createdAt.toLocalDateTime());
                    }

                    Timestamp updatedAt = rs.getTimestamp("updated_at");
                    if (updatedAt != null) {
                        event.setUpdatedAt(updatedAt.toLocalDateTime());
                    }

                    events.add(event);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return events;
    }
}
