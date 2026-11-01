/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 *
 * @author BT
 */
public final class VnPayUtil {

    private static final DateTimeFormatter DATE_FORMAT
            = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private VnPayUtil() {
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static String buildQueryString(Map<String, String> params) {
        StringBuilder result = new StringBuilder();

        for (Map.Entry<String, String> entry : new TreeMap<>(params).entrySet()) {
            if (entry.getValue() == null) {
                continue;
            }

            if (result.length() > 0) {
                result.append('&');
            }

            result.append(encode(entry.getKey()))
                    .append('=')
                    .append(encode(entry.getValue()));
        }

        return result.toString();
    }

    private static String hmacSHA512(String key, String data) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(
                    key.getBytes(StandardCharsets.UTF_8),
                    "HmacSHA512"
            );
            hmac.init(secretKey);

            byte[] bytes = hmac.doFinal(
                    data.getBytes(StandardCharsets.UTF_8)
            );

            StringBuilder hex = new StringBuilder();
            for (byte b : bytes) {
                hex.append(String.format("%02x", b & 0xff));
            }
            return hex.toString();

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Lỗi VNPay: " + e.getMessage()
            );
        }
    }

   
public static String createPaymentUrl(Map<String, String> params) {
    String tmnCode = VnPayConfig.getTmnCode();
    String hashSecret = VnPayConfig.getHashSecret();

    if (!tmnCode.equals(params.get("vnp_TmnCode"))) {
        throw new IllegalStateException(
                "vnp_TmnCode không khớp cấu hình VNPay."
        );
    }

    Map<String, String> data = new TreeMap<>(params);
    data.remove("vnp_SecureHash");
    data.remove("vnp_SecureHashType");

    String hashData = buildQueryString(data);
    String secureHash = hmacSHA512(hashSecret, hashData);

    return VnPayConfig.PAYMENT_URL
            + "?" + hashData
            + "&vnp_SecureHash=" + secureHash;
}


    public static boolean verifySignature(Map<String, String> params) {
        String receivedHash = params.get("vnp_SecureHash");

        if (receivedHash == null || receivedHash.isBlank()) {
            return false;
        }

        Map<String, String> data = new TreeMap<>(params);
        data.remove("vnp_SecureHash");
        data.remove("vnp_SecureHashType");

        String expectedHash = hmacSHA512(
                VnPayConfig.getHashSecret(),
                buildQueryString(data)
        );

        return MessageDigest.isEqual(
                expectedHash.toLowerCase().getBytes(StandardCharsets.UTF_8),
                receivedHash.toLowerCase().getBytes(StandardCharsets.UTF_8)
        );
    }

    public static String createDateNow() {
        return LocalDateTime.now().format(DATE_FORMAT);
    }
}
