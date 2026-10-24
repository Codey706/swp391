package dao;

import model.Voucher;
import utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO {

    public List<Voucher> getAllVouchers() throws SQLException {

        List<Voucher> vouchers = new ArrayList<>();

        String sql = "SELECT voucher_id, voucher_code, voucher_name, "
                + "discount_type, discount_value, min_order_amount, "
                + "max_discount_amount, start_time, end_time, "
                + "usage_limit, used_count, status, failed_attempts, "
                + "locked_until, created_at, updated_at "
                + "FROM Vouchers "
                + "ORDER BY voucher_id";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql); ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                Voucher voucher = new Voucher();

                voucher.setVoucherId(
                        resultSet.getInt("voucher_id")
                );

                voucher.setVoucherCode(
                        resultSet.getString("voucher_code")
                );

                voucher.setVoucherName(
                        resultSet.getString("voucher_name")
                );

                voucher.setDiscountType(
                        resultSet.getString("discount_type")
                );

                voucher.setDiscountValue(
                        resultSet.getBigDecimal("discount_value")
                );

                voucher.setMinOrderAmount(
                        resultSet.getBigDecimal("min_order_amount")
                );

                voucher.setMaxDiscountAmount(
                        resultSet.getBigDecimal("max_discount_amount")
                );

                Timestamp startTime = resultSet.getTimestamp("start_time");
                Timestamp endTime = resultSet.getTimestamp("end_time");
                Timestamp lockedUntil = resultSet.getTimestamp("locked_until");
                Timestamp createdAt = resultSet.getTimestamp("created_at");
                Timestamp updatedAt = resultSet.getTimestamp("updated_at");

                if (startTime != null) {
                    voucher.setStartTime(startTime.toLocalDateTime());
                }

                if (endTime != null) {
                    voucher.setEndTime(endTime.toLocalDateTime());
                }

                if (lockedUntil != null) {
                    voucher.setLockedUntil(lockedUntil.toLocalDateTime());
                }

                if (createdAt != null) {
                    voucher.setCreatedAt(createdAt.toLocalDateTime());
                }

                if (updatedAt != null) {
                    voucher.setUpdatedAt(updatedAt.toLocalDateTime());
                }

                voucher.setUsageLimit(
                        resultSet.getInt("usage_limit")
                );

                voucher.setUsedCount(
                        resultSet.getInt("used_count")
                );

                voucher.setStatus(
                        resultSet.getString("status")
                );

                voucher.setFailedAttempts(
                        resultSet.getInt("failed_attempts")
                );

                vouchers.add(voucher);
            }
        }

        return vouchers;
    }

    public void createVoucher(Voucher voucher) throws SQLException {

        String sql = "INSERT INTO Vouchers "
                + "(voucher_code, voucher_name, discount_type, "
                + "discount_value, min_order_amount, max_discount_amount, "
                + "start_time, end_time, usage_limit, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, voucher.getVoucherCode());
            statement.setString(2, voucher.getVoucherName());
            statement.setString(3, voucher.getDiscountType());
            statement.setBigDecimal(4, voucher.getDiscountValue());
            statement.setBigDecimal(5, voucher.getMinOrderAmount());

            if (voucher.getMaxDiscountAmount() != null) {
                statement.setBigDecimal(6, voucher.getMaxDiscountAmount());
            } else {
                statement.setNull(6, java.sql.Types.DECIMAL);
            }

            statement.setTimestamp(
                    7,
                    Timestamp.valueOf(voucher.getStartTime())
            );

            statement.setTimestamp(
                    8,
                    Timestamp.valueOf(voucher.getEndTime())
            );

            statement.setInt(9, voucher.getUsageLimit());
            statement.setString(10, voucher.getStatus());

            statement.executeUpdate();
        }
    }

    public Voucher getVoucherById(int voucherId) throws SQLException {

        String sql = "SELECT voucher_id, voucher_code, voucher_name, "
                + "discount_type, discount_value, min_order_amount, "
                + "max_discount_amount, start_time, end_time, "
                + "usage_limit, used_count, status, failed_attempts, "
                + "locked_until, created_at, updated_at "
                + "FROM Vouchers WHERE voucher_id = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, voucherId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Voucher voucher = new Voucher();

                    voucher.setVoucherId(resultSet.getInt("voucher_id"));
                    voucher.setVoucherCode(resultSet.getString("voucher_code"));
                    voucher.setVoucherName(resultSet.getString("voucher_name"));
                    voucher.setDiscountType(resultSet.getString("discount_type"));
                    voucher.setDiscountValue(resultSet.getBigDecimal("discount_value"));
                    voucher.setMinOrderAmount(resultSet.getBigDecimal("min_order_amount"));
                    voucher.setMaxDiscountAmount(resultSet.getBigDecimal("max_discount_amount"));

                    Timestamp startTime = resultSet.getTimestamp("start_time");
                    Timestamp endTime = resultSet.getTimestamp("end_time");
                    Timestamp lockedUntil = resultSet.getTimestamp("locked_until");
                    Timestamp createdAt = resultSet.getTimestamp("created_at");
                    Timestamp updatedAt = resultSet.getTimestamp("updated_at");

                    if (startTime != null) {
                        voucher.setStartTime(startTime.toLocalDateTime());
                    }

                    if (endTime != null) {
                        voucher.setEndTime(endTime.toLocalDateTime());
                    }

                    if (lockedUntil != null) {
                        voucher.setLockedUntil(lockedUntil.toLocalDateTime());
                    }

                    if (createdAt != null) {
                        voucher.setCreatedAt(createdAt.toLocalDateTime());
                    }

                    if (updatedAt != null) {
                        voucher.setUpdatedAt(updatedAt.toLocalDateTime());
                    }

                    voucher.setUsageLimit(resultSet.getInt("usage_limit"));
                    voucher.setUsedCount(resultSet.getInt("used_count"));
                    voucher.setStatus(resultSet.getString("status"));
                    voucher.setFailedAttempts(resultSet.getInt("failed_attempts"));

                    return voucher;
                }
            }
        }

        return null;
    }

    public void updateVoucher(Voucher voucher) throws SQLException {

        String sql = "UPDATE Vouchers SET "
                + "voucher_code = ?, "
                + "voucher_name = ?, "
                + "discount_type = ?, "
                + "discount_value = ?, "
                + "min_order_amount = ?, "
                + "max_discount_amount = ?, "
                + "start_time = ?, "
                + "end_time = ?, "
                + "usage_limit = ?, "
                + "status = ?, "
                + "updated_at = GETDATE() "
                + "WHERE voucher_id = ?";

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, voucher.getVoucherCode());
            statement.setString(2, voucher.getVoucherName());
            statement.setString(3, voucher.getDiscountType());
            statement.setBigDecimal(4, voucher.getDiscountValue());
            statement.setBigDecimal(5, voucher.getMinOrderAmount());

            if (voucher.getMaxDiscountAmount() != null) {
                statement.setBigDecimal(6, voucher.getMaxDiscountAmount());
            } else {
                statement.setNull(6, java.sql.Types.DECIMAL);
            }

            statement.setTimestamp(
                    7, Timestamp.valueOf(voucher.getStartTime())
            );

            statement.setTimestamp(
                    8, Timestamp.valueOf(voucher.getEndTime())
            );

            statement.setInt(9, voucher.getUsageLimit());
            statement.setString(10, voucher.getStatus());
            statement.setInt(11, voucher.getVoucherId());

            statement.executeUpdate();
        }
    }

}
