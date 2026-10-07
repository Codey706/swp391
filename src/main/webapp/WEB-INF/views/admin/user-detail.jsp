<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Detail - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css?v=2">
    </head>

    <body>

        <%
            User user = (User) request.getAttribute("user");
            String contextPath = request.getContextPath();
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
                    <a href="#">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <!-- Vouchers -->
                    <a href="#">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

                    <!-- Reviews -->
                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <!-- My Profile -->
                    <a href="#">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>

            </aside>

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input class="search"
                           type="text"
                           placeholder="⌕  Search...">

                    <div class="admin">
                        🔔 &nbsp; Admin &nbsp;⌄
                    </div>

                </header>

                <section class="content">

                    <div class="detail-container">

                        <div class="breadcrumb">
                            Home &nbsp; / &nbsp; User Management
                            &nbsp; / &nbsp; User Detail
                        </div>

                        <div class="page-heading">

                            <div>
                                <h1>User Detail</h1>

                                <p>
                                    Thông tin chi tiết của người dùng trong Light Ticket
                                </p>
                            </div>

                        </div>

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
                                        <%= user.getFullName()%>
                                    </h2>

                                    <p>
                                        @<%= user.getUsername()%>
                                    </p>

                                    <span class="role <%= user.getRole().toLowerCase()%>">
                                        <%= user.getRole()%>
                                    </span>

                                    &nbsp;

                                    <span class="status <%= user.getStatus().toLowerCase()%>">
                                        <%= user.getStatus()%>
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
                                        <%= user.getUsername()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Full Name
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getFullName()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Email Address
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getEmail()%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Phone Number
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getPhone() != null
                                                ? user.getPhone()
                                                : "Not provided"%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Address
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getAddress() != null
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
                                        <%= user.getRole()%>
                                    </div>

                                </div>

                                <!-- Quick Status Update -->
                                <div class="detail-item">

                                    <span class="detail-label">
                                        Account Status
                                    </span>

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

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Created At
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getCreatedAt() != null
                                                ? user.getCreatedAt()
                                                : "Not available"%>
                                    </div>

                                </div>

                                <div class="detail-item">

                                    <span class="detail-label">
                                        Updated At
                                    </span>

                                    <div class="detail-value">
                                        <%= user.getUpdatedAt() != null
                                                ? user.getUpdatedAt()
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