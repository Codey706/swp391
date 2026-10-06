<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.user}"/>
<c:set var="initial" value="${fn:toUpperCase(fn:substring(user.fullName, 0, 1))}"/>
<c:set var="paidCount" value="${empty statusCounts['Paid'] ? 0 : statusCounts['Paid']}"/>
<c:set var="pendingCount" value="${empty statusCounts['Pending'] ? 0 : statusCounts['Pending']}"/>
<c:set var="cancelledCount" value="${empty statusCounts['Cancelled'] ? 0 : statusCounts['Cancelled']}"/>
<c:set var="fromItem" value="${(currentPage - 1) * 10 + 1}"/>
<c:set var="toItem" value="${fromItem + fn:length(bookings) - 1}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử đặt vé &amp; Đơn hàng - Light Ticket</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/bootstrap.css">
    <link rel="stylesheet" href="${ctx}/assets/css/booking.css">
</head>
<body class="booking-page d-flex flex-column min-vh-100">

<!-- Icon sprite -->
<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>
    <symbol id="i-search" viewBox="0 0 24 24"><path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></symbol>
    <symbol id="i-home" viewBox="0 0 24 24"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></symbol>
    <symbol id="i-bell" viewBox="0 0 24 24"><path d="M15 17h5l-1.4-1.4A2 2 0 0118 14.2V11a6 6 0 00-4-5.7V5a2 2 0 10-4 0v.3C7.7 6.2 6 8.4 6 11v3.2c0 .5-.2 1-.6 1.4L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></symbol>
    <symbol id="i-user" viewBox="0 0 24 24"><path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></symbol>
    <symbol id="i-order" viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></symbol>
    <symbol id="i-lock" viewBox="0 0 24 24"><path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></symbol>
    <symbol id="i-chev" viewBox="0 0 24 24"><path d="M9 5l7 7-7 7"/></symbol>
    <symbol id="i-cal" viewBox="0 0 24 24"><path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></symbol>
    <symbol id="i-pin" viewBox="0 0 24 24"><path d="M17.7 16.7L13.4 20.9a2 2 0 01-2.8 0l-4.2-4.2a8 8 0 1111.3 0zM15 11a3 3 0 11-6 0 3 3 0 016 0z"/></symbol>
    <symbol id="i-ticket" viewBox="0 0 24 24"><path d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></symbol>
    <symbol id="i-eye" viewBox="0 0 24 24"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0zM2.5 12C3.7 7.9 7.5 5 12 5s8.3 2.9 9.5 7c-1.2 4.1-5 7-9.5 7S3.7 16.1 2.5 12z"/></symbol>
    <symbol id="i-check" viewBox="0 0 24 24"><path d="M5 13l4 4L19 7"/></symbol>
    <symbol id="i-clock" viewBox="0 0 24 24"><path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></symbol>
    <symbol id="i-x" viewBox="0 0 24 24"><path d="M6 18L18 6M6 6l12 12"/></symbol>
    <symbol id="i-bag" viewBox="0 0 24 24"><path d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></symbol>
    <symbol id="i-mail" viewBox="0 0 24 24"><path d="M3 8l7.9 5.3a2 2 0 002.2 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></symbol>
    <symbol id="i-phone" viewBox="0 0 24 24"><path d="M3 5a2 2 0 012-2h3.3a1 1 0 01.9.7l1.5 4.5a1 1 0 01-.5 1.2l-2.3 1.1a11 11 0 005.5 5.5l1.1-2.3a1 1 0 011.2-.5l4.5 1.5a1 1 0 01.7.9V19a2 2 0 01-2 2h-1C9.7 21 3 14.3 3 6V5z"/></symbol>
</defs></svg>

