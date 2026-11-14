package dao;

import model.Event;
import model.EventTicket;
import model.EventZone;
import utils.Constants;
import utils.DBContext;

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

public class EventDAO {

    private static final String INSERT_EVENT
            = "INSERT INTO Events (organizer_id, category_id, venue_id, event_name, description, "
            + "event_image, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String INSERT_TICKET
            = "INSERT INTO Event_Tickets (event_id, ticket_name, description, price, quantity, "
            + "available_quantity, status) VALUES (?, ?, ?, ?, ?, ?, ?)";

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
            + "JOIN Venues v ON v.venue_id = e.venue_id "; // dấu cách cuối: các hàm ghép tiếp "WHERE ..."

    private static final String[] DELETE_EVENT_STATEMENTS = {
        "DELETE FROM Event_Staff WHERE event_id = ?",
        // Ghế -> khu -> hạng vé: Event_Seats tham chiếu Event_Zones, Event_Zones tham chiếu Event_Tickets
        "DELETE FROM Event_Seats WHERE event_id = ?",
        "DELETE FROM Event_Zones WHERE event_id = ?",
        "DELETE FROM Event_Tickets WHERE event_id = ?",
        "DELETE FROM Events WHERE event_id = ? AND organizer_id = ?"
    };

    // ------------------------------------------------------------------
    // Tạo sự kiện
    // ------------------------------------------------------------------

