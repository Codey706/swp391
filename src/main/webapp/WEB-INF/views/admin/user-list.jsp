<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.User" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Management - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css?v=3">
    </head>

    <body>

        <%
            List<User> users = (List<User>) request.getAttribute("users");
            Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");

            int totalUsers = 0;
            int activeUsers = 0;
            int inactiveUsers = 0;
            int organizers = 0;
            int staffs = 0;
            int customers = 0;

            if (stats != null) {
                totalUsers = stats.getOrDefault("total", 0);
                activeUsers = stats.getOrDefault("active", 0);
                inactiveUsers = stats.getOrDefault("inactive", 0);
                organizers = stats.getOrDefault("organizers", 0);
                staffs = stats.getOrDefault("staffs", 0);
                customers = stats.getOrDefault("customers", 0);
            } else if (users != null) {
                totalUsers = users.size();
                for (User user : users) {
                    if ("ACTIVE".equalsIgnoreCase(user.getStatus())) {
                        activeUsers++;
                    } else {
                        inactiveUsers++;
                    }

                    if ("ORGANIZER".equalsIgnoreCase(user.getRole())) {
                        organizers++;
                    } else if ("STAFF".equalsIgnoreCase(user.getRole())) {
                        staffs++;
                    } else if ("CUSTOMER".equalsIgnoreCase(user.getRole())) {
                        customers++;
                    }
                }
            }

            String contextPath = request.getContextPath();
            String keyword = (String) request.getAttribute("keyword");
            if (keyword == null) {
                keyword = "";
            }
            String selectedRole = (String) request.getAttribute("selectedRole");
            if (selectedRole == null || selectedRole.isEmpty()) {
                selectedRole = "ALL";
            }
            String selectedStatus = (String) request.getAttribute("selectedStatus");
            if (selectedStatus == null || selectedStatus.isEmpty()) {
                selectedStatus = "ALL";
            }

            String errorMessage = (String) request.getAttribute("errorMessage");
            String successMessage = (String) request.getAttribute("successMessage");
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">🎟 Light Ticket</div>

                <nav class="menu">

                    <!-- Dashboard -->
                    <a href="<%= request.getContextPath()%>/admin">
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

                            <a href="<%= contextPath%>/admin/users"
                               class="active">
                                User List
                            </a>

                            <a href="<%= contextPath%>/admin/user-create">
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
                    <a href="<%= request.getContextPath()%>/admin/categories">
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
                        <input class="search" type="text" name="keyword"
                               value="<%= keyword %>"
                               placeholder="⌕  Search...">
                        <% if (!"ALL".equalsIgnoreCase(selectedRole)) { %>
                            <input type="hidden" name="role" value="<%= selectedRole %>">
                        <% } %>
                        <% if (!"ALL".equalsIgnoreCase(selectedStatus)) { %>
                            <input type="hidden" name="status" value="<%= selectedStatus %>">
                        <% } %>
                    </form>

                    <a class="admin" href="<%= contextPath%>/admin/profile">
                        <img class="admin-avatar"
                             src="<%= contextPath%>/assets/icons/user_icon.png"
                             alt="Admin Avatar">
                        <span>Admin</span>
                    </a>

                </header>

                <section class="content">

                    <!-- Page Heading -->
                    <div class="page-heading">
                        <div>
                            <h1>User Management</h1>
                            <p>Quản lý thông tin người dùng trong hệ thống Light Ticket</p>
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

                    <!-- Statistics -->
                    <div class="stats">

                        <div class="stat-card total">
                            <p>Total Users</p>
                            <h2><%= totalUsers%></h2>
                        </div>

                        <div class="stat-card active">
                            <p>Active Users</p>
                            <h2><%= activeUsers%></h2>
                        </div>

                        <div class="stat-card inactive">
                            <p>Inactive Users</p>
                            <h2><%= inactiveUsers%></h2>
                        </div>

                        <div class="stat-card organizer">
                            <p>Organizers</p>
                            <h2><%= organizers%></h2>
                        </div>

                        <div class="stat-card staff">
                            <p>Staffs</p>
                            <h2><%= staffs%></h2>
                        </div>

                        <div class="stat-card customer">
                            <p>Customers</p>
                            <h2><%= customers%></h2>
                        </div>

                    </div>

                    <!-- User List -->
                    <div class="user-panel">

                        <div class="panel-heading">
                            <div>
                                <h2>Users List</h2>
                                <p>Danh sách tất cả người dùng trong hệ thống</p>
                            </div>

                            <button class="add-button"
                                    type="button"
                                    onclick="window.location.href = '<%= contextPath%>/admin/user-create'">
                                + &nbsp; Add New User
                            </button>
                        </div>

                        <!-- Search and Filter Bar -->
                        <form method="get" action="<%= contextPath%>/admin/users" class="venue-filter-form">
                            <div class="venue-search-group">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <input type="text" name="keyword" value="<%= keyword %>"
                                       placeholder="Search by username, full name, email or phone...">
                            </div>

                            <div class="venue-status-group">
                                <select name="role">
                                    <option value="ALL" <%= "ALL".equalsIgnoreCase(selectedRole) ? "selected" : ""%>>All Roles</option>
                                    <option value="Admin" <%= "Admin".equalsIgnoreCase(selectedRole) ? "selected" : ""%>>Admin</option>
                                    <option value="Organizer" <%= "Organizer".equalsIgnoreCase(selectedRole) ? "selected" : ""%>>Organizer</option>
                                    <option value="Staff" <%= "Staff".equalsIgnoreCase(selectedRole) ? "selected" : ""%>>Staff</option>
                                    <option value="Customer" <%= "Customer".equalsIgnoreCase(selectedRole) ? "selected" : ""%>>Customer</option>
                                </select>
                            </div>

                            <div class="venue-status-group">
                                <select name="status">
                                    <option value="ALL" <%= "ALL".equalsIgnoreCase(selectedStatus) ? "selected" : ""%>>All Status</option>
                                    <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : ""%>>Active</option>
                                    <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : ""%>>Inactive</option>
                                </select>
                            </div>

                            <button type="submit" class="venue-filter-button">
                                <i class="fa-solid fa-filter"></i> Filter
                            </button>

                            <% if (!keyword.isEmpty() || !"ALL".equalsIgnoreCase(selectedRole) || !"ALL".equalsIgnoreCase(selectedStatus)) { %>
                                <a href="<%= contextPath%>/admin/users" class="venue-reset-button">
                                    <i class="fa-solid fa-rotate-left"></i> Reset
                                </a>
                            <% } %>
                        </form>

                        <div class="table-wrapper">

                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Username</th>
                                        <th>Full Name</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>

                                <tbody>

                                    <%
                                        if (users != null && !users.isEmpty()) {
                                            for (User user : users) {
                                    %>

                                    <tr>
                                        <td><%= user.getUserId()%></td>
                                        <td><%= user.getUsername() != null ? user.getUsername() : ""%></td>
                                        <td><%= user.getFullName() != null ? user.getFullName() : ""%></td>
                                        <td><%= user.getEmail() != null ? user.getEmail() : ""%></td>

                                        <td>
                                            <%= user.getPhone() != null ? user.getPhone() : ""%>
                                        </td>

                                        <td>
                                            <span class="role <%= user.getRole() != null ? user.getRole().toLowerCase() : ""%>">
                                                <%= user.getRole() != null ? user.getRole() : ""%>
                                            </span>
                                        </td>

                                        <td>
                                            <span class="status <%= user.getStatus() != null ? user.getStatus().toLowerCase() : ""%>">
                                                <%= user.getStatus() != null ? user.getStatus() : ""%>
                                            </span>
                                        </td>

                                        <td style="white-space: nowrap;">
                                            <a class="view-button"
                                               href="<%= contextPath%>/admin/user-detail?id=<%= user.getUserId()%>">
                                                View
                                            </a>
                                            <a class="view-button"
                                               style="background: #202B3C; margin-left: 4px;"
                                               href="<%= contextPath%>/admin/user-edit?id=<%= user.getUserId()%>">
                                                Edit
                                            </a>
                                            <% if (!"ADMIN".equalsIgnoreCase(user.getRole())) { %>
                                                <form method="post" action="<%= contextPath%>/admin/user-delete" style="display: inline; margin-left: 4px;"
                                                      onsubmit="return confirm('Are you sure you want to delete user &quot;<%= user.getUsername()%>&quot;?');">
                                                    <input type="hidden" name="id" value="<%= user.getUserId()%>">
                                                    <button type="submit" class="view-button" style="background: #dc3545; border: none; cursor: pointer;">
                                                        Delete
                                                    </button>
                                                </form>
                                            <% } %>
                                        </td>
                                    </tr>

                                    <%
                                            }
                                        } else {
                                    %>

                                    <tr>
                                        <td colspan="8" class="empty">
                                            <%= errorMessage != null ? "Failed to load users. Please retry later." : "No users found."%>
                                        </td>
                                    </tr>

                                    <%
                                        }
                                    %>

                                </tbody>
                            </table>

                        </div>
                    </div>

                </section>
            </main>
        </div>

    </body>
</html>
