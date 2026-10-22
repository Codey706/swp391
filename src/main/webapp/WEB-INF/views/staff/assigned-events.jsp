<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="hasFilter" value="${not empty keyword or selectedTab != 'all' or selectedRange != 'all'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Sự kiện được phân công - Light Ticket</title>
    <jsp:include page="/WEB-INF/views/staff/_head.jsp"/>
    <link rel="stylesheet" href="${ctx}/assets/css/staff-assignments.css">
</head>
<body class="org-body">
    <jsp:include page="/WEB-INF/views/staff/_header.jsp">
        <jsp:param name="active" value="dashboard"/>
        <jsp:param name="current" value="Sự kiện được phân công"/>
    </jsp:include>

    <main class="org-main">
        <div class="sa-page">
            <div class="sa-head">
                <h1>Sự kiện được phân công</h1>
                <p>Danh sách các sự kiện bạn được phân công hỗ trợ. Vui lòng kiểm tra thông tin chi tiết và thời gian làm việc.</p>
            </div>

            <section class="sa-panel">
                <%-- Tab trạng thái + tìm kiếm + lọc thời gian --%>
                <div class="sa-toolbar">
                    <nav class="sa-tabs" aria-label="Lọc theo trạng thái">
                        <c:forEach var="t" items="${tabLabels}">
                            <c:url var="tabUrl" value="/staff">
                                <c:param name="tab" value="${t.key}"/>
                                <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                                <c:if test="${selectedRange != 'all'}"><c:param name="range" value="${selectedRange}"/></c:if>
                            </c:url>
                            <a class="sa-tab ${selectedTab == t.key ? 'is-active' : ''}" href="${tabUrl}">
                                <c:out value="${t.value}"/>&nbsp;(${tabCounts[t.key]})
                            </a>
                        </c:forEach>
                    </nav>

                    <form class="sa-tools" method="get" action="${ctx}/staff">
                        <input type="hidden" name="tab" value="${selectedTab}">
                        <div class="sa-search">
                            <span class="material-symbols-outlined">search</span>
                            <input type="text" name="keyword" class="sa-input" maxlength="200"
                                   placeholder="Tìm kiếm sự kiện..." value="<c:out value='${keyword}'/>">
                        </div>
                        <select name="range" class="sa-input" aria-label="Lọc theo thời gian" onchange="this.form.submit()">
                            <c:forEach var="r" items="${rangeLabels}">
                                <option value="${r.key}" ${selectedRange == r.key ? 'selected' : ''}><c:out value="${r.value}"/></option>
                            </c:forEach>
                        </select>
                    </form>
                </div>

                <%-- Danh sách --%>
                <div class="sa-list">
                    <c:forEach var="e" items="${events}">
                        <c:set var="st" value="${e.startTime}"/>
                        <c:set var="en" value="${e.endTime}"/>
                        <c:set var="asg" value="${e.assignedAt}"/>
                        <article class="sa-item">
                            <c:choose>
                                <c:when test="${not empty e.eventImage}">
                                    <img class="sa-thumb" alt="" src="${ctx}/<c:out value='${e.eventImage}'/>">
                                </c:when>
                                <c:otherwise>
                                    <span class="sa-thumb"><span class="material-symbols-outlined" style="font-size:40px">image</span></span>
                                </c:otherwise>
                            </c:choose>

                            <div>
                                <h2 class="sa-name"><c:out value="${e.eventName}"/></h2>
                                <span class="sa-chip"><c:out value="${e.categoryName}"/></span>
                                <div class="sa-meta"><span class="material-symbols-outlined">location_on</span><span><c:out value="${e.venueName}"/></span></div>
                                <div class="sa-meta"><span class="material-symbols-outlined">calendar_month</span>
                                    <span>${fn:substring(st, 11, 16)} - ${fn:substring(st, 8, 10)}/${fn:substring(st, 5, 7)}/${fn:substring(st, 0, 4)}</span></div>
                            </div>

                            <div class="sa-col">
                                <div>
                                    <span class="sa-label">Bắt đầu</span>
                                    <span class="sa-value">${fn:substring(st, 11, 16)} - ${fn:substring(st, 8, 10)}/${fn:substring(st, 5, 7)}/${fn:substring(st, 0, 4)}</span>
                                </div>
                                <div>
                                    <span class="sa-label">Kết thúc</span>
                                    <span class="sa-value">${fn:substring(en, 11, 16)} - ${fn:substring(en, 8, 10)}/${fn:substring(en, 5, 7)}/${fn:substring(en, 0, 4)}</span>
                                </div>
                                <c:if test="${not empty asg}">
                                    <div>
                                        <span class="sa-label">Ngày phân công</span>
                                        <span class="sa-value">${fn:substring(asg, 8, 10)}/${fn:substring(asg, 5, 7)}/${fn:substring(asg, 0, 4)}</span>
                                    </div>
                                </c:if>
                            </div>

                            <div class="sa-col">
                                <c:choose>
                                    <c:when test="${e.timeStatus == 'UPCOMING'}"><span class="sa-badge is-upcoming">Sắp diễn ra</span></c:when>
                                    <c:when test="${e.timeStatus == 'ONGOING'}"><span class="sa-badge is-ongoing">Đang diễn ra</span></c:when>
                                    <c:when test="${e.timeStatus == 'CANCELLED'}"><span class="sa-badge is-cancelled">Đã hủy</span></c:when>
                                    <c:otherwise><span class="sa-badge is-ended">Đã kết thúc</span></c:otherwise>
                                </c:choose>
                                <div class="sa-stats">
                                    <div>
                                        <span class="sa-label">Tổng vé</span>
                                        <span class="sa-value"><fmt:formatNumber value="${e.ticketTotal}" pattern="#,##0"/></span>
                                    </div>
                                    <div>
                                        <span class="sa-label">Đã check-in</span>
                                        <span class="sa-value"><fmt:formatNumber value="${e.checkedIn}" pattern="#,##0"/></span>
                                    </div>
                                </div>
                            </div>

                            <div class="sa-act">
                                <a class="sa-btn" href="${ctx}/staff/event-detail?eventId=${e.eventId}">
                                    Xem chi tiết <span class="material-symbols-outlined" style="font-size:18px">arrow_forward</span>
                                </a>
                            </div>
                        </article>
                    </c:forEach>

                    <c:if test="${empty events}">
                        <div class="sa-empty">
                            <span class="material-symbols-outlined">event_busy</span>
                            <c:choose>
                                <c:when test="${totalAssigned == 0}">
                                    <p>Bạn chưa được phân công sự kiện nào.</p>
                                </c:when>
                                <c:otherwise>
                                    <p>Không tìm thấy sự kiện phù hợp.</p>
                                    <c:if test="${hasFilter}">
                                        <a class="sa-btn is-outline" href="${ctx}/staff">Xóa bộ lọc</a>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
            </section>

            <%-- Chân trang: số kết quả + phân trang (giữ nguyên tab, từ khóa, bộ lọc) --%>
            <c:if test="${totalResults > 0}">
                <div class="sa-foot">
                    <span>Hiển thị ${fromItem} - ${toItem} trong ${totalResults} sự kiện</span>
                    <c:if test="${totalPages > 1}">
                        <c:url var="pageBase" value="/staff">
                            <c:param name="tab" value="${selectedTab}"/>
                            <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                            <c:if test="${selectedRange != 'all'}"><c:param name="range" value="${selectedRange}"/></c:if>
                        </c:url>
                        <nav class="pager" aria-label="Phân trang">
                            <a class="${currentPage <= 1 ? 'disabled' : ''}" href="${pageBase}&page=${currentPage - 1}" aria-label="Trang trước"><span class="material-symbols-outlined" style="font-size:20px">chevron_left</span></a>
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <a class="${i == currentPage ? 'active' : ''}" href="${pageBase}&page=${i}">${i}</a>
                            </c:forEach>
                            <a class="${currentPage >= totalPages ? 'disabled' : ''}" href="${pageBase}&page=${currentPage + 1}" aria-label="Trang sau"><span class="material-symbols-outlined" style="font-size:20px">chevron_right</span></a>
                        </nav>
                    </c:if>
                </div>
            </c:if>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/staff/_footer.jsp"/>
    <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
    <script src="${ctx}/assets/js/event.js"></script>
</body>
</html>
