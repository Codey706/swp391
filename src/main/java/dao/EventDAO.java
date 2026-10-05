package dao;

import model.Event;
import utils.DBContext; // TODO: giả định DBContext.getConnection() là static, trả về java.sql.Connection

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
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
        try (Connection connection = DBContext.getConnection();
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
        try (Connection connection = DBContext.getConnection();
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
        try (Connection connection = DBContext.getConnection();
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
        try (Connection connection = DBContext.getConnection();
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


    // ------------------------------------------------------------ Update / Delete / View List

    private static final String SELECT_EVENT_COLUMNS =
            "SELECT e.event_id, e.organizer_id, e.category_id, e.venue_id, e.event_name, e.description, "
            + "e.event_image, e.start_time, e.end_time, e.status, e.cancellation_reason, e.created_at, "
            + "e.updated_at, c.category_name, v.venue_name "
            + "FROM Events e JOIN Categories c ON c.category_id = e.category_id "
            + "JOIN Venues v ON v.venue_id = e.venue_id ";

    private static final String GET_EVENT_BY_ID_AND_ORGANIZER =
            SELECT_EVENT_COLUMNS + "WHERE e.event_id = ? AND e.organizer_id = ?";

    private static final String UPDATE_EVENT =
            "UPDATE Events SET category_id = ?, venue_id = ?, event_name = ?, description = ?, "
            + "start_time = ?, end_time = ?, status = ?, updated_at = GETDATE() "
            + "WHERE event_id = ? AND organizer_id = ?";

    // Phiên bản "loại trừ chính nó" của hai hàm kiểm tra trùng khi tạo
    private static final String CHECK_DUPLICATE_EXCLUDING =
            "SELECT 1 FROM Events WHERE organizer_id = ? AND LOWER(event_name) = LOWER(?) "
            + "AND start_time = ? AND event_id <> ?";

    private static final String CHECK_VENUE_CONFLICT_EXCLUDING =
            "SELECT 1 FROM Events WHERE venue_id = ? AND status NOT IN (?, ?) "
            + "AND start_time < ? AND end_time > ? AND event_id <> ?";

    // Sự kiện đã phát sinh dữ liệu bán hàng (đơn, vé, đánh giá) thì không được xóa
    private static final String HAS_SALES_DATA =
            "SELECT CASE WHEN EXISTS (SELECT 1 FROM Order_Details od JOIN Event_Tickets et "
            + "ON et.event_ticket_id = od.event_ticket_id WHERE et.event_id = ?) "
            + "OR EXISTS (SELECT 1 FROM Order_Seats os JOIN Event_Seats es "
            + "ON es.event_seat_id = os.event_seat_id WHERE es.event_id = ?) "
            + "OR EXISTS (SELECT 1 FROM Tickets WHERE event_id = ?) "
            + "OR EXISTS (SELECT 1 FROM Reviews WHERE event_id = ?) THEN 1 ELSE 0 END";

    private static final String[] DELETE_EVENT_STATEMENTS = {
        "DELETE FROM Event_Staff WHERE event_id = ?",
        "DELETE FROM Event_Tickets WHERE event_id = ?",
        "DELETE FROM Event_Seats WHERE event_id = ?",
        "DELETE FROM Events WHERE event_id = ? AND organizer_id = ?" // câu cuối có thêm organizer_id
    };

    /** Lấy sự kiện theo id nhưng chỉ khi thuộc về organizer (kiểm tra ownership). */
    public Event getEventByIdAndOrganizer(int eventId, int organizerId) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(GET_EVENT_BY_ID_AND_ORGANIZER)) {
            statement.setInt(1, eventId);
            statement.setInt(2, organizerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapEvent(resultSet) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Danh sách sự kiện của organizer, có tìm theo tên, lọc theo trạng thái, phân trang.
     * @param keyword null/rỗng = không lọc; @param status null/rỗng = tất cả
     */
    public List<Event> getEventsByOrganizer(int organizerId, String keyword, String status,
                                            int page, int pageSize) {
        List<Event> events = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String where = buildListFilter(organizerId, keyword, status, params);
        String sql = SELECT_EVENT_COLUMNS + where
                + " ORDER BY e.start_time DESC, e.event_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    events.add(mapEvent(resultSet));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    public int countEventsByOrganizer(int organizerId, String keyword, String status) {
        List<Object> params = new ArrayList<>();
        String where = buildListFilter(organizerId, keyword, status, params);
        String sql = "SELECT COUNT(*) FROM Events e " + where;
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Cập nhật thông tin sự kiện (ảnh được cập nhật riêng bằng updateEventImage). */
    public boolean updateEvent(Event event) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(UPDATE_EVENT)) {
            statement.setInt(1, event.getCategoryId());
            statement.setInt(2, event.getVenueId());
            statement.setString(3, event.getEventName());
            statement.setString(4, event.getDescription());
            statement.setTimestamp(5, Timestamp.valueOf(event.getStartTime()));
            statement.setTimestamp(6, Timestamp.valueOf(event.getEndTime()));
            statement.setString(7, event.getStatus());
            statement.setInt(8, event.getEventId());
            statement.setInt(9, event.getOrganizerId());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Trùng tên + giờ bắt đầu với sự kiện KHÁC của cùng organizer. */
    public boolean existsDuplicateEvent(int organizerId, String eventName, Timestamp startTime, int excludeEventId) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(CHECK_DUPLICATE_EXCLUDING)) {
            statement.setInt(1, organizerId);
            statement.setString(2, eventName);
            statement.setTimestamp(3, startTime);
            statement.setInt(4, excludeEventId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Địa điểm đã có sự kiện KHÁC (chưa hủy/từ chối) trùng khoảng thời gian. */
    public boolean existsVenueConflict(int venueId, Timestamp startTime, Timestamp endTime,
                                       String cancelledStatus, String rejectedStatus, int excludeEventId) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(CHECK_VENUE_CONFLICT_EXCLUDING)) {
            statement.setInt(1, venueId);
            statement.setString(2, cancelledStatus);
            statement.setString(3, rejectedStatus);
            statement.setTimestamp(4, endTime);
            statement.setTimestamp(5, startTime);
            statement.setInt(6, excludeEventId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Sự kiện đã có đơn hàng / vé / đánh giá hay chưa. Lỗi DB được coi là "có" để tránh xóa nhầm. */
    public boolean hasSalesData(int eventId) {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(HAS_SALES_DATA)) {
            for (int i = 1; i <= 4; i++) {
                statement.setInt(i, eventId);
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                return !resultSet.next() || resultSet.getInt(1) == 1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    /**
     * Xóa sự kiện cùng cấu hình đi kèm (nhân viên, loại vé, ghế) trong một transaction.
     * Chỉ xóa khi sự kiện thuộc organizer.
     */
    public boolean deleteEvent(int eventId, int organizerId) {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                for (int i = 0; i < DELETE_EVENT_STATEMENTS.length; i++) {
                    boolean isEventStatement = i == DELETE_EVENT_STATEMENTS.length - 1;
                    try (PreparedStatement statement = connection.prepareStatement(DELETE_EVENT_STATEMENTS[i])) {
                        statement.setInt(1, eventId);
                        if (isEventStatement) {
                            statement.setInt(2, organizerId);
                            if (statement.executeUpdate() == 0) {
                                connection.rollback();
                                return false;
                            }
                        } else {
                            statement.executeUpdate();
                        }
                    }
                }
                connection.commit();
                return true;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private String buildListFilter(int organizerId, String keyword, String status, List<Object> params) {
        StringBuilder where = new StringBuilder("WHERE e.organizer_id = ?");
        params.add(organizerId);
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" AND e.event_name LIKE ? ESCAPE '\\'");
            params.add("%" + keyword.trim().replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_").replace("[", "\\[") + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            where.append(" AND e.status = ?");
            params.add(status.trim());
        }
        return where.toString();
    }

    private void bindParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                statement.setInt(i + 1, (Integer) value);
            } else {
                statement.setString(i + 1, (String) value);
            }
        }
    }

    private Event mapEvent(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setEventId(rs.getInt("event_id"));
        event.setOrganizerId(rs.getInt("organizer_id"));
        event.setCategoryId(rs.getInt("category_id"));
        event.setVenueId(rs.getInt("venue_id"));
        event.setEventName(rs.getString("event_name"));
        event.setDescription(rs.getString("description"));
        event.setEventImage(rs.getString("event_image"));
        Timestamp start = rs.getTimestamp("start_time");
        Timestamp end = rs.getTimestamp("end_time");
        Timestamp created = rs.getTimestamp("created_at");
        Timestamp updated = rs.getTimestamp("updated_at");
        event.setStartTime(start == null ? null : start.toLocalDateTime());
        event.setEndTime(end == null ? null : end.toLocalDateTime());
        event.setStatus(rs.getString("status"));
        event.setCancellationReason(rs.getString("cancellation_reason"));
        event.setCreatedAt(created == null ? null : created.toLocalDateTime());
        event.setUpdatedAt(updated == null ? null : updated.toLocalDateTime());
        event.setCategoryName(rs.getString("category_name"));
        event.setVenueName(rs.getString("venue_name"));
        return event;
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
        try (Connection connection = DBContext.getConnection();
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
        try (Connection connection = DBContext.getConnection();
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