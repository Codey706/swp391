<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<!DOCTYPE html>

<html>

    <head>

        <meta charset="UTF-8">

        <title>Update User - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css?v=3">

    </head>

    <body>

        <%
            User user = (User) request.getAttribute("user");
            String contextPath = request.getContextPath();
            String errorMessage = (String) request.getAttribute("errorMessage");
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

                            <a href="<%= contextPath%>/admin/user-create">
                                Create User
                            </a>

                            <a href="<%= contextPath%>/admin/user-detail?id=<%= user.getUserId()%>"
                               class="active">
                                User Detail
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
                                    Update User Information
                                </h1>

                                <p>
                                    Chỉnh sửa thông tin người dùng
                                </p>

                            </div>

                        </div>

                        <% if (errorMessage != null) { %>
                            <div class="profile-alert error">
                                <i class="fa-solid fa-circle-exclamation"></i> <%= errorMessage %>
                            </div>
                        <% } %>

                        <div class="edit-card">

                            <h3 class="section-title">
                                User Information
                            </h3>

                            <form method="post"
                                  action="<%= contextPath%>/admin/user-edit">

                                <input type="hidden"
                                       name="userId"
                                       value="<%= user.getUserId()%>">

                                <div class="form-grid">

                                    <!-- Username -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Username
                                        </label>

                                        <input class="edit-form-input readonly"
                                               type="text"
                                               value="<%= user.getUsername() != null ? user.getUsername() : ""%>"
                                               readonly>

                                    </div>

                                    <!-- Full Name -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Full Name
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="fullName"
                                               value="<%= user.getFullName() != null
                                                       ? user.getFullName()
                                                       : ""%>"
                                               required>

                                    </div>

                                    <!-- Email -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Email Address
                                        </label>

                                        <input class="edit-form-input readonly"
                                               type="email"
                                               value="<%= user.getEmail() != null
                                                       ? user.getEmail()
                                                       : ""%>"
                                               readonly>

                                    </div>

                                    <!-- Phone -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Phone Number
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="phone"
                                               value="<%= user.getPhone() != null
                                                       ? user.getPhone()
                                                       : ""%>">

                                    </div>

                                    <!-- Address -->
                                    <div class="edit-form-group full">

                                        <label class="edit-form-label">
                                            Address
                                        </label>

                                        <input class="edit-form-input"
                                               type="text"
                                               name="address"
                                               value="<%= user.getAddress() != null
                                                       ? user.getAddress()
                                                       : ""%>">

                                    </div>

                                    <!-- Role -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label">Role</label>

                                        <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>

                                        <input class="edit-form-input readonly"
                                               type="text"
                                               value="Admin"
                                               readonly>

                                        <% } else {%>

                                        <select class="edit-form-select" name="role">
                                            <option value="CUSTOMER"
                                                    <%= "CUSTOMER".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Customer
                                            </option>

                                            <option value="ORGANIZER"
                                                    <%= "ORGANIZER".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Organizer
                                            </option>

                                            <option value="STAFF"
                                                    <%= "STAFF".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Staff
                                            </option>
                                        </select>

                                        <% }%>
                                    </div>

                                    <!-- Status -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Account Status
                                        </label>

                                        <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>

                                        <input class="edit-form-input readonly"
                                               type="text"
                                               value="Active"
                                               readonly>

                                        <% } else {%>

                                        <select class="edit-form-select"
                                                name="status">

                                            <option value="ACTIVE"
                                                    <%= "ACTIVE".equalsIgnoreCase(user.getStatus())
                                                            ? "selected" : ""%>>
                                                Active
                                            </option>

                                            <option value="INACTIVE"
                                                    <%= "INACTIVE".equalsIgnoreCase(user.getStatus())
                                                            ? "selected" : ""%>>
                                                Inactive
                                            </option>

                                        </select>

                                        <% }%>

                                    </div>

                                </div>

                                <div class="edit-form-actions">

                                    <a class="edit-cancel-button"
                                       href="<%= contextPath%>/admin/user-detail?id=<%= user.getUserId()%>">
                                        Cancel
                                    </a>

                                    <button class="edit-save-button"
                                            type="submit">
                                        Update Information
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
