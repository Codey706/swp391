package utils;

/**
 * Hàm validation dùng chung.
 * Rule riêng của từng module không đặt ở đây.
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

    public static boolean isEmail(String email) {
        return email != null
                && email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    public static boolean isPhone(String phone) {
        return phone != null
                && phone.matches("^0\\d{9,10}$");
    }

    public static boolean isUsername(String username) {
        return isLengthBetween(username, 4, 50)
                && username.matches("^[A-Za-z0-9._]+$");
    }

    public static boolean isStrongPassword(String password) {
        if (!isLengthBetween(password, 8, Integer.MAX_VALUE)) {
            return false;
        }

        boolean upper = false;
        boolean lower = false;
        boolean digit = false;
        boolean special = false;

        for (int i = 0; i < password.length(); i++) {
            char c = password.charAt(i);

            if (Character.isUpperCase(c)) {
                upper = true;
            } else if (Character.isLowerCase(c)) {
                lower = true;
            } else if (Character.isDigit(c)) {
                digit = true;
            } else {
                special = true;
            }
        }

        return upper && lower && digit && special;
    }
}