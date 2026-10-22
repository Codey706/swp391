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
                        <span class="material-symbols-outlined">arrow_back</span>
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
                                <span class="material-symbols-outlined">delete_sweep</span> Xóa sơ đồ
                            </button>
                        </form>
                        <button type="submit" form="seatmap-form" class="btn-cta" id="saveBtn">
                            <span class="material-symbols-outlined">save</span> Lưu sơ đồ
                        </button>
                    </c:if>
                    <a class="btn-soft" href="${ctx}/organizer/event/list">
                        <span class="material-symbols-outlined">list</span> Danh sách sự kiện
                    </a>
                </div>
            </section>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success"><span class="material-symbols-outlined">check_circle</span><span><c:out value="${successMessage}"/></span></div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="lt-alert error"><span class="material-symbols-outlined">error</span><span><c:out value="${errorMessage}"/></span></div>
            </c:if>
            <c:if test="${readOnly}">
                <div class="lt-alert error"><span class="material-symbols-outlined">lock</span><span>Chế độ chỉ xem: <c:out value="${lockedReason}"/></span></div>
            </c:if>
            <c:if test="${not empty errorList}">
                <div class="lt-alert error">
                    <span class="material-symbols-outlined">error</span>
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
    </body>
</html>