    /**
     * Tạo sự kiện cùng các hạng vé trong MỘT transaction: lỗi ở bất kỳ hạng vé
     * nào thì sự kiện cũng không được tạo. Danh sách hạng vé có thể rỗng.
     */
    public void createEventWithTickets(Event event, List<EventTicket> tickets) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                insertEvent(connection, event);
                if (tickets != null && !tickets.isEmpty()) {
                    try (PreparedStatement statement = connection.prepareStatement(INSERT_TICKET)) {
                        for (EventTicket ticket : tickets) {
                            statement.setInt(1, event.getEventId());
                            statement.setString(2, ticket.getTicketName());
                            statement.setString(3, ticket.getDescription());
                            statement.setBigDecimal(4, ticket.getPrice());
                            statement.setInt(5, ticket.getQuantity());
                            statement.setInt(6, ticket.getQuantity()); // mới tạo: còn = tổng
                            statement.setString(7, Constants.TICKET_ACTIVE);
                            statement.addBatch();
                        }
                        statement.executeBatch();
                    }
                }
                connection.commit();
            } catch (SQLException e) {
                connection.rollback();
                event.setEventId(0);
                throw e;
            }
        }
    }

    /** Tạo sự kiện kèm hạng vé + sơ đồ ghế (khu, ghế) trong cùng một transaction. */
    public void createEventWithSeatMap(Event event, List<EventZone> zones,
            List<SeatMapDAO.TicketChange> tickets) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                insertEvent(connection, event);
                new SeatMapDAO().writeLayout(connection, event.getEventId(), zones, tickets);
                connection.commit();
            } catch (SQLException e) {
                connection.rollback();
                event.setEventId(0);
                throw e;
            }
        }
    }

    /** Insert sự kiện và gán event_id được sinh ra vào đối tượng. */
    private void insertEvent(Connection connection, Event event) throws SQLException {
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
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Cannot get generated event_id");
                }
                event.setEventId(keys.getInt(1));
            }
        }
    }

    // ------------------------------------------------------------------
    // Truy vấn sự kiện
    // ------------------------------------------------------------------

    /** Chỉ trả về sự kiện đã được duyệt (ACTIVE); bản nháp / chờ duyệt / bị từ chối không công khai. */
    public Event getPublicEventById(int eventId) throws SQLException {
        return findOne(SELECT_EVENT_COLUMNS + "WHERE e.event_id = ? AND e.status = ?",
                eventId, Constants.EVENT_ACTIVE);
    }

    /** Lấy sự kiện theo id nhưng chỉ khi thuộc về organizer (kiểm tra ownership). */
    public Event getEventByIdAndOrganizer(int eventId, int organizerId) throws SQLException {
        return findOne(SELECT_EVENT_COLUMNS + "WHERE e.event_id = ? AND e.organizer_id = ?",
                eventId, organizerId);
    }

    /** Danh sách sự kiện của organizer, có tìm theo tên, lọc theo trạng thái, phân trang. */
    public List<Event> getEventsByOrganizer(int organizerId, String keyword,
            String status, int page, int pageSize) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = SELECT_EVENT_COLUMNS + buildListFilter(organizerId, keyword, status, params)
                + " ORDER BY e.start_time DESC, e.event_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        return findMany(sql, params.toArray());
    }

    public int countEventsByOrganizer(int organizerId, String keyword, String status) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM Events e " + buildListFilter(organizerId, keyword, status, params);
        return queryInt(sql, params.toArray());
    }

    /** Danh sách sự kiện đang chờ Admin duyệt. */
    public List<Event> getEventsPendingApproval(int page, int pageSize) throws SQLException {
        String sql = SELECT_EVENT_COLUMNS + "WHERE e.status = ? "
                + "ORDER BY e.created_at ASC, e.event_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        return findMany(sql, Constants.EVENT_PENDING_APPROVAL, (page - 1) * pageSize, pageSize);
    }

    public int countEventsPendingApproval() throws SQLException {
        return queryInt("SELECT COUNT(*) FROM Events WHERE status = ?", Constants.EVENT_PENDING_APPROVAL);
    }

    /** UC-29: {email, họ tên organizer, tên sự kiện} để gửi thông báo duyệt; null nếu không có. */
    public String[] getOrganizerContact(int eventId) throws SQLException {
        String sql = "SELECT u.email, u.full_name, e.event_name FROM Events e "
                + "JOIN Users u ON u.user_id = e.organizer_id WHERE e.event_id = ?";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, eventId);
                ResultSet rs = statement.executeQuery()) {
            return rs.next() ? new String[]{rs.getString(1), rs.getString(2), rs.getString(3)} : null;
        }
    }

    // ------------------------------------------------------------------
    // Kiểm tra dữ liệu
    // ------------------------------------------------------------------

    public boolean existsDuplicateEvent(int organizerId, String eventName,
            Timestamp startTime, int excludeEventId) throws SQLException {
        return exists("SELECT 1 FROM Events WHERE organizer_id = ? AND LOWER(event_name) = LOWER(?) "
                + "AND start_time = ? AND event_id <> ?",
                organizerId, eventName, startTime, excludeEventId);
    }

    /** Hai khoảng thời gian giao nhau khi: start_cũ < end_mới AND end_cũ > start_mới. */
    public boolean existsVenueConflict(int venueId, Timestamp startTime, Timestamp endTime,
            String cancelledStatus, String rejectedStatus, int excludeEventId) throws SQLException {
        return exists("SELECT 1 FROM Events WHERE venue_id = ? AND status NOT IN (?, ?) "
                + "AND start_time < ? AND end_time > ? AND event_id <> ?",
                venueId, cancelledStatus, rejectedStatus, endTime, startTime, excludeEventId);
    }

    public boolean existsActiveCategory(int categoryId) throws SQLException {
        return exists("SELECT 1 FROM Categories WHERE category_id = ? AND status = 'ACTIVE'", categoryId);
    }

    public boolean existsActiveVenue(int venueId) throws SQLException {
        return exists("SELECT 1 FROM Venues WHERE venue_id = ? AND status = 'ACTIVE'", venueId);
    }

    /** Sự kiện đã có đơn hàng nào chưa. */
    public boolean hasSalesData(int eventId) throws SQLException {
        return exists("SELECT 1 FROM Order_Details od "
                + "JOIN Event_Tickets et ON od.event_ticket_id = et.event_ticket_id "
                + "WHERE et.event_id = ?", eventId);
    }

    // ------------------------------------------------------------------
    // Danh mục, địa điểm
    // ------------------------------------------------------------------

    public Map<Integer, String> getActiveCategories() throws SQLException {
        return getIdNameMap("SELECT category_id, category_name FROM Categories "
                + "WHERE status = 'ACTIVE' ORDER BY category_name");
    }

    public Map<Integer, String> getActiveVenues() throws SQLException {
        return getIdNameMap("SELECT venue_id, venue_name FROM Venues WHERE status = 'ACTIVE' ORDER BY venue_name");
    }

    public Map<Integer, Integer> getVenueCapacities() throws SQLException {
        Map<Integer, Integer> result = new LinkedHashMap<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(
                        "SELECT venue_id, capacity FROM Venues WHERE status = 'ACTIVE'");
                ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                result.put(rs.getInt(1), rs.getInt(2));
            }
        }
        return result;
    }

    /** Sức chứa địa điểm; -1 nếu không tồn tại. */
    public int getVenueCapacity(int venueId) throws SQLException {
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, "SELECT capacity FROM Venues WHERE venue_id = ?", venueId);
                ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    // ------------------------------------------------------------------
    // Thống kê
    // ------------------------------------------------------------------

    public Map<String, Integer> countEventsByStatus(int organizerId) throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = "SELECT UPPER(status), COUNT(*) FROM Events WHERE organizer_id = ? GROUP BY UPPER(status)";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, organizerId);
                ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString(1), rs.getInt(2));
            }
        }
        return counts;
    }

    public Map<String, Number> getOrganizerSalesSummary(int organizerId) throws SQLException {
        String ticketSql = "SELECT ISNULL(SUM(t.quantity), 0), ISNULL(SUM(t.quantity - t.available_quantity), 0) "
                + "FROM Event_Tickets t JOIN Events e ON e.event_id = t.event_id WHERE e.organizer_id = ?";
        String revenueSql = "SELECT ISNULL(SUM(od.subtotal), 0) FROM Order_Details od "
                + "JOIN Event_Tickets t ON t.event_ticket_id = od.event_ticket_id "
                + "JOIN Events e ON e.event_id = t.event_id "
                + "JOIN Orders o ON o.order_id = od.order_id "
                + "WHERE e.organizer_id = ? AND o.status = 'Paid'";

        Map<String, Number> summary = new LinkedHashMap<>();
        try (Connection connection = DBContext.getConnection()) {
            try (PreparedStatement statement = prepare(connection, ticketSql, organizerId);
                    ResultSet rs = statement.executeQuery()) {
                rs.next();
                summary.put("ticketTotal", rs.getInt(1));
                summary.put("ticketSold", rs.getInt(2));
            }
            try (PreparedStatement statement = prepare(connection, revenueSql, organizerId);
                    ResultSet rs = statement.executeQuery()) {
                rs.next();
                summary.put("revenue", rs.getBigDecimal(1));
            }
        }
        return summary;
    }

    // ------------------------------------------------------------------
    // Cập nhật trạng thái / nội dung
    // ------------------------------------------------------------------

    /** Cập nhật thông tin sự kiện (không gồm ảnh). */
    public boolean updateEvent(Event event) throws SQLException {
        return update("UPDATE Events SET category_id = ?, venue_id = ?, event_name = ?, description = ?, "
                + "start_time = ?, end_time = ?, status = ?, updated_at = GETDATE() "
                + "WHERE event_id = ? AND organizer_id = ?",
                event.getCategoryId(), event.getVenueId(), event.getEventName(), event.getDescription(),
                Timestamp.valueOf(event.getStartTime()), Timestamp.valueOf(event.getEndTime()),
                event.getStatus(), event.getEventId(), event.getOrganizerId());
    }

    public boolean updateEventImage(int eventId, String imagePath) throws SQLException {
        return update("UPDATE Events SET event_image = ?, updated_at = GETDATE() WHERE event_id = ?",
                imagePath, eventId);
    }

    public boolean submitForApproval(int eventId, int organizerId) throws SQLException {
        return update("UPDATE Events SET status = ?, updated_at = GETDATE() "
                + "WHERE event_id = ? AND organizer_id = ? AND status IN (?, ?)",
                Constants.EVENT_PENDING_APPROVAL, eventId, organizerId,
                Constants.EVENT_DRAFT, Constants.EVENT_REJECTED);
    }

    /** Admin duyệt sự kiện; chỉ cập nhật nếu trạng thái hiện tại vẫn là PENDING_APPROVAL. */
    public boolean approveEvent(int eventId) throws SQLException {
        return update("UPDATE Events SET status = ?, cancellation_reason = NULL, updated_at = GETDATE() "
                + "WHERE event_id = ? AND status = ?",
                Constants.EVENT_ACTIVE, eventId, Constants.EVENT_PENDING_APPROVAL);
    }

    /** Admin từ chối sự kiện đang chờ duyệt và lưu lý do. */
    public boolean rejectEvent(int eventId, String reason) throws SQLException {
        return update("UPDATE Events SET status = ?, cancellation_reason = ?, updated_at = GETDATE() "
                + "WHERE event_id = ? AND status = ?",
                Constants.EVENT_REJECTED, reason, eventId, Constants.EVENT_PENDING_APPROVAL);
    }

    /** Xóa sự kiện cùng staff, ghế, khu, hạng vé trong một transaction. */
    public boolean deleteEvent(int eventId, int organizerId) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                int deleted = 0;
                for (String sql : DELETE_EVENT_STATEMENTS) {
                    boolean isEventStatement = sql.startsWith("DELETE FROM Events");
                    try (PreparedStatement statement = isEventStatement
                            ? prepare(connection, sql, eventId, organizerId)
                            : prepare(connection, sql, eventId)) {
                        deleted = statement.executeUpdate();
                    }
                }
                if (deleted == 0) {
                    connection.rollback();
                    return false;
                }
                connection.commit();
                return true;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    public enum CancelResult { CANCELLED, NOT_ACTIVE, HAS_PAID_ORDERS }

    /**
     * UC-20: Organizer hủy sự kiện ACTIVE của chính mình khi CHƯA có đơn Paid.
     * Khóa dòng sự kiện để không có đơn nào kịp thanh toán xen giữa lúc kiểm tra và lúc hủy
     * (thanh toán đến sau sẽ bị PaymentDAO chuyển sang RefundPending vì sự kiện không còn ACTIVE).
     */
    public CancelResult cancelEvent(int eventId, int organizerId, String reason) throws SQLException {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                CancelResult result = checkCancellable(connection, eventId, organizerId);
                if (result != CancelResult.CANCELLED) {
                    connection.rollback();
                    return result;
                }
                try (PreparedStatement statement = prepare(connection,
                        "UPDATE Events SET status = ?, cancellation_reason = ?, updated_at = GETDATE() WHERE event_id = ?",
                        Constants.EVENT_CANCELLED, reason, eventId)) {
                    statement.executeUpdate();
                }
                connection.commit();
                return CancelResult.CANCELLED;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    private CancelResult checkCancellable(Connection connection, int eventId, int organizerId) throws SQLException {
        try (PreparedStatement statement = prepare(connection,
                "SELECT status FROM Events WITH (UPDLOCK, ROWLOCK) WHERE event_id = ? AND organizer_id = ?",
                eventId, organizerId);
                ResultSet rs = statement.executeQuery()) {
            if (!rs.next() || !Constants.EVENT_ACTIVE.equalsIgnoreCase(rs.getString(1))) {
                return CancelResult.NOT_ACTIVE;
            }
        }
        try (PreparedStatement statement = prepare(connection,
                "SELECT 1 FROM Orders o JOIN Order_Details od ON od.order_id = o.order_id "
                + "JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id "
                + "WHERE et.event_id = ? AND o.status = 'Paid'", eventId);
                ResultSet rs = statement.executeQuery()) {
            return rs.next() ? CancelResult.HAS_PAID_ORDERS : CancelResult.CANCELLED;
        }
    }

    // ------------------------------------------------------------------
    // Hàm hỗ trợ
    // ------------------------------------------------------------------

    private String buildListFilter(int organizerId, String keyword, String status, List<Object> params) {
        StringBuilder where = new StringBuilder("WHERE e.organizer_id = ?");
        params.add(organizerId);
        if (keyword != null && !keyword.isBlank()) {
            where.append(" AND e.event_name LIKE ? ESCAPE '\\'");
            String escaped = keyword.trim()
                    .replace("\\", "\\\\")
                    .replace("%", "\\%")
                    .replace("_", "\\_")
                    .replace("[", "\\[");
            params.add("%" + escaped + "%");
        }
        if (status != null && !status.isBlank()) {
    if ("ENDED".equalsIgnoreCase(status)) {
        where.append(
            " AND e.status = 'ACTIVE' AND e.end_time < GETDATE()"
        );
    } else if ("ACTIVE".equalsIgnoreCase(status)) {
        where.append(
            " AND e.status = 'ACTIVE' AND e.end_time >= GETDATE()"
        );
    } else {
        where.append(" AND e.status = ?");
        params.add(status.trim());
    }
}
        return where.toString();
    }

    private PreparedStatement prepare(Connection connection, String sql, Object... params) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            statement.setObject(i + 1, params[i]);
        }
        return statement;
    }

    private Event findOne(String sql, Object... params) throws SQLException {
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, params);
                ResultSet rs = statement.executeQuery()) {
            return rs.next() ? mapEvent(rs) : null;
        }
    }

    private List<Event> findMany(String sql, Object... params) throws SQLException {
        List<Event> events = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, params);
                ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                events.add(mapEvent(rs));
            }
        }
        return events;
    }

    private boolean exists(String sql, Object... params) throws SQLException {
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, params);
                ResultSet rs = statement.executeQuery()) {
            return rs.next();
        }
    }

    private int queryInt(String sql, Object... params) throws SQLException {
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, params);
                ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private boolean update(String sql, Object... params) throws SQLException {
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = prepare(connection, sql, params)) {
            return statement.executeUpdate() > 0;
        }
    }

    private Map<Integer, String> getIdNameMap(String sql) throws SQLException {
        Map<Integer, String> items = new LinkedHashMap<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                items.put(rs.getInt(1), rs.getString(2));
            }
        }
        return items;
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
        event.setStartTime(toLocalDateTime(rs.getTimestamp("start_time")));
        event.setEndTime(toLocalDateTime(rs.getTimestamp("end_time")));
        String status = rs.getString("status");
        event.setStatus(status == null ? null : status.trim().toUpperCase(Locale.ROOT));
        event.setCancellationReason(rs.getString("cancellation_reason"));
        event.setCreatedAt(toLocalDateTime(rs.getTimestamp("created_at")));
        event.setUpdatedAt(toLocalDateTime(rs.getTimestamp("updated_at")));
        event.setCategoryName(rs.getString("category_name"));
        event.setVenueName(rs.getString("venue_name"));
        event.setTicketTotal(rs.getInt("ticket_total"));
        event.setTicketSold(rs.getInt("ticket_sold"));
        event.setRevenue(rs.getBigDecimal("revenue"));
        event.setRemainingTickets(rs.getInt("remaining"));
        return event;
    }

    private static java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }
}