<!-- ===== HEADER ===== -->
<header class="lt-header sticky-top">
    <div class="container">
        <div class="d-flex d-lg-none justify-content-between align-items-center py-2 border-bottom border-light">
            <span class="small fw-bold text-secondary">Light Ticket</span>
            <button class="btn btn-sm btn-outline-secondary rounded-3" type="button"
                    data-bs-toggle="collapse" data-bs-target="#mobileAccountNav"
                    aria-controls="mobileAccountNav" aria-expanded="false">
                Menu
            </button>
        </div>
        <div class="collapse d-lg-none" id="mobileAccountNav">
            <nav class="d-flex flex-column gap-1 py-2">
                <a class="px-3 py-2 rounded-3 text-decoration-none text-secondary fw-semibold" href="${ctx}/">Sự kiện</a>
                <a class="px-3 py-2 rounded-3 text-decoration-none text-secondary fw-semibold" href="#">Địa điểm</a>
                <a class="px-3 py-2 rounded-3 text-decoration-none text-secondary fw-semibold" href="#">Tin tức</a>
                <a class="px-3 py-2 rounded-3 text-decoration-none text-brand fw-bold bg-light" href="${ctx}/customer/booking-history">Vé của tôi</a>
            </nav>
        </div>
        <div class="d-flex align-items-center justify-content-between gap-3" style="height:80px">
            <div class="d-flex align-items-center gap-4">
                <a class="d-flex align-items-center gap-2 text-decoration-none lt-brand" href="${ctx}/">
                    <span class="lt-logo">LT</span>
                    <span class="d-flex flex-column">
                        <span class="lt-brand-name">Light<span class="text-brand">Ticket</span></span>
                        <span class="lt-brand-sub">Live Event Platform</span>
                    </span>
                </a>
                <nav class="d-none d-lg-flex align-items-center gap-1 lt-nav">
                    <a href="${ctx}/">Sự kiện</a>
                    <a href="#">Địa điểm</a>
                    <a href="#">Tin tức</a>
                    <a href="${ctx}/customer/booking-history" class="active">Vé của tôi</a>
                </nav>
            </div>

            <form class="flex-grow-1 d-none d-md-block" style="max-width:28rem" method="get" action="${ctx}/customer/booking-history">
                <div class="lt-search-wrap">
                    <svg class="ico lt-search-ico"><use href="#i-search"/></svg>
                    <input type="text" name="keyword" maxlength="50" class="form-control lt-search-pill"
                           placeholder="Tìm kiếm mã đơn, tên sự kiện..." value="<c:out value='${keyword}'/>">
                </div>
            </form>

            <div class="d-flex align-items-center gap-2 gap-sm-3">
                <button type="button" class="lt-icon-btn d-none d-sm-inline-flex" id="themeToggle"
                        aria-label="Đổi chế độ hiển thị" title="Đổi chế độ hiển thị">
                    <span class="theme-icon">☼</span>
                </button>
                <button type="button" class="lt-icon-btn" aria-label="Thông báo">
                    <svg class="ico"><use href="#i-bell"/></svg><span class="lt-dot"></span>
                </button>
                <a class="lt-user-pill d-flex align-items-center gap-2 text-decoration-none" href="${ctx}/CustomerProfileController">
                    <span class="lt-avatar">${initial}</span>
                    <span class="d-none d-sm-block lh-sm">
                        <span class="d-block small fw-bold text-dark"><c:out value="${user.fullName}"/></span>
                        <span class="d-block lt-xs fw-semibold text-warning-emphasis">Khách hàng</span>
                    </span>
                </a>
            </div>
        </div>
    </div>
</header>

<!-- ===== BREADCRUMB ===== -->
<section class="lt-breadcrumb">
    <div class="container d-flex align-items-center gap-2 small fw-medium text-secondary">
        <a href="${ctx}/" class="d-flex align-items-center gap-1"><svg class="ico ico-sm"><use href="#i-home"/></svg>Trang chủ</a>
        <span>/</span>
        <a href="${ctx}/CustomerProfileController">Khách hàng</a>
        <span>/</span>
        <span class="text-dark fw-semibold">Quản lý đơn hàng</span>
        <span class="badge rounded-pill text-bg-light border text-secondary fw-semibold">Customer</span>
    </div>
</section>

