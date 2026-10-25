
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Admin Dashboard - Light Ticket</title>

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

        <!-- Lớp nền khi mở sidebar trên điện thoại -->
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

                    <a href="${ctx}/admin" class="is-active" aria-current="page">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span>Dashboard</span>
                    </a>

                    <a href="${ctx}/admin/users">
                        <span class="material-symbols-outlined">group</span>
                        <span>Manage Users</span>
                    </a>

                    <a href="#" title="Chức năng chưa được kết nối">
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

                    <a href="${ctx}/admin/vouchers">
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
                        <span class="material-symbols-outlined">logout</span>
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

                    <!-- Avatar và dropdown -->
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
                    <span class="admin-breadcrumb-current">Dashboard</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <!-- Nội dung Dashboard -->
            <main class="admin-content">
                <section class="content">

                    <div class="page-heading">
                        <div>
                            <h1>Admin Dashboard</h1>
                            <p>Manage your Light Ticket system</p>
                        </div>
                    </div>

                    <!-- Dashboard Cards -->
                    <div class="dashboard-grid">

                        <!-- Users -->
                        <a href="${ctx}/admin/users" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="fa-solid fa-users"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Users</h2>
                                <p>Manage system users</p>
                            </div>
                        </a>

                        <!-- Events -->
                        <a href="#" class="dashboard-card" title="Chức năng chưa được kết nối">
                            <div class="dashboard-icon">
                                <i class="fa-solid fa-calendar-days"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Events</h2>
                                <p>Manage events</p>
                            </div>
                        </a>

                        <!-- Categories -->
                        <a href="${ctx}/admin/categories" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="fa-solid fa-folder"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Categories</h2>
                                <p>Manage event categories</p>
                            </div>
                        </a>

                        <!-- Venues -->
                        <a href="${ctx}/admin/venues" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="fa-solid fa-location-dot"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Venues</h2>
                                <p>Manage event venues</p>
                            </div>
                        </a>

                        <!-- Vouchers -->
                        <a href="${ctx}/admin/vouchers" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="fa-solid fa-ticket"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Vouchers</h2>
                                <p>Manage vouchers</p>
                            </div>
                        </a>

                        <!-- Reviews -->
                        <a href="#" class="dashboard-card" title="Chức năng chưa được kết nối">
                            <div class="dashboard-icon">
                                <i class="fa-solid fa-star"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Reviews</h2>
                                <p>Manage customer reviews</p>
                            </div>
                        </a>

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
