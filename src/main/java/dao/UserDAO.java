package dao;

import model.User;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public List<User> getAllUsers() throws SQLException {

        List<User> users = new ArrayList<User>();

        String sql = "SELECT user_id, username, email, full_name, "
                + "phone, address, role, status, created_at, updated_at "
                + "FROM Users "
                + "ORDER BY user_id";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {

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
                + "SET full_name = ?, "
                + "phone = ?, "
                + "address = ?, "
                + "role = ?, "
                + "status = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, user.getFullName());
            statement.setString(2, user.getPhone());
            statement.setString(3, user.getAddress());
            statement.setString(4, user.getRole());
            statement.setString(5, user.getStatus());
            statement.setInt(6, user.getUserId());

            return statement.executeUpdate() > 0;
        }
    }

    // Đổi status nhanh
    public boolean updateUserStatus(int userId, String status) throws SQLException {

        String sql = "UPDATE Users "
                + "SET status = ?, "
                + "updated_at = GETDATE() "
                + "WHERE user_id = ?";

        try (Connection connection = DBcontext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, userId);

            return statement.executeUpdate() > 0;
        }
    }
}
