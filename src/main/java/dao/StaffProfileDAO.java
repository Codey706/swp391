package dao;

import utils.Constants;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Số liệu hiển thị trên hồ sơ Staff, lấy từ Event_Staff / Events / Tickets.
 * Thông tin cá nhân (tên, email, điện thoại, địa chỉ) vẫn nằm ở Users và được
 * ghi qua UserDAO.
 */
public class StaffProfileDAO {

    /**
     * @return {tổng sự kiện được phân công, sự kiện sắp/đang diễn ra} của staff.
     * Chỉ tính phân công ACTIVE và sự kiện chưa bị hủy.
     */
    public int[] getAssignmentSummary(int staffId) throws SQLException {
        String sql = "SELECT COUNT(*), "
                + "ISNULL(SUM(CASE WHEN e.end_time > GETDATE() THEN 1 ELSE 0 END), 0) "
                + "FROM Event_Staff es "
                + "JOIN Events e ON e.event_id = es.event_id "
                + "WHERE es.staff_id = ? AND UPPER(es.status) = ? AND UPPER(e.status) <> 'CANCELLED'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, staffId);
            statement.setString(2, Constants.EVENT_STAFF_ACTIVE);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1), rs.getInt(2)};
                }
            }
        }
        return new int[]{0, 0};
    }

    /**
     * @return số vé đã check-in thuộc các sự kiện mà staff được phân công.
     */
    public int countCheckedInTickets(int staffId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Tickets t "
                + "WHERE t.ticket_status = ? AND t.event_id IN ("
                + "SELECT es.event_id FROM Event_Staff es WHERE es.staff_id = ? AND UPPER(es.status) = ?)";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, Constants.TICKET_CHECKED_IN);
            statement.setInt(2, staffId);
            statement.setString(3, Constants.EVENT_STAFF_ACTIVE);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
