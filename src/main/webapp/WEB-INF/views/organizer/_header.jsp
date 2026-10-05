<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  Navbar + thanh breadcrumb của Organizer Portal.
  Tham số: active (events), crumb2 / crumb2Url (tùy chọn), current (tên trang hiện tại)
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<nav class="org-navbar">
    <div class="org-container org-navbar-inner">
        <a class="org-brand" href="${ctx}/organizer/event/list">
            <img alt="Light Ticket"
                 src="https://lh3.googleusercontent.com/aida/AEtjO1XCI4pNVR1LGpUueuP9_9k14rz3oGicBwB__UCCRlZ3mNWWsQwLyQcea6WY4e2S4NiF2kxi9pyZSAfD539GHPQ_33mPeRhZpIPhRtji29s4QEP6_l-3Chm3ggkHpxyI7y-uomu6uDLT-lmezb9aBB5pybNOB5jk9soXkdw9qoc89BAk7a5qlR2Pk-2gt4yjPpKuGtJB7DJGqYkGPujCmTiy8cOwTap_sH4FPUaxt6r6VaM_ztASYSlvHryI">
            <span class="org-brand-text"><strong>Light Ticket</strong><small>Organizer Portal</small></span>
        </a>
        <span class="engine-chip">Live Engine v2.4</span>

        <div class="org-nav">
            <a class="nav-pill-idle" href="#">Tổng<br>quan</a>
            <a class="${param.active == 'events' ? 'nav-pill-active' : 'nav-pill-idle'}" href="${ctx}/organizer/event/list">Sự kiện<br>của tôi</a>
            <a class="nav-pill-idle" href="#">Doanh thu &amp;<br>Đơn hàng</a>
            <a class="nav-pill-idle" href="#">Báo cáo<br>vé</a>
            <a class="nav-pill-idle" href="#">Cài đặt<br>BTC</a>
        </div>

        <a class="btn-cta" href="${ctx}/organizer/event/create">
            <span class="material-symbols-outlined">add_circle</span>
            <span>Tạo sự kiện mới</span>
        </a>
        <button type="button" class="org-icon-btn" aria-label="Thông báo">
            <span class="material-symbols-outlined">notifications</span>
            <span class="dot"></span>
        </button>
        <div class="org-user">
            <span class="org-user-avatar"><span class="material-symbols-outlined" style="font-size:20px;">person</span></span>
            <span class="org-user-meta">
                <strong><c:out value="${orgName}"/></strong>
                <small>Ban Tổ Chức</small>
            </span>
        </div>
    </div>
</nav>

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
            <span class="live">Trạng thái hệ thống: Sẵn sàng</span>
            <span class="sep"></span>
            <span>Hỗ trợ VIP BTC: <b>1900 xxxx</b></span>
        </div>
    </div>
</div>
