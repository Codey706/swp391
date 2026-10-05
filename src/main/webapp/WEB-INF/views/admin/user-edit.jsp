<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<!DOCTYPE html>

<html>

    <head>

        <meta charset="UTF-8">

        <title>Update User - Light Ticket</title>

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

                <div class="brand">
                    🎟 Light Ticket
                </div>

                <nav class="menu">

                    <a href="#">
                        ⌂ &nbsp; Dashboard
                    </a>

                    <div class="menu-group">

                        <a href="<%= contextPath%>/admin/users"
                           class="menu-parent open">

                            <span>
                                ♟ &nbsp; Users
                            </span>

                            <span class="arrow">
                                ▼
                            </span>

                        </a>

                        <div class="submenu">

                            <a href="<%= contextPath%>/admin/users">
                                ▪ &nbsp; Users List
                            </a>

                            <a href="<%= contextPath%>/admin/user-detail?id=<%= user.getUserId()%>"
                               class="active">
                                ▪ &nbsp; User Detail
                            </a>

                        </div>

                    </div>

                    <a href="#">
                        ▣ &nbsp; Events
                    </a>

                    <a href="<%= contextPath%>/admin/categories">
                        ▤ &nbsp; Categories
                    </a>

                    <a href="#">
                        ⌖ &nbsp; Venues
                    </a>

                    <a href="#">
                        🎟 &nbsp; Vouchers
                    </a>

                    <a href="#">
                        ☆ &nbsp; Reviews
                    </a>

                    <a href="#">
                        ♙ &nbsp; My Profile
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

                    <div class="edit-container">

                        <div class="breadcrumb">
                            Home &nbsp; / &nbsp; User Management
                            &nbsp; / &nbsp; Update User
                        </div>

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
                                               value="<%= user.getUsername()%>"
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

                                        <label class="edit-form-label">
                                            Role
                                        </label>

                                        <select class="edit-form-select"
                                                name="role">

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

                                            <option value="ADMIN"
                                                    <%= "ADMIN".equalsIgnoreCase(user.getRole())
                                                            ? "selected" : ""%>>
                                                Admin
                                            </option>

                                        </select>

                                    </div>

                                    <!-- Status -->
                                    <div class="edit-form-group">

                                        <label class="edit-form-label">
                                            Account Status
                                        </label>

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
