<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>

<html>

    <head>

        <meta charset="UTF-8">

        <title>Create User - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css?v=3">

    </head>

    <body>

        <%
            String contextPath = request.getContextPath();
            String error = (String) request.getAttribute("error");

            String username = (String) request.getAttribute("username");
            String email = (String) request.getAttribute("email");
            String fullName = (String) request.getAttribute("fullName");
            String phone = (String) request.getAttribute("phone");
            String address = (String) request.getAttribute("address");
            String selectedRole = (String) request.getAttribute("selectedRole");
            String selectedStatus = (String) request.getAttribute("selectedStatus");

            if (username == null) username = "";
            if (email == null) email = "";
            if (fullName == null) fullName = "";
            if (phone == null) phone = "";
            if (address == null) address = "";
            if (selectedRole == null) selectedRole = "Customer";
            if (selectedStatus == null) selectedStatus = "ACTIVE";
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">🎟 Light Ticket</div>

                <nav class="menu">

                    <!-- Dashboard -->
                    <a href="<%= contextPath%>/admin">
                        <i class="fa-solid fa-chart-line"></i>
                        Dashboard
                    </a>

                    <!-- Users -->
                    <div class="menu-group">

                        <a href="<%= contextPath%>/admin/users"
                           class="menu-parent open">

                            <span>
                                <i class="fa-solid fa-users"></i>
                                Users
                            </span>

                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">

                            <a href="<%= contextPath%>/admin/users">
                                User List
                            </a>

                            <a href="<%= contextPath%>/admin/user-create"
                               class="active">
                                Create User
                            </a>

                        </div>
                    </div>

                    <!-- Events -->
                    <a href="#">
                        <i class="fa-solid fa-calendar-days"></i>
                        Events
                    </a>

                    <!-- Categories -->
                    <a href="<%= contextPath%>/admin/categories">
                        <i class="fa-solid fa-folder"></i>
                        Categories
                    </a>

                    <!-- Venues -->
                    <a href="<%= request.getContextPath()%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <!-- Vouchers -->
                    <a href="<%= contextPath%>/admin/vouchers">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

                    <!-- Reviews -->
                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <!-- My Profile -->
                    <a href="${pageContext.request.contextPath}/admin/profile">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>
            </aside>

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <form method="get" action="<%= contextPath%>/admin/users" style="margin: 0;">
                        <input class="search"
                               type="text"
                               name="keyword"
                               placeholder="⌕  Search...">
                    </form>

                    <a class="admin" href="<%= contextPath%>/admin/profile">
                        <img class="admin-avatar"
                             src="<%= contextPath%>/assets/icons/user_icon.png"
                             alt="Admin Avatar">
                        <span>Admin</span>
                    </a>

                </header>

                <section class="content">

                    <div class="edit-container">

                        <div class="page-heading">

                            <div>

                                <h1>
                                    Create New User
                                </h1>

                                <p>
                                    Thêm tài khoản người dùng mới vào hệ thống Light Ticket
                                </p>

                            </div>

                        </div>

                        <% if (error != null) { %>
                            <div class="profile-alert error">
                                <i class="fa-solid fa-circle-exclamation"></i> <%= error %>
                            </div>
                        <% } %>

                        <div class="edit-card">

                            <h3 class="section-title">
                                User Account Information
                            </h3>

                            <form method="post"
                                  action="<%= contextPath%>/admin/user-create">

                                <div class="form-grid">

                                    <!-- Username -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Username <span style="color: #dc3545;">*</span>
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="username"
                                               value="<%= username %>"
                                               placeholder="e.g. john_doe"
                                               required>

                                    </div>

                                    <!-- Email -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Email Address <span style="color: #dc3545;">*</span>
                                        </label>

                                        <input class="edit-form-input"
                                               type="email"
                                               name="email"
                                               value="<%= email %>"
                                               placeholder="name@example.com"
                                               required>

                                    </div>

                                    <!-- Password -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Password <span style="color: #dc3545;">*</span>
                                        </label>

                                        <input class="edit-form-input"
                                               type="password"
                                               name="password"
                                               placeholder="Min 8 chars, uppercase, lowercase, number, special"
                                               required>

                                    </div>

                                    <!-- Confirm Password -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Confirm Password <span style="color: #dc3545;">*</span>
                                        </label>

                                        <input class="edit-form-input"
                                               type="password"
                                               name="confirmPassword"
                                               placeholder="Re-enter password"
                                               required>

                                    </div>

                                    <!-- Full Name -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Full Name <span style="color: #dc3545;">*</span>
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="fullName"
                                               value="<%= fullName %>"
                                               placeholder="e.g. Nguyễn Văn A"
                                               required>

                                    </div>

                                    <!-- Phone -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Phone Number
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="phone"
                                               value="<%= phone %>"
                                               placeholder="e.g. 0912345678">

                                    </div>

                                    <!-- Address -->
                                    <div class="edit-form-group full">

                                        <label class="edit-form-label">
                                            Address
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="address"
                                               value="<%= address %>"
                                               placeholder="e.g. Cần Thơ, Việt Nam">

                                    </div>

                                    <!-- Role -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label">Role <span style="color: #dc3545;">*</span></label>

                                        <select class="edit-form-select" name="role">
                                            <option value="Customer"
                                                    <%= "Customer".equalsIgnoreCase(selectedRole)
                                                            ? "selected" : ""%>>
                                                Customer
                                            </option>

                                            <option value="Organizer"
                                                    <%= "Organizer".equalsIgnoreCase(selectedRole)
                                                            ? "selected" : ""%>>
                                                Organizer
                                            </option>

                                            <option value="Staff"
                                                    <%= "Staff".equalsIgnoreCase(selectedRole)
                                                            ? "selected" : ""%>>
                                                Staff
                                            </option>

                                            <option value="Admin"
                                                    <%= "Admin".equalsIgnoreCase(selectedRole)
                                                            ? "selected" : ""%>>
                                                Admin
                                            </option>
                                        </select>
                                    </div>

                                    <!-- Status -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Account Status <span style="color: #dc3545;">*</span>
                                        </label>

                                        <select class="edit-form-select"
                                                name="status">

                                            <option value="ACTIVE"
                                                    <%= "ACTIVE".equalsIgnoreCase(selectedStatus)
                                                            ? "selected" : ""%>>
                                                Active
                                            </option>

                                            <option value="INACTIVE"
                                                    <%= "INACTIVE".equalsIgnoreCase(selectedStatus)
                                                            ? "selected" : ""%>>
                                                Inactive
                                            </option>

                                        </select>

                                    </div>

                                </div>

                                <div class="edit-form-actions">

                                    <a class="edit-cancel-button"
                                       href="<%= contextPath%>/admin/users">
                                        Cancel
                                    </a>

                                    <button class="edit-save-button"
                                            type="submit">
                                        Create User
                                    </button>

                                </div>

                            </form>

                        </div>

                    </div>

                </section>

            </main>

        </div>

    </body>

</html>
