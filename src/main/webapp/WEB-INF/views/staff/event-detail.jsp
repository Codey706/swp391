<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="st" value="${event.startTime}"/>
<c:set var="en" value="${event.endTime}"/>
<c:set var="asg" value="${event.assignedAt}"/>
<c:set var="notCheckedIn" value="${event.ticketIssued - event.checkedIn}"/>
<c:set var="pct" value="${event.ticketIssued > 0 ? event.checkedIn * 100.0 / event.ticketIssued : 0}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Chi tiết sự kiện - Light Ticket</title>
    <jsp:include page="/WEB-INF/views/staff/_head.jsp"/>
    <link rel="stylesheet" href="${ctx}/assets/css/staff-assignments.css">
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
    <jsp:include page="/WEB-INF/views/staff/_header.jsp">
        <jsp:param name="active" value="dashboard"/>
        <jsp:param name="current" value="Chi tiết sự kiện"/>
    </jsp:include>

    <main class="org-main">
        <div class="sa-page">
            <div class="sa-head d-flex flex-wrap justify-content-between align-items-start gap-2">
                <div>
                    <h1>Chi tiết sự kiện</h1>
                    <p>Thông tin sự kiện bạn được phân công hỗ trợ.</p>
                </div>
                <a class="sa-btn is-outline" href="${ctx}/staff">
                    <i class="ph ph-arrow-left" style="font-size:18px" aria-hidden="true"></i> Quay lại danh sách
                </a>
            </div>

            <section class="sa-panel">
                <div class="sa-detail-hero">
                    <c:choose>
                        <c:when test="${not empty event.eventImage}">
                            <img class="sa-thumb" alt="" src="${ctx}/<c:out value='${event.eventImage}'/>">
                        </c:when>
                        <c:otherwise>
                            <span class="sa-thumb"><i class="ph ph-image" style="font-size:48px" aria-hidden="true"></i></span>
                        </c:otherwise>
                    </c:choose>
                    <div>
                        <c:choose>
                            <c:when test="${event.timeStatus == 'UPCOMING'}"><span class="sa-badge is-upcoming mb-2">Sắp diễn ra</span></c:when>
                            <c:when test="${event.timeStatus == 'ONGOING'}"><span class="sa-badge is-ongoing mb-2">Đang diễn ra</span></c:when>
                            <c:when test="${event.timeStatus == 'CANCELLED'}"><span class="sa-badge is-cancelled mb-2">Đã hủy</span></c:when>
                            <c:otherwise><span class="sa-badge is-ended mb-2">Đã kết thúc</span></c:otherwise>
                        </c:choose>
                        <h2 class="sa-name" style="font-size:1.3rem"><c:out value="${event.eventName}"/></h2>
                        <span class="sa-chip"><c:out value="${event.categoryName}"/></span>
                        <div class="sa-meta"><i class="ph ph-map-pin" aria-hidden="true"></i>
                            <span><c:out value="${event.venueName}"/><c:if test="${not empty event.venueAddress}"> - <c:out value="${event.venueAddress}"/></c:if></span></div>
                        <div class="sa-meta"><i class="ph ph-clock" aria-hidden="true"></i>
                            <span>${fn:substring(st, 11, 16)} - ${fn:substring(st, 8, 10)}/${fn:substring(st, 5, 7)}/${fn:substring(st, 0, 4)}
                                &rarr; ${fn:substring(en, 11, 16)} - ${fn:substring(en, 8, 10)}/${fn:substring(en, 5, 7)}/${fn:substring(en, 0, 4)}</span></div>
                        <c:if test="${not empty asg}">
                            <div class="sa-meta"><i class="ph ph-user-list" aria-hidden="true"></i>
                                <span>Được phân công ngày ${fn:substring(asg, 8, 10)}/${fn:substring(asg, 5, 7)}/${fn:substring(asg, 0, 4)}</span></div>
                        </c:if>
                    </div>
                </div>
            </section>

            <div class="sa-detail-grid">
                <div class="sa-stat"><span class="sa-label">Tổng vé</span><b><fmt:formatNumber value="${event.ticketTotal}" pattern="#,##0"/></b></div>
                <div class="sa-stat"><span class="sa-label">Vé đã phát hành</span><b><fmt:formatNumber value="${event.ticketIssued}" pattern="#,##0"/></b></div>
                <div class="sa-stat"><span class="sa-label">Đã check-in</span><b><fmt:formatNumber value="${event.checkedIn}" pattern="#,##0"/></b></div>
                <div class="sa-stat"><span class="sa-label">Chưa check-in</span><b><fmt:formatNumber value="${notCheckedIn}" pattern="#,##0"/></b></div>
            </div>
            <div class="sa-progress" title="Tỷ lệ check-in"><span style="width:${pct > 100 ? 100 : pct}%"></span></div>

            <c:if test="${not empty event.description}">
                <section class="sa-panel mt-3" style="padding:1.25rem 1.5rem">
                    <span class="sa-label">Mô tả sự kiện</span>
                    <p class="mb-0 mt-1" style="white-space:pre-line;font-size:.9rem"><c:out value="${event.description}"/></p>
                </section>
            </c:if>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/staff/_footer.jsp"/>
    <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
    <script src="${ctx}/assets/js/event.js"></script>
</body>
</html>
