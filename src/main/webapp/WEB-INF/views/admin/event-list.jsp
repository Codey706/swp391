
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
        <title>Manage Events - Light Ticket</title>


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
                    <span class="admin-breadcrumb-current">Manage Events</span>
                </div>

                <div class="admin-system-label">
                    <span class="admin-system-dot"></span>
                    Light Ticket Management System
                </div>
            </div>

            <!-- Nội dung Manage Events -->
            <main class="admin-content">
                <section class="content">

                    <div class="event-page-heading">
                        <div>
                            <h1>Manage Events</h1>
                            <p>Review and approve events submitted by organizers.</p>
                        </div>

                        <div class="event-count">
                            <i class="ph ph-hourglass" aria-hidden="true"></i>
                            <span>${totalEvents} Pending Approval</span>
                        </div>
                    </div>

                    <!-- Thông báo thành công -->
                    <c:if test="${param.success == 'approved'}">
                        <div class="event-alert event-alert-success" role="status">
                            <i class="ph ph-check-circle" style="vertical-align: middle;" aria-hidden="true"></i>
                            Sự kiện đã được duyệt thành công.
                        </div>
                    </c:if>

                    <c:if test="${param.success == 'rejected'}">
                        <div class="event-alert event-alert-success" role="status">
                            <i class="ph ph-check-circle" style="vertical-align: middle;" aria-hidden="true"></i>
                            Sự kiện đã bị từ chối và lý do đã được lưu.
                        </div>
                    </c:if>

                    <!-- Thông báo lỗi -->
                    <c:if test="${param.error == 'reason_required'}">
                        <div class="event-alert event-alert-error" role="alert">
                            Vui lòng nhập lý do từ chối sự kiện.
                        </div>
                    </c:if>

                    <c:if test="${param.error == 'reason_too_long'}">
                        <div class="event-alert event-alert-error" role="alert">
                            Lý do từ chối không được vượt quá 1000 ký tự.
                        </div>
                    </c:if>

                    <c:if test="${param.error == 'action_failed'}">
                        <div class="event-alert event-alert-error" role="alert">
                            Không thể thực hiện thao tác. Sự kiện có thể không còn ở trạng thái chờ duyệt.
                        </div>
                    </c:if>

                    <!-- Danh sách sự kiện -->
                    <div class="event-table-card">

                        <c:choose>
                            <c:when test="${empty events}">
                                <div class="event-empty">
                                    <i class="ph ph-calendar-check" aria-hidden="true"></i>
                                    <h3>Không có sự kiện chờ duyệt</h3>
                                    <p>Các sự kiện Organizer gửi lên sẽ xuất hiện tại đây.</p>
                                </div>
                            </c:when>

                            <c:otherwise>
                                <div class="event-table-scroll">
                                    <table class="event-table">
                                        <thead>
                                            <tr>
                                                <th>Event</th>
                                                <th>Organizer ID</th>
                                                <th>Category</th>
                                                <th>Venue</th>
                                                <th>Time</th>
                                                <th>Tickets</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>

                                        <tbody>
                                            <c:forEach var="event" items="${events}">
                                                <tr>
                                                    <td data-label="Event">
                                                        <div class="event-id">
                                                            ID: #<c:out value="${event.eventId}"/>
                                                        </div>
                                                        <div class="event-name">
                                                            <c:out value="${event.eventName}"/>
                                                        </div>
                                                    </td>

                                                    <td data-label="Organizer ID">
                                                        #<c:out value="${event.organizerId}"/>
                                                    </td>

                                                    <td data-label="Category">
                                                        <c:out value="${event.categoryName}"/>
                                                    </td>

                                                    <td data-label="Venue">
                                                        <c:out value="${event.venueName}"/>
                                                    </td>

                                                    <td data-label="Time" class="event-time">
                                                        <span><small>Start</small><c:out value="${fn:replace(event.startTime, 'T', ' ')}"/></span>
                                                        <span><small>End</small><c:out value="${fn:replace(event.endTime, 'T', ' ')}"/></span>
                                                    </td>

                                                    <td data-label="Tickets">
                                                        <c:out value="${event.ticketTotal}"/>
                                                    </td>

                                                    <td data-label="Status">
                                                        <span class="event-status">
                                                            <c:out value="${event.status}"/>
                                                        </span>
                                                    </td>

                                                    <td data-label="Actions" class="event-actions">
                                                        <div class="event-action-buttons">

                                                            <a class="event-btn event-btn-view" href="${ctx}/admin/events?id=${event.eventId}">
                                                                <i class="ph ph-eye" aria-hidden="true"></i>
                                                                View
                                                            </a>

                                                            <!-- Duyệt sự kiện -->
                                                            <form action="${ctx}/admin/events"
                                                                  method="post"
                                                                  onsubmit="return confirm('Bạn có chắc muốn duyệt sự kiện này không?');">
                                                                <input type="hidden" name="action" value="approve">
                                                                <input type="hidden" name="eventId" value="${event.eventId}">
                                                                <button type="submit"
                                                                        class="event-btn event-btn-approve">
                                                                    <i class="ph ph-check-circle" aria-hidden="true"></i>
                                                                    Approve
                                                                </button>
                                                            </form>

                                                            <!-- Từ chối: mở modal nhập lý do -->
                                                            <button type="button"
                                                                    class="event-btn event-btn-reject"
                                                                    data-reject-event
                                                                    data-event-id="${event.eventId}"
                                                                    data-event-name="<c:out value='${event.eventName}'/>">
                                                                <i class="ph ph-x-circle" aria-hidden="true"></i>
                                                                Reject
                                                            </button>

                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Phân trang -->
                                <div class="event-pagination">
                                    <div class="event-pagination-info">
                                        Trang ${currentPage}
                                        <c:if test="${totalPages > 0}">
                                            / ${totalPages}
                                        </c:if>
                                        · Tổng ${totalEvents} sự kiện đang chờ duyệt
                                    </div>

                                    <c:if test="${totalPages > 1}">
                                        <div class="event-pagination-links">

                                            <a href="${ctx}/admin/events?page=${currentPage - 1}"
                                               class="event-page-link ${currentPage <= 1 ? 'is-disabled' : ''}"
                                               aria-label="Trang trước">
                                                <i class="ph ph-caret-left" aria-hidden="true"></i>
                                            </a>

                                            <c:forEach var="p" begin="1" end="${totalPages}">
                                                <a href="${ctx}/admin/events?page=${p}"
                                                   class="event-page-link ${p == currentPage ? 'is-current' : ''}"
                                                   <c:if test="${p == currentPage}">aria-current="page"</c:if>>
                                                    ${p}
                                                </a>
                                            </c:forEach>

                                            <a href="${ctx}/admin/events?page=${currentPage + 1}"
                                               class="event-page-link ${currentPage >= totalPages ? 'is-disabled' : ''}"
                                               aria-label="Trang sau">
                                                <i class="ph ph-caret-right" aria-hidden="true"></i>
                                            </a>

                                        </div>
                                    </c:if>
                                </div>
                            </c:otherwise>
                        </c:choose>

                    </div>
                </section>

                <!-- Modal nhập lý do từ chối (bắt buộc, tối đa 1000 ký tự) -->
                <div class="event-modal" id="rejectModal" role="dialog" aria-modal="true" aria-labelledby="rejectModalTitle" hidden>
                    <div class="event-modal-backdrop" data-reject-close></div>
                    <form class="event-modal-dialog" action="${ctx}/admin/events" method="post" id="rejectForm" novalidate>
                        <input type="hidden" name="action" value="reject">
                        <input type="hidden" name="eventId" id="rejectEventId" value="">

                        <div class="event-modal-head">
                            <div>
                                <h2 id="rejectModalTitle">Từ chối sự kiện</h2>
                                <p id="rejectEventName"></p>
                            </div>
                            <button type="button" class="event-modal-close" data-reject-close aria-label="Đóng">
                                <i class="ph ph-x" aria-hidden="true"></i>
                            </button>
                        </div>

                        <label class="event-modal-label" for="rejectReason">
                            Lý do từ chối <span class="event-req">*</span>
                        </label>
                        <textarea id="rejectReason" name="reason" rows="5" maxlength="1000" required
                                  aria-describedby="rejectReasonHelp rejectReasonError"
                                  placeholder="Nêu rõ lý do để Organizer chỉnh sửa và gửi duyệt lại..."></textarea>
                        <div class="event-modal-help">
                            <span id="rejectReasonError" class="event-modal-error" role="alert"></span>
                            <span id="rejectReasonHelp"><span id="rejectReasonCount">0</span>/1000 ký tự</span>
                        </div>

                        <div class="event-modal-actions">
                            <button type="button" class="event-btn event-btn-ghost" data-reject-close>Hủy</button>
                            <button type="submit" class="event-btn event-btn-reject-solid">
                                <i class="ph ph-x-circle" aria-hidden="true"></i>
                                Xác nhận từ chối
                            </button>
                        </div>
                    </form>
                </div>

                <footer class="admin-page-footer">
                    © 2026 Light Ticket Platform JSC. All rights reserved.
                </footer>
            </main>
        </div>

        <!-- Bootstrap JS dùng cho dropdown -->
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>

        <!-- Modal từ chối sự kiện -->
        <script>
                                                                      (function () {
                                                                          var modal = document.getElementById('rejectModal');
                                                                          if (!modal) {
                                                                              return;
                                                                          }
                                                                          var form = document.getElementById('rejectForm');
                                                                          var reason = document.getElementById('rejectReason');
                                                                          var count = document.getElementById('rejectReasonCount');
                                                                          var error = document.getElementById('rejectReasonError');
                                                                          var MAX = 1000;
                                                                          var opener = null;

                                                                          function setError(message) {
                                                                              error.textContent = message || '';
                                                                              reason.classList.toggle('is-invalid', !!message);
                                                                              reason.setAttribute('aria-invalid', message ? 'true' : 'false');
                                                                          }
                                                                          function updateCount() {
                                                                              count.textContent = reason.value.length;
                                                                          }
                                                                          function open(button) {
                                                                              opener = button;
                                                                              document.getElementById('rejectEventId').value = button.getAttribute('data-event-id');
                                                                              document.getElementById('rejectEventName').textContent =
                                                                                      '#' + button.getAttribute('data-event-id') + ' · ' + (button.getAttribute('data-event-name') || '');
                                                                              reason.value = '';
                                                                              setError('');
                                                                              updateCount();
                                                                              modal.hidden = false;
                                                                              document.body.classList.add('event-modal-open');
                                                                              reason.focus();
                                                                          }
                                                                          function close() {
                                                                              modal.hidden = true;
                                                                              document.body.classList.remove('event-modal-open');
                                                                              if (opener) {
                                                                                  opener.focus();
                                                                              }
                                                                          }

                                                                          document.querySelectorAll('[data-reject-event]').forEach(function (button) {
                                                                              button.addEventListener('click', function () {
                                                                                  open(button);
                                                                              });
                                                                          });
                                                                          modal.querySelectorAll('[data-reject-close]').forEach(function (el) {
                                                                              el.addEventListener('click', close);
                                                                          });
                                                                          document.addEventListener('keydown', function (e) {
                                                                              if (e.key === 'Escape' && !modal.hidden) {
                                                                                  close();
                                                                              }
                                                                          });
                                                                          reason.addEventListener('input', function () {
                                                                              updateCount();
                                                                              if (error.textContent) {
                                                                                  setError('');
                                                                              }
                                                                          });
                                                                          form.addEventListener('submit', function (e) {
                                                                              var value = reason.value.trim();
                                                                              if (!value) {
                                                                                  e.preventDefault();
                                                                                  setError('Vui lòng nhập lý do từ chối sự kiện.');
                                                                                  reason.focus();
                                                                              } else if (value.length > MAX) {
                                                                                  e.preventDefault();
                                                                                  setError('Lý do từ chối không được vượt quá 1000 ký tự.');
                                                                                  reason.focus();
                                                                              }
                                                                          });
                                                                      })();
        </script>

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
