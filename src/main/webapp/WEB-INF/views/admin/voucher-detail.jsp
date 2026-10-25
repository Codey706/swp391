
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Voucher" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%
    Voucher voucher = (Voucher) request.getAttribute("voucher");
    String contextPath = request.getContextPath();

    if (voucher == null) {
        response.sendError(404);
        return;
    }

    String status = voucher.getStatus() == null
            ? "unknown" : voucher.getStatus().toLowerCase();
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Voucher Detail - Light Ticket</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css?v=5">
    </head>

    <body class="admin-portal-page">

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
                        <span class="material-symbols-outlined">confirmation_number</span>
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
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>

            <div class="admin-nav-label">WORKSPACE</div>

            <nav class="admin-nav">

                <a href="${ctx}/admin">
                    <span class="material-symbols-outlined">dashboard</span>
                    <span>Dashboard</span>
                </a>

                <a href="${ctx}/admin/users">
                    <span class="material-symbols-outlined">group</span>
                    <span>Manage Users</span>
                </a>

                <a href="${ctx}/admin/events">
                    <span class="material-symbols-outlined">event</span>
                    <span>Manage Events</span>
                </a>

                <a href="${ctx}/admin/categories">
                    <span class="material-symbols-outlined">category</span>
                    <span>Manage Categories</span>
                </a>

                <a href="${ctx}/admin/venues">
                    <span class="material-symbols-outlined">location_on</span>
                    <span>Manage Venues</span>
                </a>

                <a href="${ctx}/admin/vouchers" class="is-active" aria-current="page">
                    <span class="material-symbols-outlined">confirmation_number</span>
                    <span>Manage Vouchers</span>
                </a>

                <a href="#" title="Chức năng chưa được kết nối">
                    <span class="material-symbols-outlined">star</span>
                    <span>Manage Reviews</span>
                </a>

                <a href="${ctx}/admin/profile">
                    <span class="material-symbols-outlined">account_circle</span>
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
                    <span class="material-symbols-outlined">logout</span>
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
                <span class="material-symbols-outlined">menu</span>
            </button>

            <div class="admin-top-actions">

                <button type="button"
                        class="admin-top-button admin-help-button"
                        aria-label="Hỗ trợ"
                        title="Hỗ trợ">
                    <span class="material-symbols-outlined">help_outline</span>
                </button>

                <button type="button"
                        class="admin-top-button"
                        aria-label="Thông báo"
                        title="Thông báo">
                    <span class="material-symbols-outlined">notifications</span>
                    <span class="admin-notification-dot"></span>
                </button>

                <!-- Dropdown tài khoản -->
                <div class="dropdown admin-account-dropdown">

                    <button class="admin-account-toggle"
                            type="button"
                            id="adminAccountDropdown"
                            data-bs-toggle="dropdown"
                            aria-expanded="false"
                            title="Tài khoản Admin">

                        <span class="admin-account-avatar">
                            <c:out value="${adminInitial}"/>
                        </span>

                        <span class="admin-account-name">
                            <c:out value="${adminName}"/>
                        </span>

                        <span class="material-symbols-outlined admin-account-chevron">
                            keyboard_arrow_down
                        </span>
                    </button>

                    <ul class="dropdown-menu dropdown-menu-end admin-account-menu shadow-sm"
                        aria-labelledby="adminAccountDropdown">

                        <li class="admin-account-heading">
                            <span class="admin-account-heading-name">
                                <c:out value="${adminName}"/>
                            </span>
                            <small>Administrator</small>
                        </li>

                        <li>
                            <a class="dropdown-item" href="${ctx}/admin/profile">
                                <span class="material-symbols-outlined">account_circle</span>
                                Hồ sơ của tôi
                            </a>
                        </li>

                        <li>
                            <a class="dropdown-item" href="${ctx}/home">
                                <span class="material-symbols-outlined">home</span>
                                Về trang chủ
                            </a>
                        </li>

                        <li>
                            <hr class="dropdown-divider">
                        </li>

                        <li>
                            <form action="${ctx}/logout" method="post" class="m-0">
                                <button type="submit" class="dropdown-item admin-dropdown-logout">
                                    <span class="material-symbols-outlined">logout</span>
                                    Đăng xuất
                                </button>
                            </form>
                        </li>

                    </ul>
                </div>
            </div>
        </header>

        <!-- Breadcrumb -->
        <div class="admin-subbar">
            <div class="admin-breadcrumbs">
                <span class="material-symbols-outlined">home</span>
                <a href="${ctx}/admin">Admin Portal</a>
                <span class="material-symbols-outlined">chevron_right</span>
                <a href="${ctx}/admin/vouchers">Manage Vouchers</a>
                <span class="material-symbols-outlined">chevron_right</span>
                <span class="admin-breadcrumb-current">Voucher Detail</span>
            </div>

            <div class="admin-system-label">
                <span class="admin-system-dot"></span>
                Light Ticket Management System
            </div>
        </div>

        <!-- Page Content -->
        <main class="admin-content">
            <section class="content">

                <div class="detail-container">

                    <!-- Page Heading -->
                    <div class="page-heading">
                        <div>
                            <h1>Voucher Detail</h1>
                            <p>
                                Thông tin chi tiết mã giảm giá
                                trong Light Ticket
                            </p>
                        </div>
                    </div>

                    <!-- Detail Card -->
                    <div class="detail-card">

                        <!-- Voucher Profile -->
                        <div class="profile-header">

                            <div class="avatar">
                                <i class="fa-solid fa-ticket"></i>
                            </div>

                            <div class="profile-info">

                                <h2>
                                    <%= voucher.getVoucherName() != null
                                                ? voucher.getVoucherName() : ""%>
                                </h2>

                                <p>
                                    Voucher ID: #<%= voucher.getVoucherId()%>
                                </p>

                                <span class="status <%= status%>">
                                    <%= voucher.getStatus() != null
                                                ? voucher.getStatus() : "Unknown"%>
                                </span>

                            </div>
                        </div>

                        <!-- Voucher Information -->
                        <h3 class="section-title">
                            <i class="fa-solid fa-circle-info"></i>
                            Voucher Information
                        </h3>

                        <div class="detail-grid">

                            <div class="detail-item">
                                <span class="detail-label">Voucher ID</span>
                                <div class="detail-value">
                                    #<%= voucher.getVoucherId()%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Voucher Code</span>
                                <div class="detail-value">
                                    <%= voucher.getVoucherCode() != null
                                                ? voucher.getVoucherCode() : ""%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Voucher Name</span>
                                <div class="detail-value">
                                    <%= voucher.getVoucherName() != null
                                                ? voucher.getVoucherName() : ""%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Discount Type</span>
                                <div class="detail-value">
                                    <%= voucher.getDiscountType() != null
                                                ? voucher.getDiscountType() : ""%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Discount Value</span>
                                <div class="detail-value">
                                    <%= voucher.getDiscountValue() != null
                                                ? voucher.getDiscountValue().toPlainString() : "0"%>
                                    <%= "Percentage".equals(voucher.getDiscountType())
                                                ? "%" : ""%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Minimum Order Amount</span>
                                <div class="detail-value">
                                    <%= voucher.getMinOrderAmount() != null
                                                ? voucher.getMinOrderAmount().toPlainString() : "0"%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Maximum Discount Amount</span>
                                <div class="detail-value">
                                    <%= voucher.getMaxDiscountAmount() != null
                                            ? voucher.getMaxDiscountAmount().toPlainString()
                                            : "No limit"%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Status</span>
                                <div class="detail-value">
                                    <span class="status <%= status%>">
                                        <%= voucher.getStatus() != null
                                                    ? voucher.getStatus() : "Unknown"%>
                                    </span>
                                </div>
                            </div>

                        </div>

                        <!-- Usage Information -->
                        <h3 class="section-title account-section-title">
                            <i class="fa-solid fa-chart-column"></i>
                            Usage Information
                        </h3>

                        <div class="detail-grid">

                            <div class="detail-item">
                                <span class="detail-label">Usage Limit</span>
                                <div class="detail-value">
                                    <%= voucher.getUsageLimit()%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Used Count</span>
                                <div class="detail-value">
                                    <%= voucher.getUsedCount()%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Remaining Uses</span>
                                <div class="detail-value">
                                    <%= Math.max(0,
                                            voucher.getUsageLimit()
                                            - voucher.getUsedCount())%>
                                </div>
                            </div>

                        </div>

                        <!-- Validity Information -->
                        <h3 class="section-title account-section-title">
                            <i class="fa-solid fa-calendar-days"></i>
                            Validity Information
                        </h3>

                        <div class="detail-grid">

                            <div class="detail-item">
                                <span class="detail-label">Start Time</span>
                                <div class="detail-value">
                                    <%= voucher.getStartTime() != null
                                                ? voucher.getStartTime() : "Not available"%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">End Time</span>
                                <div class="detail-value">
                                    <%= voucher.getEndTime() != null
                                                ? voucher.getEndTime() : "Not available"%>
                                </div>
                            </div>

                        </div>

                        <!-- System Information -->
                        <h3 class="section-title account-section-title">
                            <i class="fa-solid fa-clock"></i>
                            System Information
                        </h3>

                        <div class="detail-grid">

                            <div class="detail-item">
                                <span class="detail-label">Created At</span>
                                <div class="detail-value">
                                    <%= voucher.getCreatedAt() != null
                                                ? voucher.getCreatedAt() : "Not available"%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Updated At</span>
                                <div class="detail-value">
                                    <%= voucher.getUpdatedAt() != null
                                                ? voucher.getUpdatedAt() : "Not available"%>
                                </div>
                            </div>

                        </div>

                        <!-- Actions -->
                        <div class="detail-actions">

                            <a class="back-button"
                               href="${ctx}/admin/vouchers">
                                <i class="fa-solid fa-arrow-left"></i>
                                Back to Vouchers
                            </a>

                            <a class="back-button"
                               href="${ctx}/admin/vouchers?action=edit&id=<%= voucher.getVoucherId()%>"
                               style="background: #FF7043; color: white;">
                                <i class="fa-solid fa-pen-to-square"></i>
                                Update Voucher
                            </a>

                        </div>

                    </div>
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
