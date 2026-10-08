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
                <span class="org-sb-logo"><span class="material-symbols-outlined">confirmation_number</span></span>
                <span class="org-sb-brandtext">
                    <span class="name"><span>Light</span><span class="accent">Ticket</span></span>
                    <small>Organizer Portal</small>
                </span>
            </a>
            <button type="button" class="org-sb-close" id="orgSidebarClose" aria-label="Đóng menu">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>

        <a class="org-sb-create" href="${ctx}/organizer/event/create">
            <span class="material-symbols-outlined">add_circle</span>
            <span>Tạo sự kiện</span>
        </a>

        <nav class="org-sb-nav">
            <a href="#" data-soon title="Sắp ra mắt"><span class="material-symbols-outlined">dashboard</span><span>Tổng quan</span></a>
            <a class="${param.active == 'events' ? 'is-active' : ''}" href="${ctx}/organizer/event/list"
               ${param.active == 'events' ? 'aria-current="page"' : ''}><span class="material-symbols-outlined">calendar_month</span><span>Sự kiện của tôi</span></a>
            <a href="#" data-soon title="Sắp ra mắt"><span class="material-symbols-outlined">receipt_long</span><span>Vé bán ra &amp; Đơn hàng</span></a>
            <a href="#" data-soon title="Sắp ra mắt"><span class="material-symbols-outlined">analytics</span><span>Báo cáo &amp; Thống kê</span></a>
            <a href="#" data-soon title="Sắp ra mắt"><span class="material-symbols-outlined">account_balance_wallet</span><span>Tài chính &amp; Quyết toán</span></a>
            <a href="#" data-soon title="Sắp ra mắt"><span class="material-symbols-outlined">settings</span><span>Cài đặt tổ chức</span></a>
        </nav>
    </div>

    <div class="org-sb-bottom">
        <a class="org-sb-public" href="${ctx}/home">
            <span class="l"><span class="material-symbols-outlined">storefront</span><span>Về sàn vé công cộng</span></span>
            <span class="material-symbols-outlined">arrow_outward</span>
        </a>
        <div class="org-sb-user">
            <span class="org-sb-avatar"><c:out value="${orgInitial}"/></span>
            <span class="org-sb-umeta">
                <span class="n"><span><c:out value="${orgName}"/></span><span class="material-symbols-outlined">verified</span></span>
                <small>Ban Tổ Chức</small>
            </span>
        </div>
        <form method="post" action="${ctx}/logout" class="m-0">
            <button type="submit" class="org-sb-logout">
                <span class="material-symbols-outlined">logout</span> Đăng xuất
            </button>
        </form>
    </div>
</aside>

<div class="org-shell">
    <header class="org-topbar">
        <button type="button" class="org-hamburger" id="orgSidebarOpen" aria-label="Mở menu"
                aria-controls="orgSidebar" aria-expanded="false">
            <span class="material-symbols-outlined">menu</span>
        </button>

        <%-- Tìm nhanh: dùng lại tham số keyword của /organizer/event/list --%>
        <form class="org-search" method="get" action="${ctx}/organizer/event/list" role="search">
            <span class="material-symbols-outlined">search</span>
            <input type="search" name="keyword" maxlength="200" autocomplete="off"
                   placeholder="Tìm nhanh tên sự kiện..." aria-label="Tìm sự kiện theo tên"
                   value="<c:out value='${keyword}'/>">
        </form>

        <div class="org-top-actions">
            <a class="org-top-cta" href="${ctx}/organizer/event/create">
                <span class="material-symbols-outlined">add</span>
                <span>Tạo sự kiện mới</span>
            </a>
            <span class="org-top-sep"></span>
            <button type="button" class="org-top-btn hide-sm" aria-label="Hỗ trợ">
                <span class="material-symbols-outlined">help_outline</span>
            </button>
            <button type="button" class="org-top-btn" aria-label="Thông báo">
                <span class="material-symbols-outlined">notifications</span>
                <span class="dot"></span>
            </button>
            <span class="org-top-avatar" title="<c:out value='${orgName}'/>"><span class="material-symbols-outlined">person</span></span>
        </div>
    </header>

    <div class="org-subbar">
        <div class="org-container org-subbar-inner">
            <div class="org-crumbs">
                <span class="material-symbols-outlined">home</span>
                <a href="${ctx}/organizer/event/list">Portal BTC</a>
                <span class="material-symbols-outlined">chevron_right</span>
                <c:choose>
                    <c:when test="${not empty param.crumb2}">
                        <a href="${ctx}/organizer/event/list"><c:out value="${param.crumb2}"/></a>
                        <span class="material-symbols-outlined">chevron_right</span>
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
