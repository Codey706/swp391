<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Sơ đồ ghế - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
        <link rel="stylesheet" href="${ctx}/assets/css/seatmap.css">
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
            <jsp:param name="crumb2" value="Quản lý sự kiện"/>
            <jsp:param name="current" value="Sơ đồ ghế"/>
        </jsp:include>

        <main class="org-container org-main">

            <%-- Toolbar --%>
            <section class="org-card ce-toolbar">
                <div class="ce-toolbar-title">
                    <a class="ce-back" href="${ctx}/organizer/event/list" aria-label="Quay lại danh sách sự kiện">
                        <i class="ph ph-arrow-left" aria-hidden="true"></i>
                    </a>
                    <h1>Sơ đồ ghế</h1>
                    <span class="ce-pill"><c:out value="${event.eventName}"/></span>
                </div>
                <div class="ce-toolbar-actions">
                    <c:if test="${not readOnly}">
                        <form method="post" action="${ctx}/organizer/event/seatmap" class="m-0" id="clear-form">
                            <input type="hidden" name="eventId" value="${event.eventId}">
                            <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                            <input type="hidden" name="action" value="clear">
                            <button type="submit" class="btn-soft" id="clearBtn">
                                <i class="ph ph-broom" aria-hidden="true"></i> Xóa sơ đồ
                            </button>
                        </form>
                        <button type="submit" form="seatmap-form" class="btn-cta" id="saveBtn">
                            <i class="ph ph-floppy-disk" aria-hidden="true"></i> Lưu sơ đồ
                        </button>
                    </c:if>
                    <a class="btn-soft" href="${ctx}/organizer/event/list">
                        <i class="ph ph-list-bullets" aria-hidden="true"></i> Danh sách sự kiện
                    </a>
                </div>
            </section>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success"><i class="ph ph-check-circle" aria-hidden="true"></i><span><c:out value="${successMessage}"/></span></div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                <div class="lt-alert error"><i class="ph ph-warning-circle" aria-hidden="true"></i><span><c:out value="${errorMessage}"/></span></div>
                    </c:if>
                    <c:if test="${readOnly}">
                <div class="lt-alert error"><i class="ph ph-lock" aria-hidden="true"></i><span>Chế độ chỉ xem: <c:out value="${lockedReason}"/></span></div>
                    </c:if>
                    <c:if test="${not empty errorList}">
                <div class="lt-alert error">
                    <i class="ph ph-warning-circle" aria-hidden="true"></i>
                    <div>
                        <b>Chưa lưu được sơ đồ. Vui lòng kiểm tra:</b>
                        <ul class="sm-server-errors">
                            <c:forEach var="msg" items="${errorList}"><li><c:out value="${msg}"/></li></c:forEach>
                            </ul>
                        </div>
                    </div>
            </c:if>

            <form method="post" action="${ctx}/organizer/event/seatmap" id="seatmap-form" novalidate>
                <input type="hidden" name="eventId" value="${event.eventId}">
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="layoutJson" id="layoutJson" value="">
            </form>

            <jsp:include page="/WEB-INF/views/organizer/_seatmap-designer.jsp"/>
        </main>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>

        <%-- Dữ liệu ban đầu (Gson đã escape <, >, & nên an toàn khi nhúng trong thẻ script) --%>
        <script type="application/json" id="smData"><c:out value="${dataJson}" escapeXml="false"/></script>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/seatmap.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
    </body>
</html>
