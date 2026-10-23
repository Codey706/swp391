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
import model.Review;
import utils.DBContext;

/**
 *
 * @author BT
 */
public class ReviewDAO {

    public List<Review> getAllReviews() throws SQLException {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.review_id, r.customer_id, u.full_name AS customer_name, "
                + "r.event_id, e.event_name, r.ticket_id, r.rating, r.comment, "
                + "r.status, r.created_at "
                + "FROM Reviews r "
                + "INNER JOIN Users u ON r.customer_id = u.user_id "
                + "INNER JOIN Events e ON r.event_id = e.event_id "
                + "ORDER BY r.created_at DESC, r.review_id DESC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Review review = new Review();
                review.setReviewId(rs.getInt("review_id"));
                review.setCustomerId(rs.getInt("customer_id"));
                review.setCustomerName(rs.getString("customer_name"));
                review.setEventId(rs.getInt("event_id"));
                review.setEventName(rs.getString("event_name"));
                review.setTicketId(rs.getInt("ticket_id"));
                review.setRating(rs.getInt("rating"));
                review.setComment(rs.getString("comment"));
                review.setStatus(rs.getString("status"));
                Timestamp createdAt = rs.getTimestamp("created_at");
                if (createdAt != null) {
                    review.setCreatedAt(createdAt.toLocalDateTime());
                }
                reviews.add(review);
            }
        }
        return reviews;
    }

    /**
     * Changes visibility only; review content is preserved.
     */
    public boolean updateStatus(int reviewId, String status) throws SQLException {
        if (!"ACTIVE".equals(status) && !"HIDDEN".equals(status)) {
            throw new IllegalArgumentException("Invalid review status");
        }
        String sql = "UPDATE Reviews SET status = ?, updated_at = GETDATE() WHERE review_id = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() == 1;
        }
    }
}
