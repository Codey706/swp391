
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
        <title>Update User - Light Ticket</title>


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

            String userRole = user.getRole() != null ? user.getRole() : "";
            String userStatus = user.getStatus() != null ? user.getStatus() : "";
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
                    <span class="admin-breadcrumb-current">Update User</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <!-- Nội dung Update User -->
            <main class="admin-content">
                <section class="content">

                    <div class="edit-container">

                        <div class="page-heading">
                            <div>
                                <h1>Update User Information</h1>
                                <p>Chỉnh sửa thông tin người dùng</p>
                            </div>
                        </div>

                        <div class="edit-card">

                            <h3 class="section-title">User Information</h3>

                            <form method="post" action="${ctx}/admin/user-edit">

                                <input type="hidden"
                                       name="userId"
                                       value="<%= user.getUserId()%>">

                                <div class="form-grid">

                                    <!-- Username -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label" for="username">
                                            Username
                                        </label>

                                        <input class="edit-form-input readonly"
                                               id="username"
                                               type="text"
                                               value="<%= HtmlUtils.escape(user.getUsername(), "")%>"
                                               readonly>
                                    </div>

                                    <!-- Full Name -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label" for="fullName">
                                            Full Name
                                        </label>

                                        <input class="edit-form-input"
                                               id="fullName"
                                               type="text"
                                               name="fullName"
                                               value="<%= HtmlUtils.escape(user.getFullName(), "")%>"
                                               required>
                                    </div>

                                    <!-- Email -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label" for="email">
                                            Email Address
                                        </label>

                                        <input class="edit-form-input readonly"
                                               id="email"
                                               type="email"
                                               value="<%= HtmlUtils.escape(user.getEmail(), "")%>"
                                               readonly>
                                    </div>

                                    <!-- Phone -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label" for="phone">
                                            Phone Number
                                        </label>

                                        <input class="edit-form-input"
                                               id="phone"
                                               type="text"
                                               name="phone"
                                               value="<%= HtmlUtils.escape(user.getPhone(), "")%>">
                                    </div>

                                    <!-- Address -->
                                    <div class="edit-form-group full">
                                        <label class="edit-form-label" for="address">
                                            Address
                                        </label>

                                        <input class="edit-form-input"
                                               id="address"
                                               type="text"
                                               name="address"
                                               value="<%= HtmlUtils.escape(user.getAddress(), "")%>">
                                    </div>

                                    <!-- Role -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label" for="role">
                                            Role
                                        </label>

                                        <input class="edit-form-input readonly"
                                               id="role"
                                               type="text"
                                               value="<%= HtmlUtils.escape(userRole, "")%>"
                                               readonly>
                                    </div>

                                    <!-- Account Status -->
                                    <div class="edit-form-group">
                                        <label class="edit-form-label" for="status">
                                            Account Status
                                        </label>

                                        <select class="edit-form-select" id="status" name="status">

                                            <option value="ACTIVE"
                                                    <%= "ACTIVE".equalsIgnoreCase(userStatus)
                                                            ? "selected" : ""%>>
                                                Active
                                            </option>

                                            <option value="INACTIVE"
                                                    <%= "INACTIVE".equalsIgnoreCase(userStatus)
                                                            ? "selected" : ""%>>
                                                Inactive
                                            </option>

                                        </select>
                                    </div>

                                </div>

                                <!-- Nút thao tác -->
                                <div class="edit-form-actions">

                                    <a class="edit-cancel-button"
                                       href="${ctx}/admin/user-detail?id=<%= user.getUserId()%>">
                                        Cancel
                                    </a>

                                    <button class="edit-save-button" type="submit">
                                        Update Information
                                    </button>

                                </div>

                            </form>
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
