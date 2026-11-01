package dao;

import model.SeatStatusRow;
import utils.Constants;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Dữ liệu chỉ đọc cho trang Staff - Seat Status. DAO này không kiểm tra phân công:
 * controller phải xác nhận sự kiện thuộc Staff đang đăng nhập (StaffEventDAO) trước
 * khi gọi. Khu/sơ đồ lấy từ SeatMapDAO.getZones.
 */
public class StaffSeatStatusDAO {

    /**
     * Mọi ghế của sự kiện. Ghế "đã check-in" khi có vé CheckedIn trỏ tới ghế đó
     * (EXISTS nên không nhân bản dòng nếu một ghế có nhiều vé).
     */
    public List<SeatStatusRow> findSeats(int eventId) throws SQLException {
        String sql = "SELECT es.zone_id, es.row_label, es.seat_number, es.seat_type, es.status, "
                + "CASE WHEN EXISTS (SELECT 1 FROM Tickets tk WHERE tk.event_seat_id = es.event_seat_id "
                + "AND tk.ticket_status = ?) THEN 1 ELSE 0 END AS checked_in "
                + "FROM Event_Seats es WHERE es.event_id = ?";
        List<SeatStatusRow> rows = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, Constants.TICKET_CHECKED_IN);
            statement.setInt(2, eventId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    SeatStatusRow row = new SeatStatusRow();
                    int zoneId = rs.getInt("zone_id");
                    row.setZoneId(rs.wasNull() ? null : zoneId);
                    row.setRowLabel(rs.getString("row_label"));
                    row.setSeatNumber(rs.getInt("seat_number"));
                    row.setSeatType(rs.getString("seat_type"));
                    row.setStatus(rs.getString("status"));
                    row.setCheckedIn(rs.getInt("checked_in") == 1);
                    rows.add(row);
                }
            }
        }
        return rows;
    }

    /**
     * Vé khu đứng theo từng khu: [đã phát hành (không tính vé hủy), đã check-in].
     * Vé khu đứng không có event_seat_id; khu được nối với vé qua hạng vé
     * (Event_Zones.event_ticket_id = Order_Details.event_ticket_id). Nếu nhiều khu đứng
     * dùng chung một hạng vé thì số này gộp cả các khu đó, nên controller phải loại trường hợp này.
     */
    public Map<Integer, int[]> findStandingTickets(int eventId) throws SQLException {
        String sql = "SELECT z.zone_id, COUNT(tk.ticket_id) AS issued, "
                + "ISNULL(SUM(CASE WHEN tk.ticket_status = ? THEN 1 ELSE 0 END), 0) AS checked_in "
                + "FROM Event_Zones z "
                + "LEFT JOIN Order_Details od ON od.event_ticket_id = z.event_ticket_id "
                + "LEFT JOIN Tickets tk ON tk.order_detail_id = od.order_detail_id AND tk.event_id = z.event_id "
                + "AND tk.event_seat_id IS NULL AND tk.ticket_status <> ? "
                + "WHERE z.event_id = ? AND z.zone_type = 'STANDING' GROUP BY z.zone_id";
        Map<Integer, int[]> result = new HashMap<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, Constants.TICKET_CHECKED_IN);
            statement.setString(2, Constants.TICKET_CANCELLED);
            statement.setInt(3, eventId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("zone_id"), new int[]{rs.getInt("issued"), rs.getInt("checked_in")});
                }
            }
        }
        return result;
    }
}
