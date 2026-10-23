package dao;

import model.User;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserDAO {

    public List<User> getAllUsers(int currentUserId) throws SQLException {
        return getAllUsers(currentUserId, null, null, null);
    }

    public List<User> getAllUsers(int currentUserId, String keyword, String role, String status) throws SQLException {

        List<User> users = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT user_id, username, email, full_name, ")
                .append("phone, address, role, status, created_at, updated_at ")
                .append("FROM Users WHERE 1=1 ");

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasRole = role != null && !role.trim().isEmpty() && !"ALL".equalsIgnoreCase(role.trim());
        boolean hasStatus = status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim());

        if (hasKeyword) {
            sql.append("AND (username LIKE ? OR email LIKE ? OR full_name LIKE ? OR phone LIKE ?) ");
        }

        if (hasRole) {
            sql.append("AND UPPER(role) = UPPER(?) ");
        }

        if (hasStatus) {
            sql.append("AND UPPER(status) = UPPER(?) ");
        }

        sql.append("ORDER BY ")
                .append("CASE ")
                .append("    WHEN user_id = ? AND UPPER(role) = 'ADMIN' THEN 0 ")
                .append("    ELSE 1 ")
                .append("END, ")
                .append("CASE UPPER(role) ")
                .append("    WHEN 'ADMIN' THEN 1 ")
                .append("    WHEN 'ORGANIZER' THEN 2 ")
                .append("    WHEN 'STAFF' THEN 3 ")
                .append("    WHEN 'CUSTOMER' THEN 4 ")
                .append("    ELSE 5 ")
                .append("END, ")
                .append("user_id ASC");

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (hasKeyword) {
                String pattern = "%" + keyword.trim() + "%";
                statement.setString(paramIndex++, pattern);
                statement.setString(paramIndex++, pattern);
                statement.setString(paramIndex++, pattern);
                statement.setString(paramIndex++, pattern);
            }

            if (hasRole) {
                statement.setString(paramIndex++, role.trim());
            }

            if (hasStatus) {
                statement.setString(paramIndex++, status.trim());
            }

            statement.setInt(paramIndex++, currentUserId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    users.add(mapUser(resultSet));
                }
            }
        }

        return users;
    }

    public Map<String, Integer> getUserStatistics() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT "
                + "COUNT(*) AS total, "
                + "SUM(CASE WHEN UPPER(status) = 'ACTIVE' THEN 1 ELSE 0 END) AS active_count, "
                + "SUM(CASE WHEN UPPER(status) <> 'ACTIVE' THEN 1 ELSE 0 END) AS inactive_count, "
                + "SUM(CASE WHEN UPPER(role) = 'ORGANIZER' THEN 1 ELSE 0 END) AS organizer_count, "
                + "SUM(CASE WHEN UPPER(role) = 'STAFF' THEN 1 ELSE 0 END) AS staff_count, "
                + "SUM(CASE WHEN UPPER(role) = 'CUSTOMER' THEN 1 ELSE 0 END) AS customer_count "
                + "FROM Users";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                stats.put("total", resultSet.getInt("total"));
                stats.put("active", resultSet.getInt("active_count"));
                stats.put("inactive", resultSet.getInt("inactive_count"));
                stats.put("organizers", resultSet.getInt("organizer_count"));
                stats.put("staffs", resultSet.getInt("staff_count"));
                stats.put("customers", resultSet.getInt("customer_count"));
            }
        }

        return stats;
    }

    public User getUserById(int userId) throws SQLException {

        String sql = "SELECT user_id, username, email, full_name, "
                + "phone, address, role, status, created_at, updated_at "
                + "FROM Users "
                + "WHERE user_id = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapUser(resultSet);
                }
            }
        }

        return null;
    }

    private User mapUser(ResultSet resultSet) throws SQLException {
        User user = new User();

        user.setUserId(resultSet.getInt("user_id"));
        user.setUsername(resultSet.getString("username"));
        user.setEmail(resultSet.getString("email"));
        user.setFullName(resultSet.getString("full_name"));
        user.setPhone(resultSet.getString("phone"));
        user.setAddress(resultSet.getString("address"));
        user.setRole(resultSet.getString("role"));
        user.setStatus(resultSet.getString("status"));

        Timestamp createdAt = resultSet.getTimestamp("created_at");
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");

        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }

        if (updatedAt != null) {
            user.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return user;
    }

    // Update thông tin user
    public boolean updateUser(User user) throws SQLException {
        String sql = "UPDATE Users "
                + "SET full_name = ?, phone = ?, address = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getFullName());
            statement.setString(2, user.getPhone());
            statement.setString(3, user.getAddress());
            statement.setInt(4, user.getUserId());

            return statement.executeUpdate() > 0;
        }
    }

    // Đổi status nhanh
    public boolean updateUserStatus(int userId, String status) throws SQLException {
        String sql = "UPDATE Users "
                + "SET status = ?, updated_at = GETDATE() "
                + "WHERE user_id = ? AND UPPER(role) <> 'ADMIN'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, userId);

            return statement.executeUpdate() > 0;
        }
    }

    // Update Role, không cho đổi Role của Admin
    // và không cho đổi user thường thành Admin
    public boolean updateUserRole(int userId, String newRole) throws SQLException {

        String sql = "UPDATE Users "
                + "SET role = ?, updated_at = GETDATE() "
                + "WHERE user_id = ? "
                + "AND UPPER(role) <> 'ADMIN' "
                + "AND UPPER(?) <> 'ADMIN'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, newRole);
            statement.setInt(2, userId);
            statement.setString(3, newRole);

            return statement.executeUpdate() > 0;
        }
    }

    // Create User (Admin tạo người dùng)
    public boolean createUser(User user) throws SQLException {
        String sql = "INSERT INTO Users (username, email, password, full_name, phone, address, role, status, failed_attempts, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, GETDATE(), GETDATE())";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getUsername());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPassword());
            statement.setString(4, user.getFullName());

            if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
                statement.setNull(5, Types.VARCHAR);
            } else {
                statement.setString(5, user.getPhone().trim());
            }

            if (user.getAddress() == null || user.getAddress().trim().isEmpty()) {
                statement.setNull(6, Types.NVARCHAR);
            } else {
                statement.setString(6, user.getAddress().trim());
            }

            statement.setString(7, user.getRole());
            statement.setString(8, user.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    // Delete User (không cho xóa Admin)
    public boolean deleteUser(int userId) throws SQLException {
        String sql = "DELETE FROM Users WHERE user_id = ? AND UPPER(role) <> 'ADMIN'";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            return statement.executeUpdate() > 0;
        }
    }

    // Kiểm tra username đã tồn tại
    public boolean existsUsername(String username) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE LOWER(username) = LOWER(?)";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, username.trim());

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // Kiểm tra email đã tồn tại
    public boolean existsEmail(String email) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE LOWER(email) = LOWER(?)";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email.trim());

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // Kiểm tra user có ràng buộc dữ liệu giao dịch/sự kiện/phân công không
    public boolean hasRelatedRecords(int userId) throws SQLException {
        String sql = "SELECT 1 FROM Orders WHERE customer_id = ? "
                + "UNION ALL SELECT 1 FROM Events WHERE organizer_id = ? "
                + "UNION ALL SELECT 1 FROM Event_Staff WHERE staff_id = ? "
                + "UNION ALL SELECT 1 FROM Reviews WHERE customer_id = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setInt(2, userId);
            statement.setInt(3, userId);
            statement.setInt(4, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // ------------------------------------------------------------------
    // Manage My Organizer Profile
    // ------------------------------------------------------------------
    /**
     * Cập nhật hồ sơ của chính Organizer. Chỉ ghi full_name, email, phone,
     * address; không bao giờ đụng tới role, status, password. Điều kiện WHERE
     * chặn cập nhật nếu tài khoản không phải Organizer đang ACTIVE.
     */
    public boolean updateOrganizerProfile(User user) throws SQLException {
        String sql = "UPDATE Users "
                + "SET full_name = ?, email = ?, phone = ?, address = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ? AND UPPER(role) = 'ORGANIZER' AND UPPER(status) = 'ACTIVE'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getFullName());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPhone());

            if (user.getAddress() == null) {
                statement.setNull(4, Types.NVARCHAR);
            } else {
                statement.setString(4, user.getAddress());
            }

            statement.setInt(5, user.getUserId());

            return statement.executeUpdate() > 0;
        }
    }

    // Email đã thuộc về tài khoản khác (BR-02), không phân biệt hoa/thường
    public boolean existsEmailOfOtherUser(String email, int userId) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE LOWER(email) = LOWER(?) AND user_id <> ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // Số điện thoại đã thuộc về tài khoản khác (BR-02)
    public boolean existsPhoneOfOtherUser(String phone, int userId) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE phone = ? AND user_id <> ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, phone);
            statement.setInt(2, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    // ------------------------------------------------------------------
    // Manage My Staff Profile
    // ------------------------------------------------------------------
    /**
     * Cập nhật hồ sơ của chính Staff. Chỉ ghi full_name, email, phone, address;
     * không bao giờ đụng tới role, status, password. Điều kiện WHERE chặn cập
     * nhật nếu tài khoản không phải Staff đang ACTIVE.
     */
    public boolean updateStaffProfile(User user) throws SQLException {
        String sql = "UPDATE Users "
                + "SET full_name = ?, email = ?, phone = ?, address = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ? AND UPPER(role) = 'STAFF' AND UPPER(status) = 'ACTIVE'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getFullName());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPhone());

            if (user.getAddress() == null) {
                statement.setNull(4, Types.NVARCHAR);
            } else {
                statement.setString(4, user.getAddress());
            }

            statement.setInt(5, user.getUserId());

            return statement.executeUpdate() > 0;
        }
    }

    // ------------------------------------------------------------------
    // Manage My Admin Profile
    // ------------------------------------------------------------------
    /**
     * Cập nhật hồ sơ của chính Admin đang ACTIVE. Không thay đổi username,
     * role, status hoặc password.
     */
    public boolean updateAdminProfile(User user) throws SQLException {
        String sql = "UPDATE Users "
                + "SET full_name = ?, email = ?, phone = ?, address = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ? "
                + "AND UPPER(role) = 'ADMIN' "
                + "AND UPPER(status) = 'ACTIVE'";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getFullName());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getPhone());

            if (user.getAddress() == null) {
                statement.setNull(4, Types.NVARCHAR);
            } else {
                statement.setString(4, user.getAddress());
            }

            statement.setInt(5, user.getUserId());

            return statement.executeUpdate() > 0;
        }
    }
}
