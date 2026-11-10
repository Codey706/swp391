
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Venue" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Venue Management - Light Ticket</title>


        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css?v=5">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/phosphor/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/phosphor/fill.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ui.css">
        <script src="${pageContext.request.contextPath}/assets/js/ui.js" defer></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=20261109">
        <script src="${pageContext.request.contextPath}/assets/js/motion.js?v=20261109" defer></script>
    </head>

    <body class="admin-portal-page">

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

        <c:set var="ctx" value="${pageContext.request.contextPath}"/>
        <c:set var="adminName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Admin'}"/>
        <c:set var="adminInitial" value="${fn:toUpperCase(fn:substring(adminName, 0, 1))}"/>

        <!-- Lớp nền khi mở sidebar trên điện thoại -->
        <div class="admin-sidebar-backdrop" id="adminSidebarBackdrop"></div>

        <!-- Sidebar -->
        <aside class="admin-sidebar" id="adminSidebar" aria-label="Điều hướng Admin Portal">

            <div class="admin-sidebar-top">

                <div class="admin-brand-row">
                    <a class="admin-brand" href="${ctx}/admin">
                        <span class="admin-brand-logo">
                            <i class="ph ph-ticket" aria-hidden="true"></i>
                        </span>

                        <span class="admin-brand-text">
                            <span class="admin-brand-name">
                                <span>Light</span>
                                <span class="admin-brand-accent">Ticket</span>
                            </span>
                            <small>Admin Portal</small>
                        </span>
                    </a>

                    <button type="button"
                            class="admin-sidebar-close"
                            id="adminSidebarClose"
                            aria-label="Đóng menu">
                        <i class="ph ph-x" aria-hidden="true"></i>
                    </button>
                </div>

                <div class="admin-nav-label">WORKSPACE</div>

                <nav class="admin-nav">

                    <a href="${ctx}/admin">
                        <i class="ph ph-squares-four" aria-hidden="true"></i>
                        <span>Dashboard</span>
                    </a>

                    <a href="${ctx}/admin/users">
                        <i class="ph ph-users" aria-hidden="true"></i>
                        <span>Manage Users</span>
                    </a>

                    <a href="${ctx}/admin/events">
                        <i class="ph ph-calendar-blank" aria-hidden="true"></i>
                        <span>Manage Events</span>
                    </a>

                    <a href="${ctx}/admin/categories">
                        <i class="ph ph-tag" aria-hidden="true"></i>
                        <span>Manage Categories</span>
                    </a>

                    <a href="${ctx}/admin/venues" class="is-active" aria-current="page">
                        <i class="ph ph-map-pin" aria-hidden="true"></i>
                        <span>Manage Venues</span>
                    </a>

                    <a href="${ctx}/admin/vouchers">
                        <i class="ph ph-ticket" aria-hidden="true"></i>
                        <span>Manage Vouchers</span>
                    </a>

                    <a href="${ctx}/admin/reviews">
                        <i class="ph ph-star" aria-hidden="true"></i>
                        <span>Manage Reviews</span>
                    </a>

                    <a href="${ctx}/admin/profile">
                        <i class="ph ph-user-circle" aria-hidden="true"></i>
                        <span>Manage Profile</span>
                    </a>

                </nav>
            </div>

            <!-- Khu vực dưới sidebar -->
            <div class="admin-sidebar-bottom">

                <div class="admin-sidebar-user">
                    <span class="admin-sidebar-user-avatar">
                        <c:out value="${adminInitial}"/>
                    </span>

                    <span class="admin-sidebar-user-meta">
                        <span class="admin-sidebar-user-name">
                            <c:out value="${adminName}"/>
                        </span>
                        <small>Administrator</small>
                    </span>
                </div>

                <form method="post" action="${ctx}/logout" class="m-0">
                    <button type="submit" class="admin-sidebar-logout">
                        <i class="ph ph-sign-out" aria-hidden="true"></i>
                        Đăng xuất
                    </button>
                </form>

            </div>
        </aside>

        <!-- Nội dung chính -->
        <div class="admin-shell" id="adminShell">

            <!-- Topbar -->
            <header class="admin-topbar">

                <button type="button"
                        class="admin-hamburger"
                        id="adminSidebarOpen"
                        aria-label="Mở menu"
                        aria-controls="adminSidebar"
                        aria-expanded="false">
                    <i class="ph ph-list" aria-hidden="true"></i>
                </button>

                <div class="admin-top-actions">

                    <!-- Avatar và dropdown tài khoản -->
                    <jsp:include page="/WEB-INF/views/common/user-menu.jsp"/>
                </div>
            </header>

            <!-- Breadcrumb -->
            <div class="admin-subbar">
                <div class="admin-breadcrumbs">
                    <i class="ph ph-house" aria-hidden="true"></i>
                    <a href="${ctx}/admin">Admin Portal</a>
                    <i class="ph ph-caret-right" aria-hidden="true"></i>
                    <span class="admin-breadcrumb-current">Manage Venues</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <!-- Nội dung Venue Management -->
            <main class="admin-content">
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

                        <c:if test="${param.msg eq 'deleted'}">
                            <div class="alert alert-success">Đã xóa địa điểm.</div>
                        </c:if>

                        <div class="panel-heading">
                            <div>
                                <h2>Venues List</h2>
                                <p>
                                    Danh sách địa điểm tổ chức sự kiện
                                    trong hệ thống
                                </p>
                            </div>

                            <a href="${ctx}/admin/venue-create"
                               style="display: inline-flex; align-items: center; justify-content: center;
                               background: #FF5B49; color: white; padding: 13px 20px;
                               border-radius: 10px; font-weight: bold; text-decoration: none;
                               white-space: nowrap; cursor: pointer;">
                                Add New Venue
                            </a>
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
                                            <strong><%= HtmlUtils.escape(venue.getVenueName(), "")%></strong>
                                        </td>

                                        <td>
                                            <%= HtmlUtils.escape(venue.getAddress(), "")%>
                                        </td>

                                        <td><%= venue.getCapacity()%></td>

                                        <td>
                                            <span class="status <%= venueStatus%>">
                                                <%= HtmlUtils.escape(venue.getStatus(), "Unknown")%>
                                            </span>
                                        </td>

                                        <td>
                                            <%= venue.getCreatedAt() != null
                                                    ? venue.getCreatedAt().toLocalDate().format(
                                                            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                                                    : ""%>
                                        </td>

                                        <td>
                                            <%= venue.getUpdatedAt() != null
                                                    ? venue.getUpdatedAt().toLocalDate().format(
                                                            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                                                    : ""%>
                                        </td>

                                        <td>
                                            <a class="view-button"
                                               href="${ctx}/admin/venue-detail?id=<%= venue.getVenueId()%>">
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

                <footer class="admin-page-footer">
                    © 2026 Light Ticket Platform JSC. All rights reserved.
                </footer>
            </main>
        </div>

        <!-- Bootstrap JS dùng cho dropdown -->
        <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.js"></script>

        <!-- Điều khiển sidebar trên màn hình nhỏ -->
        <script>
            (function () {
                const sidebar = document.getElementById('adminSidebar');
                const backdrop = document.getElementById('adminSidebarBackdrop');
                const openButton = document.getElementById('adminSidebarOpen');
                const closeButton = document.getElementById('adminSidebarClose');

                function openSidebar() {
                    sidebar.classList.add('is-open');
                    backdrop.classList.add('is-visible');
                    openButton.setAttribute('aria-expanded', 'true');
                }

                function closeSidebar() {
                    sidebar.classList.remove('is-open');
                    backdrop.classList.remove('is-visible');
                    openButton.setAttribute('aria-expanded', 'false');
                }

                openButton.addEventListener('click', openSidebar);
                closeButton.addEventListener('click', closeSidebar);
                backdrop.addEventListener('click', closeSidebar);

                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape') {
                        closeSidebar();
                    }
                });
            })();
        </script>

    </body>
</html>
