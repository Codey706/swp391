package controller.Staff;

import model.Auth;
import utils.SessionUtils;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Lớp cha cho các trang Staff. AuthFilter đã yêu cầu đăng nhập, đúng role Staff
 * và tài khoản ACTIVE; Staff ID chỉ lấy từ session.
 */
public abstract class StaffController extends HttpServlet {

    protected Auth currentStaff(HttpServletRequest request) {
        return SessionUtils.currentUser(request);
    }
}
