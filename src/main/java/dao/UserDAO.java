package dao;

import model.User;
import utils.DBcontext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public List<User> getAllUsers() throws SQLException {

        List<User> users = new ArrayList<>();

        String sql = "SELECT user_id, username, email, full_name, "
                + "phone, address, role, status, created_at, updated_at "
                + "FROM Users";

        try (Connection connection = DBcontext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {

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
                //user.setCreatedAt(resultSet.getTimestamp("created_at"));
                //user.setUpdatedAt(resultSet.getTimestamp("updated_at"));

                users.add(user);
            }
        }

        return users;
    }

    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT user_id, username, email, full_name, "
                + "phone, address, role, status, created_at, updated_at "
                + "FROM Users WHERE user_id = ?";

        try (Connection connection = DBcontext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

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
                    //user.setCreatedAt(resultSet.getTimestamp("created_at"));
                    //user.setUpdatedAt(resultSet.getTimestamp("updated_at"));

                    return user;
                }
            }
        }

        return null;
    }
}
