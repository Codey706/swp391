
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Create Account - Light Ticket</title>


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
                <a href="${ctx}/admin/users">Manage Users</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
                <span class="admin-breadcrumb-current">Create Account</span>
            </div>

            <div class="admin-system-label">
                <span class="admin-system-dot"></span>
                Light Ticket Management System
            </div>
        </div>

        <!-- Nội dung trang -->
        <main class="admin-content">
            <section class="content">
                <c:set var="f" value="${form}"/>
                <div class="page-heading">
                    <div>
                        <h1>Create Account</h1>
                        <p>Tạo tài khoản Organizer hoặc Staff. Mật khẩu tạm được gửi qua email và phải đổi ở lần đăng nhập đầu.</p>
                    </div>
                </div>

                <div class="category-form-panel">
                    <c:if test="${not empty error}">
                        <div class="error-message"><c:out value="${error}"/></div>
                    </c:if>

                    <form method="post" action="${ctx}/admin/user-create">
                        <input type="hidden" name="csrfToken" value="${csrfToken}">

                        <div class="category-form-group">
                            <label for="role">Role</label>
                            <select id="role" name="role" required>
                                <option value="Organizer" ${f[4] eq 'Organizer' ? 'selected' : ''}>Organizer</option>
                                <option value="Staff" ${f[4] eq 'Staff' ? 'selected' : ''}>Staff</option>
                            </select>
                        </div>

                        <div class="category-form-group">
                            <label for="username">Username</label>
                            <input type="text" id="username" name="username" maxlength="50" required
                                   pattern="[A-Za-z0-9._]{4,50}" value="${fn:escapeXml(f[0])}">
                        </div>

                        <div class="category-form-group">
                            <label for="email">Email</label>
                            <input type="email" id="email" name="email" maxlength="255" required value="${fn:escapeXml(f[1])}">
                        </div>

                        <div class="category-form-group">
                            <label for="fullName">Full name / Organization name</label>
                            <input type="text" id="fullName" name="fullName" maxlength="100" required value="${fn:escapeXml(f[2])}">
                        </div>

                        <div class="category-form-group">
                            <label for="phone">Phone (optional)</label>
                            <input type="tel" id="phone" name="phone" maxlength="11" value="${fn:escapeXml(f[3])}">
                        </div>

                        <div class="category-form-actions">
                            <button type="submit" class="create-button">Create Account</button>
                            <a href="${ctx}/admin/users" class="category-cancel-button">Cancel</a>
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
