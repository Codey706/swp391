<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.user}"/>
<c:set var="userInitial" value="${empty user.fullName ? 'U' : fn:toUpperCase(fn:substring(user.fullName, 0, 1))}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn hàng - Light Ticketbox</title>

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
         HEADER (STITCH COMPATIBLE WITH ACCOUNT DROPDOWN)
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
                    <input type="search" name="keyword" placeholder="Tìm theo mã đơn hoặc tên sự kiện...">
                </form>
            </div>

            <!-- User Menu (Avatar -> Account Dropdown -> Hồ sơ của tôi) -->
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

        <c:choose>
            <c:when test="${not empty errorMessage}">
                <!-- Error State -->
                <div class="lt-card p-4 text-center my-4">
                    <div class="d-inline-flex p-3 rounded-circle mb-3" style="background:var(--lt-danger-bg);color:var(--lt-danger);">
                        <span class="material-symbols-outlined" style="font-size:36px;">error</span>
                    </div>
                    <h2 class="h5 fw-bold text-dark mb-2">Không thể tải chi tiết đơn hàng</h2>
                    <p class="text-secondary small mb-3"><c:out value="${errorMessage}"/></p>
                    <a href="${ctx}/customer/booking-history" class="btn-lt-secondary btn-sm">
                        <span class="material-symbols-outlined" style="font-size:16px;">arrow_back</span>
                        Quay lại Vé của tôi
                    </a>
                </div>
            </c:when>

            <c:when test="${not empty booking}">
                <c:if test="${not empty booking.createdAt}">
                    <fmt:parseDate value="${fn:substring(booking.createdAt, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="createdDate" type="both"/>
                    <fmt:formatDate value="${createdDate}" pattern="HH:mm • dd/MM/yyyy" var="createdText"/>
                </c:if>
                <c:if test="${not empty booking.eventStartTime}">
                    <fmt:parseDate value="${fn:substring(booking.eventStartTime, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="eventStartDate" type="both"/>
                    <fmt:formatDate value="${eventStartDate}" pattern="HH:mm • dd/MM/yyyy" var="eventStartText"/>
                </c:if>
                <c:if test="${not empty booking.eventEndTime}">
                    <fmt:parseDate value="${fn:substring(booking.eventEndTime, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="eventEndDate" type="both"/>
                    <fmt:formatDate value="${eventEndDate}" pattern="HH:mm • dd/MM/yyyy" var="eventEndText"/>
                </c:if>

                <!-- Top Action & Navigation Bar -->
                <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3">
                    <nav aria-label="Breadcrumb" class="lt-breadcrumb mb-0">
                        <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                            <span class="material-symbols-outlined" style="font-size:16px;">home</span>
                            Trang chủ
                        </a>
                        <span class="material-symbols-outlined separator">chevron_right</span>
                        <a href="${ctx}/customer/booking-history">Vé của tôi</a>
                        <span class="material-symbols-outlined separator">chevron_right</span>
                        <span class="active">Chi tiết đơn hàng #<c:out value="${booking.orderCode}"/></span>
                    </nav>

                    <a href="${ctx}/customer/booking-history" class="btn-lt-secondary btn-sm">
                        <span class="material-symbols-outlined" style="font-size:16px;">arrow_back</span>
                        Quay lại Vé của tôi
                    </a>
                </div>

                <!-- Order Header Hero Card -->
                <div class="lt-card p-4 mb-4">
                    <div class="d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
                        <div>
                            <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                                <h1 class="h3 fw-bold text-dark mb-0">Đơn hàng #<c:out value="${booking.orderCode}"/></h1>
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

                            <div class="d-flex flex-wrap align-items-center gap-3 small text-secondary">
                                <span class="d-flex align-items-center gap-1">
                                    <span class="material-symbols-outlined" style="font-size:16px;">schedule</span>
                                    Thời gian đặt: <strong><c:out value="${createdText}"/></strong>
                                </span>
                                <c:if test="${not empty booking.payment}">
                                    <span class="d-flex align-items-center gap-1">
                                        <span class="material-symbols-outlined" style="font-size:16px;">payments</span>
                                        Kênh thanh toán: <strong><c:out value="${booking.payment.paymentMethod}"/></strong>
                                    </span>
                                    <c:if test="${not empty booking.payment.transactionCode}">
                                        <span class="d-inline-block px-2 py-0.5 rounded bg-light border small font-monospace">
                                            Mã GD: <c:out value="${booking.payment.transactionCode}"/>
                                        </span>
                                    </c:if>
                                </c:if>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="d-flex flex-wrap align-items-center gap-2">
                            <c:choose>
                                <c:when test="${booking.status eq 'Paid'}">
                                    <button type="button" class="btn-lt-primary" data-bs-toggle="modal" data-bs-target="#eTicketModal">
                                        <span class="material-symbols-outlined" style="font-size:18px;">confirmation_number</span>
                                        Xem E-Ticket &amp; QR Code
                                    </button>
                                </c:when>
                                <c:when test="${booking.status eq 'Pending'}">
                                    <a href="${ctx}/booking/payment?orderId=${booking.bookingId}" class="btn-lt-primary">
                                        <span class="material-symbols-outlined" style="font-size:18px;">credit_card</span>
                                        Thanh toán ngay
                                    </a>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- 2-Column Desktop Grid Layout (65% / 35%) -->
                <div class="row g-4 align-items-start">
                    
                    <!-- LEFT COLUMN (col-lg-8) -->
                    <div class="col-lg-8 d-flex flex-column gap-4">
                        
                        <!-- Event Summary Card -->
                        <div class="lt-card p-4">
                            <div class="d-flex flex-column flex-sm-row gap-3 align-items-start">
                                <div class="rounded-3 overflow-hidden flex-shrink-0" style="width: 160px; aspect-ratio: 16/10; background-color: var(--lt-surface-low);">
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
                                </div>

                                <div class="flex-grow-1">
                                    <div class="d-flex align-items-center gap-1 text-success small fw-bold mb-1">
                                        <span class="material-symbols-outlined" style="font-size:16px;">verified</span>
                                        <span>Sự kiện trực tiếp chính hãng</span>
                                    </div>
                                    <h2 class="h5 fw-bold text-dark mb-2">
                                        <c:out value="${booking.eventName}" default="Sự kiện âm nhạc"/>
                                    </h2>
                                    <div class="d-flex flex-column gap-1 small text-secondary">
                                        <div class="d-flex align-items-start gap-1">
                                            <span class="material-symbols-outlined text-primary mt-0.5" style="font-size:16px;color:var(--lt-primary)!important;">calendar_today</span>
                                            <span><strong><c:out value="${eventStartText}" default="Chưa cập nhật"/></strong><c:if test="${not empty eventEndText}"> – <c:out value="${eventEndText}"/></c:if></span>
                                        </div>
                                        <div class="d-flex align-items-start gap-1">
                                            <span class="material-symbols-outlined text-muted mt-0.5" style="font-size:16px;">location_on</span>
                                            <span><strong class="text-dark"><c:out value="${booking.venueName}"/></strong> - <c:out value="${booking.venueAddress}"/></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Ticket List (Ticket Stubs Design) -->
                        <div class="lt-card p-4">
                            <div class="d-flex align-items-center justify-content-between pb-3 mb-3 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="material-symbols-outlined text-primary" style="font-size:22px;color:var(--lt-primary)!important;">local_activity</span>
                                    <h3 class="h6 fw-bold text-dark mb-0">Danh sách vé điện tử trong đơn (<c:out value="${booking.ticketQuantity}"/> vé)</h3>
                                </div>
                                <span class="badge bg-light text-secondary border small">Check-in QR tại cổng</span>
                            </div>

                            <div class="d-flex flex-column gap-3">
                                <c:choose>
                                    <c:when test="${not empty booking.items}">
                                        <c:forEach var="item" items="${booking.items}" varStatus="status">
                                            <!-- Ticket Stub Item -->
                                            <div class="lt-ticket-stub p-3">
                                                <div class="lt-ticket-notch-left"></div>
                                                <div class="lt-ticket-notch-right"></div>
                                                
                                                <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-3 px-2">
                                                    <div>
                                                        <div class="d-flex align-items-center gap-2 mb-1">
                                                            <span class="badge bg-primary text-white" style="background:var(--lt-primary)!important;">Hạng vé</span>
                                                            <h4 class="h6 fw-bold text-dark mb-0"><c:out value="${item.ticketName}"/></h4>
                                                        </div>
                                                        <span class="text-muted small">
                                                            Số lượng: <strong><c:out value="${item.quantity}"/> vé</strong> · Đơn giá: <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/> đ
                                                        </span>
                                                    </div>

                                                    <div class="text-sm-end">
                                                        <span class="text-muted small d-block">Thành tiền</span>
                                                        <strong class="h6 fw-bold text-primary mb-0" style="color:var(--lt-primary)!important;">
                                                            <fmt:formatNumber value="${item.subtotal}" pattern="#,##0"/> đ
                                                        </strong>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <p class="text-secondary small mb-0">Không có thông tin chi tiết loại vé trong đơn này.</p>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Seats Breakdown if available -->
                                <c:if test="${not empty booking.seatLabels}">
                                    <div class="p-3 rounded-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                        <div class="d-flex align-items-center gap-1 small fw-bold text-dark mb-2">
                                            <span class="material-symbols-outlined text-primary" style="font-size:16px;color:var(--lt-primary)!important;">chair</span>
                                            <span>Vị trí ghế đã chọn:</span>
                                        </div>
                                        <div class="d-flex flex-wrap gap-2">
                                            <c:forEach var="seat" items="${booking.seatLabels}">
                                                <span class="badge bg-white text-dark border px-2 py-1">${seat}</span>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- Customer Information Card -->
                        <div class="lt-card p-4">
                            <div class="d-flex align-items-center gap-2 pb-3 mb-3 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                                <span class="material-symbols-outlined text-primary" style="font-size:22px;color:var(--lt-primary)!important;">person</span>
                                <h3 class="h6 fw-bold text-dark mb-0">Thông tin người nhận vé</h3>
                            </div>

                            <div class="row g-3 small">
                                <div class="col-md-4">
                                    <span class="text-muted d-block mb-1">Họ và tên</span>
                                    <strong class="text-dark"><c:out value="${user.fullName}" default="Chưa cập nhật"/></strong>
                                </div>
                                <div class="col-md-4">
                                    <span class="text-muted d-block mb-1">Email nhận vé</span>
                                    <strong class="text-dark text-break"><c:out value="${user.email}" default="Chưa cập nhật"/></strong>
                                </div>
                                <div class="col-md-4">
                                    <span class="text-muted d-block mb-1">Số điện thoại</span>
                                    <strong class="text-dark"><c:out value="${user.phone}" default="Chưa cập nhật"/></strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT COLUMN: Payment Summary & Support (col-lg-4) -->
                    <aside class="col-lg-4 d-flex flex-column gap-4">
                        
                        <!-- Payment Summary Card -->
                        <div class="lt-card p-4">
                            <div class="d-flex align-items-center gap-2 pb-3 mb-3 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                                <span class="material-symbols-outlined text-primary" style="font-size:22px;color:var(--lt-primary)!important;">receipt_long</span>
                                <h3 class="h6 fw-bold text-dark mb-0">Tóm tắt thanh toán</h3>
                            </div>

                            <div class="d-flex flex-column gap-2 small mb-3">
                                <div class="d-flex justify-content-between text-secondary">
                                    <span>Tạm tính</span>
                                    <strong class="text-dark"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0"/> đ</strong>
                                </div>

                                <div class="d-flex justify-content-between text-success">
                                    <span>Giảm giá khuyến mãi</span>
                                    <strong>- <fmt:formatNumber value="${booking.discountAmount}" pattern="#,##0"/> đ</strong>
                                </div>

                                <c:if test="${not empty booking.voucherCode}">
                                    <div class="p-2 rounded-2 d-flex align-items-center justify-content-between" style="background-color: var(--lt-surface-low);">
                                        <span class="text-muted small">Voucher áp dụng:</span>
                                        <span class="badge bg-white text-primary border small font-monospace"><c:out value="${booking.voucherCode}"/></span>
                                    </div>
                                </c:if>

                                <hr class="my-2" style="border-color: var(--lt-surface-border);">

                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="fw-bold text-dark">Tổng thanh toán</span>
                                    <strong class="h5 fw-bold mb-0" style="color:var(--lt-primary);">
                                        <fmt:formatNumber value="${booking.finalAmount}" pattern="#,##0"/> đ
                                    </strong>
                                </div>
                            </div>

                            <c:if test="${not empty booking.payment}">
                                <div class="p-3 rounded-3 small text-secondary" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>Phương thức:</span>
                                        <strong class="text-dark"><c:out value="${booking.payment.paymentMethod}"/></strong>
                                    </div>
                                    <c:if test="${not empty booking.payment.paidAt}">
                                        <fmt:parseDate value="${fn:substring(booking.payment.paidAt, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="paidDate" type="both"/>
                                        <fmt:formatDate value="${paidDate}" pattern="HH:mm • dd/MM/yyyy" var="paidText"/>
                                        <div class="d-flex justify-content-between mb-1">
                                            <span>Thời gian TT:</span>
                                            <span class="text-dark"><c:out value="${paidText}"/></span>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty booking.payment.transactionCode}">
                                        <div class="d-flex justify-content-between">
                                            <span>Mã giao dịch:</span>
                                            <span class="font-monospace text-dark"><c:out value="${booking.payment.transactionCode}"/></span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>

                        <!-- Check-in Guide Card -->
                        <div class="lt-card p-4">
                            <div class="d-flex align-items-center gap-2 pb-2 mb-2">
                                <span class="material-symbols-outlined text-primary" style="font-size:22px;color:var(--lt-primary)!important;">qr_code_scanner</span>
                                <h3 class="h6 fw-bold text-dark mb-0">Hướng dẫn check-in sự kiện</h3>
                            </div>
                            <p class="small text-secondary mb-3">
                                Chuẩn bị mã QR vé điện tử E-Ticket khi đến địa điểm. Nhân viên sẽ quét vé tại cửa soát vé để bạn vào khán phòng.
                            </p>
                            <ul class="list-unstyled d-flex flex-column gap-2 small text-secondary mb-0">
                                <li class="d-flex align-items-start gap-2">
                                    <span class="material-symbols-outlined text-success mt-0.5" style="font-size:16px;">check</span>
                                    <span>Mở vé điện tử trên điện thoại hoặc tải file PDF trước khi đến.</span>
                                </li>
                                <li class="d-flex align-items-start gap-2">
                                    <span class="material-symbols-outlined text-success mt-0.5" style="font-size:16px;">check</span>
                                    <span>Mỗi vé chỉ sử dụng check-in 01 lần tại cổng sự kiện.</span>
                                </li>
                                <li class="d-flex align-items-start gap-2">
                                    <span class="material-symbols-outlined text-success mt-0.5" style="font-size:16px;">check</span>
                                    <span>Có mặt trước giờ biểu diễn ít nhất 30 phút để ổn định chỗ ngồi.</span>
                                </li>
                            </ul>
                        </div>

                        <!-- Support Hotline Card -->
                        <div class="lt-card p-3 d-flex align-items-center gap-3">
                            <div class="d-flex align-items-center justify-content-center rounded-circle p-2" style="background:var(--lt-primary-fixed);color:var(--lt-primary);">
                                <span class="material-symbols-outlined" style="font-size:24px;">support_agent</span>
                            </div>
                            <div>
                                <span class="d-block small text-muted">Cần hỗ trợ đơn hàng?</span>
                                <strong class="text-dark">Hotline: <a href="tel:19006868" class="text-decoration-none" style="color:var(--lt-primary);">1900 6868</a></strong>
                            </div>
                        </div>

                    </aside>
                </div>

                <!-- E-Ticket Modal -->
                <div class="modal fade" id="eTicketModal" tabindex="-1" aria-labelledby="eTicketModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content border-0 shadow-lg" style="border-radius: var(--lt-radius-lg);">
                            <div class="modal-header border-0 pb-0">
                                <div class="d-flex align-items-center gap-2">
                                    <div class="lt-brand-icon" style="width:32px;height:32px;border-radius:8px;">
                                        <span class="material-symbols-outlined" style="font-size:18px;">confirmation_number</span>
                                    </div>
                                    <h5 class="modal-title fw-bold text-dark" id="eTicketModalLabel">Vé điện tử E-Ticket</h5>
                                </div>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4 text-center">
                                <span class="badge bg-success-subtle text-success px-3 py-1 rounded-pill small mb-2">
                                    Đơn hàng #<c:out value="${booking.orderCode}"/>
                                </span>
                                <h4 class="h6 fw-bold text-dark mb-1"><c:out value="${booking.eventName}"/></h4>
                                <p class="text-secondary small mb-3"><c:out value="${eventStartText}"/></p>

                                <!-- QR Mock -->
                                <div class="p-3 bg-light rounded-3 d-inline-block border mb-3">
                                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${booking.orderCode}" alt="QR Check-in" class="rounded" style="width: 160px; height: 160px;" onerror="this.outerHTML='<div style=\'width:160px;height:160px;display:flex;align-items:center;justify-content:center;\'><span class=\'material-symbols-outlined\' style=\'font-size:64px;color:var(--lt-primary);\'>qr_code_2</span></div>';">
                                    <span class="d-block text-muted small mt-2 font-monospace">Mã soát vé: <c:out value="${booking.orderCode}"/></span>
                                </div>

                                <div class="text-start small p-3 rounded-3" style="background-color: var(--lt-surface-low);">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Người đặt:</span>
                                        <strong class="text-dark"><c:out value="${user.fullName}"/></strong>
                                    </div>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Tổng số vé:</span>
                                        <strong class="text-dark"><c:out value="${booking.ticketQuantity}"/> vé</strong>
                                    </div>
                                    <c:if test="${not empty booking.seatLabels}">
                                        <div class="d-flex justify-content-between">
                                            <span class="text-muted">Ghế:</span>
                                            <strong class="text-dark"><c:forEach var="s" items="${booking.seatLabels}" varStatus="loop"><c:if test="${loop.index gt 0}">, </c:if>${s}</c:forEach></strong>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                            <div class="modal-footer border-0 pt-0">
                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                                <button type="button" class="btn-lt-primary btn-sm" onclick="window.print()">In vé / Tải về</button>
                            </div>
                        </div>
                    </div>
                </div>

            </c:when>

            <c:otherwise>
                <div class="lt-card p-5 text-center my-4">
                    <span class="material-symbols-outlined text-muted" style="font-size:48px;">receipt_long</span>
                    <h2 class="h5 fw-bold text-dark mt-2 mb-1">Không có dữ liệu đơn hàng</h2>
                    <p class="text-secondary small mb-3">Vui lòng quay lại danh sách Vé của tôi để chọn đơn hàng bạn muốn xem.</p>
                    <a href="${ctx}/customer/booking-history" class="btn-lt-primary btn-sm">Quay lại Vé của tôi</a>
                </div>
            </c:otherwise>
        </c:choose>

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
