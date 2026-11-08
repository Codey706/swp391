<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  Khung layout Organizer Portal (Stitch): sidebar 260px + topbar + breadcrumb.
  - File này MỞ thẻ <div class="org-shell">; _footer.jsp ĐÓNG thẻ này.
  - Tham số: active (events), crumb2 (tùy chọn), current (tên trang hiện tại)
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<c:set var="orgInitial" value="${fn:toUpperCase(fn:substring(orgName, 0, 1))}"/>

<div class="org-sidebar-backdrop" id="orgSidebarBackdrop"></div>

<aside class="org-sidebar" id="orgSidebar" aria-label="Điều hướng Organizer Portal">
    <div class="org-sb-top">
        <div class="org-sb-head">
            <a class="org-sb-brand" href="${ctx}/organizer/event/list">
                <span class="org-sb-logo"><i class="ph ph-ticket" aria-hidden="true"></i></span>
                <span class="org-sb-brandtext">
                    <span class="name"><span>Light</span><span class="accent">Ticket</span></span>
                    <small>Organizer Portal</small>
                </span>
            </a>
            <button type="button" class="org-sb-close" id="orgSidebarClose" aria-label="Đóng menu">
                <i class="ph ph-x" aria-hidden="true"></i>
            </button>
        </div>

        <a class="org-sb-create" href="${ctx}/organizer/event/create">
            <i class="ph ph-plus-circle" aria-hidden="true"></i>
            <span>Tạo sự kiện</span>
        </a>

        <nav class="org-sb-nav">
            <a class="${param.active == 'dashboard' ? 'is-active' : ''}" href="${ctx}/organizer/dashboard"
               ${param.active == 'dashboard' ? 'aria-current="page"' : ''}><i class="ph ph-squares-four" aria-hidden="true"></i><span>Tổng quan</span></a>
            <a class="${param.active == 'events' ? 'is-active' : ''}" href="${ctx}/organizer/event/list"
               ${param.active == 'events' ? 'aria-current="page"' : ''}><i class="ph ph-calendar" aria-hidden="true"></i><span>Sự kiện của tôi</span></a>
            <a class="${param.active == 'profile' ? 'is-active' : ''}" href="${ctx}/organizer/profile"
               ${param.active == 'profile' ? 'aria-current="page"' : ''}><i class="ph ph-identification-badge" aria-hidden="true"></i><span>Hồ sơ tổ chức</span></a>
            <a class="${param.active == 'password' ? 'is-active' : ''}" href="${ctx}/Auth?action=changePassword"
               ${param.active == 'password' ? 'aria-current="page"' : ''}><i class="ph ph-lock-key" aria-hidden="true"></i><span>Đổi mật khẩu</span></a>
        </nav>
    </div>

    <div class="org-sb-bottom">
        <a class="org-sb-public" href="${ctx}/home">
            <span class="l"><i class="ph ph-storefront" aria-hidden="true"></i><span>Về sàn vé công cộng</span></span>
            <i class="ph ph-arrow-up-right" aria-hidden="true"></i>
        </a>
        <div class="org-sb-user">
            <span class="org-sb-avatar"><c:out value="${orgInitial}"/></span>
            <span class="org-sb-umeta">
                <span class="n"><span><c:out value="${orgName}"/></span><i class="ph ph-seal-check" aria-hidden="true"></i></span>
                <small>Ban Tổ Chức</small>
            </span>
        </div>
        <form method="post" action="${ctx}/logout" class="m-0">
            <button type="submit" class="org-sb-logout">
                <i class="ph ph-sign-out" aria-hidden="true"></i> Đăng xuất
            </button>
        </form>
    </div>
</aside>

<div class="org-shell">
    <header class="org-topbar">
        <button type="button" class="org-hamburger" id="orgSidebarOpen" aria-label="Mở menu"
                aria-controls="orgSidebar" aria-expanded="false">
            <i class="ph ph-list" aria-hidden="true"></i>
        </button>

        <%-- Tìm nhanh: dùng lại tham số keyword của /organizer/event/list --%>
        <form class="org-search" method="get" action="${ctx}/organizer/event/list" role="search">
            <i class="ph ph-magnifying-glass" aria-hidden="true"></i>
            <input type="search" name="keyword" maxlength="200" autocomplete="off"
                   placeholder="Tìm nhanh tên sự kiện..." aria-label="Tìm sự kiện theo tên"
                   value="<c:out value='${keyword}'/>">
        </form>

        <div class="org-top-actions">
            <a class="org-top-cta" href="${ctx}/organizer/event/create">
                <i class="ph ph-plus" aria-hidden="true"></i>
                <span>Tạo sự kiện mới</span>
            </a>
            <span class="org-top-sep"></span>

            <jsp:include page="/WEB-INF/views/common/user-menu.jsp"/>
        </div>
    </header>

    <div class="org-subbar">
        <div class="org-container org-subbar-inner">
            <div class="org-crumbs">
                <i class="ph ph-house" aria-hidden="true"></i>
                <a href="${ctx}/organizer/event/list">Portal BTC</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
                <c:choose>
                    <c:when test="${not empty param.crumb2}">
                        <a href="${ctx}/organizer/event/list"><c:out value="${param.crumb2}"/></a>
                        <i class="ph ph-caret-right" aria-hidden="true"></i>
                        <span class="current"><c:out value="${param.current}"/></span>
                    </c:when>
                    <c:otherwise>
                        <span class="current"><c:out value="${param.current}"/></span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="org-system">
                <span>Hỗ trợ VIP BTC: <b>1900 xxxx</b></span>
            </div>
        </div>
    </div>
    <%-- org-shell được đóng trong _footer.jsp --%>
