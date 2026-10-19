
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.Voucher" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Voucher Management - Light Ticket</title>

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css?v=3">
    </head>

    <body>

        <%
            List<Voucher> vouchers
                    = (List<Voucher>) request.getAttribute("vouchers");

            int totalVouchers = vouchers != null ? vouchers.size() : 0;
            int activeVouchers = 0;
            int inactiveVouchers = 0;

            if (vouchers != null) {
                for (Voucher voucher : vouchers) {
                    if ("ACTIVE".equalsIgnoreCase(voucher.getStatus())) {
                        activeVouchers++;
                    } else {
                        inactiveVouchers++;
                    }
                }
            }

            String contextPath = request.getContextPath();

            DateTimeFormatter formatter
                    = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
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
                        <a href="<%= contextPath%>/admin/categories">
                            <span>
                                <i class="fa-solid fa-folder"></i>
                                Categories
                            </span>
                        </a>
                    </div>

                    <a href="<%= contextPath%>/admin/venues">
                        <i class="fa-solid fa-location-dot"></i>
                        Venues
                    </a>

                    <div class="menu-group">

                        <a href="<%= contextPath%>/admin/vouchers"
                           class="menu-parent open">

                            <span>
                                <i class="fa-solid fa-ticket"></i>
                                Vouchers
                            </span>

                            <span class="arrow">▼</span>

                        </a>

                        <div class="submenu">

                            <a href="<%= contextPath%>/admin/vouchers"
                               class="active">
                                Vouchers List
                            </a>

                        </div>

                    </div>

                    <a href="#">
                        <i class="fa-solid fa-star"></i>
                        Reviews
                    </a>

                    <a href="<%= contextPath%>/admin/profile">
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
                            <h1>Voucher Management</h1>

                            <p>
                                Quản lý mã giảm giá trong hệ thống Light Ticket
                            </p>
                        </div>

                    </div>

                    <!-- Statistics -->
                    <div class="stats">

                        <div class="stat-card total">
                            <p>Total Vouchers</p>
                            <h2><%= totalVouchers%></h2>
                        </div>

                        <div class="stat-card active">
                            <p>Active Vouchers</p>
                            <h2><%= activeVouchers%></h2>
                        </div>

                        <div class="stat-card inactive">
                            <p>Inactive Vouchers</p>
                            <h2><%= inactiveVouchers%></h2>
                        </div>

                    </div>

                    <!-- Voucher List -->
                    <div class="user-panel">

                        <div class="panel-heading">

                            <div>
                                <h2>Vouchers List</h2>

                                <p>
                                    Danh sách tất cả mã giảm giá trong hệ thống
                                </p>
                            </div>

                            <button class="add-button"
                                    type="button"
                                    onclick="alert('Add Voucher feature is coming soon.')">
                                + &nbsp; Add New Voucher
                            </button>

                        </div>

                        <div class="table-wrapper">

                            <table>

                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Voucher Code</th>
                                        <th>Voucher Name</th>
                                        <th>Discount</th>
                                        <th>Min Order</th>
                                        <th>Max Discount</th>
                                        <th>Validity Period</th>
                                        <th>Usage</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>

                                <tbody>

                                    <%
                                        if (vouchers != null && !vouchers.isEmpty()) {
                                            for (Voucher voucher : vouchers) {

                                                String discount = "";

                                                if ("Percentage".equalsIgnoreCase(voucher.getDiscountType())) {
                                                    discount = voucher.getDiscountValue()
                                                            .stripTrailingZeros().toPlainString() + "%";
                                                } else {
                                                    discount = voucher.getDiscountValue()
                                                            .stripTrailingZeros().toPlainString() + " VND";
                                                }

                                                String startTime = voucher.getStartTime() != null
                                                        ? voucher.getStartTime().format(formatter) : "";

                                                String endTime = voucher.getEndTime() != null
                                                        ? voucher.getEndTime().format(formatter) : "";

                                                String status = voucher.getStatus() != null
                                                        ? voucher.getStatus() : "";
                                    %>

                                    <tr>
                                        <td><%= voucher.getVoucherId()%></td>

                                        <td>
                                            <strong><%= voucher.getVoucherCode()%></strong>
                                        </td>

                                        <td><%= voucher.getVoucherName()%></td>

                                        <td><%= discount%></td>

                                        <td>
                                            <%= voucher.getMinOrderAmount() != null
                                                    ? voucher.getMinOrderAmount().toPlainString() + " VND" : "-"%>
                                        </td>

                                        <td>
                                            <%= voucher.getMaxDiscountAmount() != null
                                                    ? voucher.getMaxDiscountAmount().toPlainString() + " VND" : "-"%>
                                        </td>

                                        <td>
                                            <%= startTime%>
                                            <br>
                                            <span>to</span>
                                            <br>
                                            <%= endTime%>
                                        </td>

                                        <td>
                                            <%= voucher.getUsedCount()%>
                                            /
                                            <%= voucher.getUsageLimit()%>
                                        </td>

                                        <td>
                                            <span class="status <%= status.toLowerCase()%>">
                                                <%= status%>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="view-button"
                                               href="<%= contextPath%>/admin/voucher-detail?id=<%= voucher.getVoucherId()%>">
                                                View
                                            </a>
                                        </td>
                                    </tr>

                                    <%
                                        }
                                    } else {
                                    %>

                                    <tr>
                                        <td colspan="10" class="empty">
                                            No vouchers found.
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
