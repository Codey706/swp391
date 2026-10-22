/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utils;

/**
 *
 * @author BT
 */
public final class VnPayConfig {

    public static final String PAYMENT_URL =
            "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    private VnPayConfig() {
    }

    public static String getTmnCode() {
        return requireEnv("VNPAY_TMN_CODE");
    }

    public static String getHashSecret() {
        return requireEnv("VNPAY_HASH_SECRET");
    }

    private static String requireEnv(String name) {
        String value = System.getenv(name);

        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                    "Thiếu biến môi trường " + name
            );
        }

        return value.trim();
    }
}