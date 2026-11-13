package utils;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;

/**
 * Tài liệu pháp lý của Organizer lưu ngoài thư mục web (${user.home}/ltm-uploads/organizer-docs),
 * chỉ trả về qua controller đã kiểm tra quyền.
 */
public final class PrivateDocuments {

    private PrivateDocuments() {
    }

    public static Path directory() {
        return Paths.get(System.getProperty("user.home"), Constants.PRIVATE_DOC_DIR_NAME.split("/"))
                .toAbsolutePath().normalize();
    }

    /** Gửi file (inline) về trình duyệt; 404 nếu tên file không hợp lệ hoặc không tồn tại. */
    public static void serve(HttpServletResponse response, String storedFileName) throws IOException {
        Path directory = directory();
        Path file = directory.resolve(Paths.get(storedFileName).getFileName().toString()).normalize();
        if (!file.startsWith(directory) || !Files.isRegularFile(file)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String name = file.getFileName().toString();
        int dot = name.lastIndexOf('.');
        String extension = dot < 0 ? "" : name.substring(dot + 1).toLowerCase(Locale.ROOT);
        String contentType = switch (extension) {
            case "pdf" -> "application/pdf";
            case "png" -> "image/png";
            case "jpg", "jpeg" -> "image/jpeg";
            default -> "application/octet-stream";
        };
        response.setContentType(contentType);
        response.setContentLengthLong(Files.size(file));
        response.setHeader("Content-Disposition", "inline; filename=\"organizer-document." + extension + "\"");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, no-store");
        Files.copy(file, response.getOutputStream());
    }
}
