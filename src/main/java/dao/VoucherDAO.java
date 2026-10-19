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
}
