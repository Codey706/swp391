
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>User Management - Light Ticket</title>

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css">
    </head>

    <body>

        <%
            List<User> users = (List<User>) request.getAttribute("users");

            int totalUsers = users != null ? users.size() : 0;
            int activeUsers = 0;
            int inactiveUsers = 0;
            int organizers = 0;
            int staffs = 0;
            int customers = 0;

            if (users != null) {
                for (User user : users) {

                    if ("ACTIVE".equalsIgnoreCase(user.getStatus())) {
                        activeUsers++;
                    } else {
                        inactiveUsers++;
                    }

                    if ("ORGANIZER".equalsIgnoreCase(user.getRole())) {
                        organizers++;
                    }

                    if ("STAFF".equalsIgnoreCase(user.getRole())) {
                        staffs++;
                    }

                    if ("CUSTOMER".equalsIgnoreCase(user.getRole())) {
                        customers++;
                    }
                }
            }

            String contextPath = request.getContextPath();
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">🎟 Light Ticket</div>

                <nav class="menu">

                    <a href="#">⌂ &nbsp; Dashboard</a>

                    <!-- Users Menu -->
                    <div class="menu-group">

                        <a href="<%= contextPath%>/admin/users"
                           class="menu-parent open">
                            <span>♟ &nbsp; Users</span>
                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">

                            <a href="<%= contextPath%>/admin/users"
                               class="active">
                                ▪ &nbsp; Users List
                            </a>

                        </div>

                    </div>

                    <a href="#">▣ &nbsp; Events</a>
                    <a href="<%= contextPath%>/admin/categories">
                        ▤ &nbsp; Categories
                    </a>
                    <a href="#">⌖ &nbsp; Venues</a>
                    <a href="#">🎟 &nbsp; Vouchers</a>
                    <a href="#">☆ &nbsp; Reviews</a>
                    <a href="#">♙ &nbsp; My Profile</a>

                </nav>

            </aside>

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input class="search" type="text"
                           placeholder="⌕  Search...">

                    <div class="admin">🔔 &nbsp; Admin &nbsp;⌄</div>

                </header>

                <section class="content">

                    <!-- Page Heading -->
                    <div class="page-heading">
                        <div>
                            <h1>User Management</h1>
                            <p>Quản lý thông tin người dùng trong hệ thống Light Ticket</p>
                        </div>
                    </div>

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

                            <button class="add-button" type="button">
                                + &nbsp; Add New User
                            </button>
                        </div>

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
                                        <td><%= user.getUsername()%></td>
                                        <td><%= user.getFullName()%></td>
                                        <td><%= user.getEmail()%></td>

                                        <td>
                                            <%= user.getPhone() != null
                                                    ? user.getPhone() : ""%>
                                        </td>

                                        <td>
                                            <span class="role <%= user.getRole().toLowerCase()%>">
                                                <%= user.getRole()%>
                                            </span>
                                        </td>

                                        <td>
                                            <span class="status <%= user.getStatus().toLowerCase()%>">
                                                <%= user.getStatus()%>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="view-button"
                                               href="<%= contextPath%>/admin/user-detail?id=<%= user.getUserId()%>">
                                                View
                                            </a>
                                        </td>
                                    </tr>

                                    <%
                                        }
                                    } else {
                                    %>

                                    <tr>
                                        <td colspan="8" class="empty">
                                            No users found.
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