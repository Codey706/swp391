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
                <span class="org-sb-logo"><i class="ph ph-identification-badge" aria-hidden="true"></i></span>
                <span class="org-sb-brandtext">
                    <span class="name"><span>Light</span><span class="accent">Ticket</span></span>
                    <small>Staff Portal</small>
                </span>
            </a>
            <button type="button" class="org-sb-close" id="orgSidebarClose">
                <i class="ph ph-x" aria-hidden="true"></i>
            </button>
        </div>

        <nav class="org-sb-nav mt-3">
            <a class="${param.active == 'dashboard' ? 'is-active' : ''}" href="${ctx}/staff">
                <i class="ph ph-calendar" aria-hidden="true"></i><span>Sự kiện phân công</span>
            </a>
            <a class="${param.active == 'checkin' ? 'is-active' : ''}" href="${ctx}/staff/checkin">
                <i class="ph ph-scan" aria-hidden="true"></i><span>Check-in vé (QR)</span>
            </a>
            <a class="${param.active == 'seats' ? 'is-active' : ''}" href="${ctx}/staff/seats">
                <i class="ph ph-armchair" aria-hidden="true"></i><span>Sơ đồ &amp; Trạng thái ghế</span>
            </a>
            <a class="${param.active == 'customers' ? 'is-active' : ''}" href="${ctx}/staff/customers">
                <i class="ph ph-user-focus" aria-hidden="true"></i><span>Tra cứu khách hàng</span>
            </a>
            <a class="${param.active == 'profile' ? 'is-active' : ''}" href="${ctx}/staff/profile">
                <i class="ph ph-identification-badge" aria-hidden="true"></i><span>Hồ sơ nhân viên</span>
            </a>
            <a class="${param.active == 'password' ? 'is-active' : ''}" href="${ctx}/Auth?action=changePassword">
                <i class="ph ph-lock-key" aria-hidden="true"></i><span>Đổi mật khẩu</span>
            </a>
        </nav>
    </div>

    <div class="org-sb-bottom">
        <a class="org-sb-public" href="${ctx}/home">
            <span class="l"><i class="ph ph-storefront" aria-hidden="true"></i><span>Về trang chủ</span></span>
            <i class="ph ph-arrow-up-right" aria-hidden="true"></i>
        </a>
        <div class="org-sb-user">
            <span class="org-sb-avatar" style="background:#d93a27; color:#fff;"><c:out value="${staffInitial}"/></span>
            <span class="org-sb-umeta">
                <span class="n"><span><c:out value="${staffName}"/></span><i class="ph ph-seal-check" aria-hidden="true"></i></span>
                <small>Nhân viên kiểm soát</small>
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
        <button type="button" class="org-hamburger" id="orgSidebarOpen" aria-label="Mở menu" aria-controls="orgSidebar" aria-expanded="false">
            <i class="ph ph-list" aria-hidden="true"></i>
        </button>

        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-light text-dark border px-2 py-1 small">
                <i class="ph ph-shield-check text-warning" style="font-size:16px; vertical-align:middle;" aria-hidden="true"></i> Cổng Soát Vé Sự Kiện
            </span>
        </div>

        <div class="org-top-actions">
            <a class="org-top-cta" href="${ctx}/staff/checkin" style="background:#d93a27;">
                <i class="ph ph-scan" aria-hidden="true"></i>
                <span>Quét vé ngay</span>
            </a>
            <span class="org-top-sep"></span>
            <jsp:include page="/WEB-INF/views/common/user-menu.jsp"/>
        </div>
    </header>

    <div class="org-subbar">
        <div class="org-container org-subbar-inner">
            <div class="org-crumbs">
                <i class="ph ph-house" aria-hidden="true"></i>
                <a href="${ctx}/staff">Portal Staff</a>
                <i class="ph ph-caret-right" aria-hidden="true"></i>
                <span class="current"><c:out value="${param.current}"/></span>
            </div>
            <div class="org-system">
                <span>Trực ban sự kiện: <b>Hotline 1900 xxxx</b></span>
            </div>
        </div>
    </div>