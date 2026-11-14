<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  Menu tài khoản dùng chung cho cả 4 role (Customer, Staff, Organizer, Admin).
  Avatar tròn chữ cái đầu + tên + role + mũi tên; dropdown: Hồ sơ của tôi, Về trang chủ, Đăng xuất.
  Không phụ thuộc Bootstrap JS (tự mở/đóng bằng assets/js/user-menu.js).

  Tham số:
    context = "public" -> thêm mục theo role: Customer "Vé của tôi", role khác "Về Dashboard".
  Dùng: <jsp:include page="/WEB-INF/views/common/user-menu.jsp"/>
--%>
<c:set var="umCtx" value="${pageContext.request.contextPath}"/>
<c:set var="umUser" value="${sessionScope.user}"/>
<c:set var="umName" value="${not empty umUser.fullName ? umUser.fullName : umUser.username}"/>
<c:set var="umName" value="${empty umName ? 'Tài khoản' : umName}"/>
<c:set var="umInitial" value="${fn:toUpperCase(fn:substring(umName, 0, 1))}"/>
<c:set var="umRole" value="${fn:toLowerCase(umUser.role)}"/>
<c:choose>
    <c:when test="${umRole == 'admin'}">
        <c:set var="umRoleLabel" value="Quản trị viên"/>
        <c:set var="umProfile" value="${umCtx}/admin/profile"/>
        <c:set var="umDashboard" value="${umCtx}/admin"/>
    </c:when>
    <c:when test="${umRole == 'organizer'}">
        <c:set var="umRoleLabel" value="Ban tổ chức"/>
        <c:set var="umProfile" value="${umCtx}/organizer/profile"/>
        <c:set var="umDashboard" value="${umCtx}/organizer/dashboard"/>
    </c:when>
    <c:when test="${umRole == 'staff'}">
        <c:set var="umRoleLabel" value="Nhân viên"/>
        <c:set var="umProfile" value="${umCtx}/staff/profile"/>
        <c:set var="umDashboard" value="${umCtx}/staff"/>
    </c:when>
    <c:otherwise>
        <c:set var="umRoleLabel" value="Khách hàng"/>
        <c:set var="umProfile" value="${umCtx}/CustomerProfileController"/>
        <c:set var="umDashboard" value=""/>
    </c:otherwise>
</c:choose>

<link rel="stylesheet" href="${umCtx}/assets/css/user-menu.css?v=20261108">
<div class="um" data-user-menu>
    <button type="button" class="um-toggle" aria-haspopup="menu" aria-expanded="false" data-um-toggle>
        <span class="um-avatar" aria-hidden="true"><c:out value="${umInitial}"/></span>
        <span class="um-meta">
            <span class="um-name"><c:out value="${umName}"/></span>
            <span class="um-role"><c:out value="${umRoleLabel}"/></span>
        </span>
        <i class="ph ph-caret-down um-chevron" aria-hidden="true"></i>
    </button>

    <div class="um-menu" role="menu" hidden data-um-menu>
        <div class="um-head">
            <span class="um-head-name"><c:out value="${umName}"/></span>
            <span class="um-head-role"><c:out value="${umRoleLabel}"/></span>
        </div>
        <a class="um-item" role="menuitem" href="${umProfile}">
            <i class="ph ph-user-circle" aria-hidden="true"></i>Hồ sơ của tôi
        </a>
        <c:if test="${param.context == 'public'}">
            <c:choose>
                <c:when test="${empty umDashboard}">
                    <a class="um-item" role="menuitem" href="${umCtx}/customer/booking-history">
                        <i class="ph ph-ticket" aria-hidden="true"></i>Vé của tôi

                        <a class="um-item"
                           role="menuitem"
                           href="${umCtx}/customer/wishlist">

                            <i class="ph ph-heart" aria-hidden="true"></i>
                            Sự kiện yêu thích

                        </a>
                    </a>
                </c:when>
                <c:otherwise>
                    <a class="um-item" role="menuitem" href="${umDashboard}">
                        <i class="ph ph-squares-four" aria-hidden="true"></i>Về Dashboard
                    </a>
                </c:otherwise>
            </c:choose>
        </c:if>
        <a class="um-item" role="menuitem" href="${umCtx}/home">
            <i class="ph ph-house" aria-hidden="true"></i>Về trang chủ
        </a>
        <div class="um-divider" role="separator"></div>
        <form method="post" action="${umCtx}/logout" class="um-form">
            <button type="submit" class="um-item um-logout" role="menuitem">
                <i class="ph ph-sign-out" aria-hidden="true"></i>Đăng xuất
            </button>
        </form>
    </div>
</div>
<script src="${umCtx}/assets/js/user-menu.js?v=20261108" defer></script>
