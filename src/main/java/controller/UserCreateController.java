package controller;

import dao.UserDAO;
import model.Auth;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import utils.Constants;
import utils.ValidationUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/admin/user-create")
public class UserCreateController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UserCreateController.class.getName());
    private static final String VIEW = "/WEB-INF/views/admin/user-create.jsp";

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    private Auth getAuthenticatedAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object userObj = session == null ? null : session.getAttribute(Constants.SESSION_USER);

        if (!(userObj instanceof Auth)) {
            response.sendRedirect(request.getContextPath() + "/Auth?action=login");
            return null;
        }

        Auth currentUser = (Auth) userObj;
        if (!Constants.ROLE_ADMIN.equalsIgnoreCase(currentUser.getRole())
                || !Constants.STATUS_ACTIVE.equalsIgnoreCase(currentUser.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        return currentUser;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
        }

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        Auth admin = getAuthenticatedAdmin(request, response);
        if (admin == null) {
            return;
        }

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String role = request.getParameter("role");
        String status = request.getParameter("status");

        String trimmedUsername = username != null ? username.trim() : "";
        String trimmedEmail = email != null ? email.trim() : "";
        String trimmedFullName = fullName != null ? fullName.trim() : "";
        String trimmedPhone = phone != null ? phone.trim() : "";
        String trimmedAddress = address != null ? address.trim() : "";

        // Backend Validations
        if (!ValidationUtils.isUsername(trimmedUsername)) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Username must be 4-50 characters long and contain only letters, numbers, dots or underscores.");
            return;
        }

        if (!ValidationUtils.isEmail(trimmedEmail)) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Invalid email address format.");
            return;
        }

        if (!ValidationUtils.isStrongPassword(password)) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Password must be at least 8 characters long and include uppercase, lowercase, numbers, and special characters.");
            return;
        }

        if (password == null || !password.equals(confirmPassword)) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Password and confirm password do not match.");
            return;
        }

        if (!ValidationUtils.isLengthBetween(trimmedFullName, 2, 100)) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Full name must be between 2 and 100 characters.");
            return;
        }

        if (!trimmedPhone.isEmpty() && !ValidationUtils.isPhone(trimmedPhone)) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Phone number is invalid (must be 10-11 digits starting with 0).");
            return;
        }

        if (trimmedAddress.length() > 255) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Address must not exceed 255 characters.");
            return;
        }

        if (role == null
                || (!"CUSTOMER".equalsIgnoreCase(role)
                && !"ORGANIZER".equalsIgnoreCase(role)
                && !"STAFF".equalsIgnoreCase(role)
                && !"ADMIN".equalsIgnoreCase(role))) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Invalid role selected.");
            return;
        }

        if (status == null
                || (!"ACTIVE".equalsIgnoreCase(status)
                && !"INACTIVE".equalsIgnoreCase(status))) {
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Invalid status selected.");
            return;
        }

        try {
            // Kiểm tra username đã tồn tại
            if (userDAO.existsUsername(trimmedUsername)) {
                forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                        "Username is already registered. Please choose another username.");
                return;
            }

            // Kiểm tra email đã tồn tại
            if (userDAO.existsEmail(trimmedEmail)) {
                forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                        "Email is already registered. Please choose another email.");
                return;
            }

            // Hash password bằng BCrypt
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

            User user = new User();
            user.setUsername(trimmedUsername);
            user.setEmail(trimmedEmail);
            user.setPassword(hashedPassword);
            user.setFullName(trimmedFullName);
            user.setPhone(trimmedPhone.isEmpty() ? null : trimmedPhone);
            user.setAddress(trimmedAddress.isEmpty() ? null : trimmedAddress);

            // Chuẩn hóa role (Customer, Organizer, Staff, Admin)
            String normalizedRole = "Customer";
            if ("ORGANIZER".equalsIgnoreCase(role)) {
                normalizedRole = "Organizer";
            } else if ("STAFF".equalsIgnoreCase(role)) {
                normalizedRole = "Staff";
            } else if ("ADMIN".equalsIgnoreCase(role)) {
                normalizedRole = "Admin";
            }
            user.setRole(normalizedRole);
            user.setStatus(status.toUpperCase());

            boolean created = userDAO.createUser(user);

            if (created) {
                HttpSession session = request.getSession();
                session.setAttribute("userSuccessMessage", "User @" + trimmedUsername + " created successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                        "Cannot create user in database.");
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cannot create user: " + trimmedUsername, e);
            forwardWithError(request, response, trimmedUsername, trimmedEmail, trimmedFullName, trimmedPhone, trimmedAddress, role, status,
                    "Database error occurred while creating user.");
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response,
            String username, String email, String fullName, String phone, String address, String role, String status,
            String errorMessage) throws ServletException, IOException {
        request.setAttribute("username", username);
        request.setAttribute("email", email);
        request.setAttribute("fullName", fullName);
        request.setAttribute("phone", phone);
        request.setAttribute("address", address);
        request.setAttribute("selectedRole", role);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("error", errorMessage);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
