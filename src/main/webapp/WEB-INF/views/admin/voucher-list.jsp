
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.Voucher" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Manage Vouchers - Light Ticket</title>


        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css?v=6">
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
            List<Voucher> vouchers
                    = (List<Voucher>) request.getAttribute("allVouchers");

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

            List<Voucher> listedItems = (List<Voucher>) request.getAttribute("vouchers");
            String contextPath = request.getContextPath();

            DateTimeFormatter formatter
                    = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        %>

        <c:set var="ctx" value="${pageContext.request.contextPath}"/>
        <c:set var="adminName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Admin'}"/>
        <c:set var="adminInitial" value="${fn:toUpperCase(fn:substring(adminName, 0, 1))}"/>

        <!-- Lớp nền khi mở sidebar trên màn hình nhỏ -->
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

                    <a href="${ctx}/admin/venues">
                        <i class="ph ph-map-pin" aria-hidden="true"></i>
                        <span>Manage Venues</span>
                    </a>

                    <a href="${ctx}/admin/vouchers" class="is-active" aria-current="page">
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

            <!-- Tài khoản ở cuối sidebar -->
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

        <!-- Main -->
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

                    <!-- Dropdown tài khoản -->
                    <jsp:include page="/WEB-INF/views/common/user-menu.jsp"/>
                </div>
            </header>

            <!-- Breadcrumb -->
            <div class="admin-subbar">
                <div class="admin-breadcrumbs">
                    <i class="ph ph-house" aria-hidden="true"></i>
                    <a href="${ctx}/admin">Admin Portal</a>
                    <i class="ph ph-caret-right" aria-hidden="true"></i>
                    <span class="admin-breadcrumb-current">Manage Vouchers</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <!-- Page Content -->
            <main class="admin-content">
                <section class="content">

                    <!-- Page Heading -->
                    <div class="page-heading">
                        <div>
                            <h1>Manage Vouchers</h1>
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
                                    onclick="window.location.href = '${ctx}/admin/vouchers?action=create'">
                                Add New Voucher
                            </button>
                        </div>

                        <!-- Table -->
                        <form method="get" action="${ctx}/admin/vouchers" class="admin-list-filter" role="search">
                            <label class="admin-filter-search">
                                <span class="visually-hidden">Search</span>
                                <input type="search" name="keyword" maxlength="100" class="form-control" placeholder="Search code or voucher name..." value="${fn:escapeXml(keyword)}">
                            </label>
                            <select name="status" class="form-select" aria-label="Filter status">
                                <option value="ALL" ${(selectedStatus eq 'ALL' or (empty selectedStatus and 'ALL' eq 'ALL')) ? 'selected' : ''}>All statuses</option>
                                <option value="ACTIVE" ${selectedStatus eq 'ACTIVE' ? 'selected' : ''}>Active</option>
                                <option value="INACTIVE" ${selectedStatus eq 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                            </select>
                            <select name="type" class="form-select" aria-label="Filter type">
                                <option value="ALL" ${(selectedType eq 'ALL' or (empty selectedType and 'ALL' eq 'ALL')) ? 'selected' : ''}>All discount types</option>
                                <option value="Percentage" ${selectedType eq 'Percentage' ? 'selected' : ''}>Percentage</option>
                                <option value="Fixed" ${selectedType eq 'Fixed' ? 'selected' : ''}>Fixed amount</option>
                            </select>
                            <button type="submit" class="add-button">Filter</button>
                            <a href="${ctx}/admin/vouchers" class="view-button admin-filter-reset">Reset</a>
                            <span class="admin-filter-count">${matchedCount} result(s)</span>
                        </form>

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
                                        if (listedItems != null && !listedItems.isEmpty()) {
                                            for (Voucher voucher : listedItems) {

                                                String discount = "";

                                                if ("Percentage".equalsIgnoreCase(voucher.getDiscountType())) {
                                                    discount = voucher.getDiscountValue() != null
                                                            ? voucher.getDiscountValue()
                                                                    .stripTrailingZeros().toPlainString() + "%"
                                                            : "0%";
                                                } else {
                                                    discount = voucher.getDiscountValue() != null
                                                            ? voucher.getDiscountValue()
                                                                    .stripTrailingZeros().toPlainString() + " VND"
                                                            : "0 VND";
                                                }

                                                String startTime = voucher.getStartTime() != null
                                                        ? voucher.getStartTime().format(formatter) : "";

                                                String endTime = voucher.getEndTime() != null
                                                        ? voucher.getEndTime().format(formatter) : "";

                                                String status = voucher.getStatus() != null
                                                        ? voucher.getStatus() : "";

                                                String statusClass = status.toLowerCase();
                                    %>

                                    <tr>
                                        <td><%= voucher.getVoucherId()%></td>

                                        <td>
                                            <strong><%= HtmlUtils.escape(voucher.getVoucherCode(), "")%></strong>
                                        </td>

                                        <td title="<%= HtmlUtils.escape(voucher.getVoucherName(), "")%>">
                                            <%
                                                String voucherName = voucher.getVoucherName() != null
                                                        ? voucher.getVoucherName() : "";

                                                String shortName = voucherName.length() > 20
                                                        ? voucherName.substring(0, 20) + "..."
                                                        : voucherName;
                                            %>
                                            <%= HtmlUtils.escape(shortName, "")%>
                                        </td>

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
                                            <span class="status <%= statusClass%>">
                                                <%= status%>
                                            </span>
                                        </td>

                                        <td>
                                            <a class="view-button"
                                               href="${ctx}/admin/voucher-detail?id=<%= voucher.getVoucherId()%>">
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
                        <c:if test="${totalPages gt 1}">
                            <nav class="admin-list-pages" aria-label="Pagination">
                                <c:if test="${page gt 1}"><a class="view-button" href="${ctx}/admin/vouchers?${fn:escapeXml(filterQuery)}page=${page - 1}">Previous</a></c:if>
                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <a class="${p eq page ? 'add-button' : 'view-button'}" href="${ctx}/admin/vouchers?${fn:escapeXml(filterQuery)}page=${p}">${p}</a>
                                </c:forEach>
                                <c:if test="${page lt totalPages}"><a class="view-button" href="${ctx}/admin/vouchers?${fn:escapeXml(filterQuery)}page=${page + 1}">Next</a></c:if>
                                </nav>
                        </c:if>

                    </div>
                </section>

                <footer class="admin-page-footer">
                    © 2026 Light Ticket Platform JSC. All rights reserved.
                </footer>
            </main>
        </div>

        <!-- Bootstrap JS cho dropdown -->
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
