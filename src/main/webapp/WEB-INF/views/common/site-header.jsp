<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  Header chung cho mọi trang công khai (home, chi tiết sự kiện, đặt vé, vé của khách...).
  Cùng logo, cùng ô tìm kiếm (GET /home?keyword=), cùng avatar chữ cái đầu (common/user-menu.jsp).
  Menu theo role:
    - Khách / Customer: "Vé của tôi"
    - Staff / Organizer / Admin: "Về Dashboard"
  Tham số: active = events | tickets (mục đang chọn, tùy chọn)
  Dùng: <jsp:include page="/WEB-INF/views/common/site-header.jsp"/>
--%>
<c:set var="shCtx" value="${pageContext.request.contextPath}"/>
<c:set var="shRole" value="${fn:toLowerCase(sessionScope.user.role)}"/>
<c:choose>
    <c:when test="${shRole == 'admin'}"><c:set var="shDashboard" value="${shCtx}/admin"/></c:when>
    <c:when test="${shRole == 'organizer'}"><c:set var="shDashboard" value="${shCtx}/organizer/dashboard"/></c:when>
    <c:when test="${shRole == 'staff'}"><c:set var="shDashboard" value="${shCtx}/staff"/></c:when>
    <c:otherwise><c:set var="shDashboard" value=""/></c:otherwise>
</c:choose>
<c:set var="shKeyword" value="${not empty keyword ? keyword : param.keyword}"/>

<link rel="stylesheet" href="${shCtx}/assets/css/site-header.css?v=20261108">
<header class="sh-header">
    <div class="sh-inner">
        <a class="sh-brand" href="${shCtx}/home">
            <img src="${shCtx}/assets/images/logo.svg" alt="" width="28" height="28">
            <span>Light Ticket</span>
        </a>

        <nav class="sh-nav" aria-label="Điều hướng chính">
            <a class="sh-link ${param.active == 'events' ? 'is-active' : ''}" href="${shCtx}/home#events">Sự kiện</a>
            <c:choose>
                <c:when test="${empty shDashboard}">
                    <a class="sh-link ${param.active == 'tickets' ? 'is-active' : ''}" href="${shCtx}/customer/booking-history">Vé của tôi</a>

                    <c:if test="${shRole == 'customer'}">
                        <a class="sh-link ${param.active == 'wishlist' ? 'is-active' : ''}"
                           href="${shCtx}/customer/wishlist">

                            <i class="ph ph-heart"></i>
                            Yêu thích

                        </a>
                    </c:if>

                </c:when>
                <c:otherwise>
                    <a class="sh-link" href="${shDashboard}">Về Dashboard</a>
                </c:otherwise>
            </c:choose>
        </nav>

        <form class="sh-search" method="get" action="${shCtx}/home" role="search">
            <i class="ph ph-magnifying-glass" aria-hidden="true"></i>
            <input type="search" name="keyword" maxlength="200" autocomplete="off"
                   value="${fn:escapeXml(shKeyword)}"
                   placeholder="Tìm kiếm buổi hòa nhạc, lễ hội, rạp hát..." aria-label="Tìm sự kiện">
        </form>

        <div class="sh-account">
            <c:choose>
                <c:when test="${empty sessionScope.user}">
                    <a class="sh-login" href="${shCtx}/Auth?action=login">Đăng nhập</a>
                </c:when>
                <c:otherwise>
                    <jsp:include page="/WEB-INF/views/common/user-menu.jsp">
                        <jsp:param name="context" value="public"/>
                    </jsp:include>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
