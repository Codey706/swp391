
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

            <!-- Dashboard analytics: numbers and tables are served from SQL Server. -->
            <main class="admin-content">
                <section class="content lt-analytics">
                    <div class="page-heading lt-heading">
                        <div><h1>Admin Dashboard</h1><p>System performance &amp; management overview</p></div>
                        <form method="get" action="${ctx}/admin" class="lt-period">
                            <label for="ltDays">Revenue period</label>
                            <select name="days" id="ltDays" onchange="this.form.submit()">
                                <option value="7" ${selectedDays == 7 ? 'selected' : ''}>Last 7 days</option>
                                <option value="30" ${selectedDays == 30 ? 'selected' : ''}>Last 30 days</option>
                                <option value="90" ${selectedDays == 90 ? 'selected' : ''}>Last 90 days</option>
                            </select>
                        </form>
                    </div>
                    <div class="lt-kpis">
                        <a class="lt-kpi" href="${ctx}/admin/orders?status=Paid"><span class="lt-icon"><i class="ph ph-currency-circle-dollar"></i></span><span class="lt-kpi-label">Total revenue</span><strong><fmt:formatNumber value="${revenue}" pattern="#,##0"/> ₫</strong><small>Paid orders · All time <i class="ph ph-arrow-up-right"></i></small></a>
                        <a class="lt-kpi" href="${ctx}/admin/orders"><span class="lt-icon"><i class="ph ph-shopping-cart"></i></span><span class="lt-kpi-label">Paid orders</span><strong><fmt:formatNumber value="${paidOrders}" pattern="#,##0"/></strong><small>View transactions <i class="ph ph-arrow-up-right"></i></small></a>
                        <a class="lt-kpi" href="${ctx}/admin/users"><span class="lt-icon"><i class="ph ph-users-three"></i></span><span class="lt-kpi-label">Total users</span><strong><fmt:formatNumber value="${userTotal}" pattern="#,##0"/></strong><small><fmt:formatNumber value="${usersByRole['Organizer']}" pattern="#,##0"/> organizers · View users <i class="ph ph-arrow-up-right"></i></small></a>
                        <a class="lt-kpi" href="${ctx}/admin/events"><span class="lt-icon"><i class="ph ph-calendar-check"></i></span><span class="lt-kpi-label">Total events</span><strong><fmt:formatNumber value="${eventTotal}" pattern="#,##0"/></strong><small><fmt:formatNumber value="${pendingEvents}" pattern="#,##0"/> awaiting approval <i class="ph ph-arrow-up-right"></i></small></a>
                    </div>
                    <div class="lt-chart-grid">
                        <section class="lt-panel lt-revenue">
                            <div class="lt-panel-head"><div><h2><i class="ph ph-chart-line-up"></i> Revenue overview</h2><p>Revenue from paid orders in the last ${selectedDays} days</p></div><span class="lt-chart-unit">VND</span></div>
                            <div class="lt-chart-container"><svg id="ltRevenueChart" viewBox="0 0 740 250" preserveAspectRatio="none" role="img" aria-label="Revenue by day"></svg><div id="ltChartEmpty" class="lt-chart-empty" hidden>No paid orders in this period</div></div>
                            <div class="lt-chart-data" id="ltChartData" hidden>
                                <c:forEach var="point" items="${revenueTrend}"><span data-day="${point.day}" data-amount="${point.amount}"></span></c:forEach>
                                </div>
                            </section>
                            <section class="lt-panel lt-status-panel">
                                <div class="lt-panel-head"><div><h2><i class="ph ph-chart-donut"></i> Order status</h2><p>All-time order distribution</p></div></div>
                                        <c:set var="paidCount" value="${orderStatuses['Paid']}"/><c:set var="pendingCount" value="${orderStatuses['Pending']}"/><c:set var="cancelledCount" value="${orderStatuses['Cancelled']}"/>
                                        <c:set var="paidPct" value="${orderTotal gt 0 ? paidCount * 100 / orderTotal : 0}"/><c:set var="pendingPct" value="${orderTotal gt 0 ? pendingCount * 100 / orderTotal : 0}"/>
                            <div class="lt-donut-wrap"><div class="lt-donut" style="--paid:${paidPct}%;--pending:${pendingPct}%;"><div><strong><fmt:formatNumber value="${orderTotal}" pattern="#,##0"/></strong><small>Orders</small></div></div></div>
                            <div class="lt-status-legend">
                                <a href="${ctx}/admin/orders?status=Paid"><i class="lt-dot lt-dot-paid"></i><span>Paid</span><strong><fmt:formatNumber value="${paidCount}" pattern="#,##0"/></strong></a>
                                <a href="${ctx}/admin/orders?status=Pending"><i class="lt-dot lt-dot-pending"></i><span>Pending</span><strong><fmt:formatNumber value="${pendingCount}" pattern="#,##0"/></strong></a>
                                <a href="${ctx}/admin/orders?status=Cancelled"><i class="lt-dot lt-dot-cancelled"></i><span>Cancelled</span><strong><fmt:formatNumber value="${cancelledCount}" pattern="#,##0"/></strong></a>
                            </div>
                        </section>
                    </div>
                    <div class="lt-tables-grid">
                        <section class="lt-panel"><div class="lt-panel-head"><h2><i class="ph ph-receipt"></i> Recent transactions</h2><a href="${ctx}/admin/orders">View all orders <i class="ph ph-arrow-right"></i></a></div>
                            <div class="lt-table-scroll"><table class="lt-table"><thead><tr><th>Order</th><th>Customer</th><th>Event</th><th>Amount</th><th>Status</th><th>Action</th></tr></thead><tbody>
                                        <c:forEach var="order" items="${recentOrders}"><tr><td><strong><c:out value="${order.code}"/></strong></td><td><c:out value="${order.customer}"/></td><td><c:out value="${empty order.event ? '—' : order.event}"/></td><td><fmt:formatNumber value="${order.amount}" pattern="#,##0"/> ₫</td><td><span class="lt-chip lt-chip-${fn:toLowerCase(order.status)}"><c:out value="${order.status}"/></span></td><td><a href="${ctx}/admin/orders?id=${order.id}">View</a></td></tr></c:forEach>
                                        <c:if test="${empty recentOrders}"><tr><td colspan="6" class="lt-empty">No orders yet.</td></tr></c:if>
                                        </tbody></table></div>
                            </section>
                            <section class="lt-panel"><div class="lt-panel-head"><h2><i class="ph ph-clock-countdown"></i> Events awaiting approval</h2><a href="${ctx}/admin/events">View all <i class="ph ph-arrow-right"></i></a></div>
                            <div class="lt-table-scroll"><table class="lt-table"><thead><tr><th>Event</th><th>Organizer</th><th>Submitted</th><th>Action</th></tr></thead><tbody>
                                        <c:forEach var="event" items="${pendingEventPreview}"><tr><td><strong><c:out value="${event.name}"/></strong></td><td><c:out value="${event.organizer}"/></td><td><fmt:formatDate value="${event.created}" pattern="dd/MM/yyyy"/></td><td><a href="${ctx}/admin/events">Review</a></td></tr></c:forEach>
                                        <c:if test="${empty pendingEventPreview}"><tr><td colspan="4" class="lt-empty">No events awaiting approval.</td></tr></c:if>
                                        </tbody></table></div>
                            </section>
                        </div>                                    
                    </section>
                    <footer class="admin-page-footer">
                        © 2026 Light Ticket Platform JSC. All rights reserved.
                    </footer>
                </main>
            </div>

            <script src="${ctx}/assets/js/admin-dashboard.js?v=1" defer></script>
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
