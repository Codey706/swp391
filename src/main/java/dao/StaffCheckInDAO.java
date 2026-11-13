package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import utils.Constants;
import utils.DBContext;

/**
 * Staff - Check-in vé: soát vé theo mã (nội dung QR trên vé điện tử chính là ticket_code).
 * Quyền của staff với sự kiện được controller kiểm tra trước khi gọi DAO.
 */
public class StaffCheckInDAO {

    public enum Outcome {
        CHECKED_IN, NOT_FOUND, WRONG_EVENT, ALREADY_CHECKED_IN, CANCELLED, NOT_PAID
    }

    /** Kết quả một lượt soát vé (cũng dùng cho danh sách lượt check-in gần đây). */
    public static class Result implements java.io.Serializable {

        private static final long serialVersionUID = 1L;

        private Outcome outcome;
        private String ticketCode;
        private String ticketName;
        private String seatLabel;
        private String customerName;
        private LocalDateTime checkInTime;

        public String getOutcomeName() {
            return outcome == null ? "" : outcome.name();
        }

        public String getTicketCode() {
            return ticketCode;
        }

        public String getTicketName() {
            return ticketName;
        }

        public String getSeatLabel() {
            return seatLabel;
        }

        public String getCustomerName() {
            return customerName;
        }

        public LocalDateTime getCheckInTime() {
            return checkInTime;
        }
    }

    private static final String SELECT_TICKET
            = "SELECT tk.ticket_id, tk.event_id, tk.ticket_code, tk.ticket_status, tk.check_in_time, "
            + "et.ticket_name, es.seat_label, u.full_name, o.status AS order_status "
            + "FROM Tickets tk "
            + "JOIN Order_Details od ON od.order_detail_id = tk.order_detail_id "
            + "JOIN Orders o ON o.order_id = od.order_id "
            + "JOIN Users u ON u.user_id = o.customer_id "
            + "JOIN Event_Tickets et ON et.event_ticket_id = od.event_ticket_id "
            + "LEFT JOIN Event_Seats es ON es.event_seat_id = tk.event_seat_id ";

    /**
     * Soát một vé cho sự kiện eventId. Khóa dòng vé (UPDLOCK) để hai cổng quét cùng lúc
     * không check-in một vé hai lần.
     */
    public Result checkIn(int eventId, String ticketCode) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Result result = checkInInTransaction(conn, eventId, ticketCode);
                conn.commit();
                return result;
            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private Result checkInInTransaction(Connection conn, int eventId, String ticketCode) throws SQLException {
        Result result = new Result();
        result.ticketCode = ticketCode;
        int ticketId;
        try (PreparedStatement ps = conn.prepareStatement(
                SELECT_TICKET.replace("FROM Tickets tk ", "FROM Tickets tk WITH (UPDLOCK, ROWLOCK) ")
                + "WHERE tk.ticket_code = ?")) {
            ps.setString(1, ticketCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    result.outcome = Outcome.NOT_FOUND;
                    return result;
                }
                fill(result, rs);
                ticketId = rs.getInt("ticket_id");
                if (rs.getInt("event_id") != eventId) {
                    result.outcome = Outcome.WRONG_EVENT;
                    return result;
                }
                String status = rs.getString("ticket_status");
                if (Constants.TICKET_CHECKED_IN.equalsIgnoreCase(status)) {
                    result.outcome = Outcome.ALREADY_CHECKED_IN;
                    return result;
                }
                if (Constants.TICKET_CANCELLED.equalsIgnoreCase(status)) {
                    result.outcome = Outcome.CANCELLED;
                    return result;
                }
                if (!Constants.ORDER_PAID.equalsIgnoreCase(rs.getString("order_status"))) {
                    result.outcome = Outcome.NOT_PAID;
                    return result;
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Tickets SET ticket_status = ?, check_in_time = GETDATE() "
                + "WHERE ticket_id = ? AND ticket_status = 'Valid'")) {
            ps.setString(1, Constants.TICKET_CHECKED_IN);
            ps.setInt(2, ticketId);
            if (ps.executeUpdate() != 1) {
                result.outcome = Outcome.ALREADY_CHECKED_IN;
                return result;
            }
        }
        result.outcome = Outcome.CHECKED_IN;
        result.checkInTime = LocalDateTime.now();
        return result;
    }

    /** Các lượt check-in mới nhất của sự kiện. */
    public List<Result> findRecentCheckIns(int eventId, int limit) throws SQLException {
        String sql = SELECT_TICKET.replace("SELECT ", "SELECT TOP (?) ")
                + "WHERE tk.event_id = ? AND tk.ticket_status = ? "
                + "ORDER BY tk.check_in_time DESC, tk.ticket_id DESC";
        List<Result> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, eventId);
            ps.setString(3, Constants.TICKET_CHECKED_IN);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Result r = new Result();
                    r.outcome = Outcome.CHECKED_IN;
                    fill(r, rs);
                    list.add(r);
                }
            }
        }
        return list;
    }

    private void fill(Result result, ResultSet rs) throws SQLException {
        result.ticketCode = rs.getString("ticket_code");
        result.ticketName = rs.getString("ticket_name");
        result.seatLabel = rs.getString("seat_label");
        result.customerName = rs.getString("full_name");
        Timestamp checkIn = rs.getTimestamp("check_in_time");
        result.checkInTime = checkIn == null ? null : checkIn.toLocalDateTime();
    }
}
