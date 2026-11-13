
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="utils.HtmlUtils" %>
<%@ page import="model.Venue" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Venue Detail - Light Ticket</title>


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

    <%
        Venue venue = (Venue) request.getAttribute("venue");
        String contextPath = request.getContextPath();
        DateTimeFormatter dateTimeFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        if (venue == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
    %>

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

                <a href="${ctx}/admin/venues" class="is-active" aria-current="page">
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
                <a href="${ctx}/admin/venues">Manage Venues</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
                <span class="admin-breadcrumb-current">Venue Detail</span>
            </div>

            <div class="admin-system-label">
                <span class="admin-system-dot"></span>
                Light Ticket Management System
            </div>
        </div>

        <!-- Nội dung trang -->
        <main class="admin-content">
            <section class="content">

                <div class="detail-container">

                    <div class="page-heading">
                        <div>
                            <h1>Venue Detail</h1>
                            <p>Thông tin chi tiết địa điểm tổ chức sự kiện trong Light Ticket</p>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${param.msg eq 'in_use'}"><div class="alert alert-danger">Địa điểm đang được dùng cho sự kiện ACTIVE hoặc đang chờ duyệt nên không thể ngừng hoạt động / xóa.</div></c:when>
                        <c:when test="${param.msg eq 'has_history'}"><div class="alert alert-danger">Địa điểm đã từng có sự kiện nên không thể xóa (để giữ lịch sử). Hãy chuyển sang INACTIVE.</div></c:when>
                        <c:when test="${param.msg eq 'activated'}"><div class="alert alert-success">Đã kích hoạt địa điểm.</div></c:when>
                        <c:when test="${param.msg eq 'deactivated'}"><div class="alert alert-success">Đã ngừng hoạt động địa điểm.</div></c:when>
                    </c:choose>

                    <div class="detail-card">

                        <div class="profile-header">
                            <div class="avatar">
                                <i class="ph ph-map-pin"></i>
                            </div>
                            <div class="profile-info">
                                <h2><%= HtmlUtils.escape(venue.getVenueName())%></h2>
                                <p>Venue ID: #<%= venue.getVenueId()%></p>
                                <span class="status <%= HtmlUtils.escape(venue.getStatus()).toLowerCase()%>">
                                    <%= HtmlUtils.escape(venue.getStatus(), "Unknown")%>
                                </span>
                            </div>
                        </div>

                        <h3 class="section-title">
                            <i class="ph ph-info"></i>
                            Venue Information
                        </h3>

                        <div class="detail-grid">
                            <div class="detail-item">
                                <span class="detail-label">Venue Name</span>
                                <div class="detail-value"><%= HtmlUtils.escape(venue.getVenueName())%></div>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Capacity</span>
                                <div class="detail-value"><%= String.format("%,d", venue.getCapacity())%> people</div>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Address</span>
                                <div class="detail-value"><%= HtmlUtils.escape(venue.getAddress(), "Not provided")%></div>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Description</span>
                                <div class="detail-value"><%= HtmlUtils.escape(venue.getDescription(), "No description provided")%></div>
                            </div>
                        </div>

                        <h3 class="section-title account-section-title">
                            <i class="ph ph-clock"></i>
                            System Information
                        </h3>

                        <div class="detail-grid">
                            <div class="detail-item">
                                <span class="detail-label">Created At</span>
                                <div class="detail-value">
                                    <%= venue.getCreatedAt() != null ? venue.getCreatedAt().format(dateTimeFormat) : "Not available"%>
                                </div>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Updated At</span>
                                <div class="detail-value">
                                    <%= venue.getUpdatedAt() != null ? venue.getUpdatedAt().format(dateTimeFormat) : "Not available"%>
                                </div>
                            </div>
                        </div>

                        <div class="detail-actions">
                            <a class="back-button" href="<%= contextPath%>/admin/venues">
                                <i class="ph ph-arrow-left"></i>
                                Back to Venues
                            </a>

                            <form method="post" action="<%= contextPath%>/admin/venue-action" style="display: inline;">
                                <input type="hidden" name="csrfToken" value="${csrfToken}">
                                <input type="hidden" name="id" value="<%= venue.getVenueId()%>">
                                <% if ("ACTIVE".equalsIgnoreCase(venue.getStatus())) { %>
                                <input type="hidden" name="action" value="deactivate">
                                <button type="submit" class="delete-button"><i class="ph ph-prohibit"></i> Deactivate</button>
                                <% } else { %>
                                <input type="hidden" name="action" value="activate">
                                <button type="submit" class="back-button"><i class="ph ph-check-circle"></i> Activate</button>
                                <% } %>
                            </form>

                            <form method="post" action="<%= contextPath%>/admin/venue-action" style="display: inline;"
                                  onsubmit="return confirm('Xóa vĩnh viễn địa điểm này?');">
                                <input type="hidden" name="csrfToken" value="${csrfToken}">
                                <input type="hidden" name="id" value="<%= venue.getVenueId()%>">
                                <input type="hidden" name="action" value="delete">
                                <button type="submit" class="delete-button"><i class="ph ph-trash"></i> Delete</button>
                            </form>

                            <a class="back-button" href="<%= contextPath%>/admin/venue-edit?id=<%= venue.getVenueId()%>"
                               style="background: #d93a27; color: white;">
                                <i class="ph ph-pencil-simple-line"></i> Edit Venue
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
