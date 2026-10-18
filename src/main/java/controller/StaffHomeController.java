package controller;
 
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
 
import java.io.IOException;
 
/**
 * TẠM THỜI: trang chủ Staff (/staff) chưa có chức năng riêng,
 * nên chuyển sang /staff/profile. Xóa file này khi làm xong
 * "Sự kiện phân công" cho /staff.
 */
@WebServlet(name = "StaffHomeController", urlPatterns = {"/staff"})
public class StaffHomeController extends HttpServlet {
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/staff/profile");
    }
}
 