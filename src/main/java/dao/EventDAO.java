package dao;

import model.Event;
import model.EventTicket;
import model.EventZone;
import utils.Constants;
import utils.DBContext; // giả định DBContext.getConnection() là static, trả về java.sql.Connection

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
import java.util.Locale;
import java.util.Map;

/**
 * Data Access Object for Events. All operations needed by EventController and
 * EventUpdateController are provided here.
 */
public class EventDAO {

    /* --------------------------------------------------------------------
     * SQL statements
     * -------------------------------------------------------------------- */
    private static final String INSERT_EVENT
            = "INSERT INTO Events (organizer_id, category_id, venue_id, event_name, description, "
            + "event_image, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String UPDATE_EVENT_IMAGE
            = "UPDATE Events SET event_image = ?, updated_at = GETDATE() WHERE event_id = ?";

    // --------------------------------------------------------------------
    // Update event (excluding image)
    // --------------------------------------------------------------------
    private static final String UPDATE_EVENT
            = "UPDATE Events SET category_id = ?, venue_id = ?, event_name = ?, description = ?, "
            + "start_time = ?, end_time = ?, status = ?, updated_at = GETDATE() "
            + "WHERE event_id = ? AND organizer_id = ?";

    private static final String CHECK_DUPLICATE_EXCLUDING
            = "SELECT 1 FROM Events WHERE organizer_id = ? AND LOWER(event_name) = LOWER(?) "
            + "AND start_time = ? AND event_id <> ?";

    private static final String CHECK_VENUE_CONFLICT_EXCLUDING
            = "SELECT 1 FROM Events WHERE venue_id = ? AND status NOT IN (?, ?) "
            + "AND start_time < ? AND end_time > ? AND event_id <> ?";

    private static final String HAS_SALES_DATA
            = "SELECT CASE WHEN EXISTS (SELECT 1 FROM Order_Details od "
            + "JOIN Event_Tickets et ON od.event_ticket_id = et.event_ticket_id "
            + "WHERE et.event_id = ?) THEN 1 ELSE 0 END";

    private static final String CHECK_DUPLICATE
            = "SELECT 1 FROM Events WHERE organizer_id = ? AND LOWER(event_name) = LOWER(?) "
            + "AND start_time = ?";

    // Hai khoảng thời gian giao nhau khi: start_cũ < end_mới AND end_cũ > start_mới
    private static final String CHECK_VENUE_CONFLICT
            = "SELECT 1 FROM Events WHERE venue_id = ? AND status NOT IN (?, ?) "
            + "AND start_time < ? AND end_time > ?";

    private static final String CHECK_CATEGORY
            = "SELECT 1 FROM Categories WHERE category_id = ? AND status = 'ACTIVE'";

    private static final String CHECK_VENUE
            = "SELECT 1 FROM Venues WHERE venue_id = ? AND status = 'ACTIVE'";

    private static final String LIST_CATEGORIES
            = "SELECT category_id, category_name FROM Categories WHERE status = 'ACTIVE' ORDER BY category_name";

    private static final String LIST_VENUES
            = "SELECT venue_id, venue_name FROM Venues WHERE status = 'ACTIVE' ORDER BY venue_name";

    private static final String INSERT_TICKET
            = "INSERT INTO Event_Tickets (event_id, ticket_name, description, price, quantity, "
            + "available_quantity, status) VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String GET_VENUE_CAPACITY
            = "SELECT capacity FROM Venues WHERE venue_id = ?";

    private static final String SELECT_EVENT_COLUMNS
            = "SELECT e.event_id, e.organizer_id, e.category_id, e.venue_id, e.event_name, e.description, "
            + "e.event_image, e.start_time, e.end_time, e.status, e.cancellation_reason, e.created_at, "
            + "e.updated_at, c.category_name, v.venue_name, "
            + "(SELECT ISNULL(SUM(t.quantity), 0) FROM Event_Tickets t WHERE t.event_id = e.event_id) AS ticket_total, "
            + "(SELECT ISNULL(SUM(t.quantity - t.available_quantity), 0) FROM Event_Tickets t WHERE t.event_id = e.event_id) AS ticket_sold, "
            + "(SELECT ISNULL(SUM(od.subtotal), 0) FROM Order_Details od "
            + "JOIN Event_Tickets t ON t.event_ticket_id = od.event_ticket_id "
            + "JOIN Orders o ON o.order_id = od.order_id "
            + "WHERE t.event_id = e.event_id AND o.status = 'Paid') AS revenue, "
            + "(SELECT ISNULL(SUM(t.available_quantity), 0) FROM Event_Tickets t WHERE t.event_id = e.event_id) AS remaining "
            + "FROM Events e JOIN Categories c ON c.category_id = e.category_id "
            + "JOIN Venues v ON v.venue_id = e.venue_id";

