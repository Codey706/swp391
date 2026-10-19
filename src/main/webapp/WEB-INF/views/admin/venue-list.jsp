
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Venue" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Venue Management - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css?v=3">
    </head>

    <body>

        <%
            List<Venue> venues
                    = (List<Venue>) request.getAttribute("venues");

            int totalVenues = venues != null ? venues.size() : 0;
            int activeVenues = 0;
            int inactiveVenues = 0;

            if (venues != null) {
                for (Venue venue : venues) {
                    if ("ACTIVE".equalsIgnoreCase(venue.getStatus())) {
                        activeVenues++;
                    } else if ("INACTIVE".equalsIgnoreCase(venue.getStatus())) {
                        inactiveVenues++;
                    }
                }
            }

            String contextPath = request.getContextPath();

            String keyword = (String) request.getAttribute("keyword");
            if (keyword == null) {
                keyword = "";
            }

            String selectedStatus
                    = (String) request.getAttribute("selectedStatus");

            if (selectedStatus == null || selectedStatus.isEmpty()) {
                selectedStatus = "ALL";
            }
        %>

        <div class="layout">

            <!-- Sidebar -->
            <aside class="sidebar">

                <div class="brand">🎟 Light Ticket</div>

                <nav class="menu">

                    <a href="<%= contextPath%>/admin">
                        <i class="fa-solid fa-chart-line"></i>
                        Dashboard
                    </a>

                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/users">
                            <i class="fa-solid fa-users"></i>
                            Users
                        </a>
                    </div>

                    <a href="#">
                        <i class="fa-solid fa-calendar-days"></i>
                        Events
                    </a>

                    <div class="menu-group">
                        <a href="<%= request.getContextPath()%>/admin/categories">
                            <i class="fa-solid fa-folder"></i>
                            Categories
                        </a>
                    </div>

                    <!-- Venues -->
                    <div class="menu-group">
                        <a href="<%= contextPath%>/admin/venues"
                           class="menu-parent open active">
                            <span>
                                <i class="fa-solid fa-location-dot"></i>
                                Venues
                            </span>
                            <span class="arrow">▼</span>
                        </a>

                        <div class="submenu">
                            <a href="<%= contextPath%>/admin/venues"
                               class="active">
                                Venues List
                            </a>
                        </div>
                    </div>

                    <a href="#">
                        <i class="fa-solid fa-ticket"></i>
                        Vouchers
                    </a>

                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/profile">
                        <i class="fa-solid fa-user"></i>
                        My Profile
                    </a>

                </nav>

            </aside>

            <main class="main">

                <!-- Topbar -->
                <header class="topbar">

                    <input class="search" type="text"
                           placeholder="⌕  Search...">

                    <a class="admin"
                       href="<%= contextPath%>/admin/profile">
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
                            <h1>Venue Management</h1>
                            <p>
                                Quản lý địa điểm tổ chức sự kiện
                                trong hệ thống Light Ticket
                            </p>
                        </div>
                    </div>

                    <!-- Statistics -->
                    <div class="stats">

                        <div class="stat-card total">
                            <p>Total Venues</p>
                            <h2><%= totalVenues%></h2>
                        </div>

                        <div class="stat-card active">
                            <p>Active Venues</p>
                            <h2><%= activeVenues%></h2>
                        </div>

                        <div class="stat-card inactive">
                            <p>Inactive Venues</p>
                            <h2><%= inactiveVenues%></h2>
                        </div>

                    </div>

                    <!-- Venue List -->
                    <div class="user-panel">

                        <div class="panel-heading">
                            <div>
                                <h2>Venues List</h2>
                                <p>
                                    Danh sách địa điểm tổ chức sự kiện
                                    trong hệ thống
                                </p>
                            </div>
                        </div>



                        <!-- Table -->
                        <div class="table-wrapper">

                            <table>

                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Venue Name</th>
                                        <th>Address</th>
                                        <th>Capacity</th>
                                        <th>Status</th>
                                        <th>Created At</th>
                                        <th>Updated At</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>

                                <tbody>

                                    <%
                                        if (venues != null && !venues.isEmpty()) {
                                            for (Venue venue : venues) {
                                                String venueStatus = venue.getStatus() != null
                                                        ? venue.getStatus().toLowerCase()
                                                        : "unknown";
                                    %>

                                    <tr>

                                        <td><%= venue.getVenueId()%></td>

                                        <td>
                                            <strong><%= venue.getVenueName() != null
                                                    ? venue.getVenueName() : ""%></strong>
                                        </td>

                                        <td>
                                            <%= venue.getAddress() != null
                                                    ? venue.getAddress() : ""%>
                                        </td>

                                        <td><%= venue.getCapacity()%></td>

                                        <td>
                                            <span class="status <%= venueStatus%>">
                                                <%= venue.getStatus() != null
                                                        ? venue.getStatus() : "Unknown"%>
                                            </span>
                                        </td>

                                        <td>
                                            <%= venue.getCreatedAt() != null
                                                    ? venue.getCreatedAt().toString().replace('T', ' ')
                                                    : ""%>
                                        </td>

                                        <td>
                                            <%= venue.getUpdatedAt() != null
                                                    ? venue.getUpdatedAt().toString().replace('T', ' ')
                                                    : ""%>
                                        </td>

                                        <td>
                                            <a class="view-button"
                                               href="<%= contextPath%>/admin/venue-detail?id=<%= venue.getVenueId()%>">
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
                                            No venues found.
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
