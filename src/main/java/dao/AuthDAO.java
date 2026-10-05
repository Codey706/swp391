package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import model.Auth;
import utils.DBContext;

public class AuthDAO {

    private final String SELECT_FIELDS = "SELECT user_id, username, email, password, full_name, phone, address, role, status, failed_attempts, locked_until FROM Users ";

    public Auth findByUsernameOrEmail(String identifier) throws SQLException {
        String sql = SELECT_FIELDS + "WHERE username = ? OR email = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, identifier);
            ps.setString(2, identifier);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public Auth findByEmail(String email) throws SQLException {
        String sql = SELECT_FIELDS + "WHERE email = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public Auth findById(int userId) throws SQLException {
        String sql = SELECT_FIELDS + "WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    public boolean usernameExists(String username) throws SQLException {
        return exists("SELECT 1 FROM Users WHERE username = ?", username);
    }

    public boolean emailExists(String email) throws SQLException {
        return exists("SELECT 1 FROM Users WHERE email = ?", email);
    }

    public boolean phoneExists(String phone) throws SQLException {
        return exists("SELECT 1 FROM Users WHERE phone = ?", phone);
    }

    public boolean insertCustomer(Auth user) throws SQLException {
        String sql = "INSERT INTO Users (username, email, password, full_name, phone, address, role, status, failed_attempts) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'Customer', 'ACTIVE', 0)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getAddress());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePassword(int userId, String password) throws SQLException {
        String sql = "UPDATE Users SET password = ?, updated_at = GETDATE() WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, password);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public void recordFailedAttempt(int userId, int failedAttempts, Timestamp lockedUntil) throws SQLException {
        String sql = "UPDATE Users SET failed_attempts = ?, locked_until = ? WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, failedAttempts);
            ps.setTimestamp(2, lockedUntil);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    public void resetFailedAttempts(int userId) throws SQLException {
        String sql = "UPDATE Users SET failed_attempts = 0, locked_until = NULL WHERE user_id = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    private boolean exists(String sql, String value) throws SQLException {
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Auth map(ResultSet rs) throws SQLException {
        Auth user = new Auth();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        user.setFailedAttempts(rs.getInt("failed_attempts"));
        user.setLockedUntil(rs.getTimestamp("locked_until"));
        return user;
    }
}
