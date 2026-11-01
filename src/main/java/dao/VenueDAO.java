package dao;

import model.Venue;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class VenueDAO {

    public List<Venue> getAllVenues(String keyword, String status)
            throws SQLException {

        List<Venue> venues = new ArrayList<>();

        String sql = "SELECT venue_id, venue_name, address, "
                + "description, capacity, status, failed_attempts, "
                + "locked_until, created_at, updated_at "
                + "FROM Venues "
                + "WHERE (venue_name LIKE ? OR address LIKE ?) ";

        if (status != null && !status.isEmpty()
                && !status.equalsIgnoreCase("ALL")) {
            sql += "AND status = ? ";
        }

        sql += "ORDER BY venue_id";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            String search = keyword == null ? "" : keyword.trim();

            statement.setString(1, "%" + search + "%");
            statement.setString(2, "%" + search + "%");

            if (status != null && !status.isEmpty()
                    && !status.equalsIgnoreCase("ALL")) {
                statement.setString(3, status);
            }

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Venue venue = mapVenue(resultSet);
                    venues.add(venue);
                }
            }
        }

        return venues;
    }

    public Venue getVenueById(int venueId) throws SQLException {

        String sql = "SELECT venue_id, venue_name, address, "
                + "description, capacity, status, failed_attempts, "
                + "locked_until, created_at, updated_at "
                + "FROM Venues "
                + "WHERE venue_id = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, venueId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return mapVenue(resultSet);
                }
            }
        }

        return null;
    }

    private Venue mapVenue(ResultSet resultSet) throws SQLException {

        Venue venue = new Venue();

        venue.setVenueId(resultSet.getInt("venue_id"));
        venue.setVenueName(resultSet.getString("venue_name"));
        venue.setAddress(resultSet.getString("address"));
        venue.setDescription(resultSet.getString("description"));
        venue.setCapacity(resultSet.getInt("capacity"));
        venue.setStatus(resultSet.getString("status"));
        venue.setFailedAttempts(resultSet.getInt("failed_attempts"));

        Timestamp lockedUntil = resultSet.getTimestamp("locked_until");
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");

        if (lockedUntil != null) {
            venue.setLockedUntil(lockedUntil.toLocalDateTime());
        }

        if (createdAt != null) {
            venue.setCreatedAt(createdAt.toLocalDateTime());
        }

        if (updatedAt != null) {
            venue.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return venue;
    }
}
