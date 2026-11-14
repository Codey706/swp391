
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Create Voucher - Light Ticket</title>


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
            String contextPath = request.getContextPath();
            String error = (String) request.getAttribute("error");
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
                <a href="${ctx}/admin/vouchers">Manage Vouchers</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
                <span class="admin-breadcrumb-current">Create Voucher</span>
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
                        <h1>Create Voucher</h1>
                        <p>
                            Thêm mã giảm giá mới vào hệ thống
                            Light Ticket
                        </p>
                    </div>
                </div>

                <!-- Form -->
                <div class="category-form-panel">

                    <% if (error != null) {%>
                    <div class="error-message">
                        <%= error%>
                    </div>
                    <% }%>

                    <form method="post" action="${ctx}/admin/vouchers">

                        <input type="hidden" name="action" value="create">

                        <!-- Voucher Code -->
                        <div class="category-form-group">
                            <label for="voucherCode">Voucher Code</label>

                            <input type="text"
                                   id="voucherCode"
                                   name="voucherCode"
                                   maxlength="50"
                                   placeholder="Example: EARLYBIRD10"
                                   pattern="[A-Za-z0-9_-]+"
                                   title="Only letters, numbers, underscores and hyphens"
                                   required>
                        </div>

                        <!-- Voucher Name -->
                        <div class="category-form-group">
                            <label for="voucherName">Voucher Name</label>

                            <input type="text"
                                   id="voucherName"
                                   name="voucherName"
                                   maxlength="150"
                                   placeholder="Enter voucher name"
                                   required>
                        </div>

                        <!-- Discount Type -->
                        <div class="category-form-group">
                            <label for="discountType">Discount Type</label>

                            <select id="discountType" name="discountType" required>
                                <option value="Percentage">Percentage (%)</option>
                                <option value="Fixed">Fixed Amount (VND)</option>
                            </select>
                        </div>

                        <!-- Discount Value -->
                        <div class="category-form-group">
                            <label for="discountValue">Discount Value</label>

                            <input type="number"
                                   id="discountValue"
                                   name="discountValue"
                                   min="0.01"
                                   step="0.01"
                                   placeholder="Enter discount value"
                                   required>
                        </div>

                        <!-- Minimum Order Amount -->
                        <div class="category-form-group">
                            <label for="minOrderAmount">Minimum Order Amount (VND)</label>

                            <input type="number"
                                   id="minOrderAmount"
                                   name="minOrderAmount"
                                   min="0"
                                   step="0.01"
                                   value="0"
                                   required>
                        </div>

                        <!-- Maximum Discount Amount -->
                        <div class="category-form-group">
                            <label for="maxDiscountAmount">Maximum Discount Amount (VND)</label>

                            <input type="number"
                                   id="maxDiscountAmount"
                                   name="maxDiscountAmount"
                                   min="0"
                                   step="0.01"
                                   placeholder="Leave empty if unlimited">
                        </div>

                        <!-- Start Time -->
                        <div class="category-form-group">
                            <label for="startTime">Start Time</label>

                            <input type="datetime-local"
                                   id="startTime"
                                   name="startTime"
                                   required>
                        </div>

                        <!-- End Time -->
                        <div class="category-form-group">
                            <label for="endTime">End Time</label>

                            <input type="datetime-local"
                                   id="endTime"
                                   name="endTime"
                                   required>
                        </div>

                        <!-- Usage Limit -->
                        <div class="category-form-group">
                            <label for="usageLimit">Usage Limit</label>

                            <input type="number"
                                   id="usageLimit"
                                   name="usageLimit"
                                   min="1"
                                   step="1"
                                   placeholder="Enter maximum usage"
                                   required>
                        </div>

                        <!-- Status -->
                        <div class="category-form-group">
                            <label for="status">Status</label>

                            <select id="status" name="status" required>
                                <option value="ACTIVE">ACTIVE</option>
                                <option value="INACTIVE">INACTIVE</option>
                            </select>
                        </div>

                        <!-- Buttons -->
                        <div class="category-form-actions">

                            <button type="submit" class="create-button">
                                Create Voucher
                            </button>

                            <a href="${ctx}/admin/vouchers"
                               class="category-cancel-button">
                                Cancel
                            </a>

                        </div>
                    </form>
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
