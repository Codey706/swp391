package dao;

import model.Event;
import utils.DBcontext; // TODO: giả định DBcontext.getConnection() là static, trả về java.sql.Connection

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.LinkedHashMap;
import java.util.Map;

public class EventDAO {

    private static final String INSERT_EVENT =
            "INSERT INTO Events (organizer_id, category_id, venue_id, event_name, description, "
            + "event_image, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE_EVENT_IMAGE =
            "UPDATE Events SET event_image = ?, updated_at = GETDATE() WHERE event_id = ?";

    private static final String CHECK_DUPLICATE =
            "SELECT 1 FROM Events WHERE organizer_id = ? AND LOWER(event_name) = LOWER(?) AND start_time = ?";

    // Hai khoảng thời gian giao nhau khi: start_cũ < end_mới AND end_cũ > start_mới
    private static final String CHECK_VENUE_CONFLICT =
            "SELECT 1 FROM Events WHERE venue_id = ? AND status NOT IN (?, ?) "
            + "AND start_time < ? AND end_time > ?";

    private static final String CHECK_CATEGORY =
            "SELECT 1 FROM Categories WHERE category_id = ? AND status = 'ACTIVE'";

    private static final String CHECK_VENUE =
            "SELECT 1 FROM Venues WHERE venue_id = ? AND status = 'ACTIVE'";

    private static final String LIST_CATEGORIES =
            "SELECT category_id, category_name FROM Categories WHERE status = 'ACTIVE' ORDER BY category_name";

    private static final String LIST_VENUES =
            "SELECT venue_id, venue_name FROM Venues WHERE status = 'ACTIVE' ORDER BY venue_name";

    /** Tạo sự kiện mới. Thành công thì gán eventId được sinh ra vào đối tượng event. */
    public boolean createEvent(Event event) {
        try (Connection connection = DBcontext.getConnection();
             PreparedStatement statement = connection.prepareStatement(INSERT_EVENT, Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, event.getOrganizerId());
            statement.setInt(2, event.getCategoryId());
            statement.setInt(3, event.getVenueId());
            statement.setString(4, event.getEventName());
            statement.setString(5, event.getDescription());
            if (event.getEventImage() == null) {
                statement.setNull(6, Types.VARCHAR);
            } else {
                statement.setString(6, event.getEventImage());
            }
            statement.setTimestamp(7, Timestamp.valueOf(event.getStartTime()));
            statement.setTimestamp(8, Timestamp.valueOf(event.getEndTime()));
            statement.setString(9, event.getStatus());

            if (statement.executeUpdate() == 0) {
                return false;
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    event.setEventId(keys.getInt(1));
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace(); // TODO: thay bằng logger
            return false;
        }
    }

    /** Cập nhật đường dẫn ảnh sau khi đã biết eventId (tên file ảnh chứa eventId). */
    public boolean updateEventImage(int eventId, String imagePath) {
        try (Connection connection = DBcontext.getConnection();
             PreparedStatement statement = connection.prepareStatement(UPDATE_EVENT_IMAGE)) {
            statement.setString(1, imagePath);
            statement.setInt(2, eventId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Organizer đã có sự kiện cùng tên và cùng giờ bắt đầu chưa. */
    public boolean existsDuplicateEvent(int organizerId, String eventName, Timestamp startTime) {
        try (Connection connection = DBcontext.getConnection();
             PreparedStatement statement = connection.prepareStatement(CHECK_DUPLICATE)) {
            statement.setInt(1, organizerId);
            statement.setString(2, eventName);
            statement.setTimestamp(3, startTime);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Địa điểm đã có sự kiện khác (chưa hủy/từ chối) trùng khoảng thời gian chưa. */
    public boolean existsVenueConflict(int venueId, Timestamp startTime, Timestamp endTime,
                                       String cancelledStatus, String rejectedStatus) {
        try (Connection connection = DBcontext.getConnection();
             PreparedStatement statement = connection.prepareStatement(CHECK_VENUE_CONFLICT)) {
            statement.setInt(1, venueId);
            statement.setString(2, cancelledStatus);
            statement.setString(3, rejectedStatus);
            statement.setTimestamp(4, endTime);
            statement.setTimestamp(5, startTime);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Các hàm dưới đây nên chuyển sang CategoryDAO / VenueDAO khi hai module đó hoàn thành.

    public boolean existsActiveCategory(int categoryId) {
        return existsById(CHECK_CATEGORY, categoryId);
    }

    public boolean existsActiveVenue(int venueId) {
        return existsById(CHECK_VENUE, venueId);
    }

    public Map<Integer, String> getActiveCategories() {
        return getIdNameMap(LIST_CATEGORIES);
    }

    public Map<Integer, String> getActiveVenues() {
        return getIdNameMap(LIST_VENUES);
    }

    private boolean existsById(String sql, int id) {
        try (Connection connection = DBcontext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Map<Integer, String> getIdNameMap(String sql) {
        Map<Integer, String> items = new LinkedHashMap<>();
        try (Connection connection = DBcontext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                items.put(resultSet.getInt(1), resultSet.getString(2));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
}