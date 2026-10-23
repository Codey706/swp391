<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ckUser" value="${not empty customer ? customer : sessionScope.user}"/>
<header class="ck-header">
    <div class="ck-header-inner">
        <a class="ck-brand" href="${pageContext.request.contextPath}/">
            <span>Light <strong style="color:var(--ck-orange, #ff5722);">Ticketbox</strong></span>
        </a>
        <nav>
            <a href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/home#events">Khám phá sự kiện</a>
            <a href="${pageContext.request.contextPath}/customer/e-tickets">Vé điện tử</a>
        </nav>
        <a class="ck-account" href="${pageContext.request.contextPath}/CustomerProfileController">
            <span style="display:inline-block;width:28px;height:28px;border-radius:50%;background:var(--ck-orange,#ff5722);color:#fff;text-align:center;line-height:28px;margin-right:6px;font-size:12px;font-weight:700;">
                ${empty ckUser.fullName ? 'U' : fn:toUpperCase(fn:substring(ckUser.fullName, 0, 1))}
            </span>
            <c:out value="${ckUser.fullName}" default="Tài khoản"/>
        </a>
    </div>
</header>
