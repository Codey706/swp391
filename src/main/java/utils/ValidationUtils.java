package utils;

/**
 * Hàm validation dùng chung. Rule riêng của từng module (ví dụ Event)
 * không đặt ở đây mà đặt ở Controller của module đó.
 */
public final class ValidationUtils {

    private ValidationUtils() {
    }

    public static boolean isNullOrBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static boolean isLengthBetween(String value, int minLength, int maxLength) {
        if (value == null) {
            return false;
        }
        int length = value.trim().length();
        return length >= minLength && length <= maxLength;
    }

    public static int parseIntOrDefault(String value, int defaultValue) {
        if (value == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
