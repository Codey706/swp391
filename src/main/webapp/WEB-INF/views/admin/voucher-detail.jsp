
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
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
                <a href="${ctx}/admin/vouchers">Manage Vouchers</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
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
                    <c:if test="${param.msg eq 'activated'}"><div class="alert alert-success">Đã kích hoạt voucher.</div></c:if>
                    <c:if test="${param.msg eq 'deactivated'}"><div class="alert alert-success">Đã ngừng voucher. Khách hàng không thể dùng mã này nữa.</div></c:if>
                    <div class="detail-card">

                        <!-- Voucher Profile -->
                        <div class="profile-header">

                            <div class="avatar">
                                <i class="ph ph-ticket"></i>
                            </div>

                            <div class="profile-info">

                                <h2>
                                    <%= HtmlUtils.escape(voucher.getVoucherName(), "")%>
                                </h2>

                                <p>
                                    Voucher ID: #<%= voucher.getVoucherId()%>
                                </p>

                                <span class="status <%= status%>">
                                    <%= HtmlUtils.escape(voucher.getStatus(), "Unknown")%>
                                </span>

                            </div>
                        </div>

                        <!-- Voucher Information -->
                        <h3 class="section-title">
                            <i class="ph ph-info"></i>
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
                                    <%= HtmlUtils.escape(voucher.getVoucherCode(), "")%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Voucher Name</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(voucher.getVoucherName(), "")%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Discount Type</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(voucher.getDiscountType(), "")%>
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
                                        <%= HtmlUtils.escape(voucher.getStatus(), "Unknown")%>
                                    </span>
                                </div>
                            </div>

                        </div>

                        <!-- Usage Information -->
                        <h3 class="section-title account-section-title">
                            <i class="ph ph-chart-bar"></i>
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
                            <i class="ph ph-calendar"></i>
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
                            <i class="ph ph-clock"></i>
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
                                <i class="ph ph-arrow-left"></i>
                                Back to Vouchers
                            </a>

                            <form method="post" action="${ctx}/admin/vouchers" style="display: inline;">
                                <input type="hidden" name="csrfToken" value="${csrfToken}">
                                <input type="hidden" name="id" value="<%= voucher.getVoucherId()%>">
                                <% if ("ACTIVE".equalsIgnoreCase(voucher.getStatus())) { %>
                                <input type="hidden" name="action" value="deactivate">
                                <button type="submit" class="delete-button"><i class="ph ph-prohibit"></i> Deactivate Voucher</button>
                                <% } else { %>
                                <input type="hidden" name="action" value="activate">
                                <button type="submit" class="back-button"><i class="ph ph-check-circle"></i> Activate Voucher</button>
                                <% } %>
                            </form>

                            <a class="back-button"
                               href="${ctx}/admin/vouchers?action=edit&id=<%= voucher.getVoucherId()%>"
                               style="background: #d93a27; color: white;">
                                <i class="ph ph-pencil-simple-line"></i>
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
