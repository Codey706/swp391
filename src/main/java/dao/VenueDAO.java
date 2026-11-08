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

    // ------------------------------------------------------------ UC-31: thêm / sửa / ngừng / xóa
    public int createVenue(Venue venue) throws SQLException {
        String sql = "INSERT INTO Venues (venue_name, address, description, capacity, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            bindVenue(statement, venue);
            statement.setString(5, venue.getStatus());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : -1;
            }
        }
    }

    public boolean updateVenue(Venue venue) throws SQLException {
        String sql = "UPDATE Venues SET venue_name = ?, address = ?, description = ?, capacity = ?, "
                + "updated_at = GETDATE() WHERE venue_id = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            bindVenue(statement, venue);
            statement.setInt(5, venue.getVenueId());
            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int venueId, String status) throws SQLException {
        String sql = "UPDATE Venues SET status = ?, updated_at = GETDATE() WHERE venue_id = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, venueId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean deleteVenue(int venueId) throws SQLException {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement("DELETE FROM Venues WHERE venue_id = ?")) {
            statement.setInt(1, venueId);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Số sự kiện dùng venue; activeOnly = chỉ đếm sự kiện ACTIVE /
     * PENDING_APPROVAL.
     */
    public int countEvents(int venueId, boolean activeOnly) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Events WHERE venue_id = ?"
                + (activeOnly ? " AND UPPER(status) IN ('ACTIVE', 'PENDING_APPROVAL')" : "");
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, venueId);
            try (ResultSet rs = statement.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /**
     * Seat_Maps / Seats cũ (mẫu theo địa điểm, không còn dùng) vẫn tham chiếu
     * khóa ngoại.
     */
    public boolean hasLegacySeatMaps(int venueId) throws SQLException {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT 1 FROM Seat_Maps WHERE venue_id = ?")) {
            statement.setInt(1, venueId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void bindVenue(PreparedStatement statement, Venue venue) throws SQLException {
        statement.setString(1, venue.getVenueName());
        statement.setString(2, venue.getAddress());
        if (venue.getDescription() == null || venue.getDescription().isEmpty()) {
            statement.setNull(3, java.sql.Types.NVARCHAR);
        } else {
            statement.setString(3, venue.getDescription());
        }
        statement.setInt(4, venue.getCapacity());
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
