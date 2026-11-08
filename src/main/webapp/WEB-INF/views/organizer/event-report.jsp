<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Báo cáo bán vé - Light Ticket</title>
    <jsp:include page="_head.jsp"/>
    <style>
        .rp-card { background: #fff; border: 1px solid #e4e4e7; border-radius: 12px; padding: 22px; margin-bottom: 20px; }
        .rp-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 14px; margin-bottom: 20px; }
        .rp-stat { background: #fff; border: 1px solid #e4e4e7; border-radius: 12px; padding: 16px; }
        .rp-stat span { font-size: 12px; color: #66666d; text-transform: uppercase; letter-spacing: .04em; }
        .rp-stat b { display: block; font-size: 22px; color: #141414; margin-top: 4px; }
        .rp-stat small { color: #66666d; }
        .rp-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .rp-table th, .rp-table td { padding: 10px 8px; border-bottom: 1px solid #e4e4e7; text-align: right; }
        .rp-table th:first-child, .rp-table td:first-child { text-align: left; }
        .rp-table th { font-size: 12px; color: #66666d; text-transform: uppercase; }
        .rp-table tfoot td { font-weight: 700; }
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
        <jsp:param name="current" value="Báo cáo bán vé"/>
    </jsp:include>

    <main class="org-main">
        <div style="max-width: 1100px; margin: 0 auto; padding: 32px 20px;">
            <p class="mb-1"><a href="${ctx}/organizer/event/list" class="text-decoration-none">← Sự kiện của tôi</a></p>
            <h1 class="h4 fw-bold mb-1">Báo cáo bán vé</h1>
            <p class="text-muted mb-4"><c:out value="${event.eventName}"/> · <c:out value="${event.status}"/></p>

            <div class="rp-stats">
                <div class="rp-stat"><span>Doanh thu</span><b><fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/> đ</b><small>Từ đơn đã thanh toán</small></div>
                <div class="rp-stat"><span>Vé đã bán</span><b><fmt:formatNumber value="${totalSold}" pattern="#,##0"/> / <fmt:formatNumber value="${totalQuantity}" pattern="#,##0"/></b><small>${soldPercent}% sức bán</small></div>
                <div class="rp-stat"><span>Đã check-in</span><b><fmt:formatNumber value="${totalCheckedIn}" pattern="#,##0"/></b><small>${checkInPercent}% vé đã bán</small></div>
                <div class="rp-stat"><span>Đang giữ chỗ</span><b><fmt:formatNumber value="${totalHeld}" pattern="#,##0"/></b><small>Trong đơn chờ thanh toán</small></div>
                <div class="rp-stat"><span>Đơn hàng</span><b><fmt:formatNumber value="${orderCounts['Paid']}" pattern="#,##0"/></b>
                    <small><fmt:formatNumber value="${orderCounts['Pending']}" pattern="#,##0"/> chờ · <fmt:formatNumber value="${orderCounts['Cancelled']}" pattern="#,##0"/> đã hủy</small></div>
            </div>

            <section class="rp-card">
                <h2 class="h6 fw-bold mb-3">Theo hạng vé</h2>
                <c:choose>
                    <c:when test="${empty rows}">
                        <p class="text-muted mb-0">Sự kiện chưa có hạng vé.</p>
                    </c:when>
                    <c:otherwise>
                        <div style="overflow-x:auto;">
                            <table class="rp-table">
                                <thead>
                                    <tr><th>Hạng vé</th><th>Giá</th><th>Số lượng</th><th>Đã bán</th><th>Giữ chỗ</th><th>Còn lại</th><th>Check-in</th><th>Doanh thu</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${rows}">
                                        <tr>
                                            <td><c:out value="${r.ticketName}"/><c:if test="${r.status ne 'ACTIVE'}"> <small class="text-muted">(<c:out value="${r.status}"/>)</small></c:if></td>
                                            <td><fmt:formatNumber value="${r.price}" pattern="#,##0"/></td>
                                            <td><fmt:formatNumber value="${r.quantity}" pattern="#,##0"/></td>
                                            <td><fmt:formatNumber value="${r.sold}" pattern="#,##0"/></td>
                                            <td><fmt:formatNumber value="${r.held}" pattern="#,##0"/></td>
                                            <td><fmt:formatNumber value="${r.available}" pattern="#,##0"/></td>
                                            <td><fmt:formatNumber value="${r.checkedIn}" pattern="#,##0"/></td>
                                            <td><fmt:formatNumber value="${r.revenue}" pattern="#,##0"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr><td>Tổng</td><td></td>
                                        <td><fmt:formatNumber value="${totalQuantity}" pattern="#,##0"/></td>
                                        <td><fmt:formatNumber value="${totalSold}" pattern="#,##0"/></td>
                                        <td><fmt:formatNumber value="${totalHeld}" pattern="#,##0"/></td>
                                        <td></td>
                                        <td><fmt:formatNumber value="${totalCheckedIn}" pattern="#,##0"/></td>
                                        <td><fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/></td></tr>
                                </tfoot>
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
