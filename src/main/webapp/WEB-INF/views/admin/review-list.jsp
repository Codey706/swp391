
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Manage Reviews - Light Ticket</title>


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

                    <a href="${ctx}/admin/vouchers">
                        <i class="ph ph-ticket" aria-hidden="true"></i>
                        <span>Manage Vouchers</span>
                    </a>

                    <a href="${ctx}/admin/reviews" class="is-active" aria-current="page">
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
                    <a href="${ctx}/admin">Admin Portal</a>
                    <i class="ph ph-caret-right" aria-hidden="true"></i>
                    <span class="admin-breadcrumb-current">Manage Reviews</span>
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
                            <h1>Manage Reviews</h1>
                            <p>Kiểm duyệt đánh giá của khách hàng. Đánh giá bị ẩn không hiển thị công khai.</p>
                        </div>
                    </div>

                    <div class="user-panel">
                        <div class="panel-heading">
                            <div>
                                <h2>Reviews (${total})</h2>
                                <p>Lọc theo trạng thái, số sao hoặc từ khóa (sự kiện, khách hàng, nội dung)</p>
                            </div>
                        </div>

                        <form method="get" action="${ctx}/admin/reviews" class="d-flex flex-wrap gap-2 mb-3">
                            <select name="status" class="form-select" style="max-width:180px">
                                <option value="">All status</option>
                                <option value="ACTIVE" ${status eq 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                <option value="HIDDEN" ${status eq 'HIDDEN' ? 'selected' : ''}>HIDDEN</option>
                            </select>
                            <select name="rating" class="form-select" style="max-width:150px">
                                <option value="">All ratings</option>
                                <c:forEach var="n" begin="1" end="5">
                                    <option value="${n}" ${rating eq n ? 'selected' : ''}>${n} ★</option>
                                </c:forEach>
                            </select>
                            <input type="text" name="keyword" maxlength="100" class="form-control" style="max-width:280px"
                                   placeholder="Event, customer, comment" value="${fn:escapeXml(keyword)}">
                            <button type="submit" class="add-button">Filter</button>
                        </form>

                        <div class="table-wrapper">
                            <table>
                                <thead>
                                    <tr><th>Date</th><th>Event</th><th>Customer</th><th>Rating</th><th>Comment</th><th>Status</th><th>Action</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${reviews}">
                                        <tr>
                                            <td style="white-space:nowrap"><c:out value="${empty r.createdAt ? '' : fn:substring(r.createdAt, 0, 10)}"/></td>
                                            <td><c:out value="${r.eventName}"/></td>
                                            <td><c:out value="${r.customerName}"/><br><small>@<c:out value="${r.username}"/></small></td>
                                            <td style="white-space:nowrap">${r.rating} ★</td>
                                            <td class="review-comment">
                                                <c:out value="${r.comment}" default="-"/>
                                            </td>
                                            <td><span class="status ${r.status eq 'ACTIVE' ? 'active' : 'inactive'}"><c:out value="${r.status}"/></span></td>
                                            <td>
                                                <form method="post" action="${ctx}/admin/reviews" class="m-0">
                                                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                                                    <input type="hidden" name="reviewId" value="${r.reviewId}">
                                                    <input type="hidden" name="back" value="${fn:escapeXml(filterQuery)}&amp;page=${page}">
                                                    <input type="hidden" name="action" value="${r.status eq 'ACTIVE' ? 'hide' : 'show'}">
                                                    <button type="submit" class="${r.status eq 'ACTIVE' ? 'delete-button' : 'view-button'}">
                                                        ${r.status eq 'ACTIVE' ? 'Hide' : 'Show'}
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty reviews}">
                                        <tr><td colspan="7" style="text-align:center">No reviews found.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>

                        <c:if test="${totalPages > 1}">
                            <div class="d-flex gap-2 mt-3 flex-wrap">
                                <c:forEach var="p" begin="1" end="${totalPages}">
                                    <a class="${p == page ? 'add-button' : 'view-button'}" href="${ctx}/admin/reviews?${fn:escapeXml(filterQuery)}&amp;page=${p}">${p}</a>
                                </c:forEach>
                            </div>
                        </c:if>
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
