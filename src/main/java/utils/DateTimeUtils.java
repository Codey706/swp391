package utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public final class DateTimeUtils {

    /** Định dạng của input type="datetime-local". */
    private static final DateTimeFormatter DATETIME_LOCAL =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final DateTimeFormatter DISPLAY =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private DateTimeUtils() {
    }

    /** @return LocalDateTime, hoặc null nếu rỗng/sai định dạng. */
    public static LocalDateTime parseDateTimeLocal(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.trim(), DATETIME_LOCAL);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    public static String formatDateTimeLocal(LocalDateTime dateTime) {
        return dateTime == null ? "" : dateTime.format(DATETIME_LOCAL);
    }

    public static String formatDateTime(LocalDateTime dateTime) {
        return dateTime == null ? "" : dateTime.format(DISPLAY);
    }
}
