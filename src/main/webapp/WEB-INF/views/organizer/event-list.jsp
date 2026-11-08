<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<%-- Tổng hợp số liệu cho các thẻ thống kê --%>
<c:set var="allEvents" value="0"/>
<c:forEach var="entry" items="${statusCounts}">
    <c:set var="allEvents" value="${allEvents + entry.value}"/>
</c:forEach>
<c:set var="activeCount" value="${empty statusCounts['ACTIVE'] ? 0 : statusCounts['ACTIVE']}"/>
<c:set var="draftCount" value="${empty statusCounts['DRAFT'] ? 0 : statusCounts['DRAFT']}"/>
<c:set var="sumSold" value="${empty salesSummary ? 0 : salesSummary.ticketSold}"/>
<c:set var="sumTotal" value="${empty salesSummary ? 0 : salesSummary.ticketTotal}"/>
<c:set var="sumPct" value="${sumTotal > 0 ? sumSold * 100.0 / sumTotal : 0}"/>
<c:set var="rangeFrom" value="${totalEvents == 0 ? 0 : (page - 1) * pageSize + 1}"/>
<c:set var="rangeTo" value="${page * pageSize > totalEvents ? totalEvents : page * pageSize}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Quản lý sự kiện - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
        <style>
        /* Cột thao tác: tối đa 3 nút mỗi hàng để bảng không tràn ngang trên màn hình laptop */
        .lt-table .row-actions { flex-wrap: wrap; max-width: calc(36px * 3 + 0.4rem * 2); }
        .ev-cancel-form { border-radius: 12px; }
        .ev-cancel-form textarea { border: 1px solid #d4d4d8; border-radius: 8px; padding: 8px; font: inherit; width: 100%; }
        .ev-cancel-form textarea:focus { outline: none; border-color: #d93a27; box-shadow: 0 0 0 3px rgba(217, 58, 39, .18); }    </style>
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
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/organizer/_header.jsp">
            <jsp:param name="active" value="events"/>
            <jsp:param name="current" value="Không gian làm việc"/>
        </jsp:include>

        <main class="org-container org-main">

            <%-- Tiêu đề trang --%>
            <section class="org-card org-page-head">
                <div>
                    <h1 class="org-title">Quản lý sự kiện</h1>
                </div>
                <div class="org-head-actions">
                    <a class="btn-cta" href="${ctx}/organizer/event/create">
                        <i class="ph ph-plus-circle" aria-hidden="true"></i> Tạo sự kiện mới
                    </a>
                </div>
            </section>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success"><i class="ph ph-check-circle" aria-hidden="true"></i><span><c:out value="${successMessage}"/></span></div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="lt-alert error"><i class="ph ph-warning-circle" aria-hidden="true"></i><span><c:out value="${errorMessage}"/></span></div>
            </c:if>

            <%-- Thẻ thống kê --%>

            <%-- Thẻ thống kê: Bootstrap 5 --%>
            <section class="row g-3 mb-4">

                <%-- Tổng số sự kiện --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 h-100">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small fw-semibold text-secondary text-uppercase">
                                    Tổng số sự kiện
                                </span>
                                <span class="d-flex align-items-center justify-content-center rounded-4 p-2 bg-primary bg-opacity-10 text-danger">
                                    <i class="ph ph-buildings" aria-hidden="true"></i>
                                </span>
                            </div>

                            <div class="fs-2 fw-bold lh-1 text-dark mb-3">
                                <fmt:formatNumber value="${allEvents}" pattern="#,##0"/>
                            </div>

                            <div class="border-top pt-2 d-flex justify-content-between align-items-center">
                                <small class="text-secondary">Bản nháp</small>
                                <span class="badge rounded-pill bg-secondary bg-opacity-10 text-secondary">
                                    <fmt:formatNumber value="${draftCount}" pattern="#,##0"/>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Đang mở bán --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 h-100">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small fw-semibold text-secondary text-uppercase">
                                    Đang mở bán
                                </span>
                                <span class="d-flex align-items-center justify-content-center rounded-4 p-2 bg-danger bg-opacity-10 text-danger">
                                    <i class="ph ph-broadcast" aria-hidden="true"></i>
                                </span>
                            </div>

                            <div class="fs-2 fw-bold lh-1 text-danger mb-3">
                                <fmt:formatNumber value="${activeCount}" pattern="#,##0"/>
                            </div>

                            <div class="border-top pt-2 d-flex justify-content-between align-items-center">
                                <small class="text-secondary">Phòng vé mở</small>
                                <span class="badge rounded-pill bg-success bg-opacity-10 text-success">
                                    Đang bán
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Tổng vé đã xuất --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 h-100">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small fw-semibold text-secondary text-uppercase">
                                    Tổng vé đã xuất
                                </span>
                                <span class="d-flex align-items-center justify-content-center rounded-4 p-2 bg-danger bg-opacity-10 text-danger">
                                    <i class="ph ph-ticket" aria-hidden="true"></i>
                                </span>
                            </div>

                            <div class="d-flex align-items-baseline gap-1 mb-3">
                                <span class="fs-2 fw-bold lh-1 text-dark">
                                    <fmt:formatNumber value="${sumSold}" pattern="#,##0"/>
                                </span>
                                <small class="text-secondary">
                                    / <fmt:formatNumber value="${sumTotal}" pattern="#,##0"/> vé
                                </small>
                            </div>

                            <div class="progress rounded-pill mb-2" style="height:5px;">
                                <div class="progress-bar bg-danger"
                                     role="progressbar"
                                     style="width:${sumPct > 100 ? 100 : (sumPct < 0 ? 0 : sumPct)}%;"
                                     aria-valuenow="${sumPct}"
                                     aria-valuemin="0"
                                     aria-valuemax="100">
                                </div>
                            </div>

                            <small class="fw-semibold text-danger">
                                <fmt:formatNumber value="${sumPct}" pattern="0.0"/>%
                            </small>
                        </div>
                    </div>
                </div>

                <%-- Tổng doanh thu --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 h-100">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="small fw-semibold text-secondary text-uppercase">
                                    Tổng doanh thu
                                </span>
                                <span class="d-flex align-items-center justify-content-center rounded-4 p-2 bg-primary bg-opacity-10 text-danger">
                                    <i class="ph ph-money" aria-hidden="true"></i>
                                </span>
                            </div>

                            <div class="fs-3 fw-bold lh-sm text-danger mb-3">
                                <fmt:formatNumber
                                    value="${empty salesSummary ? 0 : salesSummary.revenue}"
                                    pattern="#,##0"/> đ
                            </div>

                            <div class="border-top pt-2">
                                <small class="text-secondary">Đối soát kỳ hạn 15d</small>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <%-- Tìm kiếm & lọc --%>
            <section class="org-card filter-bar">
                <form method="get" action="${ctx}/organizer/event/list">
                    <div class="lt-search">
                        <input type="text" name="keyword" class="lt-input" maxlength="200"
                               placeholder="Tìm theo tên sự kiện..." value="<c:out value='${keyword}'/>">
                    </div>
                    <select name="status" class="lt-input" style="width:auto;min-width:200px;" onchange="this.form.submit()">
                        <option value="">Tất cả trạng thái</option>
                        <c:forEach var="status" items="${statuses}">
                            <option value="${status}" ${selectedStatus == status ? 'selected' : ''}>
                                <c:choose>
                                    <c:when test="${status == 'ACTIVE'}">Đang mở bán</c:when>
                                    <c:when test="${status == 'DRAFT'}">Bản nháp (Draft)</c:when>
                                    <c:when test="${status == 'PENDING_APPROVAL'}">Chờ duyệt</c:when>
                                    <c:when test="${status == 'REJECTED'}">Bị từ chối</c:when>
                                    <c:when test="${status == 'CANCELLED'}">Đã hủy</c:when>
                                    <c:otherwise>${status}</c:otherwise>
                                </c:choose>
                            </option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn-soft"><i class="ph ph-sliders-horizontal" aria-hidden="true"></i> Lọc</button>
                    <c:if test="${not empty keyword or not empty selectedStatus}">
                        <a class="btn-ghost" href="${ctx}/organizer/event/list">Xóa lọc</a>
                    </c:if>
                </form>
            </section>

            <%-- Bảng sự kiện --%>
            <section class="org-card table-card">
                <div class="lt-table-wrap">
                    <table class="lt-table">
                        <thead>
                            <tr>
                                <th>Sự kiện</th>
                                <th>Thời gian &amp; Địa điểm</th>
                                <th>Trạng thái</th>
                                <th>Tiến độ vé</th>
                                <th style="text-align:right">Doanh thu tạm tính</th>
                                <th style="text-align:right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${events}">
                                <c:set var="modifiable" value="${e.status == 'DRAFT' || e.status == 'REJECTED'}"/>
                                <c:set var="soldOut" value="${e.status == 'ACTIVE' && e.ticketTotal > 0 && e.ticketSold >= e.ticketTotal}"/>
                                <c:set var="st" value="${e.startTime}"/>
                                <tr>
                                    <td>
                                        <div class="ev-cell">
                                            <c:choose>
                                                <c:when test="${not empty e.eventImage}">
                                                    <img class="ev-thumb" alt="" src="${ctx}/<c:out value='${e.eventImage}'/>">
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="ev-thumb"><i class="ph ph-image" aria-hidden="true"></i></span>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <span class="ev-cat"><c:out value="${e.categoryName}"/></span>
                                                <p class="ev-name"><c:out value="${e.eventName}"/></p>
                                                <div class="ev-code">Mã: <b>#EV-${fn:substring(st, 0, 4)}-<fmt:formatNumber value="${e.eventId}" pattern="000"/></b></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="ev-meta">
                                            <i class="ph ph-calendar" aria-hidden="true"></i>
                                            ${fn:substring(st, 8, 10)}/${fn:substring(st, 5, 7)}/${fn:substring(st, 0, 4)}
                                            <span class="t">(${fn:substring(st, 11, 16)})</span>
                                        </div>
                                        <div class="ev-meta muted">
                                            <i class="ph ph-map-pin" aria-hidden="true"></i>
                                            <span class="ev-venue" title="<c:out value='${e.venueName}'/>"><c:out value="${e.venueName}"/></span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${soldOut}"><span class="st-pill st-danger">Hết vé / Kết thúc</span></c:when>
                                            <c:when test="${e.status == 'ACTIVE'}"><span class="st-pill st-active">Đang mở bán</span></c:when>
                                            <c:when test="${e.status == 'PENDING_APPROVAL'}"><span class="st-pill st-pending">Chờ duyệt</span></c:when>
                                            <c:when test="${e.status == 'DRAFT'}"><span class="st-pill st-draft">Bản nháp (Draft)</span></c:when>
                                            <c:when test="${e.status == 'REJECTED'}"><span class="st-pill st-danger">Bị từ chối</span></c:when>
                                            <c:when test="${e.status == 'CANCELLED'}"><span class="st-pill st-danger" title="<c:out value='${e.cancellationReason}'/>">Đã hủy</span></c:when>
                                            <c:otherwise><span class="st-pill st-draft"><c:out value="${e.status}"/></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="tk-progress">
                                            <div class="tk-progress-top">
                                                <span>
                                                    <fmt:formatNumber value="${e.ticketSold}" pattern="#,##0"/>
                                                    /
                                                    <fmt:formatNumber value="${e.ticketTotal}" pattern="#,##0"/> vé
                                                </span>
                                                <span class="pct">
                                                    <fmt:formatNumber value="${e.soldPercent}" pattern="#,##0.##"/>%
                                                </span>
                                            </div>
                                            <div class="progress-slim ${soldOut ? 'full' : ''}"><span style="width:${e.soldPercent > 100 ? 100 : e.soldPercent}%"></span></div>
                                        </div>
                                    </td>
                                    <td class="rev-cell">
                                        <div class="amount"><fmt:formatNumber value="${e.revenue}" pattern="#,##0"/> đ</div>
                                        <div class="note">
                                            <c:choose>
                                                <c:when test="${e.status == 'DRAFT'}">Chưa phát hành</c:when>
                                                <c:when test="${e.ticketSold > 0}"><fmt:formatNumber value="${e.ticketSold}" pattern="#,##0"/> vé đã bán</c:when>
                                                <c:otherwise>Chưa có đơn hàng</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="row-actions">
                                            <a class="icon-action" title="Sơ đồ ghế" href="${ctx}/organizer/event/seatmap?eventId=${e.eventId}">
                                                <i class="ph ph-armchair" aria-hidden="true"></i>
                                            </a>
                                            <a class="icon-action" title="Báo cáo bán vé" href="${ctx}/organizer/event/report?eventId=${e.eventId}">
                                                <i class="ph ph-chart-bar" aria-hidden="true"></i>
                                            </a>
                                            <a class="icon-action" title="Phân công nhân viên" href="${ctx}/organizer/event/staff?eventId=${e.eventId}">
                                                <i class="ph ph-users-three" aria-hidden="true"></i>
                                            </a>
                                            <c:choose>
                                                <c:when test="${modifiable}">
                                                    <a class="icon-action" title="Chỉnh sửa" href="${ctx}/organizer/event/update?eventId=${e.eventId}">
                                                        <i class="ph ph-pencil-simple" aria-hidden="true"></i>
                                                    </a>
                                                    <form method="post" class="js-confirm-submit m-0" action="${ctx}/organizer/event/submit"
                                                          data-event-name="<c:out value='${e.eventName}'/>">
                                                        <input type="hidden" name="eventId" value="${e.eventId}">
                                                        <button type="submit" class="icon-action" title="Gửi Admin duyệt">
                                                            <i class="ph ph-paper-plane-tilt" aria-hidden="true"></i>
                                                        </button>
                                                    </form>
                                                    <form method="post" class="js-confirm-delete m-0" action="${ctx}/organizer/event/delete"
                                                          data-event-name="<c:out value='${e.eventName}'/>">
                                                        <input type="hidden" name="eventId" value="${e.eventId}">
                                                        <button type="submit" class="icon-action danger" title="Xóa sự kiện">
                                                            <i class="ph ph-trash" aria-hidden="true"></i>
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${e.status == 'ACTIVE'}">
                                                    <%-- Mở hộp thoại hủy (modal cuối trang) thay vì khung thả xuống trong bảng:
                                                         khung trong bảng có thanh cuộn bị cắt ở các hàng cuối. --%>
                                                    <button type="button" class="icon-action danger" title="Hủy sự kiện"
                                                            data-bs-toggle="modal" data-bs-target="#cancelEventModal"
                                                            data-event-id="${e.eventId}" data-event-name="<c:out value='${e.eventName}'/>">
                                                        <i class="ph ph-calendar-x" aria-hidden="true"></i>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="icon-action locked" title="Chỉ sự kiện nháp hoặc bị từ chối mới được sửa/xóa">
                                                        <i class="ph ph-lock" aria-hidden="true"></i>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty events}">
                                <tr>
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <i class="ph ph-calendar-x" aria-hidden="true"></i>
                                            <p class="mb-1 fw-bold text-dark">Chưa có sự kiện nào</p>
                                            <p class="mb-3 small">Hãy tạo sự kiện đầu tiên để bắt đầu mở bán vé.</p>
                                            <a class="btn-cta" href="${ctx}/organizer/event/create"><i class="ph ph-plus-circle" aria-hidden="true"></i> Tạo sự kiện mới</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="table-foot">
                    <c:if test="${totalPages > 1}">
                        <c:url var="pageBase" value="/organizer/event/list">
                            <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                            <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                        </c:url>
                        <c:set var="joiner" value="${fn:contains(pageBase, '?') ? '&' : '?'}"/>
                        <nav class="pager" aria-label="Phân trang">
                            <a class="${page <= 1 ? 'disabled' : ''}" href="${pageBase}${joiner}page=${page - 1}" aria-label="Trang trước"><i class="ph ph-caret-left" style="font-size:20px" aria-hidden="true"></i></a>
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <a class="${i == page ? 'active' : ''}" href="${pageBase}${joiner}page=${i}">${i}</a>
                            </c:forEach>
                            <a class="${page >= totalPages ? 'disabled' : ''}" href="${pageBase}${joiner}page=${page + 1}" aria-label="Trang sau"><i class="ph ph-caret-right" style="font-size:20px" aria-hidden="true"></i></a>
                        </nav>
                    </c:if>
                </div>
            </section>
        </main>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>

        <!-- Hộp thoại hủy sự kiện: dùng chung cho mọi hàng, eventId được gán khi mở -->
        <div class="modal fade" id="cancelEventModal" tabindex="-1" aria-labelledby="cancelEventTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <form method="post" action="${ctx}/organizer/event/cancel" class="modal-content ev-cancel-form">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <input type="hidden" name="eventId" id="cancelEventId" value="">
                    <div class="modal-header">
                        <h2 class="modal-title h5 fw-bold" id="cancelEventTitle">Hủy sự kiện</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                    </div>
                    <div class="modal-body d-grid gap-2">
                        <p class="mb-1">Bạn sắp hủy <b id="cancelEventName"></b>. Thao tác này không thể hoàn tác.</p>
                        <label class="small fw-semibold" for="cancelReason">Lý do hủy sự kiện <span class="text-danger">*</span></label>
                        <textarea id="cancelReason" name="reason" rows="4" maxlength="1000" required
                                  placeholder="VD: Nghệ sĩ không thể tham gia, thời tiết xấu..."></textarea>
                        <small class="text-muted">Chỉ hủy được khi chưa có đơn hàng đã thanh toán.</small>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-danger">Xác nhận hủy</button>
                    </div>
                </form>
            </div>
        </div>

        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
        <script>
            (function () {
                var modal = document.getElementById('cancelEventModal');
                if (!modal) return;
                modal.addEventListener('show.bs.modal', function (e) {
                    var btn = e.relatedTarget;
                    document.getElementById('cancelEventId').value = btn ? btn.getAttribute('data-event-id') : '';
                    document.getElementById('cancelEventName').textContent = btn ? btn.getAttribute('data-event-name') : '';
                    document.getElementById('cancelReason').value = '';
                });
                modal.addEventListener('shown.bs.modal', function () {
                    document.getElementById('cancelReason').focus();
                });
            })();
        </script>
    </body>
</html>