<!-- ===== MAIN ===== -->
<main class="container py-4 py-lg-5 flex-grow-1">
    <div class="row g-4 align-items-start">

        <!-- SIDEBAR -->
        <aside class="col-lg-3">
            <div class="lt-card lt-profile text-center mb-4">
                <div class="lt-profile-cover"></div>
                <div class="position-relative pt-3">
                    <span class="lt-avatar lt-avatar-lg mb-3">${initial}</span>
                    <h2 class="h6 fw-bold text-dark mb-1"><c:out value="${user.fullName}"/></h2>
                    <p class="lt-side-line"><svg class="ico ico-sm"><use href="#i-mail"/></svg><c:out value="${user.email}"/></p>
                    <c:if test="${not empty user.phone}">
                        <p class="lt-side-line"><svg class="ico ico-sm"><use href="#i-phone"/></svg><c:out value="${user.phone}"/></p>
                    </c:if>
                </div>
                <div class="row g-2 mt-3 pt-3 border-top mx-0">
                    <div class="col-4 px-1"><div class="lt-mini"><b>${allCount}</b><span>Đơn đặt</span></div></div>
                    <div class="col-4 px-1"><div class="lt-mini"><b>${paidCount}</b><span>Đã thanh toán</span></div></div>
                    <div class="col-4 px-1"><div class="lt-mini"><b>${pendingCount}</b><span>Chờ TT</span></div></div>
                </div>
            </div>

            <nav class="lt-card lt-sidenav p-2 mb-4">
                <a href="${ctx}/CustomerProfileController">
                    <span><svg class="ico"><use href="#i-user"/></svg>Thông tin cá nhân</span>
                    <svg class="ico ico-sm text-secondary-emphasis"><use href="#i-chev"/></svg>
                </a>
                <a href="${ctx}/customer/booking-history" class="active">
                    <span><svg class="ico"><use href="#i-order"/></svg>Lịch sử đặt vé &amp; Đơn hàng</span>
                    <span class="badge rounded-pill bg-white text-brand">${allCount}</span>
                </a>
                <a href="${ctx}/Auth?action=changePassword">
                    <span><svg class="ico"><use href="#i-lock"/></svg>Bảo mật &amp; Đổi mật khẩu</span>
                    <svg class="ico ico-sm text-secondary-emphasis"><use href="#i-chev"/></svg>
                </a>
            </nav>

            <div class="lt-help text-center">
                <h4 class="small fw-bold text-uppercase mb-1">Cần trợ giúp đơn vé?</h4>
                <p class="lt-xs text-secondary mb-2">Tổng đài viên sẵn sàng giải đáp thắc mắc đổi/trả vé 24/7 qua hotline:</p>
                <a href="tel:19006868" class="btn btn-brand btn-sm rounded-3">📞 1900 6868</a>
            </div>
        </aside>

        <!-- CONTENT -->
        <section class="col-lg-9">

            <div class="lt-card p-4 mb-4 d-flex flex-column flex-md-row justify-content-between gap-3">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="lt-chip">Customer Dashboard</span>
                        <span class="lt-xs text-secondary">• Flow: Orders → Detail</span>
                    </div>
                    <h1 class="h3 fw-black text-dark mb-1">Lịch sử đặt vé &amp; Đơn hàng</h1>
                    <p class="small text-secondary mb-0">Xem lại toàn bộ các giao dịch đặt vé, trạng thái thanh toán và tra cứu thông tin đơn hàng.</p>
                </div>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
            </c:if>

            <!-- STATS -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-sm-3"><div class="lt-card lt-stat">
                    <div class="d-flex justify-content-between"><span class="text-secondary">Tổng đơn hàng</span><span class="lt-stat-ico bg-light text-secondary"><svg class="ico ico-sm"><use href="#i-bag"/></svg></span></div>
                    <p class="lt-stat-num text-dark">${allCount}</p><p class="lt-xs text-secondary mb-0">Tất cả giao dịch</p></div></div>
                <div class="col-6 col-sm-3"><div class="lt-card lt-stat lt-stat-paid">
                    <div class="d-flex justify-content-between"><span>Đã thanh toán</span><span class="lt-stat-ico"><svg class="ico ico-sm"><use href="#i-check"/></svg></span></div>
                    <p class="lt-stat-num">${paidCount}</p><p class="lt-xs mb-0">Vé hợp lệ check-in</p></div></div>
                <div class="col-6 col-sm-3"><div class="lt-card lt-stat lt-stat-pending">
                    <div class="d-flex justify-content-between"><span>Chờ thanh toán</span><span class="lt-stat-ico"><svg class="ico ico-sm"><use href="#i-clock"/></svg></span></div>
                    <p class="lt-stat-num">${pendingCount}</p><p class="lt-xs mb-0">Đang giữ chỗ 15p</p></div></div>
                <div class="col-6 col-sm-3"><div class="lt-card lt-stat lt-stat-cancelled">
                    <div class="d-flex justify-content-between"><span>Đã hủy</span><span class="lt-stat-ico"><svg class="ico ico-sm"><use href="#i-x"/></svg></span></div>
                    <p class="lt-stat-num text-dark">${cancelledCount}</p><p class="lt-xs text-secondary mb-0">Đơn đã hủy</p></div></div>
            </div>

            <!-- FILTERS -->
            <div class="lt-card p-3 mb-4">
                <div class="d-flex gap-2 overflow-auto pb-1 lt-tabs">
                    <c:url var="allUrl" value="/customer/booking-history">
                        <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                    </c:url>
                    <a href="${allUrl}" class="${empty status ? 'active' : ''}">Tất cả <span class="lt-count">${allCount}</span></a>
                    <c:forEach var="tab" items="${['Paid:Đã thanh toán:paid', 'Pending:Chờ thanh toán:pending', 'Cancelled:Đã hủy:cancelled']}">
                        <c:set var="tabValue" value="${fn:split(tab, ':')[0]}"/>
                        <c:url var="tabUrl" value="/customer/booking-history">
                            <c:param name="status" value="${tabValue}"/>
                            <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                        </c:url>
                        <a href="${tabUrl}" class="${status == tabValue ? 'active' : ''}">${fn:split(tab, ':')[1]}
                            <span class="lt-count lt-count-${fn:split(tab, ':')[2]}">${statusCounts[tabValue] == null ? 0 : statusCounts[tabValue]}</span></a>
                    </c:forEach>
                </div>
                <form class="d-flex gap-2 pt-3 mt-2 border-top" method="get" action="${ctx}/customer/booking-history">
                    <c:if test="${not empty status}"><input type="hidden" name="status" value="<c:out value='${status}'/>"></c:if>
                    <div class="lt-search-wrap flex-grow-1">
                        <svg class="ico lt-search-ico"><use href="#i-search"/></svg>
                        <input type="text" name="keyword" maxlength="50" class="form-control lt-search-box"
                               placeholder="Tìm theo mã đơn (ORD2026100101), tên sự kiện..." value="<c:out value='${keyword}'/>">
                    </div>
                    <button type="submit" class="btn btn-brand rounded-3">Tìm</button>
                    <a href="${ctx}/customer/booking-history" class="lt-icon-btn border" title="Làm mới bộ lọc">
                        <svg class="ico"><use href="#i-x"/></svg></a>
                </form>
            </div>

            <!-- ORDERS -->
            <c:choose>
                <c:when test="${empty bookings}">
                    <div class="lt-card text-center text-secondary py-5">
                        <c:choose>
                            <c:when test="${not empty keyword or not empty status}">Không tìm thấy đơn đặt vé phù hợp với bộ lọc.</c:when>
                            <c:otherwise>Bạn chưa có đơn đặt vé nào.</c:otherwise>
                        </c:choose>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="booking" items="${bookings}">
                        <fmt:parseDate value="${fn:substring(booking.createdAt, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="createdDate" type="both"/>
                        <fmt:formatDate value="${createdDate}" pattern="dd/MM/yyyy • HH:mm" var="createdText"/>
                        <c:if test="${not empty booking.eventStartTime}">
                            <fmt:parseDate value="${fn:substring(booking.eventStartTime, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="eventDate" type="both"/>
                            <fmt:formatDate value="${eventDate}" pattern="HH:mm - dd/MM/yyyy" var="eventTimeText"/>
                        </c:if>
                        <fmt:formatNumber value="${booking.finalAmount}" pattern="#,##0" var="finalText"/>
                        <fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0" var="totalText"/>
                        <fmt:formatNumber value="${booking.discountAmount}" pattern="#,##0" var="discountText"/>

                        <c:set var="detailBtn">
                            data-bs-toggle="modal" data-bs-target="#orderDetailModal"
                            data-code="<c:out value='${booking.orderCode}'/>" data-event="<c:out value='${booking.eventName}'/>"
                            data-time="${eventTimeText}" data-venue="<c:out value='${booking.venueName}'/>"
                            data-ticket="<c:out value='${booking.ticketName}'/> (x${booking.ticketQuantity})"
                            data-created="${createdText}" data-status="<c:out value='${booking.status}'/>"
                            data-total="${totalText} đ" data-discount="${discountText} đ" data-final="${finalText} đ"
                        </c:set>

                        <c:choose>
                        <%-- ===== PAID: thẻ lớn ===== --%>
                        <c:when test="${booking.status == 'Paid'}">
                            <article class="lt-card lt-order lt-order-paid mb-3">
                                <div class="lt-order-head d-flex flex-wrap justify-content-between align-items-center gap-2">
                                    <div class="d-flex align-items-center gap-3">
                                        <span class="lt-code"><c:out value="${booking.orderCode}"/></span>
                                        <span class="small text-secondary fw-medium">Đặt lúc: <strong class="text-dark">${createdText}</strong></span>
                                    </div>
                                    <span class="lt-status lt-status-paid"><i class="lt-pulse"></i>Thanh toán thành công • Đã xác nhận</span>
                                </div>
                                <div class="p-3 p-sm-4">
                                    <div class="row g-4">
                                        <div class="col-md-4 col-lg-3">
                                            <div class="lt-thumb"><c:if test="${not empty booking.eventImage}"><img class="js-event-image" src="${ctx}/<c:out value='${booking.eventImage}'/>" alt="<c:out value='${booking.eventName}'/>"></c:if></div>
                                        </div>
                                        <div class="col-md-8 col-lg-9 d-flex flex-column justify-content-between">
                                            <div>
                                                <h3 class="h5 fw-extrabold text-dark">${fn:escapeXml(booking.eventName)}</h3>
                                                <div class="row g-2 mt-1 small fw-medium text-body-secondary">
                                                    <div class="col-sm-6 lt-meta"><svg class="ico ico-sm text-brand"><use href="#i-cal"/></svg>Thời gian: <strong>${eventTimeText}</strong></div>
                                                    <div class="col-sm-6 lt-meta"><svg class="ico ico-sm text-brand"><use href="#i-pin"/></svg>Địa điểm: <strong><c:out value="${booking.venueName}"/></strong></div>
                                                    <div class="col-sm-6 lt-meta"><svg class="ico ico-sm text-brand"><use href="#i-ticket"/></svg>Hạng vé: <strong class="text-brand"><c:out value="${booking.ticketName}"/></strong> (x${booking.ticketQuantity} vé)</div>
                                                </div>
                                            </div>
                                            <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mt-4 pt-3 border-top">
                                                <div>
                                                    <span class="lt-xs text-secondary d-block fw-medium">Tổng tiền thanh toán:</span>
                                                    <span class="lt-price">${finalText} <u class="fs-6">đ</u></span>
                                                    <c:if test="${booking.discountAmount.signum() > 0}"><span class="lt-xs text-success ms-1">(đã giảm ${discountText} đ)</span></c:if>
                                                </div>
                                                <button type="button" class="btn btn-brand rounded-3 fw-bold small d-flex align-items-center gap-2 js-order-detail" ${detailBtn}>
                                                    <svg class="ico ico-sm"><use href="#i-eye"/></svg>Xem chi tiết đơn hàng (Detail)</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </c:when>

                        <%-- ===== PENDING: thẻ vàng + đếm ngược ===== --%>
                        <c:when test="${booking.status == 'Pending'}">
                            <article class="lt-card lt-order lt-order-pending mb-3">
                                <div class="lt-order-head d-flex flex-wrap justify-content-between align-items-center gap-2">
                                    <div class="d-flex align-items-center gap-3 flex-wrap">
                                        <span class="lt-code lt-code-pending"><c:out value="${booking.orderCode}"/></span>
                                        <c:if test="${not empty booking.holdExpiredAt}">
                                            <span class="small fw-semibold text-warning-emphasis">⏳ Thời gian giữ chỗ còn lại:
                                                <span class="lt-countdown js-countdown" data-expire="${fn:substring(booking.holdExpiredAt, 0, 19)}">--:--</span></span>
                                        </c:if>
                                    </div>
                                    <span class="lt-status lt-status-pending"><i class="lt-ping"></i>Chờ thanh toán</span>
                                </div>
                                <div class="p-3 p-sm-4">
                                    <div class="d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="lt-thumb lt-thumb-sm"><c:if test="${not empty booking.eventImage}"><img class="js-event-image" src="${ctx}/<c:out value='${booking.eventImage}'/>" alt=""></c:if></div>
                                            <div>
                                                <div class="lt-xs fw-semibold text-uppercase text-warning-emphasis"><c:out value="${booking.venueName}"/></div>
                                                <h4 class="h6 fw-bold text-dark mb-1"><c:out value="${booking.eventName}"/></h4>
                                                <p class="lt-xs text-secondary mb-0">${eventTimeText} • Hạng <c:out value="${booking.ticketName}"/> (x${booking.ticketQuantity} vé)</p>
                                            </div>
                                        </div>
                                        <div class="text-sm-end"><span class="lt-xs text-warning-emphasis d-block">Cần thanh toán:</span>
                                            <span class="fs-5 fw-extrabold text-warning-emphasis">${finalText} đ</span></div>
                                    </div>
                                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mt-3 pt-3 border-top border-warning-subtle">
                                        <p class="lt-xs text-warning-emphasis mb-0">⚠️ Vui lòng hoàn tất thanh toán để tránh việc ghế bị tự động hủy và mở bán lại.</p>
                                        <button type="button" class="btn btn-light border-warning-subtle btn-sm rounded-3 fw-bold js-order-detail" ${detailBtn}>
                                            <svg class="ico ico-sm me-1"><use href="#i-eye"/></svg>Chi tiết (Detail)</button>
                                    </div>
                                </div>
                            </article>
                        </c:when>

                        <%-- ===== CANCELLED / khác: thẻ gọn ===== --%>
                        <c:otherwise>
                            <article class="lt-card lt-order mb-3">
                                <div class="lt-order-head lt-order-head-muted d-flex flex-wrap justify-content-between align-items-center gap-2">
                                    <div class="d-flex align-items-center gap-3">
                                        <span class="lt-code lt-code-muted"><c:out value="${booking.orderCode}"/></span>
                                        <span class="small text-secondary fw-medium">Đặt ngày: ${createdText}</span>
                                    </div>
                                    <span class="lt-status lt-status-cancelled"><i class="lt-dot-sm"></i>Đã hủy</span>
                                </div>
                                <div class="p-3 p-sm-4">
                                    <div class="d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="lt-thumb lt-thumb-sm"><c:if test="${not empty booking.eventImage}"><img class="js-event-image" src="${ctx}/<c:out value='${booking.eventImage}'/>" alt=""></c:if></div>
                                            <div>
                                                <div class="lt-xs fw-semibold text-uppercase text-secondary"><c:out value="${booking.venueName}"/></div>
                                                <h4 class="h6 fw-bold text-dark mb-1"><c:out value="${booking.eventName}"/></h4>
                                                <p class="lt-xs text-secondary mb-0">${eventTimeText} • Hạng <c:out value="${booking.ticketName}"/> (x${booking.ticketQuantity} vé)</p>
                                            </div>
                                        </div>
                                        <div class="text-sm-end"><span class="lt-xs text-secondary d-block">Tổng cộng:</span><span class="fw-extrabold text-dark">${finalText} đ</span></div>
                                    </div>
                                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mt-3 pt-3 border-top">
                                        <span class="lt-xs fw-semibold text-danger">✕ Đơn hàng đã bị hủy</span>
                                        <button type="button" class="btn btn-light btn-sm rounded-3 fw-bold js-order-detail" ${detailBtn}>
                                            <svg class="ico ico-sm me-1"><use href="#i-eye"/></svg>Xem chi tiết (Detail)</button>
                                    </div>
                                </div>
                            </article>
                        </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <!-- PAGINATION -->
                    <div class="lt-card p-3 d-flex flex-column flex-sm-row justify-content-between align-items-center gap-3 small fw-semibold">
                        <div class="text-secondary">Hiển thị <b class="text-dark">${fromItem} - ${toItem}</b> trong tổng số <b class="text-dark">${totalBookings}</b> đơn hàng</div>
                        <nav aria-label="Phân trang đơn hàng">
                            <ul class="pagination pagination-sm mb-0">
                            <c:url var="prevUrl" value="/customer/booking-history"><c:param name="page" value="${currentPage - 1}"/><c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if><c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if></c:url>
                            <c:url var="nextUrl" value="/customer/booking-history"><c:param name="page" value="${currentPage + 1}"/><c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if><c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if></c:url>
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link rounded-3" href="${prevUrl}" aria-label="Trang trước">← Trước</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:url var="pageUrl" value="/customer/booking-history"><c:param name="page" value="${p}"/><c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if><c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if></c:url>
                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                    <a class="page-link rounded-3" href="${pageUrl}">${p}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link rounded-3" href="${nextUrl}" aria-label="Trang sau">Sau →</a>
                            </li>
                            </ul>
                        </nav>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>
    </div>
