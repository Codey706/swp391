<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<%-- Tổng hợp số liệu --%>
<c:set var="allEvents" value="0"/>
<c:forEach var="entry" items="${statusCounts}">
    <c:set var="allEvents" value="${allEvents + entry.value}"/>
</c:forEach>
<c:set var="activeCount" value="${empty statusCounts['ACTIVE'] ? 0 : statusCounts['ACTIVE']}"/>
<c:set var="sumSold" value="${empty salesSummary ? 0 : salesSummary.ticketSold}"/>
<c:set var="sumTotal" value="${empty salesSummary ? 0 : salesSummary.ticketTotal}"/>
<c:set var="sumLeft" value="${sumTotal - sumSold}"/>
<c:set var="sumPct" value="${sumTotal > 0 ? sumSold * 100.0 / sumTotal : 0}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Tổng quan - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
        <link rel="stylesheet" href="${ctx}/assets/css/organizer-dashboard.css">
    </head>
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/organizer/_header.jsp">
            <jsp:param name="active" value="dashboard"/>
            <jsp:param name="current" value="Tổng quan"/>
        </jsp:include>

        <main class="org-container org-main">

            <%-- Banner chào mừng --%>
            <section class="org-card org-page-head dash-welcome">
                <div class="d-flex align-items-center gap-3">
                    <span class="dash-welcome-icon"><span class="material-symbols-outlined">event_available</span></span>
                    <div>
                        <h1 class="org-title">Chào mừng trở lại, <c:out value="${orgName}"/>!</h1>
                        <p class="text-secondary small mb-0">Theo dõi hiệu quả và quản lý các sự kiện của bạn tại đây.</p>
                    </div>
                </div>
                <div class="org-head-actions">
                    <a class="btn-cta" href="${ctx}/organizer/event/create">
                        <span class="material-symbols-outlined">add_circle</span> Tạo sự kiện mới
                    </a>
                </div>
            </section>

            <%-- 4 thẻ thống kê --%>
            <section class="row g-3 mb-3">

                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="dash-stat">
                        <div class="dash-stat-top">
                            <span class="dash-stat-label">Tổng doanh thu</span>
                            <span class="dash-stat-icon"><span class="material-symbols-outlined">payments</span></span>
                        </div>
                        <div class="dash-stat-value"><fmt:formatNumber value="${empty salesSummary ? 0 : salesSummary.revenue}" pattern="#,##0"/> đ</div>
                        <div class="dash-stat-foot">
                            <c:choose>
                                <c:when test="${revenueChange == null}">Chưa có dữ liệu kỳ trước</c:when>
                                <c:otherwise>
                                    <span class="dash-trend ${revenueChange >= 0 ? 'up' : 'down'}">
                                        <span class="material-symbols-outlined">${revenueChange >= 0 ? 'arrow_drop_up' : 'arrow_drop_down'}</span><fmt:formatNumber value="${revenueChange < 0 ? -revenueChange : revenueChange}" pattern="0.#"/>%
                                    </span>
                                    so với ${periodDays} ngày trước
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="dash-stat">
                        <div class="dash-stat-top">
                            <span class="dash-stat-label">Vé đã bán</span>
                            <span class="dash-stat-icon"><span class="material-symbols-outlined">confirmation_number</span></span>
                        </div>
                        <div class="dash-stat-value"><fmt:formatNumber value="${sumSold}" pattern="#,##0"/></div>
                        <div class="dash-stat-foot">
                            <c:choose>
                                <c:when test="${soldChange == null}">Chưa có dữ liệu kỳ trước</c:when>
                                <c:otherwise>
                                    <span class="dash-trend ${soldChange >= 0 ? 'up' : 'down'}">
                                        <span class="material-symbols-outlined">${soldChange >= 0 ? 'arrow_drop_up' : 'arrow_drop_down'}</span><fmt:formatNumber value="${soldChange < 0 ? -soldChange : soldChange}" pattern="0.#"/>%
                                    </span>
                                    so với ${periodDays} ngày trước
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <a class="dash-stat is-link" href="${ctx}/organizer/event/list">
                        <div class="dash-stat-top">
                            <span class="dash-stat-label">Sự kiện của tôi</span>
                            <span class="dash-stat-icon"><span class="material-symbols-outlined">calendar_month</span></span>
                        </div>
                        <div class="dash-stat-value"><fmt:formatNumber value="${allEvents}" pattern="#,##0"/></div>
                        <div class="dash-stat-foot"><fmt:formatNumber value="${activeCount}" pattern="#,##0"/> sự kiện đang mở bán</div>
                    </a>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="dash-stat">
                        <div class="dash-stat-top">
                            <span class="dash-stat-label">Đơn hàng</span>
                            <span class="dash-stat-icon"><span class="material-symbols-outlined">shopping_bag</span></span>
                        </div>
                        <div class="dash-stat-value"><fmt:formatNumber value="${orderTotal}" pattern="#,##0"/></div>
                        <div class="dash-stat-foot"><fmt:formatNumber value="${orderPending}" pattern="#,##0"/> đơn đang chờ xử lý</div>
                    </div>
                </div>
            </section>

            <%-- Hàng 1: biểu đồ doanh thu + tình hình bán vé --%>
            <div class="row g-3 mb-3">
                <div class="col-12 col-xl-8">
                    <section class="dash-card">
                        <div class="dash-card-head">
                            <div>
                                <h2 class="dash-card-title">Doanh thu</h2>
                                <span class="dash-card-sub">Chỉ tính các đơn đã thanh toán</span>
                            </div>
                            <div class="dash-range" role="group" aria-label="Khoảng thời gian">
                                <button type="button" class="btn js-range active" data-range="7">7 ngày</button>
                                <button type="button" class="btn js-range" data-range="30">30 ngày</button>
                                <button type="button" class="btn js-range" data-range="90">90 ngày</button>
                            </div>
                        </div>
                        <div class="dash-chart-box">
                            <canvas id="revenueChart" data-labels='${chartLabels}' data-values='${chartValues}'></canvas>
                        </div>
                    </section>
                </div>

                <div class="col-12 col-xl-4">
                    <section class="dash-card">
                        <div class="dash-card-head">
                            <div>
                                <h2 class="dash-card-title">Tình hình bán vé</h2>
                                <span class="dash-card-sub">Tổng hợp tất cả sự kiện</span>
                            </div>
                        </div>
                        <div class="dash-donut" style="--pct:${sumPct}">
                            <div class="dash-donut-inner">
                                <span class="dash-donut-pct"><fmt:formatNumber value="${sumPct}" pattern="0.#"/>%</span>
                                <small class="text-secondary">Đã bán</small>
                            </div>
                        </div>
                        <ul class="dash-legend">
                            <li><span><span class="dash-dot" style="background:#c5cbd8"></span>Tổng số vé</span><b><fmt:formatNumber value="${sumTotal}" pattern="#,##0"/></b></li>
                            <li><span><span class="dash-dot" style="background:var(--primary-orange)"></span>Đã bán</span><b><fmt:formatNumber value="${sumSold}" pattern="#,##0"/></b></li>
                            <li><span><span class="dash-dot" style="background:#eef1f8"></span>Còn lại</span><b><fmt:formatNumber value="${sumLeft}" pattern="#,##0"/></b></li>
                        </ul>
                    </section>
                </div>
            </div>

            <%-- Hàng 2: sự kiện của tôi + hoạt động gần đây --%>
            <div class="row g-3 mb-3">
                <div class="col-12 col-xl-8">
                    <section class="dash-card is-flush">
                        <div class="dash-card-head">
                            <h2 class="dash-card-title">Sự kiện của tôi</h2>
                            <a class="dash-link" href="${ctx}/organizer/event/list">Xem tất cả</a>
                        </div>
                        <div class="lt-table-wrap">
                            <table class="lt-table">
                                <thead>
                                    <tr>
                                        <th>Sự kiện</th>
                                        <th>Thời gian</th>
                                        <th>Vé đã bán</th>
                                        <th style="text-align:right">Doanh thu</th>
                                        <th>Trạng thái</th>
                                        <th style="text-align:right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="e" items="${recentEvents}">
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
                                                            <span class="ev-thumb"><span class="material-symbols-outlined">image</span></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <p class="ev-name"><c:out value="${e.eventName}"/></p>
                                                        <span class="ev-cat"><c:out value="${e.categoryName}"/></span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="ev-meta">${fn:substring(st, 11, 16)} - ${fn:substring(st, 8, 10)}/${fn:substring(st, 5, 7)}/${fn:substring(st, 0, 4)}</div>
                                            </td>
                                            <td>
                                                <div class="tk-progress">
                                                    <div class="tk-progress-top">
                                                        <span><fmt:formatNumber value="${e.ticketSold}" pattern="#,##0"/> / <fmt:formatNumber value="${e.ticketTotal}" pattern="#,##0"/></span>
                                                    </div>
                                                    <div class="progress-slim ${soldOut ? 'full' : ''}"><span style="width:${e.soldPercent > 100 ? 100 : e.soldPercent}%"></span></div>
                                                </div>
                                            </td>
                                            <td class="rev-cell">
                                                <div class="amount"><fmt:formatNumber value="${e.revenue}" pattern="#,##0"/> đ</div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${soldOut}"><span class="st-pill st-danger">Hết vé</span></c:when>
                                                    <c:when test="${e.status == 'ACTIVE'}"><span class="st-pill st-active">Đang mở bán</span></c:when>
                                                    <c:when test="${e.status == 'PENDING_APPROVAL'}"><span class="st-pill st-pending">Chờ duyệt</span></c:when>
                                                    <c:when test="${e.status == 'DRAFT'}"><span class="st-pill st-draft">Bản nháp</span></c:when>
                                                    <c:when test="${e.status == 'REJECTED'}"><span class="st-pill st-danger">Bị từ chối</span></c:when>
                                                    <c:when test="${e.status == 'CANCELLED'}"><span class="st-pill st-danger">Đã hủy</span></c:when>
                                                    <c:otherwise><span class="st-pill st-draft"><c:out value="${e.status}"/></span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <a class="icon-action" title="Sơ đồ ghế" href="${ctx}/organizer/event/seatmap?eventId=${e.eventId}">
                                                        <span class="material-symbols-outlined">event_seat</span>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty recentEvents}">
                                        <tr>
                                            <td colspan="6">
                                                <div class="empty-state">
                                                    <span class="material-symbols-outlined">event_busy</span>
                                                    <p class="mb-1 fw-bold text-dark">Chưa có sự kiện nào</p>
                                                    <p class="mb-3 small">Hãy tạo sự kiện đầu tiên để bắt đầu mở bán vé.</p>
                                                    <a class="btn-cta" href="${ctx}/organizer/event/create"><span class="material-symbols-outlined">add_circle</span> Tạo sự kiện mới</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>

                <div class="col-12 col-xl-4">
                    <section class="dash-card">
                        <div class="dash-card-head">
                            <h2 class="dash-card-title">Hoạt động gần đây</h2>
                        </div>
                        <c:forEach var="a" items="${activities}">
                            <c:set var="ut" value="${a.updatedAt}"/>
                            <div class="dash-tl-item">
                                <span class="dash-activity-icon">
                                    <span class="material-symbols-outlined">
                                        <c:choose>
                                            <c:when test="${a.status == 'ACTIVE'}">verified</c:when>
                                            <c:when test="${a.status == 'PENDING_APPROVAL'}">hourglass_top</c:when>
                                            <c:when test="${a.status == 'DRAFT'}">edit_note</c:when>
                                            <c:otherwise>event_busy</c:otherwise>
                                        </c:choose>
                                    </span>
                                </span>
                                <div>
                                    <div class="dash-tl-text">
                                        Sự kiện <c:out value="${a.eventName}"/>
                                        <c:choose>
                                            <c:when test="${a.status == 'ACTIVE'}">đã được duyệt, đang mở bán</c:when>
                                            <c:when test="${a.status == 'PENDING_APPROVAL'}">đang chờ duyệt</c:when>
                                            <c:when test="${a.status == 'DRAFT'}">đang ở bản nháp</c:when>
                                            <c:when test="${a.status == 'REJECTED'}">bị từ chối</c:when>
                                            <c:when test="${a.status == 'CANCELLED'}">đã bị hủy</c:when>
                                            <c:otherwise>đã được cập nhật</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <span class="dash-tl-time">${fn:substring(ut, 11, 16)} - ${fn:substring(ut, 8, 10)}/${fn:substring(ut, 5, 7)}/${fn:substring(ut, 0, 4)}</span>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty activities}">
                            <p class="small text-secondary mb-0">Chưa có hoạt động nào.</p>
                        </c:if>
                    </section>
                </div>
            </div>

            <%-- Hàng 3: đơn hàng gần đây (toàn chiều rộng) --%>
            <section class="dash-card is-flush">
                <div class="dash-card-head">
                    <h2 class="dash-card-title">Đơn hàng gần đây</h2>
                </div>
                <div class="lt-table-wrap">
                    <table class="lt-table">
                        <thead>
                            <tr>
                                <th>Mã đơn hàng</th>
                                <th>Khách hàng</th>
                                <th>Sự kiện</th>
                                <th>Số lượng vé</th>
                                <th style="text-align:right">Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Thời gian</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${recentOrders}">
                                <c:set var="ot" value="${o.createdAt}"/>
                                <tr>
                                    <td class="dash-code">#<c:out value="${o.orderCode}"/></td>
                                    <td><c:out value="${o.customerName}"/></td>
                                    <td><c:out value="${o.eventName}"/></td>
                                    <td><fmt:formatNumber value="${o.quantity}" pattern="#,##0"/></td>
                                    <td class="rev-cell"><div class="amount"><fmt:formatNumber value="${o.amount}" pattern="#,##0"/> đ</div></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.status == 'Paid'}"><span class="st-pill st-active">Đã thanh toán</span></c:when>
                                            <c:when test="${o.status == 'Pending'}"><span class="st-pill st-pending">Chờ thanh toán</span></c:when>
                                            <c:when test="${o.status == 'Cancelled'}"><span class="st-pill st-danger">Đã hủy</span></c:when>
                                            <c:otherwise><span class="st-pill st-draft"><c:out value="${o.status}"/></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="small text-secondary">${fn:substring(ot, 11, 16)} - ${fn:substring(ot, 8, 10)}/${fn:substring(ot, 5, 7)}/${fn:substring(ot, 0, 4)}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty recentOrders}">
                                <tr>
                                    <td colspan="7">
                                        <div class="empty-state">
                                            <span class="material-symbols-outlined">receipt_long</span>
                                            <p class="mb-0 fw-bold text-dark">Chưa có đơn hàng nào</p>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js"></script>
        <script src="${ctx}/assets/js/organizer-dashboard.js"></script>
    </body>
</html>
