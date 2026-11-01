<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.user}"/>
<c:set var="userInitial" value="${empty user.fullName ? 'U' : fn:toUpperCase(fn:substring(user.fullName, 0, 1))}"/>
<c:set var="paidCount" value="${empty statusCounts['Paid'] ? 0 : statusCounts['Paid']}"/>
<c:set var="pendingCount" value="${empty statusCounts['Pending'] ? 0 : statusCounts['Pending']}"/>
<c:set var="cancelledCount" value="${empty statusCounts['Cancelled'] ? 0 : statusCounts['Cancelled']}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vé của tôi - Lịch sử đơn hàng & Vé điện tử - Light Ticketbox</title>

    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com" rel="preconnect"/>
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>

    <!-- Material Symbols Outlined -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Stitch Design System CSS -->
    <link rel="stylesheet" href="${ctx}/assets/css/stitch-custom.css">
</head>

<body class="lt-body d-flex flex-column min-vh-100">

    <!-- ======================================================================
         HEADER (STITCH COMPATIBLE)
         ====================================================================== -->
    <header class="lt-navbar">
        <div class="container-xl d-flex align-items-center justify-content-between gap-3">
            <!-- Brand Logo -->
            <a class="lt-brand-logo" href="${ctx}/">
                <div class="lt-brand-icon">
                    <span class="material-symbols-outlined">confirmation_number</span>
                </div>
                <span class="lt-brand-title">Light <span>Ticketbox</span></span>
            </a>

            <!-- Navigation Links -->
            <nav class="d-none d-lg-flex align-items-center gap-1">
                <a class="lt-nav-link" href="${ctx}/">Trang chủ</a>
                <a class="lt-nav-link" href="${ctx}/home#events">Khám phá sự kiện</a>
                <a class="lt-nav-link active" href="${ctx}/customer/booking-history">Vé của tôi</a>
            </nav>

            <!-- Search Bar in Header -->
            <div class="lt-search-box d-none d-md-block">
                <form method="get" action="${ctx}/customer/booking-history" class="m-0">
                    <span class="material-symbols-outlined search-icon">search</span>
                    <input type="search" name="keyword" placeholder="Tìm theo mã đơn hoặc tên sự kiện..." value="<c:out value='${keyword}'/>">
                    <c:if test="${not empty status}">
                        <input type="hidden" name="status" value="<c:out value='${status}'/>">
                    </c:if>
                </form>
            </div>

            <!-- User Menu -->
            <div class="dropdown">
                <button class="lt-user-btn" type="button" id="userMenuDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <div class="lt-avatar-round">
                        <span>${userInitial}</span>
                    </div>
                    <div class="lt-user-info-text d-none d-sm-block">
                        <span class="lt-user-name"><c:out value="${empty user.fullName ? user.username : user.fullName}"/></span>
                        <span class="lt-user-tier"><c:out value="${empty user.role ? 'Khách hàng' : user.role}"/></span>
                    </div>
                    <span class="material-symbols-outlined text-secondary d-none d-sm-inline" style="font-size:18px;">expand_more</span>
                </button>

                <ul class="dropdown-menu dropdown-menu-end lt-dropdown-menu" aria-labelledby="userMenuDropdown">
                    <li class="lt-dropdown-header d-sm-none">
                        <p class="fw-bold mb-0 text-dark small"><c:out value="${user.fullName}"/></p>
                        <span class="text-secondary small"><c:out value="${user.role}"/></span>
                    </li>
                    <li>
                        <a class="lt-dropdown-item" href="${ctx}/CustomerProfileController">
                            <span class="material-symbols-outlined text-secondary" style="font-size:18px;">account_circle</span>
                            Hồ sơ của tôi
                        </a>
                    </li>
                    <li>
                        <a class="lt-dropdown-item" href="${ctx}/customer/booking-history">
                            <span class="material-symbols-outlined text-secondary" style="font-size:18px;">local_activity</span>
                            Vé của tôi
                        </a>
                    </li>
                    <li><hr class="dropdown-divider my-1"></li>
                    <li>
                        <form action="${ctx}/logout" method="POST" class="m-0">
                            <button type="submit" class="lt-dropdown-item danger border-0 bg-transparent w-100 text-start">
                                <span class="material-symbols-outlined" style="font-size:18px;">logout</span>
                                Đăng xuất
                            </button>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </header>

    <!-- ======================================================================
         MAIN CONTENT
         ====================================================================== -->
    <main class="container-xl py-4 flex-grow-1">

        <!-- Breadcrumb Navigation -->
        <nav aria-label="Breadcrumb" class="lt-breadcrumb mb-3">
            <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                <span class="material-symbols-outlined" style="font-size:16px;">home</span>
                Trang chủ
            </a>
            <span class="material-symbols-outlined separator">chevron_right</span>
            <a href="${ctx}/CustomerProfileController">Tài khoản của tôi</a>
            <span class="material-symbols-outlined separator">chevron_right</span>
            <span class="active">Vé của tôi</span>
        </nav>

        <!-- Page Header & Overview Metric Bento -->
        <div class="d-flex flex-column flex-md-row align-items-md-end justify-content-between gap-3 mb-4">
            <div>
                <div class="d-inline-flex align-items-center gap-1 mb-2 px-2 py-1 rounded-pill" style="background: var(--lt-primary-fixed); color: var(--lt-on-primary-fixed); font-size: 12px; font-weight: 600;">
                    <span class="material-symbols-outlined" style="font-size:14px;">receipt_long</span>
                    Trung tâm đơn hàng cá nhân
                </div>
                <h1 class="h2 fw-bold text-dark mb-1">Vé của tôi - Lịch sử đơn hàng &amp; Vé điện tử</h1>
                <p class="text-secondary mb-0 small">
                    Quản lý lịch sử giao dịch mua vé concert, kịch nói và workshop nghệ thuật. Tải vé điện tử và theo dõi trạng thái thanh toán theo thời gian thực.
                </p>
            </div>

            <!-- Quick stats counter pills -->
            <div class="d-flex flex-wrap align-items-center gap-2 p-2 rounded-3" style="background-color: var(--lt-surface-low);">
                <div class="d-flex align-items-center gap-2 px-3 py-1 bg-white rounded-3 shadow-sm">
                    <div class="d-flex align-items-center justify-content-center rounded-circle" style="width:32px;height:32px;background:var(--lt-success-bg);color:var(--lt-success);">
                        <span class="material-symbols-outlined" style="font-size:18px;">check_circle</span>
                    </div>
                    <div>
                        <span class="d-block text-muted" style="font-size:11px;">Thành công</span>
                        <strong class="text-dark small">${paidCount} đơn</strong>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2 px-3 py-1 bg-white rounded-3 shadow-sm">
                    <div class="d-flex align-items-center justify-content-center rounded-circle" style="width:32px;height:32px;background:var(--lt-warning-bg);color:var(--lt-warning);">
                        <span class="material-symbols-outlined" style="font-size:18px;">pending_actions</span>
                    </div>
                    <div>
                        <span class="d-block text-muted" style="font-size:11px;">Cần thanh toán</span>
                        <strong class="small" style="color:var(--lt-primary);">${pendingCount} đơn</strong>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filter Bar & Search Tabs -->
        <div class="lt-card p-3 mb-4">
            <div class="d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
                <!-- Status Tabs -->
                <div class="d-flex flex-wrap align-items-center gap-2">
                    <a href="${ctx}/customer/booking-history<c:if test='${not empty keyword}'>?keyword=<c:out value='${keyword}'/></c:if>"
                       class="btn btn-sm ${empty status ? 'btn-lt-primary' : 'btn-light'}" style="border-radius:var(--lt-radius-pill);">
                        Tất cả <span class="badge ${empty status ? 'bg-white text-dark' : 'bg-secondary'} ms-1">${allCount}</span>
                    </a>

                    <a href="${ctx}/customer/booking-history?status=Paid<c:if test='${not empty keyword}'>&keyword=<c:out value='${keyword}'/></c:if>"
                       class="btn btn-sm ${status eq 'Paid' ? 'btn-lt-primary' : 'btn-light'}" style="border-radius:var(--lt-radius-pill);">
                        Đã thanh toán <span class="badge ${status eq 'Paid' ? 'bg-white text-dark' : 'bg-secondary'} ms-1">${paidCount}</span>
                    </a>

                    <a href="${ctx}/customer/booking-history?status=Pending<c:if test='${not empty keyword}'>&keyword=<c:out value='${keyword}'/></c:if>"
                       class="btn btn-sm ${status eq 'Pending' ? 'btn-lt-primary' : 'btn-light'}" style="border-radius:var(--lt-radius-pill);">
                        Chờ xử lý <span class="badge ${status eq 'Pending' ? 'bg-white text-dark' : 'bg-secondary'} ms-1">${pendingCount}</span>
                    </a>

                    <a href="${ctx}/customer/booking-history?status=Cancelled<c:if test='${not empty keyword}'>&keyword=<c:out value='${keyword}'/></c:if>"
                       class="btn btn-sm ${status eq 'Cancelled' ? 'btn-lt-primary' : 'btn-light'}" style="border-radius:var(--lt-radius-pill);">
                        Đã hủy <span class="badge ${status eq 'Cancelled' ? 'bg-white text-dark' : 'bg-secondary'} ms-1">${cancelledCount}</span>
                    </a>
                </div>

                <!-- Search form within orders -->
                <form method="get" action="${ctx}/customer/booking-history" class="d-flex align-items-center gap-2">
                    <c:if test="${not empty status}">
                        <input type="hidden" name="status" value="<c:out value='${status}'/>">
                    </c:if>
                    <div class="input-group input-group-sm" style="max-width: 320px;">
                        <input type="text" name="keyword" class="form-control" placeholder="Tìm theo mã đơn hoặc tên..." value="<c:out value='${keyword}'/>">
                        <button class="btn btn-lt-primary" type="submit">
                            <span class="material-symbols-outlined" style="font-size:16px;">search</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Orders Feed List -->
        <div class="d-flex flex-column gap-3">
            <c:choose>
                <c:when test="${empty bookings}">
                    <!-- Empty State -->
                    <div class="lt-card p-5 text-center my-3">
                        <div class="d-inline-flex align-items-center justify-content-center rounded-circle p-4 mb-3" style="background-color: var(--lt-surface-low); color: var(--lt-primary);">
                            <span class="material-symbols-outlined" style="font-size: 48px;">receipt_long</span>
                        </div>
                        <h3 class="h5 fw-bold text-dark mb-2">Chưa tìm thấy đơn hàng nào</h3>
                        <p class="text-secondary small mb-3" style="max-width: 400px; margin: 0 auto;">
                            <c:choose>
                                <c:when test="${not empty keyword or not empty status}">
                                    Không có đơn hàng nào khớp với bộ lọc hiện tại. Vui lòng thử tìm kiếm với từ khóa khác hoặc xóa bộ lọc.
                                </c:when>
                                <c:otherwise>
                                    Bạn chưa có đơn đặt vé nào. Hãy khám phá các buổi biểu diễn âm nhạc, concert và workshop hấp dẫn đang mở bán!
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <div class="d-flex justify-content-center gap-2">
                            <c:if test="${not empty keyword or not empty status}">
                                <a href="${ctx}/customer/booking-history" class="btn-lt-secondary btn-sm">Xem tất cả đơn</a>
                            </c:if>
                            <a href="${ctx}/home#events" class="btn-lt-primary btn-sm">Khám phá sự kiện ngay</a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- List of Order Cards -->
                    <c:forEach var="booking" items="${bookings}">
                        <c:if test="${not empty booking.createdAt}">
                            <fmt:parseDate value="${fn:substring(booking.createdAt, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="createdDate" type="both"/>
                            <fmt:formatDate value="${createdDate}" pattern="HH:mm • dd/MM/yyyy" var="createdText"/>
                        </c:if>
                        <c:if test="${not empty booking.eventStartTime}">
                            <fmt:parseDate value="${fn:substring(booking.eventStartTime, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="startDate" type="both"/>
                            <fmt:formatDate value="${startDate}" pattern="HH:mm • dd/MM/yyyy" var="startText"/>
                        </c:if>

                        <article class="lt-card p-3 p-md-4">
                            <!-- Top bar: Order ID, Date, Status -->
                            <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 pb-3 mb-3 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                                <div class="d-flex flex-wrap align-items-center gap-3">
                                    <div class="d-flex align-items-center gap-1">
                                        <span class="material-symbols-outlined text-primary" style="font-size:20px;color:var(--lt-primary)!important;">confirmation_number</span>
                                        <span class="small fw-bold text-dark">Mã đơn: <span style="color:var(--lt-primary); font-family:monospace; font-size:1rem;">#<c:out value="${booking.orderCode}"/></span></span>
                                    </div>
                                    <div class="d-flex align-items-center gap-1 text-secondary small">
                                        <span class="material-symbols-outlined" style="font-size:16px;">schedule</span>
                                        <span>Ngày đặt: <c:out value="${createdText}"/></span>
                                    </div>
                                </div>

                                <!-- Status Badge -->
                                <div>
                                    <c:choose>
                                        <c:when test="${booking.status eq 'Paid'}">
                                            <span class="lt-pill lt-pill-paid">
                                                <span class="material-symbols-outlined" style="font-size:14px;">check_circle</span>
                                                Đã thanh toán thành công
                                            </span>
                                        </c:when>
                                        <c:when test="${booking.status eq 'Pending'}">
                                            <span class="lt-pill lt-pill-pending">
                                                <span class="material-symbols-outlined" style="font-size:14px;">hourglass_top</span>
                                                Chờ thanh toán
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="lt-pill lt-pill-cancelled">
                                                <span class="material-symbols-outlined" style="font-size:14px;">cancel</span>
                                                Đã hủy
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Bento Split Content -->
                            <div class="row g-3 align-items-center mb-3">
                                <!-- Thumbnail Poster -->
                                <div class="col-md-3 col-sm-4">
                                    <div class="position-relative rounded-3 overflow-hidden" style="aspect-ratio: 16/10; background-color: var(--lt-surface-low);">
                                        <c:choose>
                                            <c:when test="${not empty booking.eventImage and fn:startsWith(booking.eventImage, 'http')}">
                                                <img src="<c:out value='${booking.eventImage}'/>" alt="Event Poster" class="w-100 h-100 object-fit-cover" onerror="this.parentElement.innerHTML='<div class=\'d-flex align-items-center justify-content-center w-100 h-100 text-muted\'><span class=\'material-symbols-outlined\'>confirmation_number</span></div>';">
                                            </c:when>
                                            <c:when test="${not empty booking.eventImage}">
                                                <img src="${ctx}/<c:out value='${booking.eventImage}'/>" alt="Event Poster" class="w-100 h-100 object-fit-cover" onerror="this.parentElement.innerHTML='<div class=\'d-flex align-items-center justify-content-center w-100 h-100 text-muted\'><span class=\'material-symbols-outlined\'>confirmation_number</span></div>';">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="d-flex align-items-center justify-content-center w-100 h-100 text-muted">
                                                    <span class="material-symbols-outlined" style="font-size:32px;">confirmation_number</span>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <span class="position-absolute top-0 start-0 m-2 px-2 py-0.5 rounded-pill bg-dark text-white" style="font-size:10px; font-weight:700; opacity:0.85;">
                                            SỰ KIỆN
                                        </span>
                                    </div>
                                </div>

                                <!-- Event Info -->
                                <div class="col-md-6 col-sm-8 d-flex flex-column justify-content-between">
                                    <div>
                                        <h2 class="h6 fw-bold text-dark mb-2 text-truncate" title="<c:out value="${booking.eventName}"/>">
                                            <a href="${ctx}/customer/booking-detail?orderId=${booking.bookingId}" class="text-dark text-decoration-none hover-primary">
                                                <c:out value="${booking.eventName}" default="Sự kiện trực tiếp"/>
                                            </a>
                                        </h2>
                                        <div class="d-flex flex-column gap-1 small text-secondary mb-2">
                                            <div class="d-flex align-items-center gap-1">
                                                <span class="material-symbols-outlined text-primary" style="font-size:16px;color:var(--lt-primary)!important;">event</span>
                                                <span><c:out value="${startText}" default="Thời gian chưa cập nhật"/></span>
                                            </div>
                                            <div class="d-flex align-items-center gap-1">
                                                <span class="material-symbols-outlined text-muted" style="font-size:16px;">location_on</span>
                                                <span class="text-truncate"><c:out value="${booking.venueName}" default="Địa điểm sự kiện"/></span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Ticket Quantity Chip -->
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="px-2 py-1 rounded-2 small" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                            <span class="material-symbols-outlined text-success align-middle" style="font-size:15px;">chair</span>
                                            <c:out value="${booking.ticketQuantity}"/> vé
                                            <c:if test="${not empty booking.ticketName}">· <c:out value="${booking.ticketName}"/></c:if>
                                        </span>
                                    </div>
                                </div>

                                <!-- Total Payment Card -->
                                <div class="col-md-3 text-md-end p-3 rounded-3" style="background-color: var(--lt-surface-low);">
                                    <span class="text-secondary small d-block">Tổng thanh toán:</span>
                                    <strong class="h5 fw-bold d-block my-1" style="color:var(--lt-primary);">
                                        <fmt:formatNumber value="${booking.finalAmount}" pattern="#,##0"/> đ
                                    </strong>
                                    <span class="text-muted" style="font-size:11px;">
                                        <c:choose>
                                            <c:when test="${booking.status eq 'Paid'}">Đã thanh toán đủ</c:when>
                                            <c:when test="${booking.status eq 'Pending'}">Cần thanh toán qua cổng</c:when>
                                            <c:otherwise>Giao dịch đã hủy</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>

                            <!-- Actions Toolbar -->
                            <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 pt-2 border-top" style="border-color: var(--lt-surface-border)!important;">
                                <div class="d-flex align-items-center gap-1 text-secondary small">
                                    <c:choose>
                                        <c:when test="${booking.status eq 'Paid'}">
                                            <span class="material-symbols-outlined text-success" style="font-size:16px;">verified_user</span>
                                            <span>Vé chính hãng đã kích hoạt mã định danh bảo mật</span>
                                        </c:when>
                                        <c:when test="${booking.status eq 'Pending'}">
                                            <span class="material-symbols-outlined text-danger" style="font-size:16px;">timer</span>
                                            <span class="text-danger">Đơn hàng đang giữ vé, vui lòng thanh toán sớm</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="material-symbols-outlined text-muted" style="font-size:16px;">info</span>
                                            <span>Đơn hàng đã hết hạn hoặc bị hủy</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="d-flex flex-wrap align-items-center gap-2">
                                    <c:if test="${booking.status eq 'Pending'}">
                                        <a href="${ctx}/booking/payment?orderId=${booking.bookingId}" class="btn-lt-primary btn-sm">
                                            <span class="material-symbols-outlined" style="font-size:16px;">credit_card</span>
                                            Thanh toán ngay
                                        </a>
                                    </c:if>

                                    <!-- CTA Direct into Order Detail Screen (UC-07.1) -->
                                    <a href="${ctx}/customer/booking-detail?orderId=${booking.bookingId}" class="btn-lt-secondary btn-sm">
                                        Xem chi tiết đơn
                                        <span class="material-symbols-outlined" style="font-size:16px;">arrow_forward</span>
                                    </a>
                                </div>
                            </div>
                        </article>
                    </c:forEach>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Order pagination" class="mt-4">
                            <ul class="pagination justify-content-center">
                                <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="${ctx}/customer/booking-history?page=${currentPage - 1}<c:if test='${not empty status}'>&status=<c:out value='${status}'/></c:if><c:if test='${not empty keyword}'>&keyword=<c:out value='${keyword}'/></c:if>">
                                        &laquo; Trang trước
                                    </a>
                                </li>
                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="${ctx}/customer/booking-history?page=${p}<c:if test='${not empty status}'>&status=<c:out value='${status}'/></c:if><c:if test='${not empty keyword}'>&keyword=<c:out value='${keyword}'/></c:if>">
                                            ${p}
                                        </a>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="${ctx}/customer/booking-history?page=${currentPage + 1}<c:if test='${not empty status}'>&status=<c:out value='${status}'/></c:if><c:if test='${not empty keyword}'>&keyword=<c:out value='${keyword}'/></c:if>">
                                        Trang sau &raquo;
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <!-- ======================================================================
         FOOTER
         ====================================================================== -->
    <footer class="lt-footer">
        <div class="container-xl d-flex flex-column flex-md-row align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <div class="lt-brand-icon" style="width:30px;height:30px;border-radius:8px;">
                    <span class="material-symbols-outlined" style="font-size:18px;">confirmation_number</span>
                </div>
                <span class="fw-bold text-dark">Light Ticketbox</span>
            </div>
            <div class="d-flex align-items-center gap-4 small">
                <a href="${ctx}/">Trang chủ</a>
                <a href="${ctx}/customer/booking-history">Vé của tôi</a>
                <a href="${ctx}/CustomerProfileController">Hồ sơ cá nhân</a>
            </div>
            <span class="text-secondary small">© 2026 Light Ticket. All rights reserved.</span>
        </div>
    </footer>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
