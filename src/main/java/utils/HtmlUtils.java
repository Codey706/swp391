package utils;

/**
 * Escape dữ liệu trước khi in ra HTML trong scriptlet (<%= %>) để chống XSS.
 * Với EL nên dùng <c:out> hoặc ${fn:escapeXml(...)}.
 */
public final class HtmlUtils {

    private HtmlUtils() {
    }

    public static String escape(Object value) {
        return escape(value, "");
    }

    /** @param fallback giá trị hiển thị khi value null/rỗng (cũng được escape) */
    public static String escape(Object value, String fallback) {
        String text = value == null ? null : value.toString();
        if (text == null || text.trim().isEmpty()) {
            text = fallback == null ? "" : fallback;
        }
        StringBuilder sb = new StringBuilder(text.length() + 16);
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '&' -> sb.append("&amp;");
                case '<' -> sb.append("&lt;");
                case '>' -> sb.append("&gt;");
                case '"' -> sb.append("&quot;");
                case '\'' -> sb.append("&#39;");
                default -> sb.append(c);
            }
        }
        return sb.toString();
    }
}
