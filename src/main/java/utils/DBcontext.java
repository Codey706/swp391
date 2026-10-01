package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBcontext {

    private static final String URL =
            "jdbc:sqlserver://localhost:1433;"
          + "databaseName=LightTicketDB;"
          + "encrypt=false;"
          + "trustServerCertificate=true";

    private static final String USER = "sa";
    private static final String PASSWORD = "123";

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}