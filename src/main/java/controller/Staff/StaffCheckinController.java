/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.Staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import model.Auth;

/**
 *
 * @author BT
 */
@WebServlet("/staff/checkin")
public class StaffCheckinController extends StaffController {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra nhân viên đã đăng nhập và tài khoản còn ACTIVE
        Auth staff = getAuthenticatedStaff(request, response);

        // Nếu chưa đăng nhập hoặc không đủ quyền thì dừng xử lý
        if (staff == null) {
            return;
        }

        // Mở trang quét QR riêng
        request.getRequestDispatcher(
                "/WEB-INF/views/staff/staff-checkin.jsp"
        ).forward(request, response);
    }
}