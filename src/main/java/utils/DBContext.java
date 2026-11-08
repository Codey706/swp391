
package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    // Có thể ghi đè bằng biến môi trường LTM_DB_URL / LTM_DB_USER / LTM_DB_PASSWORD
    private static final String URL = env("LTM_DB_URL",
              "jdbc:sqlserver://127.0.0.1:1433;"
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

    private static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value.trim();
    }
}
