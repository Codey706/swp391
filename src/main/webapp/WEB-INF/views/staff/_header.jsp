<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="staffName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nhân viên sự kiện'}"/>
<c:set var="staffInitial" value="${fn:toUpperCase(fn:substring(staffName, 0, 1))}"/>

<div class="org-sidebar-backdrop" id="orgSidebarBackdrop"></div>

<aside class="org-sidebar" id="orgSidebar">
    <div class="org-sb-top">
        <div class="org-sb-head">
            <a class="org-sb-brand" href="${ctx}/staff">
                <span class="org-sb-logo"><span class="material-symbols-outlined">badge</span></span>
                <span class="org-sb-brandtext">
                    <span class="name"><span>Light</span><span class="accent">Ticket</span></span>
                    <small>Staff Portal</small>
                </span>
            </a>
            <button type="button" class="org-sb-close" id="orgSidebarClose">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>

        <nav class="org-sb-nav mt-3">
            <a class="${param.active == 'dashboard' ? 'is-active' : ''}" href="${ctx}/staff">
                <span class="material-symbols-outlined">calendar_month</span><span>Sự kiện phân công</span>
            </a>
            <a class="${param.active == 'checkin' ? 'is-active' : ''}" href="${ctx}/staff/checkin">
                <span class="material-symbols-outlined">qr_code_scanner</span><span>Check-in vé (QR)</span>
            </a>
            <a class="${param.active == 'seats' ? 'is-active' : ''}" href="${ctx}/staff/seats">
                <span class="material-symbols-outlined">event_seat</span><span>Sơ đồ &amp; Trạng thái ghế</span>
            </a>
            <a class="${param.active == 'customers' ? 'is-active' : ''}" href="${ctx}/staff/customers">
                <span class="material-symbols-outlined">person_search</span><span>Tra cứu khách hàng</span>
            </a>
            <a class="${param.active == 'profile' ? 'is-active' : ''}" href="${ctx}/staff/profile">
                <span class="material-symbols-outlined">badge</span><span>Hồ sơ nhân viên</span>
            </a>
            <a class="${param.active == 'password' ? 'is-active' : ''}" href="${ctx}/staff/change-password">
                <span class="material-symbols-outlined">lock_reset</span><span>Đổi mật khẩu</span>
            </a>
        </nav>
    </div>

    <div class="org-sb-bottom">
        <a class="org-sb-public" href="${ctx}/home">
            <span class="l"><span class="material-symbols-outlined">storefront</span><span>Về trang chủ</span></span>
            <span class="material-symbols-outlined">arrow_outward</span>
        </a>
        <div class="org-sb-user">
            <span class="org-sb-avatar" style="background:#ff7043; color:#fff;"><c:out value="${staffInitial}"/></span>
            <span class="org-sb-umeta">
                <span class="n"><span><c:out value="${staffName}"/></span><span class="material-symbols-outlined">verified</span></span>
                <small>Nhân viên kiểm soát</small>
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
        <button type="button" class="org-hamburger" id="orgSidebarOpen">
            <span class="material-symbols-outlined">menu</span>
        </button>

        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-light text-dark border px-2 py-1 small">
                <span class="material-symbols-outlined text-warning" style="font-size:16px; vertical-align:middle;">security</span> Cổng Soát Vé Sự Kiện
            </span>
        </div>

        <div class="org-top-actions">
            <a class="org-top-cta" href="${ctx}/staff/checkin" style="background:#ff7043;">
                <span class="material-symbols-outlined">qr_code_scanner</span>
                <span>Quét vé ngay</span>
            </a>
            <span class="org-top-sep"></span>
            <a href="${ctx}/staff/profile" class="org-top-avatar" title="<c:out value='${staffName}'/>"><span class="material-symbols-outlined">person</span></a>
        </div>
    </header>

    <div class="org-subbar">
        <div class="org-container org-subbar-inner">
            <div class="org-crumbs">
                <span class="material-symbols-outlined">home</span>
                <a href="${ctx}/staff">Portal Staff</a>
                <span class="material-symbols-outlined">chevron_right</span>
                <span class="current"><c:out value="${param.current}"/></span>
            </div>
            <div class="org-system">
                <span>Trực ban sự kiện: <b>Hotline 1900 xxxx</b></span>
            </div>
        </div>
    </div>