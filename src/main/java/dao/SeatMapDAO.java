package dao;

import model.EventTicket;
import model.EventZone;
import utils.Constants;
import utils.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Sơ đồ ghế của từng sự kiện: Event_Zones (khu) + Event_Seats (ghế sinh ra từ
 * các khu ngồi). Ghi theo kiểu "thay thế toàn bộ" trong một transaction.
 */
public class SeatMapDAO {

    private static final int BATCH_SIZE = 1000;

    /**
     * Thay đổi hạng vé đi kèm khi lưu sơ đồ. refId &gt; 0: hạng vé đã có (cập nhật
     * tên, giá, số lượng); refId &lt;= 0: hạng vé mới do trình thiết kế tạo (refId
     * chỉ là mã tạm của trình duyệt, được đổi sang event_ticket_id thật khi lưu).
     */
    public static class TicketChange {

        public final int refId;
        public final String name;
        public final BigDecimal price;
        public final int quantity;

        public TicketChange(int refId, String name, BigDecimal price, int quantity) {
            this.refId = refId;
            this.name = name;
            this.price = price;
            this.quantity = quantity;
        }

        public boolean isNew() {
            return refId <= 0;
        }
    }

    private static final String SELECT_ZONES
            = "SELECT zone_id, event_ticket_id, zone_name, zone_type, color, pos_x, pos_y, width, height, "
            + "row_count, seats_per_row, capacity, blocked_seats, sort_order "
            + "FROM Event_Zones WHERE event_id = ? ORDER BY sort_order, zone_id";

    private static final String INSERT_ZONE
            = "INSERT INTO Event_Zones (event_id, event_ticket_id, zone_name, zone_type, color, pos_x, pos_y, "
            + "width, height, row_count, seats_per_row, capacity, blocked_seats, sort_order) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String INSERT_SEAT
            = "INSERT INTO Event_Seats (event_id, source_seat_id, zone_id, row_label, seat_number, seat_label, "
            + "seat_type, status) VALUES (?, NULL, ?, ?, ?, ?, ?, 'Available')";

