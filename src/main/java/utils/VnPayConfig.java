package utils;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Cấu hình VNPay Sandbox. Thứ tự lấy giá trị: biến môi trường VNPAY_TMN_CODE / VNPAY_HASH_SECRET,
 * rồi src/main/resources/vnpay.properties (bỏ qua giá trị mẫu "YOUR_...").
 *
 * @author BT
 */
public final class VnPayConfig {

    private static final Logger LOGGER = Logger.getLogger(VnPayConfig.class.getName());

    public static final String PAYMENT_URL =
            "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    private static final Properties FILE_CONFIG = loadFileConfig();

    private VnPayConfig() {
    }

    public static String getTmnCode() {
        return require("VNPAY_TMN_CODE", "vnpay.tmnCode");
    }

    public static String getHashSecret() {
        return require("VNPAY_HASH_SECRET", "vnpay.hashSecret");
    }

    /** true khi đã có đủ TMN code và hash secret. */
    public static boolean isConfigured() {
        return value("VNPAY_TMN_CODE", "vnpay.tmnCode") != null
                && value("VNPAY_HASH_SECRET", "vnpay.hashSecret") != null;
    }

    private static String require(String envName, String fileKey) {
        String value = value(envName, fileKey);
        if (value == null) {
            throw new IllegalStateException("Thiếu cấu hình VNPay: đặt biến môi trường " + envName
                    + " hoặc khóa " + fileKey + " trong vnpay.properties");
        }
        return value;
    }

    private static String value(String envName, String fileKey) {
        String value = System.getenv(envName);
        if (value == null || value.isBlank()) {
            value = FILE_CONFIG.getProperty(fileKey);
        }
        if (value == null || value.isBlank() || value.trim().startsWith("YOUR_")) {
            return null;
        }
        return value.trim();
    }

    private static Properties loadFileConfig() {
        Properties props = new Properties();
        try (InputStream in = VnPayConfig.class.getClassLoader().getResourceAsStream("vnpay.properties")) {
            if (in != null) {
                props.load(new InputStreamReader(in, StandardCharsets.UTF_8));
            }
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Cannot read vnpay.properties", e);
        }
        return props;
    }
}