</main>

<!-- ===== FOOTER ===== -->
<footer class="lt-footer mt-auto">
    <div class="container d-flex flex-column flex-sm-row justify-content-between align-items-center gap-2 py-4 lt-xs text-secondary">
        <span>© Light Ticket Joint Stock Co. Bảo lưu mọi quyền.</span>
        <span class="fw-bold text-dark text-uppercase">An toàn • Liền mạch • Nhanh chóng</span>
    </div>
</footer>

<!-- ===== ORDER DETAIL MODAL ===== -->
<div class="modal fade" id="orderDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
        <div class="modal-content lt-modal">
            <div class="lt-modal-head">
                <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-4" data-bs-dismiss="modal" aria-label="Đóng"></button>
                <div class="lt-xs text-uppercase fw-semibold opacity-75 mb-1">Order Detail View • <span id="detailCode"></span></div>
                <h3 class="h5 fw-black mb-1" id="detailEvent"></h3>
                <p class="lt-xs mb-0 opacity-75">Thông tin chi tiết đơn đặt vé trực tuyến trên hệ thống Light Ticket</p>
            </div>
            <div class="modal-body p-4">
                <div class="lt-banner mb-4">
                    <div><span class="lt-xs text-secondary d-block">Trạng thái hiện tại:</span><strong class="small" id="detailStatus"></strong></div>
                    <div class="text-end"><span class="lt-xs text-secondary d-block">Ngày đặt:</span><strong class="small font-monospace" id="detailCreated"></strong></div>
                </div>
                <h4 class="lt-label">Thông tin vé &amp; Suất diễn</h4>
                <div class="row g-3 mb-4">
                    <div class="col-sm-6"><div class="lt-info"><span class="lt-xs text-secondary d-block">Thời gian diễn:</span><strong id="detailTime"></strong></div></div>
                    <div class="col-sm-6"><div class="lt-info"><span class="lt-xs text-secondary d-block">Hạng vé &amp; Số lượng:</span><strong class="text-brand" id="detailTicket"></strong></div></div>
                    <div class="col-12"><div class="lt-info"><span class="lt-xs text-secondary d-block">Địa điểm:</span><strong id="detailVenue"></strong></div></div>
                </div>
                <h4 class="lt-label">Thông tin khách hàng</h4>
                <div class="lt-info-list mb-4 small">
                    <div><span class="text-secondary">Họ và tên:</span><b><c:out value="${user.fullName}"/></b></div>
                    <div><span class="text-secondary">Email nhận vé:</span><b><c:out value="${user.email}"/></b></div>
                    <div><span class="text-secondary">Số điện thoại:</span><b><c:out value="${user.phone}"/></b></div>
                </div>
                <div class="small border-top pt-3">
                    <div class="d-flex justify-content-between text-secondary mb-1"><span>Giá gốc vé:</span><b class="text-dark" id="detailTotal"></b></div>
                    <div class="d-flex justify-content-between text-secondary mb-1"><span>Giảm giá voucher:</span><b class="text-success" id="detailDiscount"></b></div>
                    <div class="d-flex justify-content-between align-items-center border-top mt-2 pt-3">
                        <b class="text-dark">Tổng thanh toán thực tế:</b><b class="fs-4 fw-black text-brand" id="detailFinal"></b>
                    </div>
                </div>
            </div>
            <div class="modal-footer lt-modal-foot">
                <button type="button" class="btn btn-outline-secondary rounded-3 fw-bold small" data-bs-dismiss="modal">Đóng cửa sổ</button>
            </div>
        </div>
    </div>
</div>

<script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
<script src="${ctx}/assets/js/booking.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const toggle = document.getElementById('themeToggle');
        if (toggle) {
            toggle.addEventListener('click', function () {
                document.body.classList.toggle('lt-dark-preview');
                const icon = toggle.querySelector('.theme-icon');
                if (icon) icon.textContent = document.body.classList.contains('lt-dark-preview') ? '☾' : '☼';
            });
        }
    });
</script>
</body>
</html>
