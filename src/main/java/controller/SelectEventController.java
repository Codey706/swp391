package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Trang chọn sự kiện cũ (/booking/select-event) trùng chức năng với trang chủ:
 * chuyển hướng vĩnh viễn về /home (giữ từ khóa tìm kiếm nếu có) để link cũ vẫn dùng được.
 */
@WebServlet(name = "SelectEventController", urlPatterns = {"/booking/select-event"})
public class SelectEventController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String keyword = request.getParameter("keyword");
        String target = request.getContextPath() + "/home";
        if (keyword != null && !keyword.isBlank()) {
            target += "?keyword=" + java.net.URLEncoder.encode(keyword.trim(), java.nio.charset.StandardCharsets.UTF_8);
        }
        response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
        response.setHeader("Location", target);
    }
}
