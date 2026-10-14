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
import java.util.List;

public class UserDAO {

    public List<User> getAllUsers(int currentUserId) throws SQLException {

        List<User> users = new ArrayList<>();

        String sql = "SELECT user_id, username, email, full_name, "
                + "phone, address, role, status, created_at, updated_at "
                + "FROM Users "
                + "ORDER BY "
                + "CASE "
                + "    WHEN user_id = ? AND UPPER(role) = 'ADMIN' THEN 0 "
                + "    ELSE 1 "
                + "END, "
                + "CASE UPPER(role) "
                + "    WHEN 'ADMIN' THEN 1 "
                + "    WHEN 'ORGANIZER' THEN 2 "
                + "    WHEN 'STAFF' THEN 3 "
                + "    WHEN 'CUSTOMER' THEN 4 "
                + "    ELSE 5 "
                + "END, "
                + "user_id ASC";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, currentUserId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

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

                    users.add(user);
                }
            }
        }

        return users;
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
            }
        }

        return null;
    }

    // Update thông tin user
    public boolean updateUser(User user) throws SQLException {
        String sql = "UPDATE Users "
                + "SET full_name = ?, phone = ?, address = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ? AND UPPER(role) <> 'ADMIN'";

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
}
