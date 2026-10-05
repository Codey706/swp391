package dao;

import model.Category;
import utils.DBcontext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> getAllCategories() throws SQLException {

        List<Category> categories = new ArrayList<>();

        String sql = "SELECT category_id, category_name, description, "
                + "status, created_at, updated_at "
                + "FROM Categories "
                + "ORDER BY category_id";

        try (Connection connection = DBcontext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                Category category = new Category();

                category.setCategoryId(
                        resultSet.getInt("category_id")
                );

                category.setCategoryName(
                        resultSet.getString("category_name")
                );

                category.setDescription(
                        resultSet.getString("description")
                );

                category.setStatus(
                        resultSet.getString("status")
                );

                Timestamp createdAt
                        = resultSet.getTimestamp("created_at");

                Timestamp updatedAt
                        = resultSet.getTimestamp("updated_at");

                if (createdAt != null) {
                    category.setCreatedAt(
                            createdAt.toLocalDateTime()
                    );
                }

                if (updatedAt != null) {
                    category.setUpdatedAt(
                            updatedAt.toLocalDateTime()
                    );
                }

                categories.add(category);
            }
        }

        return categories;
    }
}
