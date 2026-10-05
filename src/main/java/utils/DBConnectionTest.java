package utils;

import java.sql.Connection;

public class DBConnectionTest {

    public static void main(String[] args) {

        try (Connection connection = DBContext.getConnection()) {

            if (connection != null) {
                System.out.println("=================================");
                System.out.println("DATABASE CONNECTED SUCCESSFULLY");
                System.out.println("Database: " + connection.getCatalog());
                System.out.println("=================================");
            }

        } catch (Exception e) {
            System.out.println("DATABASE CONNECTION FAILED");
            e.printStackTrace();
        }
    }
}