<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="utils.DateTimeUtils" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Detail - Light Ticket</title>

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
            String successMessage = (String) request.getAttribute("successMessage");
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

                    <div class="detail-container">

                        <div class="page-heading">

                            <div>
                                <h1>User Detail</h1>

                                <p>
                                    Thông tin chi tiết của người dùng trong Light Ticket
                                </p>
                            </div>

                        </div>

                        <% if (errorMessage != null) { %>
                            <div class="profile-alert error">
                                <i class="fa-solid fa-circle-exclamation"></i> <%= errorMessage %>
                            </div>
                        <% } %>

                        <% if (successMessage != null) { %>
                            <div class="profile-alert success">
                                <i class="fa-solid fa-circle-check"></i> <%= successMessage %>
                            </div>
                        <% } %>

                        <div class="detail-card">

                            <!-- Profile -->
                            <div class="profile-header">

                                <div class="avatar">
                                    <%= user.getFullName() != null
                                            && !user.getFullName().isEmpty()
                                            ? user.getFullName()
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                            : "U"%>
                                </div>

                                <div class="profile-info">

                                    <h2>
                                        <%= user.getFullName() != null ? user.getFullName() : ""%>
                                    </h2>

                                    <p>
                                        @<%= user.getUsername() != null ? user.getUsername() : ""%>
                                    </p>

                                    <span class="role <%= user.getRole() != null ? user.getRole().toLowerCase() : ""%>">
                                        <%= user.getRole() != null ? user.getRole() : ""%>
                                    </span>

                                    &nbsp;

                                    <span class="status <%= user.getStatus() != null ? user.getStatus().toLowerCase() : ""%>">
                                        <%= user.getStatus() != null ? user.getStatus() : ""%>
                                    </span>

                                </div>

                            </div>

                            <!-- Personal Information -->
                            <h3 class="section-title">
                                Personal Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">

                                    <span class="detail-label">
                                        User ID
                                    </span>

                                    <div class="detail-value">
                                        #<%= user.getUserId()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Username
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getUsername() != null ? user.getUsername() : ""%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Full Name
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getFullName() != null ? user.getFullName() : ""%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Email Address
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getEmail() != null ? user.getEmail() : ""%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Phone Number
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getPhone() != null && !user.getPhone().isEmpty()
                                                ? user.getPhone()
                                                : "Not provided"%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Address
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getAddress() != null && !user.getAddress().isEmpty()
                                                ? user.getAddress()
                                                : "Not provided"%>
                                    </div>

                                </div>

                            </div>

                            <!-- Account Information -->
                            <h3 class="section-title account-section-title">
                                Account Information
                            </h3>

                            <div class="detail-grid">

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Role
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getRole() != null ? user.getRole() : ""%>
                                    </div>

                                </div>

                                <!-- Quick Status Update -->
                                <div class="detail-item">

                                    <span class="detail-label">
                                        Account Status
                                    </span>

                                    <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
                                        <div class="detail-value">
                                            <span class="status active">Active (Protected)</span>
                                        </div>
                                    <% } else { %>
                                        <form class="status-form"
                                              method="post"
                                              action="<%= contextPath%>/admin/user-detail">

                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= user.getUserId()%>">

                                            <select class="status-select"
                                                    name="status"
                                                    onchange="this.form.submit()">

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

                                        </form>
                                    <% } %>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Created At
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getCreatedAt() != null
                                                ? DateTimeUtils.formatDateTime(user.getCreatedAt())
                                                : "Not available"%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Updated At
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getUpdatedAt() != null
                                                ? DateTimeUtils.formatDateTime(user.getUpdatedAt())
                                                : "Not available"%>
                                    </div>

                                </div>

                            </div>

                            <!-- Buttons -->
                            <div class="detail-actions">

                                <div class="action-left">

                                    <a class="back-button"
                                       href="<%= contextPath%>/admin/users">
                                        ← Back to User List
                                    </a>

                                    <% if (!"ADMIN".equalsIgnoreCase(user.getRole())) { %>
                                        <form method="post"
                                              action="<%= contextPath%>/admin/user-delete"
                                              style="display: inline; margin-left: 10px;"
                                              onsubmit="return confirm('Are you sure you want to delete user &quot;<%= user.getUsername()%>&quot;?');">
                                            <input type="hidden"
                                                   name="id"
                                                   value="<%= user.getUserId()%>">

                                            <button type="submit" class="delete-button">
                                                <i class="fa-solid fa-trash"></i>
                                                Delete User
                                            </button>
                                        </form>
                                    <% } %>

                                </div>

                                <a class="update-button"
                                   href="<%= contextPath%>/admin/user-edit?id=<%= user.getUserId()%>">
                                    Update Information
                                </a>

                            </div>

                        </div>

                    </div>

                </section>

            </main>

        </div>

    </body>
</html>
