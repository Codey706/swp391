package utils;

import jakarta.servlet.http.HttpServletRequest;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Shared GET filters and pagination for admin listing screens.
 */
public final class AdminListFilter {

    private static final int PAGE_SIZE = 10;

    private AdminListFilter() {
    }

    public static String param(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim().substring(0, Math.min(value.trim().length(), 100));
    }

    public static boolean contains(String value, String keyword) {
        return value != null && value.toLowerCase(java.util.Locale.ROOT).contains(keyword.toLowerCase(java.util.Locale.ROOT));
    }

    public static boolean matches(String actual, String selected) {
        return selected.isEmpty() || "ALL".equalsIgnoreCase(selected) || selected.equalsIgnoreCase(actual);
    }

    public static String query(String... pairs) {
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < pairs.length; i += 2) {
            if (pairs[i + 1] != null && !pairs[i + 1].isEmpty() && !"ALL".equalsIgnoreCase(pairs[i + 1])) {
                if (result.length() > 0) {
                    result.append('&');
                }
                result.append(URLEncoder.encode(pairs[i], StandardCharsets.UTF_8));
                result.append('=');
                result.append(URLEncoder.encode(pairs[i + 1], StandardCharsets.UTF_8));
            }
        }
        return result.length() == 0 ? "" : result.append('&').toString();
    }

    public static <T> List<T> page(HttpServletRequest request, List<T> matches, String filterQuery) {
        int count = matches.size();
        int totalPages = Math.max(1, (count + PAGE_SIZE - 1) / PAGE_SIZE);
        int page;
        try {
            page = Integer.parseInt(param(request, "page"));
        } catch (NumberFormatException e) {
            page = 1;
        }
        page = Math.max(1, Math.min(page, totalPages));
        int start = (page - 1) * PAGE_SIZE;
        request.setAttribute("page", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("matchedCount", count);
        request.setAttribute("filterQuery", filterQuery);
        return matches.subList(start, Math.min(start + PAGE_SIZE, count));
    }
}
