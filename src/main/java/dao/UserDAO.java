/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;
import utils.DBcontext;

/**
 *
 * @author TRUC MAI
 */
public class UserDAO {

    private DBcontext dbContext = new DBcontext();

    public User getUserById(int userId) {
        String sql = "SELECT user_id, username, email, full_name, "
                + "phone, address, role, status "
                + "FROM Users "
                + "WHERE user_id = ?";
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

                    return user;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
  public boolean updateUser(User user) {

    String sql = "UPDATE Users "
            + "SET email = ?, "
            + "full_name = ?, "
            + "phone = ?, "
            + "address = ?, "
            + "updated_at = GETDATE() "
            + "WHERE user_id = ?";

    try (Connection connection = DBcontext.getConnection();
         PreparedStatement statement =
                 connection.prepareStatement(sql)) {

        statement.setString(1, user.getEmail());
        statement.setString(2, user.getFullName());
        statement.setString(3, user.getPhone());
        statement.setString(4, user.getAddress());
        statement.setInt(5, user.getUserId());

        int rowsAffected = statement.executeUpdate();

        System.out.println("Rows affected: " + rowsAffected);

        return rowsAffected > 0;

    } catch (SQLException e) {

        System.out.println("UPDATE USER ERROR:");
        e.printStackTrace();

    }

    return false;
}
}
