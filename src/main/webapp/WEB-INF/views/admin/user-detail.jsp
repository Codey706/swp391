
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
<%@ page import="model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>User Detail - Light Ticket</title>


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
            User user = (User) request.getAttribute("user");
            String contextPath = request.getContextPath();

            if (user == null) {
                response.sendError(404);
                return;
            }

            String fullName = user.getFullName() != null
                    ? user.getFullName() : "";
            String role = user.getRole() != null
                    ? user.getRole() : "";
            String status = user.getStatus() != null
                    ? user.getStatus() : "";
            String userInitial = !fullName.isEmpty()
                    ? fullName.substring(0, 1).toUpperCase()
                    : "U";
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

                <a href="${ctx}/admin/users" class="is-active" aria-current="page">
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
                <a href="${ctx}/admin/users">Manage Users</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
                <span class="admin-breadcrumb-current">User Detail</span>
            </div>

            <div class="admin-system-label">
                <span class="admin-system-dot"></span>
                Light Ticket Management System
            </div>
        </div>

        <!-- Nội dung User Detail -->
        <main class="admin-content">
            <section class="content">

                <div class="detail-container">

                    <div class="page-heading">
                        <div>
                            <h1>User Detail</h1>
                            <p>Thông tin chi tiết của người dùng trong Light Ticket</p>
                        </div>
                    </div>

                    <c:if test="${not empty sessionScope.createdTempPassword}">
                        <div class="alert alert-success" role="status">
                            Đã tạo tài khoản. Mật khẩu tạm (chỉ hiển thị một lần, đã gửi tới email người dùng):
                            <b><c:out value="${sessionScope.createdTempPassword}"/></b>
                        </div>
                        <c:remove var="createdTempPassword" scope="session"/>
                    </c:if>

                    <div class="detail-card">

                        <!-- Thông tin hồ sơ -->
                        <div class="profile-header">

                            <div class="avatar">
                                <%= HtmlUtils.escape(userInitial)%>
                            </div>

                            <div class="profile-info">

                                <h2>
                                    <%= HtmlUtils.escape(user.getFullName(), "")%>
                                </h2>

                                <p>
                                    @<%= HtmlUtils.escape(user.getUsername(), "")%>
                                </p>

                                <span class="role <%= role.toLowerCase()%>">
                                    <%= role%>
                                </span>

                                &nbsp;

                                <span class="status <%= status.toLowerCase()%>">
                                    <%= status%>
                                </span>

                            </div>
                        </div>

                        <!-- Personal Information -->
                        <h3 class="section-title">
                            Personal Information
                        </h3>

                        <div class="detail-grid">

                            <div class="detail-item">
                                <span class="detail-label">User ID</span>
                                <div class="detail-value">
                                    #<%= user.getUserId()%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Username</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(user.getUsername(), "")%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Full Name</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(user.getFullName(), "")%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Email Address</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(user.getEmail(), "")%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Phone Number</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(user.getPhone(), "Not provided")%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Address</span>
                                <div class="detail-value">
                                    <%= HtmlUtils.escape(user.getAddress(), "Not provided")%>
                                </div>
                            </div>

                        </div>

                        <!-- Account Information -->
                        <h3 class="section-title account-section-title">
                            Account Information
                        </h3>

                        <div class="detail-grid">

                            <div class="detail-item">
                                <span class="detail-label">Role</span>
                                <div class="detail-value">
                                    <%= role%>
                                </div>
                            </div>

                            <!-- Cập nhật trạng thái tài khoản -->
                            <div class="detail-item">
                                <span class="detail-label">Account Status</span>

                                <form class="status-form"
                                      method="post"
                                      action="${ctx}/admin/user-detail">

                                    <input type="hidden"
                                           name="id"
                                           value="<%= user.getUserId()%>">

                                    <select class="status-select"
                                            name="status"
                                            onchange="this.form.submit()">

                                        <option value="ACTIVE"
                                                <%= "ACTIVE".equalsIgnoreCase(status)
                                                        ? "selected" : ""%>>
                                            Active
                                        </option>

                                        <option value="INACTIVE"
                                                <%= "INACTIVE".equalsIgnoreCase(status)
                                                        ? "selected" : ""%>>
                                            Inactive
                                        </option>

                                    </select>
                                </form>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Created At</span>
                                <div class="detail-value">
                                    <%= user.getCreatedAt() != null
                                                ? user.getCreatedAt() : "Not available"%>
                                </div>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Updated At</span>
                                <div class="detail-value">
                                    <%= user.getUpdatedAt() != null
                                                ? user.getUpdatedAt() : "Not available"%>
                                </div>
                            </div>

                        </div>

                        <!-- Nút thao tác -->
                        <div class="detail-actions">

                            <div class="action-left">
                                <a class="back-button" href="${ctx}/admin/users">
                                    ← Back to User List
                                </a>
                            </div>

                            <% if ("Organizer".equalsIgnoreCase(role)) { %>
                            <a class="update-button"
                               href="${ctx}/admin/organizer-kyc?userId=<%= user.getUserId()%>">
                                Organizer KYC
                            </a>
                            <% } %>

                            <a class="update-button"
                               href="${ctx}/admin/user-edit?id=<%= user.getUserId()%>">
                                Update Information
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
