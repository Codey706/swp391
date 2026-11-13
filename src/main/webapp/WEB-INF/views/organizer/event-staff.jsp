<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Phân công nhân viên - Light Ticket</title>
    <jsp:include page="_head.jsp"/>
    <style>
        .es-card { background: #fff; border: 1px solid #e4e4e7; border-radius: 12px; padding: 24px; margin-bottom: 20px; }
        .es-card h2 { font-size: 17px; font-weight: 700; margin: 0 0 14px; }
        .es-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .es-table th, .es-table td { padding: 10px 8px; border-bottom: 1px solid #e4e4e7; text-align: left; vertical-align: middle; }
        .es-table th { font-size: 12px; color: #66666d; text-transform: uppercase; letter-spacing: .04em; }
        .es-form { display: flex; gap: 10px; flex-wrap: wrap; }
        .es-form select { flex: 1 1 280px; min-height: 44px; border: 1px solid #d4d4d8; border-radius: 10px; padding: 0 12px; }
        .es-btn { min-height: 44px; border: 0; border-radius: 10px; padding: 0 18px; font-weight: 600; background: #d93a27; color: #fff; }
        .es-btn-outline { min-height: 36px; border: 1px solid #ffd6cf; border-radius: 8px; padding: 0 12px; background: #fff; color: #b42e1d; font-weight: 600; }
    </style>
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
    <jsp:include page="_header.jsp">
        <jsp:param name="active" value="events"/>
        <jsp:param name="current" value="Phân công nhân viên"/>
    </jsp:include>

    <main class="org-main">
        <div style="max-width: 1000px; margin: 0 auto; padding: 32px 20px;">
            <p class="mb-1"><a href="${ctx}/organizer/event/list" class="text-decoration-none">← Sự kiện của tôi</a></p>
            <h1 class="h4 fw-bold mb-1">Phân công nhân viên soát vé</h1>
            <p class="text-muted mb-4"><c:out value="${event.eventName}"/></p>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success"><i class="ph ph-check-circle" aria-hidden="true"></i><span><c:out value="${successMessage}"/></span></div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="lt-alert error"><i class="ph ph-warning-circle" aria-hidden="true"></i><span><c:out value="${errorMessage}"/></span></div>
            </c:if>

            <c:if test="${editable}">
                <section class="es-card">
                    <h2>Thêm nhân viên</h2>
                    <c:choose>
                        <c:when test="${empty available}">
                            <p class="text-muted mb-0">Không còn tài khoản Staff đang hoạt động nào để phân công.</p>
                        </c:when>
                        <c:otherwise>
                            <form method="post" action="${ctx}/organizer/event/staff" class="es-form">
                                <input type="hidden" name="csrfToken" value="${csrfToken}">
                                <input type="hidden" name="eventId" value="${event.eventId}">
                                <input type="hidden" name="action" value="assign">
                                <select name="staffId" required aria-label="Chọn nhân viên">
                                    <option value="">-- Chọn nhân viên --</option>
                                    <c:forEach var="s" items="${available}">
                                        <option value="${s.userId}"><c:out value="${s.fullName}"/> (@<c:out value="${s.username}"/> · <c:out value="${s.email}"/>)</option>
                                    </c:forEach>
                                </select>
                                <button type="submit" class="es-btn">Phân công</button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </section>
            </c:if>

            <section class="es-card">
                <h2>Đang phân công (${fn:length(assigned)})</h2>
                <c:choose>
                    <c:when test="${empty assigned}">
                        <p class="text-muted mb-0">Chưa có nhân viên nào được phân công cho sự kiện này.</p>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x:auto;">
                            <table class="es-table">
                                <thead><tr><th>Nhân viên</th><th>Email</th><th>Điện thoại</th><th>Phân công lúc</th><th></th></tr></thead>
                                <tbody>
                                    <c:forEach var="s" items="${assigned}">
                                        <tr>
                                            <td><b><c:out value="${s.fullName}"/></b><br><small class="text-muted">@<c:out value="${s.username}"/></small></td>
                                            <td><c:out value="${s.email}"/></td>
                                            <td><c:out value="${s.phone}" default="-"/></td>
                                            <td><c:out value="${empty s.assignedAt ? '' : fn:replace(fn:substring(s.assignedAt, 0, 16), 'T', ' ')}"/></td>
                                            <td class="text-end">
                                                <c:if test="${editable}">
                                                    <form method="post" action="${ctx}/organizer/event/staff" class="m-0">
                                                        <input type="hidden" name="csrfToken" value="${csrfToken}">
                                                        <input type="hidden" name="eventId" value="${event.eventId}">
                                                        <input type="hidden" name="staffId" value="${s.userId}">
                                                        <input type="hidden" name="action" value="unassign">
                                                        <button type="submit" class="es-btn-outline">Gỡ</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </main>
    <jsp:include page="_footer.jsp"/>
    <%-- Cần cho menu ☰ (mobile) và dropdown tài khoản trong _header.jsp --%>
    <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
    <script src="${ctx}/assets/js/event.js"></script>
</body>
</html>