    private static final String[] DELETE_EVENT_STATEMENTS = {
        "DELETE FROM Event_Staff WHERE event_id = ?",
        // Ghế -> khu -> hạng vé: Event_Seats tham chiếu Event_Zones, Event_Zones tham chiếu Event_Tickets
        "DELETE FROM Event_Seats WHERE event_id = ?",
        "DELETE FROM Event_Zones WHERE event_id = ?",
        "DELETE FROM Event_Tickets WHERE event_id = ?",
        "DELETE FROM Events WHERE event_id = ? AND organizer_id = ?"
    };

    /* --------------------------------------------------------------------
     * Core CRUD operations
     * -------------------------------------------------------------------- */
    /**
     * Tạo sự kiện mới. Thành công thì gán eventId được sinh ra vào đối tượng
     * event.
     */
    public boolean createEvent(Event event) {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(INSERT_EVENT, Statement.RETURN_GENERATED_KEYS)) {

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
            e.printStackTrace(); // TODO: replace with logger
            return false;
        }
    }

    /**
     * Tạo sự kiện cùng các hạng vé trong MỘT transaction: lỗi ở bất kỳ hạng vé
     * nào thì sự kiện cũng không được tạo. Danh sách hạng vé có thể rỗng.
     */
    public boolean createEventWithTickets(Event event, List<EventTicket> tickets) {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                // Insert event (same logic as createEvent but inside transaction)
                try (PreparedStatement statement = connection.prepareStatement(INSERT_EVENT, Statement.RETURN_GENERATED_KEYS)) {
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
                        connection.rollback();
                        return false;
                    }
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            connection.rollback();
                            return false;
                        }
                        event.setEventId(keys.getInt(1));
                    }
                }

                if (tickets != null && !tickets.isEmpty()) {
                    try (PreparedStatement stmt = connection.prepareStatement(INSERT_TICKET)) {
                        for (EventTicket ticket : tickets) {
                            stmt.setInt(1, event.getEventId());
                            stmt.setString(2, ticket.getTicketName());
                            if (ticket.getDescription() == null) {
                                stmt.setNull(3, Types.NVARCHAR);
                            } else {
                                stmt.setString(3, ticket.getDescription());
                            }
                            stmt.setBigDecimal(4, ticket.getPrice());
                            stmt.setInt(5, ticket.getQuantity());
                            // khi mới tạo, available_quantity = quantity (chưa bán)
                            stmt.setInt(6, ticket.getQuantity());
                            stmt.setString(7, Constants.TICKET_ACTIVE);
                            stmt.addBatch();
                        }
                        stmt.executeBatch();
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
            event.setEventId(0);
            return false;
        }
    }

    /**
     * Tạo sự kiện kèm hạng vé + sơ đồ ghế (khu, ghế) trong cùng một
     * transaction.
     */
    public boolean createEventWithSeatMap(Event event, List<EventZone> zones,
            List<SeatMapDAO.TicketChange> tickets) {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                // Insert event (same as above)
                try (PreparedStatement statement = connection.prepareStatement(INSERT_EVENT, Statement.RETURN_GENERATED_KEYS)) {
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
                        connection.rollback();
                        return false;
                    }
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            connection.rollback();
                            return false;
                        }
                        event.setEventId(keys.getInt(1));
                    }
                }

                // Write seat map layout (delegated to SeatMapDAO)
                new SeatMapDAO().writeLayout(connection, event.getEventId(), zones, tickets);

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
            event.setEventId(0);
            return false;
        }
    }

    /* --------------------------------------------------------------------
     * Helper queries used by public UI
     * -------------------------------------------------------------------- */
    /**
     * Lấy danh sách sự kiện công khai (khách) với tùy chọn tìm kiếm và lọc
     * trạng thái.
     */
    public List<Event> getPublicEvents(String keyword, String status,
            int page, int pageSize, List<Object> outParams) {
        List<Object> params = new ArrayList<>();
        StringBuilder where = new StringBuilder("WHERE e.status = ?");
        // Mặc định hiển thị ACTIVE nếu không truyền
        params.add((status != null && !status.isBlank()) ? status : Constants.EVENT_ACTIVE);
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" AND e.event_name LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        String sql = SELECT_EVENT_COLUMNS + where
                + " ORDER BY e.start_time DESC, e.event_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        int offset = (page - 1) * pageSize;
        params.add(offset);
        params.add(pageSize);
        List<Event> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            bindParams(stmt, params);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapEvent(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // total count for pagination
        outParams.add(countPublicEvents(keyword, status));
        return list;
    }

    /**
     * Lấy chi tiết một sự kiện công khai không kiểm tra organizer.
     */
    public Event getPublicEventById(int eventId) {
        String sql = SELECT_EVENT_COLUMNS + " WHERE e.event_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, eventId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? mapEvent(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    private int countPublicEvents(String keyword, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Events e WHERE e.status = ?");
        List<Object> params = new ArrayList<>();
        params.add((status != null && !status.isBlank()) ? status : Constants.EVENT_ACTIVE);
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND e.event_name LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            bindParams(stmt, params);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /* --------------------------------------------------------------------
     * Misc helper methods
     * -------------------------------------------------------------------- */
    public Map<Integer, Integer> getVenueCapacities() {
        Map<Integer, Integer> result = new LinkedHashMap<>();
        String sql = "SELECT venue_id, capacity FROM Venues WHERE status = 'ACTIVE'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                result.put(rs.getInt(1), rs.getInt(2));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public boolean submitForApproval(int eventId, int organizerId) {
        String sql = "UPDATE Events SET status = ?, updated_at = GETDATE() "
                + "WHERE event_id = ? AND organizer_id = ? AND status IN (?, ?)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, Constants.EVENT_PENDING_APPROVAL);
            statement.setInt(2, eventId);
            statement.setInt(3, organizerId);
            statement.setString(4, Constants.EVENT_DRAFT);
            statement.setString(5, Constants.EVENT_REJECTED);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getVenueCapacity(int venueId) {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(GET_VENUE_CAPACITY)) {
            statement.setInt(1, venueId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }

    public boolean updateEventImage(int eventId, String imagePath) {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(UPDATE_EVENT_IMAGE)) {
            statement.setString(1, imagePath);
            statement.setInt(2, eventId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean existsDuplicateEvent(int organizerId, String eventName,
            Timestamp startTime, int excludeEventId) {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(CHECK_DUPLICATE_EXCLUDING)) {
            statement.setInt(1, organizerId);
            statement.setString(2, eventName);
            statement.setTimestamp(3, startTime);
            statement.setInt(4, excludeEventId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean existsVenueConflict(int venueId, Timestamp startTime,
            Timestamp endTime, String cancelledStatus,
            String rejectedStatus, int excludeEventId) {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(CHECK_VENUE_CONFLICT_EXCLUDING)) {
            statement.setInt(1, venueId);
            statement.setString(2, cancelledStatus);
            statement.setString(3, rejectedStatus);
            statement.setTimestamp(4, endTime);
            statement.setTimestamp(5, startTime);
            statement.setInt(6, excludeEventId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // --------------------------------------------------------------------
    // Lấy sự kiện theo id nhưng chỉ khi thuộc về organizer (kiểm tra ownership).
    // --------------------------------------------------------------------
    private static final String GET_EVENT_BY_ID_AND_ORGANIZER
            = SELECT_EVENT_COLUMNS + " WHERE e.event_id = ? AND e.organizer_id = ?";

    public Event getEventByIdAndOrganizer(int eventId, int organizerId) {
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(GET_EVENT_BY_ID_AND_ORGANIZER)) {
            statement.setInt(1, eventId);
            statement.setInt(2, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? mapEvent(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    // --------------------------------------------------------------------
    // Danh sách sự kiện của organizer, có tìm theo tên, lọc theo trạng thái, phân trang.
    // --------------------------------------------------------------------
    public List<Event> getEventsByOrganizer(int organizerId, String keyword,
            String status, int page, int pageSize) {
        List<Event> events = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        String where = buildListFilter(organizerId, keyword, status, params);
        String sql = SELECT_EVENT_COLUMNS + where
                + " ORDER BY e.start_time DESC, e.event_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    events.add(mapEvent(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    // --------------------------------------------------------------------
    // Các hàm hỗ trợ chung
    // --------------------------------------------------------------------
    private String buildListFilter(int organizerId, String keyword,
            String status, List<Object> params) {
        StringBuilder where = new StringBuilder("WHERE e.organizer_id = ?");
        params.add(organizerId);
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" AND e.event_name LIKE ? ESCAPE '\\'");
            // escape special chars for LIKE
            String escaped = keyword.trim()
                    .replace("\\", "\\\\")
                    .replace("%", "\\%")
                    .replace("_", "\\_")
                    .replace("[", "\\[");
            params.add("%" + escaped + "%");
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
            } else if (value instanceof java.math.BigDecimal) {
                statement.setBigDecimal(i + 1, (java.math.BigDecimal) value);
            } else {
                statement.setString(i + 1, value.toString());
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
        event.setStartTime(start == null ? null : start.toLocalDateTime());
        event.setEndTime(end == null ? null : end.toLocalDateTime());
        String status = rs.getString("status");
        event.setStatus(status == null ? null : status.trim().toUpperCase(Locale.ROOT));
        event.setCancellationReason(rs.getString("cancellation_reason"));
        Timestamp created = rs.getTimestamp("created_at");
        Timestamp updated = rs.getTimestamp("updated_at");
        event.setCreatedAt(created == null ? null : created.toLocalDateTime());
        event.setUpdatedAt(updated == null ? null : updated.toLocalDateTime());
        event.setCategoryName(rs.getString("category_name"));
        event.setVenueName(rs.getString("venue_name"));
        event.setTicketTotal(rs.getInt("ticket_total"));
        event.setTicketSold(rs.getInt("ticket_sold"));
        event.setRevenue(rs.getBigDecimal("revenue"));
        event.setRemainingTickets(rs.getInt("remaining"));
        return event;
    }

    // --------------------------------------------------------------------
    // Các phương thức truy xuất danh mục & địa điểm (giữ nguyên)
    // --------------------------------------------------------------------
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
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Map<Integer, String> getIdNameMap(String sql) {
        Map<Integer, String> items = new LinkedHashMap<>();
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                items.put(rs.getInt(1), rs.getString(2));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    /**
     * Kiểm tra xem sự kiện có dữ liệu bán hàng (đơn hàng, vé, đánh giá) hay
     * không.
     */
    public boolean hasSalesData(int eventId) {
        String sql = HAS_SALES_DATA;
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, eventId);
            statement.setInt(2, eventId);
            statement.setInt(3, eventId);
            statement.setInt(4, eventId);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() && rs.getInt(1) == 1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // --------------------------------------------------------------------
    // Thống kê
    // --------------------------------------------------------------------
    public Map<String, Integer> countEventsByStatus(int organizerId) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = "SELECT UPPER(status), COUNT(*) FROM Events WHERE organizer_id = ? GROUP BY UPPER(status)";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, organizerId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getString(1), rs.getInt(2));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counts;
    }

    public Map<String, Number> getOrganizerSalesSummary(int organizerId) {
        Map<String, Number> summary = new LinkedHashMap<>();
        summary.put("ticketTotal", 0);
        summary.put("ticketSold", 0);
        summary.put("revenue", java.math.BigDecimal.ZERO);
        String ticketSql = "SELECT ISNULL(SUM(t.quantity), 0), ISNULL(SUM(t.quantity - t.available_quantity), 0) "
                + "FROM Event_Tickets t JOIN Events e ON e.event_id = t.event_id WHERE e.organizer_id = ?";
        String revenueSql = "SELECT ISNULL(SUM(od.subtotal), 0) FROM Order_Details od "
                + "JOIN Event_Tickets t ON t.event_ticket_id = od.event_ticket_id "
                + "JOIN Events e ON e.event_id = t.event_id "
                + "JOIN Orders o ON o.order_id = od.order_id "
                + "WHERE e.organizer_id = ? AND o.status = 'Paid'";
        try (Connection connection = DBContext.getConnection()) {
            try (PreparedStatement stmt = connection.prepareStatement(ticketSql)) {
                stmt.setInt(1, organizerId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        summary.put("ticketTotal", rs.getInt(1));
                        summary.put("ticketSold", rs.getInt(2));
                    }
                }
            }
            try (PreparedStatement stmt = connection.prepareStatement(revenueSql)) {
                stmt.setInt(1, organizerId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        summary.put("revenue", rs.getBigDecimal(1));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return summary;
    }

    // --------------------------------------------------------------------
    // Delete event (cascading deletes)
    // --------------------------------------------------------------------
    public boolean deleteEvent(int eventId, int organizerId) {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                for (int i = 0; i < DELETE_EVENT_STATEMENTS.length; i++) {
                    boolean isEventStatement = i == DELETE_EVENT_STATEMENTS.length - 1;
                    try (PreparedStatement stmt = connection.prepareStatement(DELETE_EVENT_STATEMENTS[i])) {
                        stmt.setInt(1, eventId);
                        if (isEventStatement) {
                            stmt.setInt(2, organizerId);
                            if (stmt.executeUpdate() == 0) {
                                connection.rollback();
                                return false;
                            }
                        } else {
                            stmt.executeUpdate();
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

    // --------------------------------------------------------------------
    // Update event (excluding image)  <-- **KEEP THIS ONE ONLY**
    // --------------------------------------------------------------------
    public boolean updateEvent(Event event) {
        String sql = UPDATE_EVENT;
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
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

    /**
     * Đếm tổng số sự kiện của Organizer. Hỗ trợ tìm kiếm theo tên sự kiện và
     * lọc theo trạng thái.
     *
     * @param organizerId ID của Organizer
     * @param keyword Từ khóa tìm kiếm (có thể null hoặc rỗng)
     * @param status Trạng thái sự kiện (có thể null hoặc rỗng)
     * @return Tổng số sự kiện phù hợp
     */
    public int countEventsByOrganizer(int organizerId, String keyword, String status) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Events WHERE organizer_id = ?"
        );

        List<Object> params = new ArrayList<>();
        params.add(organizerId);

        // Tìm kiếm theo tên sự kiện
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND event_name LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }

        // Lọc theo trạng thái
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {

            // Gán tham số cho PreparedStatement
            for (int i = 0; i < params.size(); i++) {
                statement.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    // --------------------------------------------------------------------
    // Admin - Quản lý và duyệt sự kiện
    // --------------------------------------------------------------------
    /**
     * Lấy danh sách sự kiện đang chờ Admin duyệt.
     */
    public List<Event> getEventsPendingApproval(int page, int pageSize) {
        List<Event> events = new ArrayList<>();

        String sql = SELECT_EVENT_COLUMNS
                + " WHERE e.status = ?"
                + " ORDER BY e.created_at ASC, e.event_id ASC"
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, Constants.EVENT_PENDING_APPROVAL);
            statement.setInt(2, (page - 1) * pageSize);
            statement.setInt(3, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    events.add(mapEvent(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return events;
    }

    /**
     * Đếm số sự kiện đang chờ Admin duyệt.
     */
    public int countEventsPendingApproval() {
        String sql = "SELECT COUNT(*) FROM Events WHERE status = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, Constants.EVENT_PENDING_APPROVAL);

            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Admin duyệt sự kiện đang chờ duyệt. Chỉ cập nhật nếu trạng thái hiện tại
     * vẫn là PENDING_APPROVAL.
     */
    public boolean approveEvent(int eventId) {
        String sql = "UPDATE Events "
                + "SET status = ?, cancellation_reason = NULL, updated_at = GETDATE() "
                + "WHERE event_id = ? AND status = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, Constants.EVENT_ACTIVE);
            statement.setInt(2, eventId);
            statement.setString(3, Constants.EVENT_PENDING_APPROVAL);

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Admin từ chối sự kiện đang chờ duyệt và lưu lý do.
     */
    public boolean rejectEvent(int eventId, String reason) {
        String sql = "UPDATE Events "
                + "SET status = ?, cancellation_reason = ?, updated_at = GETDATE() "
                + "WHERE event_id = ? AND status = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, Constants.EVENT_REJECTED);
            statement.setString(2, reason);
            statement.setInt(3, eventId);
            statement.setString(4, Constants.EVENT_PENDING_APPROVAL);

            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

}
