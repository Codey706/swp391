
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Admin Dashboard - Light Ticket</title>


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

                    <a href="${ctx}/admin" class="is-active" aria-current="page">
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

                    <%-- UC-35: số liệu hệ thống --%>
                    <div class="stats">
                        <div class="stat-card total"><p>Users</p><h2><fmt:formatNumber value="${userTotal}" pattern="#,##0"/></h2></div>
                        <div class="stat-card customer"><p>Customers</p><h2><fmt:formatNumber value="${usersByRole['Customer']}" pattern="#,##0"/></h2></div>
                        <div class="stat-card organizer"><p>Organizers</p><h2><fmt:formatNumber value="${usersByRole['Organizer']}" pattern="#,##0"/></h2></div>
                        <div class="stat-card staff"><p>Staff</p><h2><fmt:formatNumber value="${usersByRole['Staff']}" pattern="#,##0"/></h2></div>
                        <div class="stat-card active"><p>Paid orders</p><h2><fmt:formatNumber value="${paidOrders}" pattern="#,##0"/></h2></div>
                        <div class="stat-card total"><p>Revenue (VND)</p><h2><fmt:formatNumber value="${revenue}" pattern="#,##0"/></h2></div>
                    </div>

                    <div class="stats">
                        <a class="stat-card inactive" href="${ctx}/admin/events" style="text-decoration:none">
                            <p>Events awaiting approval</p><h2><fmt:formatNumber value="${pendingEvents}" pattern="#,##0"/></h2>
                        </a>
                        <c:forEach var="entry" items="${eventsByStatus}">
                            <c:if test="${entry.key ne 'PENDING_APPROVAL'}">
                                <div class="stat-card"><p>Events · <c:out value="${entry.key}"/></p><h2><fmt:formatNumber value="${entry.value}" pattern="#,##0"/></h2></div>
                                </c:if>
                            </c:forEach>
                            <c:if test="${refundPending gt 0}">
                            <div class="stat-card inactive" title="Thanh toán VNPay đến sau khi đơn đã hủy: cần hoàn tiền thủ công (Payments.payment_status = RefundPending)">
                                <p>Payments to refund</p><h2><fmt:formatNumber value="${refundPending}" pattern="#,##0"/></h2>
                            </div>
                        </c:if>
                    </div>

                    <!-- Dashboard Cards -->
                    <div class="dashboard-grid">

                        <!-- Users -->
                        <a href="${ctx}/admin/users" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="ph ph-users"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Users</h2>
                                <p>Manage system users</p>
                            </div>
                        </a>

                        <!-- Events -->
                        <a href="${ctx}/admin/events" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="ph ph-calendar"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Events</h2>
                                <p>Manage events</p>
                            </div>
                        </a>

                        <!-- Categories -->
                        <a href="${ctx}/admin/categories" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="ph ph-folder"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Categories</h2>
                                <p>Manage event categories</p>
                            </div>
                        </a>

                        <!-- Venues -->
                        <a href="${ctx}/admin/venues" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="ph ph-map-pin"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Venues</h2>
                                <p>Manage event venues</p>
                            </div>
                        </a>

                        <!-- Vouchers -->
                        <a href="${ctx}/admin/vouchers" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="ph ph-ticket"></i>
                            </div>

                            <div class="dashboard-info">
                                <h2>Vouchers</h2>
                                <p>Manage vouchers</p>
                            </div>
                        </a>

                        <!-- Reviews -->
                        <a href="${ctx}/admin/reviews" class="dashboard-card">
                            <div class="dashboard-icon">
                                <i class="ph ph-star"></i>
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
