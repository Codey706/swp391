
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Event" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="adminName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Admin'}"/>
<c:set var="adminInitial" value="${fn:toUpperCase(fn:substring(adminName, 0, 1))}"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Event Details - Light Ticket</title>


        <link rel="stylesheet" href="${ctx}/assets/css/bootstrap.css">
        <link rel="stylesheet" href="${ctx}/css/admin.css?v=7">

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

                    <a href="${ctx}/admin/events"
                       class="is-active"
                       aria-current="page">
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
                    <span class="admin-breadcrumb-current">Event Details</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <main class="admin-content">
                <section class="content">
                    <div class="event-detail-header">
                        <div>
                            <a class="event-back-link" href="${ctx}/admin/events"><i class="ph ph-arrow-left"></i> Back to Manage Events</a>
                            <h1>Event Details</h1>
                            <p>Review all submitted information before making an approval decision.</p>
                        </div>
                        <span class="event-status"><c:out value="${event.status}"/></span>
                    </div>
                    <c:if test="${param.success == 'approved' || param.success == 'rejected'}">
                        <div class="event-alert event-alert-success" role="status">Event decision saved successfully.</div>
                    </c:if>
                    <c:if test="${param.error == 'action_failed'}">
                        <div class="event-alert event-alert-error" role="alert">This event is no longer pending approval.</div>
                    </c:if>
                    <c:if test="${param.error == 'reason_required' || param.error == 'reason_too_long'}">
                        <div class="event-alert event-alert-error" role="alert">Please provide a rejection reason (maximum 1000 characters).</div>
                    </c:if>
                    <div class="event-detail-layout">
                        <div class="event-detail-main">
                            <section class="event-detail-panel">
                                <c:if test="${not empty event.eventImage}">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(event.eventImage, 'http://') || fn:startsWith(event.eventImage, 'https://')}">
                                            <img class="event-detail-banner" src="<c:out value='${event.eventImage}'/>" alt="Event cover"/>
                                        </c:when>
                                        <c:otherwise>
                                            <img class="event-detail-banner" src="${ctx}/<c:out value='${fn:replace(event.eventImage, "/", "/")}'/>" alt="Event cover"/>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>
                                <div class="event-detail-pad">
                                    <p class="event-detail-overline">EVENT #<c:out value="${event.eventId}"/></p>
                                    <h2><c:out value="${event.eventName}"/></h2>
                                    <h3>Description</h3>
                                    <p class="event-detail-description"><c:out value="${event.description}" default="No description provided."/></p>
                                </div>
                            </section>
                            <section class="event-detail-panel event-detail-pad">
                                <h3>Ticket categories</h3>
                                <div class="event-detail-table-scroll">
                                    <table class="event-detail-ticket-table">
                                        <thead><tr><th>Ticket type</th><th>Price (VND)</th><th>Quantity</th><th>Available</th><th>Status</th></tr></thead>
                                        <tbody>
                                        <c:forEach var="ticket" items="${tickets}">
                                            <tr><td><strong><c:out value="${ticket.ticketName}"/></strong><c:if test="${not empty ticket.description}"><small><c:out value="${ticket.description}"/></small></c:if></td>
                                            <td><c:out value="${ticket.price}"/></td><td><c:out value="${ticket.quantity}"/></td><td><c:out value="${ticket.availableQuantity}"/></td><td><c:out value="${ticket.status}"/></td></tr>
                                        </c:forEach>
                                        <c:if test="${empty tickets}"><tr><td colspan="5">No ticket categories provided.</td></tr></c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </section>
                        </div>
                        <aside class="event-detail-side">
                            <section class="event-detail-panel event-detail-pad">
                                <h3>Event information</h3>
                                <dl class="event-detail-facts">
                                    <dt>Category</dt><dd><c:out value="${event.categoryName}"/></dd>
                                    <dt>Venue</dt><dd><c:out value="${event.venueName}"/></dd>
                                    <dt>Start time</dt><dd><c:out value="${fn:replace(event.startTime, 'T', ' ')}"/></dd>
                                    <dt>End time</dt><dd><c:out value="${fn:replace(event.endTime, 'T', ' ')}"/></dd>
                                    <dt>Total tickets</dt><dd><c:out value="${event.ticketTotal}"/></dd>
                                    <dt>Organizer ID</dt><dd>#<c:out value="${event.organizerId}"/></dd>
                                    <c:if test="${not empty organizer}">
                                        <dt>Organizer name</dt><dd><c:out value="${organizer[1]}"/></dd>
                                        <dt>Organizer email</dt><dd><c:out value="${organizer[0]}"/></dd>
                                    </c:if>
                                    <dt>Submitted / created</dt><dd><c:out value="${fn:replace(event.createdAt, 'T', ' ')}"/></dd>
                                </dl>
                            </section>
                            <c:if test="${event.status == 'PENDING_APPROVAL'}">
                                <section class="event-detail-panel event-detail-pad">
                                    <h3>Approval decision</h3>
                                    <p class="event-detail-hint">Check the description, venue, schedule and ticket categories before deciding.</p>
                                    <div class="event-detail-decisions">
                                        <form method="post" action="${ctx}/admin/events" onsubmit="return confirm('Approve this event?');">
                                            <input type="hidden" name="action" value="approve"/>
                                            <input type="hidden" name="eventId" value="${event.eventId}"/>
                                            <input type="hidden" name="returnTo" value="detail"/>
                                            <button type="submit" class="event-btn event-btn-approve">Approve event</button>
                                        </form>
                                        <button type="button" class="event-btn event-btn-reject" id="showRejectReason">Reject event</button>
                                    </div>
                                    <form id="detailRejectForm" class="event-detail-reject-form" method="post" action="${ctx}/admin/events" hidden>
                                        <input type="hidden" name="action" value="reject"/>
                                        <input type="hidden" name="eventId" value="${event.eventId}"/>
                                        <input type="hidden" name="returnTo" value="detail"/>
                                        <label for="detailRejectReason">Rejection reason <span class="event-req">*</span></label>
                                        <textarea id="detailRejectReason" name="reason" rows="4" maxlength="1000" required placeholder="Explain what needs to be corrected..."></textarea>
                                        <button type="submit" class="event-btn event-btn-reject-solid">Confirm rejection</button>
                                    </form>
                                </section>
                            </c:if>
                            <c:if test="${event.status == 'REJECTED'}">
                                <section class="event-detail-panel event-detail-pad"><h3>Rejection reason</h3><p class="event-detail-description"><c:out value="${event.cancellationReason}"/></p></section>
                            </c:if>
                        </aside>
                    </div>
                </section>
                <footer class="admin-page-footer">© 2026 Light Ticket Platform JSC. All rights reserved.</footer>
            </main>
        </div>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>

        <script>
                                            (function () {
                                                var btn = document.getElementById('showRejectReason');
                                                var form = document.getElementById('detailRejectForm');
                                                if (btn && form)
                                                    btn.addEventListener('click', function () {
                                                        form.hidden = !form.hidden;
                                                        if (!form.hidden)
                                                            document.getElementById('detailRejectReason').focus();
                                                    });
                                            }());
        </script>
        <script>
            (function () {
                var sidebar = document.getElementById('adminSidebar');
                var backdrop = document.getElementById('adminSidebarBackdrop');
                var openButton = document.getElementById('adminSidebarOpen');
                var closeButton = document.getElementById('adminSidebarClose');
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
                document.addEventListener('keydown', function (e) {
                    if (e.key === 'Escape')
                        closeSidebar();
                });
            }());
        </script>
    </body>
</html>