    /** Các hạng vé ACTIVE của sự kiện, dùng để gán giá cho từng khu. */
    public List<EventTicket> getTickets(int eventId) {
        String sql = "SELECT event_ticket_id, ticket_name, price, quantity, available_quantity "
                + "FROM Event_Tickets WHERE event_id = ? AND status = ? ORDER BY event_ticket_id";
        List<EventTicket> tickets = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, eventId);
            statement.setString(2, Constants.TICKET_ACTIVE);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    EventTicket t = new EventTicket();
                    t.setEventTicketId(rs.getInt("event_ticket_id"));
                    t.setEventId(eventId);
                    t.setTicketName(rs.getString("ticket_name"));
                    t.setPrice(rs.getBigDecimal("price"));
                    t.setQuantity(rs.getInt("quantity"));
                    t.setAvailableQuantity(rs.getInt("available_quantity"));
                    tickets.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * @throws SQLException để controller phân biệt "chưa có sơ đồ" (danh sách
     * rỗng) với lỗi DB (ví dụ database chưa có bảng Event_Zones trong db.sql).
     */
    public List<EventZone> getZones(int eventId) throws SQLException {
        List<EventZone> zones = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(SELECT_ZONES)) {
            statement.setInt(1, eventId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    EventZone z = new EventZone();
                    z.setZoneId(rs.getInt("zone_id"));
                    int ticketId = rs.getInt("event_ticket_id");
                    z.setEventTicketId(rs.wasNull() ? null : ticketId);
                    z.setZoneName(rs.getString("zone_name"));
                    z.setZoneType(rs.getString("zone_type"));
                    z.setColor(rs.getString("color"));
                    z.setPosX(rs.getInt("pos_x"));
                    z.setPosY(rs.getInt("pos_y"));
                    z.setWidth(rs.getInt("width"));
                    z.setHeight(rs.getInt("height"));
                    z.setRowCount(rs.getInt("row_count"));
                    z.setSeatsPerRow(rs.getInt("seats_per_row"));
                    z.setCapacity(rs.getInt("capacity"));
                    z.setBlockedSeats(rs.getString("blocked_seats"));
                    z.setSortOrder(rs.getInt("sort_order"));
                    zones.add(z);
                }
            }
        }
        return zones;
    }

    /**
     * Thay toàn bộ sơ đồ của sự kiện bằng danh sách khu mới: lưu/cập nhật hạng
     * vé, ghi các khu, sinh ghế cho khu ngồi, tất cả trong một transaction (lỗi ở
     * đâu thì rollback hết). Số lượng vé của hạng vé được gán cho khu luôn bằng
     * tổng sức chứa các khu đó.
     *
     * @param zones mỗi khu mang eventTicketId = refId của hạng vé trong tickets
     */
    public boolean saveLayout(int eventId, List<EventZone> zones, List<TicketChange> tickets) {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                deleteLayout(connection, eventId);
                writeLayout(connection, eventId, zones, tickets);
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

    /**
     * Ghi hạng vé, khu và ghế của một sự kiện trên connection có sẵn (không
     * commit): dùng chung cho lưu sơ đồ và cho tạo sự kiện kèm sơ đồ để cả hai
     * nằm trong transaction của người gọi.
     */
    public void writeLayout(Connection connection, int eventId, List<EventZone> zones,
            List<TicketChange> tickets) throws SQLException {
        // refId (có thể là mã tạm) -> event_ticket_id thật
        Map<Integer, Integer> realIds = new HashMap<>();
        for (TicketChange change : tickets) {
            if (change.isNew()) {
                realIds.put(change.refId, insertTicket(connection, eventId, change));
            } else {
                updateTicket(connection, eventId, change);
                realIds.put(change.refId, change.refId);
            }
        }

        int sortOrder = 0;
        for (EventZone zone : zones) {
            if (!zone.isStage()) {
                zone.setEventTicketId(realIds.get(zone.getEventTicketId()));
            }
            int zoneId = insertZone(connection, eventId, zone, sortOrder++);
            if (zone.isSeated()) {
                insertSeats(connection, eventId, zoneId, zone);
            }
        }
    }

    private int insertTicket(Connection connection, int eventId, TicketChange change) throws SQLException {
        String sql = "INSERT INTO Event_Tickets (event_id, ticket_name, description, price, quantity, "
                + "available_quantity, status) VALUES (?, ?, NULL, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, eventId);
            statement.setString(2, change.name);
            statement.setBigDecimal(3, change.price);
            statement.setInt(4, change.quantity);
            statement.setInt(5, change.quantity);
            statement.setString(6, Constants.TICKET_ACTIVE);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Không lấy được event_ticket_id vừa tạo.");
                }
                return keys.getInt(1);
            }
        }
    }

    private void updateTicket(Connection connection, int eventId, TicketChange change) throws SQLException {
        // Sự kiện nháp/bị từ chối chưa có đơn hàng nên đặt available = quantity là an toàn
        String sql = "UPDATE Event_Tickets SET ticket_name = ?, price = ?, quantity = ?, available_quantity = ?, "
                + "updated_at = GETDATE() WHERE event_ticket_id = ? AND event_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, change.name);
            statement.setBigDecimal(2, change.price);
            statement.setInt(3, change.quantity);
            statement.setInt(4, change.quantity);
            statement.setInt(5, change.refId);
            statement.setInt(6, eventId);
            statement.executeUpdate();
        }
    }

    /** Xóa toàn bộ sơ đồ ghế của sự kiện (khu + ghế). */
    public boolean clearLayout(int eventId) {
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                deleteLayout(connection, eventId);
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

    private void deleteLayout(Connection connection, int eventId) throws SQLException {
        // Ghế trước (tham chiếu khu), rồi mới đến khu
        for (String sql : new String[]{
            "DELETE FROM Event_Seats WHERE event_id = ?",
            "DELETE FROM Event_Zones WHERE event_id = ?"}) {
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setInt(1, eventId);
                statement.executeUpdate();
            }
        }
    }

    private int insertZone(Connection connection, int eventId, EventZone zone, int sortOrder) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(INSERT_ZONE, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, eventId);
            if (zone.getEventTicketId() == null) {
                statement.setNull(2, Types.INTEGER);
            } else {
                statement.setInt(2, zone.getEventTicketId());
            }
            statement.setString(3, zone.getZoneName());
            statement.setString(4, zone.getZoneType());
            statement.setString(5, zone.getColor());
            statement.setInt(6, zone.getPosX());
            statement.setInt(7, zone.getPosY());
            statement.setInt(8, zone.getWidth());
            statement.setInt(9, zone.getHeight());
            statement.setInt(10, zone.getRowCount());
            statement.setInt(11, zone.getSeatsPerRow());
            statement.setInt(12, zone.getCapacity());
            if (zone.getBlockedSeats() == null || zone.getBlockedSeats().isEmpty()) {
                statement.setNull(13, Types.NVARCHAR);
            } else {
                statement.setString(13, zone.getBlockedSeats());
            }
            statement.setInt(14, sortOrder);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Không lấy được zone_id vừa tạo.");
                }
                return keys.getInt(1);
            }
        }
    }

    /**
     * Sinh Event_Seats cho khu ngồi: mỗi vị trí (hàng, cột) không bị bỏ trống là
     * một ghế. row_label = "{mã khu}-{chữ hàng}" (VD VIPA-A), seat_label =
     * row_label + số ghế 2 chữ số (VD VIPA-A05); seat_number giữ đúng vị trí cột.
     */
    private void insertSeats(Connection connection, int eventId, int zoneId, EventZone zone) throws SQLException {
        Set<String> blocked = zone.blockedSet();
        String seatType = zone.getZoneName() != null && zone.getZoneName().toLowerCase().contains("vip")
                ? "VIP" : "Standard";

        try (PreparedStatement statement = connection.prepareStatement(INSERT_SEAT)) {
            int pending = 0;
            for (int r = 0; r < zone.getRowCount(); r++) {
                String rowLabel = zone.getCode() + "-" + EventZone.rowLetter(r);
                for (int c = 0; c < zone.getSeatsPerRow(); c++) {
                    if (blocked.contains(r + ":" + c)) {
                        continue;
                    }
                    int seatNumber = c + 1;
                    statement.setInt(1, eventId);
                    statement.setInt(2, zoneId);
                    statement.setString(3, rowLabel);
                    statement.setInt(4, seatNumber);
                    statement.setString(5, rowLabel + String.format(java.util.Locale.ROOT, "%02d", seatNumber));
                    statement.setString(6, seatType);
                    statement.addBatch();
                    if (++pending % BATCH_SIZE == 0) {
                        statement.executeBatch();
                    }
                }
            }
            statement.executeBatch();
        }
    }
}
