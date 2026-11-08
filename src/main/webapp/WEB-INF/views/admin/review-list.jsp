
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Review" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%!
    private String escReview(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Review Management - Light Ticket</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
              rel="stylesheet">

        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap"
              rel="stylesheet">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/bootstrap.css">

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/css/admin.css?v=5">

        <style>
            /* Main content */
            .review-content {
                padding: 32px;
                min-width: 0;
                width: 100%;
            }

            /* Page heading */
            .review-heading {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 15px;
                margin-bottom: 28px;
            }

            .review-heading h1 {
                margin: 0 0 8px;
                font-size: 28px;
                color: #202B3C;
            }

            .review-heading p {
                margin: 0;
                color: #8290A7;
                font-size: 14px;
            }

            .review-summary {
                color: #526078;
                white-space: nowrap;
            }

            /* Review table container */
            .review-card {
                background: #FFFFFF;
                border: 1px solid #E9EDF6;
                border-radius: 16px;
                padding: 22px;
                box-shadow: 0 5px 20px rgba(40, 55, 90, 0.04);
                min-width: 0;
            }

            .review-table-wrapper {
                width: 100%;
                overflow-x: auto;
            }

            .review-table {
                width: 100%;
                min-width: 1000px;
                border-collapse: collapse;
            }

            .review-table th {
                background: #F2F5FC;
                color: #526078;
                font-size: 12px;
                font-weight: 600;
                text-align: left;
                padding: 16px 12px;
            }

            .review-table td {
                padding: 17px 12px;
                border-bottom: 1px solid #EDF0F7;
                font-size: 13px;
                vertical-align: top;
            }

            .review-table tbody tr:hover {
                background: #FFFAF8;
            }

            .review-table small {
                display: inline-block;
                margin-top: 5px;
                color: #8290A7;
            }

            /* Rating stars */
            .review-stars {
                color: #F59E0B;
                white-space: nowrap;
            }

            /* Review status */
            .review-status {
                display: inline-block;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: bold;
            }

            .status-active {
                background: #E2F7EF;
                color: #13966D;
            }

            .status-hidden {
                background: #FFE9E9;
                color: #D94B4B;
            }

            /* Action buttons */
            .review-action {
                border: none;
                border-radius: 8px;
                padding: 9px 13px;
                color: white;
                cursor: pointer;
                font-size: 12px;
                white-space: nowrap;
            }

            .action-hide {
                background: #E94B4B;
            }

            .action-show {
                background: #20B486;
            }

            .review-action:hover {
                opacity: 0.85;
            }

            /* Review comment */
            .review-comment {
                max-width: 260px;
                white-space: pre-wrap;
                overflow-wrap: anywhere;
            }

            /* Alert */
            .review-alert {
                padding: 12px 15px;
                border-radius: 8px;
                margin-bottom: 16px;
                background: #E2F7EF;
                color: #13966D;
            }

            /* Empty data */
            .review-empty {
                text-align: center;
                padding: 30px;
                color: #8290A7;
            }

            /* Responsive */
            @media (max-width: 768px) {
                .review-content {
                    padding: 18px;
                }

                .review-heading {
                    align-items: flex-start;
                    flex-direction: column;
                }

                .review-card {
                    padding: 12px;
                }
            }
        </style>
    </head>

    <body class="admin-portal-page">

        <c:set var="ctx"
               value="${pageContext.request.contextPath}"/>

        <c:set var="adminName"
               value="${not empty sessionScope.user && not empty sessionScope.user.fullName
                        ? sessionScope.user.fullName : 'Admin'}"/>

        <c:set var="adminInitial"
               value="${fn:toUpperCase(fn:substring(adminName, 0, 1))}"/>

        <%
            List<Review> reviews
                    = (List<Review>) request.getAttribute("reviews");

            String message = request.getParameter("message");

            int total = reviews == null ? 0 : reviews.size();

            int active = 0;

            if (reviews != null) {
                for (Review r : reviews) {
                    if ("ACTIVE".equalsIgnoreCase(r.getStatus())) {
                        active++;
                    }
                }
            }
        %>

        <!-- Sidebar backdrop -->
        <div class="admin-sidebar-backdrop"
             id="adminSidebarBackdrop">
        </div>

        <!-- Sidebar -->
        <aside class="admin-sidebar"
               id="adminSidebar"
               aria-label="Điều hướng Admin Portal">

            <div class="admin-sidebar-top">

                <div class="admin-brand-row">

                    <a class="admin-brand" href="${ctx}/admin">

                        <span class="admin-brand-logo">
                            <span class="material-symbols-outlined">
                                confirmation_number
                            </span>
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

                        <span class="material-symbols-outlined">
                            close
                        </span>

                    </button>
                </div>

                <div class="admin-nav-label">WORKSPACE</div>

                <nav class="admin-nav">

                    <a href="${ctx}/admin">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span>Dashboard</span>
                    </a>

                    <a href="${ctx}/admin/users">
                        <span class="material-symbols-outlined">group</span>
                        <span>Manage Users</span>
                    </a>

                    <a href="${ctx}/admin/events">
                        <span class="material-symbols-outlined">event</span>
                        <span>Manage Events</span>
                    </a>

                    <a href="${ctx}/admin/categories">
                        <span class="material-symbols-outlined">category</span>
                        <span>Manage Categories</span>
                    </a>

                    <a href="${ctx}/admin/profile">
                        <span class="material-symbols-outlined">person</span>
                        <span>My Profile</span>
                    </a>

                    <a href="${ctx}/admin/venues">
                        <span class="material-symbols-outlined">location_on</span>
                        <span>Manage Venues</span>
                    </a>

                    <a href="${ctx}/admin/vouchers">
                        <span class="material-symbols-outlined">confirmation_number</span>
                        <span>Manage Vouchers</span>
                    </a>

                    <a href="${ctx}/admin/reviews"
                       class="is-active"
                       aria-current="page">

                        <span class="material-symbols-outlined">star</span>
                        <span>Manage Reviews</span>

                    </a>

                </nav>
            </div>

            <!-- Sidebar bottom -->
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

                <form method="post"
                      action="${ctx}/logout"
                      class="m-0">

                    <button type="submit"
                            class="admin-sidebar-logout">

                        <span class="material-symbols-outlined">
                            logout
                        </span>

                        Đăng xuất

                    </button>
                </form>

            </div>
        </aside>

        <!-- Main shell -->
        <div class="admin-shell" id="adminShell">

            <!-- Header -->
            <header class="admin-topbar">

                <button type="button"
                        class="admin-hamburger"
                        id="adminSidebarOpen"
                        aria-label="Mở menu"
                        aria-controls="adminSidebar"
                        aria-expanded="false">

                    <span class="material-symbols-outlined">
                        menu
                    </span>

                </button>

                <div class="admin-top-actions">

                    <button type="button"
                            class="admin-top-button admin-help-button"
                            aria-label="Hỗ trợ"
                            title="Hỗ trợ">

                        <span class="material-symbols-outlined">
                            help_outline
                        </span>

                    </button>

                    <button type="button"
                            class="admin-top-button"
                            aria-label="Thông báo"
                            title="Thông báo">

                        <span class="material-symbols-outlined">
                            notifications
                        </span>

                        <span class="admin-notification-dot"></span>

                    </button>

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
                                <a class="dropdown-item"
                                   href="${ctx}/admin/profile">

                                    <span class="material-symbols-outlined">
                                        account_circle
                                    </span>

                                    Hồ sơ của tôi
                                </a>
                            </li>

                            <li>
                                <a class="dropdown-item"
                                   href="${ctx}/home">

                                    <span class="material-symbols-outlined">
                                        home
                                    </span>

                                    Về trang chủ
                                </a>
                            </li>

                            <li>
                                <hr class="dropdown-divider">
                            </li>

                            <li>

                                <form action="${ctx}/logout"
                                      method="post"
                                      class="m-0">

                                    <button type="submit"
                                            class="dropdown-item admin-dropdown-logout">

                                        <span class="material-symbols-outlined">
                                            logout
                                        </span>

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

                    <span class="material-symbols-outlined">
                        home
                    </span>

                    <a href="${ctx}/admin">
                        Admin Portal
                    </a>

                    <span class="material-symbols-outlined">
                        chevron_right
                    </span>

                    <span class="admin-breadcrumb-current">
                        Manage Reviews
                    </span>

                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>

            </div>

            <!-- Main content -->
            <main class="admin-content">

                <section class="content review-content">

                    <!-- Page heading -->
                    <div class="page-heading review-heading">

                        <div>
                            <h1>Review Management</h1>
                            <p>
                                View customer feedback and manage review visibility.
                            </p>
                        </div>

                        <div class="review-summary">

                            <strong><%=total%></strong> reviews

                            &nbsp; | &nbsp;

                            <strong><%=active%></strong> active

                        </div>

                    </div>

                    <!-- Messages -->
                    <% if ("updated".equals(message)) { %>

                    <div class="review-alert">
                        Review status updated successfully.
                    </div>

                    <% } %>

                    <% if ("notfound".equals(message)) { %>

                    <div class="review-alert">
                        The selected review was not found.
                    </div>

                    <% } %>

                    <!-- Review table -->
                    <section class="review-card">

                        <div class="review-table-wrapper">

                            <table class="review-table">

                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Customer</th>
                                        <th>Event</th>
                                        <th>Rating</th>
                                        <th>Comment</th>
                                        <th>Created at</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>

                                <tbody>

                                    <% if (reviews == null || reviews.isEmpty()) { %>

                                    <tr>
                                        <td colspan="8" class="review-empty">
                                            No reviews are available.
                                        </td>
                                    </tr>

                                    <% } else {

                                        for (Review r : reviews) {

                                            boolean isActive
                                                    = "ACTIVE".equalsIgnoreCase(r.getStatus());

                                    %>

                                    <tr>

                                        <td>
                                            #<%=r.getReviewId()%>
                                        </td>

                                        <td>
                                            <%=escReview(r.getCustomerName())%>
                                            <br>

                                            <small>
                                                Customer ID: <%=r.getCustomerId()%>
                                            </small>
                                        </td>

                                        <td>
                                            <%=escReview(r.getEventName())%>
                                            <br>

                                            <small>
                                                Event ID: <%=r.getEventId()%>
                                            </small>
                                        </td>

                                        <td>

                                            <span class="review-stars">
                                                <%="★".repeat(
                                                        Math.max(
                                                                0,
                                                                Math.min(5, r.getRating())
                                                        )
                                                )%>
                                            </span>

                                            <%=r.getRating()%>/5

                                        </td>

                                        <td>

                                            <div class="review-comment">
                                                <%=escReview(r.getComment())%>
                                            </div>

                                        </td>

                                        <td>

                                            <%=r.getCreatedAt() == null
                                                    ? "—"
                                                    : r.getCreatedAt()
                                                            .toString()
                                                            .replace('T', ' ')%>

                                        </td>

                                        <td>

                                                  <span class="review-status <%=isActive
                                                    ? "status-active"
                                                    : "status-hidden"%>">

                                                <%=escReview(r.getStatus())%>

                                            </span>

                                        </td>

                                        <td>

                                            <form method="post"
                                                  action="${ctx}/admin/reviews"
                                                  onsubmit="return confirm('Are you sure you want to change this review status?');">

                                                <input type="hidden"
                                                       name="action"
                                                       value="changeStatus">

                                                <input type="hidden"
                                                       name="reviewId"
                                                       value="<%=r.getReviewId()%>">

                                                <input type="hidden"
                                                       name="status"
                                                       value="<%=isActive
                                                               ? "HIDDEN"
                                                               : "ACTIVE"%>">

                                                        <button class="review-action <%=isActive
                                                        ? "action-hide"
                                                        : "action-show"%>"
                                                        type="submit">

                                                    <%=isActive
                                                            ? "Hide review"
                                                            : "Show review"%>

                                                </button>

                                            </form>

                                        </td>

                                    </tr>

                                    <%  }
                                        }
                                    %>

                                </tbody>

                            </table>

                        </div>

                    </section>

                </section>

                <!-- Footer -->
                <footer class="admin-page-footer">
                    © 2026 Light Ticket Platform JSC. All rights reserved.
                </footer>

            </main>
        </div>

        <!-- Bootstrap -->
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>

        <!-- Sidebar script -->
        <script>
                                                          (function () {

                                                              const sidebar =
                                                                      document.getElementById('adminSidebar');

                                                              const backdrop =
                                                                      document.getElementById('adminSidebarBackdrop');

                                                              const openButton =
                                                                      document.getElementById('adminSidebarOpen');

                                                              const closeButton =
                                                                      document.getElementById('adminSidebarClose');

                                                              if (!sidebar || !backdrop || !openButton || !closeButton) {
                                                                  return;
                                                              }

                                                              function openSidebar() {
                                                                  sidebar.classList.add('is-open');
                                                                  backdrop.classList.add('is-visible');

                                                                  openButton.setAttribute(
                                                                          'aria-expanded',
                                                                          'true'
                                                                          );
                                                              }

                                                              function closeSidebar() {
                                                                  sidebar.classList.remove('is-open');
                                                                  backdrop.classList.remove('is-visible');

                                                                  openButton.setAttribute(
                                                                          'aria-expanded',
                                                                          'false'
                                                                          );
                                                              }

                                                              openButton.addEventListener(
                                                                      'click',
                                                                      openSidebar
                                                                      );

                                                              closeButton.addEventListener(
                                                                      'click',
                                                                      closeSidebar
                                                                      );

                                                              backdrop.addEventListener(
                                                                      'click',
                                                                      closeSidebar
                                                                      );

                                                              document.addEventListener('keydown', function (event) {

                                                                  if (event.key === 'Escape') {
                                                                      closeSidebar();
                                                                  }

                                                              });

                                                          })();
        </script>

    </body>
</html>
