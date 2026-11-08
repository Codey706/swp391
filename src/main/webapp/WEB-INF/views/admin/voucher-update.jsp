
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Voucher" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%
    Voucher voucher = (Voucher) request.getAttribute("voucher");
    String contextPath = request.getContextPath();
    String errorMessage = (String) request.getAttribute("error");

    if (errorMessage == null) {
        errorMessage = (String) request.getAttribute("errorMessage");
    }

    if (voucher == null) {
        response.sendError(404);
        return;
    }

    String voucherCode = voucher.getVoucherCode() == null
            ? "" : voucher.getVoucherCode();

    String voucherName = voucher.getVoucherName() == null
            ? "" : voucher.getVoucherName();

    String discountType = voucher.getDiscountType() == null
            ? "Percentage" : voucher.getDiscountType();

    String discountValue = voucher.getDiscountValue() == null
            ? "" : voucher.getDiscountValue().toPlainString();

    String minOrderAmount = voucher.getMinOrderAmount() == null
            ? "0" : voucher.getMinOrderAmount().toPlainString();

    String maxDiscountAmount = voucher.getMaxDiscountAmount() == null
            ? "" : voucher.getMaxDiscountAmount().toPlainString();

    String startTime = voucher.getStartTime() == null
            ? "" : voucher.getStartTime().format(
                    DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));

    String endTime = voucher.getEndTime() == null
            ? "" : voucher.getEndTime().format(
                    DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));

    String status = voucher.getStatus() == null
            ? "INACTIVE" : voucher.getStatus();

    // Escape dữ liệu khi hiển thị trong HTML
    String escapedVoucherCode = voucherCode
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    String escapedVoucherName = voucherName
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    String escapedDiscountValue = discountValue
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    String escapedMinOrderAmount = minOrderAmount
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    String escapedMaxDiscountAmount = maxDiscountAmount
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    String escapedVoucherNameForText = voucherName
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Update Voucher - Light Ticket</title>


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

                    <!-- Avatar và dropdown -->
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
                    <span class="admin-breadcrumb-current">Update Voucher</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <!-- Nội dung trang -->
            <main class="admin-content">
                <section class="content">

                    <div class="page-heading">
                        <div>
                            <h1>Update Voucher</h1>
                            <p>Chỉnh sửa thông tin mã giảm giá trong Light Ticket.</p>
                        </div>
                    </div>

                    <!-- Form cập nhật voucher: dùng bố cục giống Edit Category -->
                    <div class="edit-category-card">

                        <h2>
                            <i class="ph ph-ticket"></i>
                            Voucher Information
                        </h2>

                        <p class="subtitle">
                            Cập nhật thông tin mã giảm giá bên dưới.
                            Voucher ID: #<%= voucher.getVoucherId()%>
                        </p>

                        <% if (errorMessage != null && !errorMessage.isEmpty()) {%>
                        <div class="error-message" role="alert">
                            <%= errorMessage.replace("&", "&amp;")
                                    .replace("<", "&lt;")
                                    .replace(">", "&gt;")%>
                        </div>
                        <% }%>

                        <form method="post" action="<%= contextPath%>/admin/vouchers">

                            <input type="hidden" name="action" value="update">
                            <input type="hidden"
                                   name="voucherId"
                                   value="<%= voucher.getVoucherId()%>">

                            <div class="form-group">
                                <label for="voucherCode">Voucher Code *</label>

                                <input id="voucherCode"
                                       type="text"
                                       name="voucherCode"
                                       maxlength="50"
                                       required
                                       value="<%= escapedVoucherCode%>">
                            </div>

                            <div class="form-group">
                                <label for="voucherName">Voucher Name *</label>

                                <input id="voucherName"
                                       type="text"
                                       name="voucherName"
                                       maxlength="255"
                                       required
                                       value="<%= escapedVoucherName%>">
                            </div>

                            <div class="form-group">
                                <label for="discountType">Discount Type *</label>

                                <select id="discountType" name="discountType" required>
                                    <option value="Percentage"
                                            <%= "Percentage".equals(discountType) ? "selected" : ""%>>
                                        Percentage
                                    </option>

                                    <option value="Fixed"
                                            <%= "Fixed".equals(discountType) ? "selected" : ""%>>
                                        Fixed
                                    </option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="discountValue">Discount Value *</label>

                                <input id="discountValue"
                                       type="number"
                                       name="discountValue"
                                       min="0.01"
                                       step="0.01"
                                       required
                                       value="<%= escapedDiscountValue%>">

                                <small class="text-muted">
                                    Percentage không được vượt quá 100.
                                </small>
                            </div>

                            <div class="form-group">
                                <label for="minOrderAmount">Minimum Order Amount *</label>

                                <input id="minOrderAmount"
                                       type="number"
                                       name="minOrderAmount"
                                       min="0"
                                       step="0.01"
                                       required
                                       value="<%= escapedMinOrderAmount%>">
                            </div>

                            <div class="form-group">
                                <label for="maxDiscountAmount">Maximum Discount Amount</label>

                                <input id="maxDiscountAmount"
                                       type="number"
                                       name="maxDiscountAmount"
                                       min="0"
                                       step="0.01"
                                       value="<%= escapedMaxDiscountAmount%>">

                                <small class="text-muted">
                                    Để trống nếu không giới hạn.
                                </small>
                            </div>

                            <div class="form-group">
                                <label for="startTime">Start Time *</label>

                                <input id="startTime"
                                       type="datetime-local"
                                       name="startTime"
                                       required
                                       value="<%= startTime%>">
                            </div>

                            <div class="form-group">
                                <label for="endTime">End Time *</label>

                                <input id="endTime"
                                       type="datetime-local"
                                       name="endTime"
                                       required
                                       value="<%= endTime%>">
                            </div>

                            <div class="form-group">
                                <label for="usageLimit">Usage Limit *</label>

                                <input id="usageLimit"
                                       type="number"
                                       name="usageLimit"
                                       min="1"
                                       step="1"
                                       required
                                       value="<%= voucher.getUsageLimit()%>">
                            </div>

                            <div class="form-group">
                                <label for="status">Status *</label>

                                <select id="status" name="status" required>
                                    <option value="ACTIVE"
                                            <%= "ACTIVE".equalsIgnoreCase(status) ? "selected" : ""%>>
                                        ACTIVE
                                    </option>

                                    <option value="INACTIVE"
                                            <%= "INACTIVE".equalsIgnoreCase(status) ? "selected" : ""%>>
                                        INACTIVE
                                    </option>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button class="save-button" type="submit">
                                    <i class="ph ph-floppy-disk"></i>
                                    Save Changes
                                </button>

                                <a class="cancel-button"
                                   href="<%= contextPath%>/admin/voucher-detail?id=<%= voucher.getVoucherId()%>">
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
