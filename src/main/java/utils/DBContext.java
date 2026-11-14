package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    // Có thể ghi đè bằng biến môi trường LTM_DB_URL / LTM_DB_USER / LTM_DB_PASSWORD
    // để mỗi máy dùng cấu hình riêng mà không phải sửa code.
    private static final String URL = env("LTM_DB_URL",
              "jdbc:sqlserver://localhost:1433;"
            + "databaseName=LightTicketDB;"
            + "encrypt=false;"
            + "trustServerCertificate=true");

    private static final String USER = env("LTM_DB_USER", "sa");
    private static final String PASSWORD = env("LTM_DB_PASSWORD", "123");

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQL Server JDBC Driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    /** Lỗi vi phạm UNIQUE constraint (2627) / unique index (2601) của SQL Server. */
    public static boolean isDuplicateKey(SQLException e) {
        return e.getErrorCode() == 2627 || e.getErrorCode() == 2601;
    }

    private static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value.trim();
    }
}
