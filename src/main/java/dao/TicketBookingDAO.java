package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;
import java.util.TreeMap;
import java.util.UUID;
import model.Event;
import model.EventSeat;
import model.EventTicket;
import utils.Constants;
import utils.DBContext;

/**
 * UC-06 Book Tickets: đọc dữ liệu để đặt vé và tạo đơn Pending (giữ vé/ghế
 * trong {@link Constants#BOOKING_HOLD_SECONDS} giây, tương đương 10 phút). Thanh toán là UC-12.
 */
public class TicketBookingDAO {

    /** Lỗi nghiệp vụ (hết vé, ghế đã bị giữ, voucher sai...) - message hiển thị được cho người dùng. */
    public static class BookingException extends Exception {

        public BookingException(String message) {
            super(message);
        }
    }

    /** Sự kiện đang mở bán: ACTIVE và chưa bắt đầu. */
    public Event getBookableEvent(int eventId) throws SQLException {
        String sql = "SELECT e.event_id, e.event_name, e.description, e.event_image, e.start_time, e.end_time, "
                + "e.status, v.venue_name "
                + "FROM Events e JOIN Venues v ON v.venue_id = e.venue_id "
                + "WHERE e.event_id = ? AND e.status = ? AND e.start_time > GETDATE()";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.setString(2, Constants.EVENT_ACTIVE);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Event event = new Event();
                event.setEventId(rs.getInt("event_id"));
                event.setEventName(rs.getString("event_name"));
                event.setDescription(rs.getString("description"));
                event.setEventImage(rs.getString("event_image"));
                event.setStatus(rs.getString("status"));
                event.setVenueName(rs.getString("venue_name"));
                Timestamp start = rs.getTimestamp("start_time");
                Timestamp end = rs.getTimestamp("end_time");
                event.setStartTime(start == null ? null : start.toLocalDateTime());
                event.setEndTime(end == null ? null : end.toLocalDateTime());
                return event;
            }
        }
    }

    public List<EventTicket> getActiveTickets(int eventId) throws SQLException {
        String sql = "SELECT event_ticket_id, event_id, ticket_name, description, price, quantity, available_quantity "
                + "FROM Event_Tickets WHERE event_id = ? AND status = 'ACTIVE' ORDER BY price DESC, event_ticket_id";
        List<EventTicket> tickets = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EventTicket t = new EventTicket();
                    t.setEventTicketId(rs.getInt("event_ticket_id"));
                    t.setEventId(rs.getInt("event_id"));
                    t.setTicketName(rs.getString("ticket_name"));
                    t.setDescription(rs.getString("description"));
                    t.setPrice(rs.getBigDecimal("price"));
                    t.setQuantity(rs.getInt("quantity"));
                    t.setAvailableQuantity(rs.getInt("available_quantity"));
                    tickets.add(t);
                }
            }
        }
        return tickets;
    }

    public List<EventSeat> getSeats(int eventId) throws SQLException {
        String sql = "SELECT event_seat_id, event_id, row_label, seat_number, seat_label, seat_type, status "
                + "FROM Event_Seats WHERE event_id = ? ORDER BY row_label, seat_number";
        List<EventSeat> seats = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EventSeat s = new EventSeat();
                    s.setEventSeatId(rs.getInt("event_seat_id"));
                    s.setEventId(rs.getInt("event_id"));
                    s.setRowLabel(rs.getString("row_label"));
                    s.setSeatNumber(rs.getInt("seat_number"));
                    s.setSeatLabel(rs.getString("seat_label"));
                    s.setSeatType(rs.getString("seat_type"));
                    s.setStatus(rs.getString("status"));
                    seats.add(s);
                }
            }
        }
        return seats;
    }

    /**
     * Hủy các đơn Pending đã quá hạn giữ vé và trả lại vé/ghế/voucher.
     * Đổi trạng thái đơn trước (OUTPUT vào bảng tạm) để hai request chạy song
     * song không trả vé hai lần.
     */
    public void releaseExpiredHolds() throws SQLException {
        String sql = """
                DECLARE @expired TABLE (order_id INT PRIMARY KEY);

                UPDATE Orders SET status = 'Cancelled', updated_at = GETDATE()
                OUTPUT inserted.order_id INTO @expired
                WHERE status = 'Pending' AND hold_expired_at IS NOT NULL AND hold_expired_at < GETDATE();

                UPDATE Payments SET payment_status = 'Failed'
                WHERE payment_status = 'Pending'
                  AND order_id IN (SELECT order_id FROM @expired);

                UPDATE et
                SET et.available_quantity = CASE WHEN et.available_quantity + x.qty > et.quantity
                                                 THEN et.quantity ELSE et.available_quantity + x.qty END,
                    et.updated_at = GETDATE()
                FROM Event_Tickets et
                JOIN (SELECT od.event_ticket_id, SUM(od.quantity) AS qty
                      FROM Order_Details od JOIN @expired e ON e.order_id = od.order_id
                      GROUP BY od.event_ticket_id) x ON x.event_ticket_id = et.event_ticket_id;

                UPDATE es SET es.status = 'Available'
                FROM Event_Seats es
                JOIN Order_Seats os ON os.event_seat_id = es.event_seat_id
                JOIN @expired e ON e.order_id = os.order_id
                WHERE es.status = 'Held';

                UPDATE v SET v.used_count = CASE WHEN v.used_count > 0 THEN v.used_count - 1 ELSE 0 END,
                             v.updated_at = GETDATE()
                FROM Vouchers v
                JOIN Orders o ON o.voucher_id = v.voucher_id
                JOIN @expired e ON e.order_id = o.order_id;
                """;
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement st = conn.createStatement()) {
                st.execute(sql);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /**
     * Tạo đơn Pending: trừ vé, giữ ghế, áp voucher, ghi Orders/Order_Details/Order_Seats
     * trong MỘT transaction. Lỗi nghiệp vụ -> rollback và ném BookingException.
     *
     * @param quantities eventTicketId -> số lượng (>0)
     * @param seatIds    ghế đã chọn (rỗng nếu vé đứng/không chọn ghế)
     * @param voucherCode null/rỗng nếu không dùng
     * @return order_id vừa tạo
     */
    public int createBooking(int customerId, int eventId, Map<Integer, Integer> quantities,
            List<Integer> seatIds, String voucherCode) throws SQLException, BookingException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId = createBookingInTransaction(conn, customerId, eventId, quantities, seatIds, voucherCode);
                conn.commit();
                return orderId;
            } catch (SQLException | BookingException | RuntimeException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private int createBookingInTransaction(Connection conn, int customerId, int eventId,
            Map<Integer, Integer> quantities, List<Integer> seatIds, String voucherCode)
            throws SQLException, BookingException {

        if (!isActiveCustomer(conn, customerId)) {
            throw new BookingException("Tài khoản không có quyền đặt vé.");
        }
        if (quantities == null || quantities.isEmpty()) {
            throw new BookingException("Vui lòng chọn ít nhất 1 vé.");
        }
        long requested = 0;
        for (int q : quantities.values()) {
            if (q <= 0) {
                throw new BookingException("Số lượng vé phải lớn hơn 0.");
            }
            requested += q;
        }
        if (requested > Constants.BOOKING_MAX_TICKETS_PER_ORDER) {
            throw new BookingException("Mỗi đơn tối đa " + Constants.BOOKING_MAX_TICKETS_PER_ORDER + " vé.");
        }
        seatIds = seatIds == null ? new ArrayList<>() : new ArrayList<>(new TreeSet<>(seatIds)); // bỏ ghế trùng
        if (!isEventBookable(conn, eventId)) {
            throw new BookingException("Sự kiện không còn mở bán.");
        }

        // Khóa theo thứ tự id tăng dần để tránh deadlock giữa các đơn đặt cùng lúc
        Map<Integer, Integer> ordered = new TreeMap<>(quantities);
        List<Object[]> lines = new ArrayList<>(); // {ticketId, qty, unitPrice, subtotal}
        BigDecimal total = BigDecimal.ZERO;
        int totalQty = 0;

        for (Map.Entry<Integer, Integer> entry : ordered.entrySet()) {
            int ticketId = entry.getKey();
            int qty = entry.getValue();

            String lockSql = "SELECT ticket_name, price, available_quantity FROM Event_Tickets WITH (UPDLOCK, ROWLOCK) "
                    + "WHERE event_ticket_id = ? AND event_id = ? AND status = 'ACTIVE'";
            BigDecimal price;
            try (PreparedStatement ps = conn.prepareStatement(lockSql)) {
                ps.setInt(1, ticketId);
                ps.setInt(2, eventId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new BookingException("Loại vé không hợp lệ hoặc đã ngừng bán.");
                    }
                    int available = rs.getInt("available_quantity");
                    if (available < qty) {
                        throw new BookingException("Loại vé \"" + rs.getString("ticket_name")
                                + "\" chỉ còn " + available + " vé.");
                    }
                    price = rs.getBigDecimal("price");
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE Event_Tickets SET available_quantity = available_quantity - ?, updated_at = GETDATE() "
                    + "WHERE event_ticket_id = ? AND available_quantity >= ?")) {
                ps.setInt(1, qty);
                ps.setInt(2, ticketId);
                ps.setInt(3, qty);
                if (ps.executeUpdate() != 1) {
                    throw new BookingException("Vé vừa được người khác đặt. Vui lòng thử lại.");
                }
            }

            BigDecimal subtotal = price.multiply(BigDecimal.valueOf(qty));
            lines.add(new Object[]{ticketId, qty, price, subtotal});
            total = total.add(subtotal);
            totalQty += qty;
        }

        if (!seatIds.isEmpty() && seatIds.size() != totalQty) {
            throw new BookingException("Số ghế đã chọn (" + seatIds.size()
                    + ") phải bằng tổng số vé (" + totalQty + ").");
        }
        for (int seatId : seatIds) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE Event_Seats SET status = 'Held' "
                    + "WHERE event_seat_id = ? AND event_id = ? AND status = 'Available'")) {
                ps.setInt(1, seatId);
                ps.setInt(2, eventId);
                if (ps.executeUpdate() != 1) {
                    throw new BookingException("Có ghế đã được giữ hoặc đã bán. Vui lòng chọn ghế khác.");
                }
            }
        }

        Integer voucherId = null;
        BigDecimal discount = BigDecimal.ZERO;
        if (voucherCode != null && !voucherCode.isBlank()) {
            Object[] applied = applyVoucher(conn, voucherCode.trim(), total);
            voucherId = (Integer) applied[0];
            discount = (BigDecimal) applied[1];
        }
        BigDecimal finalAmount = total.subtract(discount);

        int orderId = insertOrder(conn, customerId, voucherId, total, discount, finalAmount);

        for (Object[] line : lines) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Order_Details (order_id, event_ticket_id, quantity, unit_price, subtotal) "
                    + "VALUES (?, ?, ?, ?, ?)")) {
                ps.setInt(1, orderId);
                ps.setInt(2, (Integer) line[0]);
                ps.setInt(3, (Integer) line[1]);
                ps.setBigDecimal(4, (BigDecimal) line[2]);
                ps.setBigDecimal(5, (BigDecimal) line[3]);
                ps.executeUpdate();
            }
        }
        for (int seatId : seatIds) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Order_Seats (order_id, event_seat_id) VALUES (?, ?)")) {
                ps.setInt(1, orderId);
                ps.setInt(2, seatId);
                ps.executeUpdate();
            }
        }
        return orderId;
    }

    /** Đối chiếu DB (không tin hoàn toàn session): tài khoản Customer đang ACTIVE. */
    private boolean isActiveCustomer(Connection conn, int customerId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM Users WHERE user_id = ? AND role = ? AND status = ?")) {
            ps.setInt(1, customerId);
            ps.setString(2, Constants.ROLE_CUSTOMER);
            ps.setString(3, Constants.STATUS_ACTIVE);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean isEventBookable(Connection conn, int eventId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM Events WITH (UPDLOCK) WHERE event_id = ? AND status = ? AND start_time > GETDATE()")) {
            ps.setInt(1, eventId);
            ps.setString(2, Constants.EVENT_ACTIVE);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** @return {voucherId, discountAmount}; tăng used_count trong cùng transaction. */
    private Object[] applyVoucher(Connection conn, String code, BigDecimal total)
            throws SQLException, BookingException {
        String sql = "SELECT voucher_id, discount_type, discount_value, min_order_amount, max_discount_amount, "
                + "usage_limit, used_count FROM Vouchers WITH (UPDLOCK, ROWLOCK) "
                + "WHERE voucher_code = ? AND status = 'ACTIVE' AND GETDATE() BETWEEN start_time AND end_time";
        int voucherId;
        BigDecimal discount;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new BookingException("Mã giảm giá không tồn tại hoặc đã hết hạn.");
                }
                voucherId = rs.getInt("voucher_id");
                if (rs.getInt("used_count") >= rs.getInt("usage_limit")) {
                    throw new BookingException("Mã giảm giá đã hết lượt sử dụng.");
                }
                BigDecimal minOrder = rs.getBigDecimal("min_order_amount");
                if (minOrder != null && total.compareTo(minOrder) < 0) {
                    throw new BookingException("Đơn hàng chưa đạt giá trị tối thiểu "
                            + minOrder.setScale(0, RoundingMode.HALF_UP).toPlainString() + " đ để dùng mã này.");
                }
                BigDecimal value = rs.getBigDecimal("discount_value");
                BigDecimal max = rs.getBigDecimal("max_discount_amount");
                if ("Percentage".equalsIgnoreCase(rs.getString("discount_type"))) {
                    discount = total.multiply(value).divide(BigDecimal.valueOf(100), 0, RoundingMode.DOWN);
                } else {
                    discount = value;
                }
                if (max != null && discount.compareTo(max) > 0) {
                    discount = max;
                }
                if (discount.compareTo(total) > 0) {
                    discount = total;
                }
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Vouchers SET used_count = used_count + 1, updated_at = GETDATE() WHERE voucher_id = ?")) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        }
        return new Object[]{voucherId, discount};
    }

    private int insertOrder(Connection conn, int customerId, Integer voucherId, BigDecimal total,
            BigDecimal discount, BigDecimal finalAmount) throws SQLException {
        String sql = "INSERT INTO Orders (customer_id, voucher_id, order_code, total_amount, discount_amount, "
                + "final_amount, status, hold_started_at, hold_expired_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'Pending', GETDATE(), DATEADD(SECOND, ?, GETDATE()))";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            if (voucherId == null) {
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(2, voucherId);
            }
            ps.setString(3, generateOrderCode());
            ps.setBigDecimal(4, total);
            ps.setBigDecimal(5, discount);
            ps.setBigDecimal(6, finalAmount);
            ps.setInt(7, Constants.BOOKING_HOLD_SECONDS);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Cannot read generated order id");
    }

    private String generateOrderCode() {
        return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"))
                + UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
    }
}
