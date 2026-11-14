<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %><fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.user}"/>
<c:set var="userInitial" value="${empty user.fullName ? 'U' : fn:toUpperCase(fn:substring(user.fullName, 0, 1))}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chi tiết đơn hàng - Light Ticket</title>

        <!-- Google Fonts: Plus Jakarta Sans -->
        <link href="https://fonts.googleapis.com" rel="preconnect"/>
        <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>

        <!-- Material Symbols Outlined -->

        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Stitch Design System CSS -->
        <link rel="stylesheet" href="${ctx}/assets/css/stitch-custom.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/phosphor/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/phosphor/fill.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ui.css">
        <script src="${pageContext.request.contextPath}/assets/js/ui.js" defer></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=20261109">
        <script src="${pageContext.request.contextPath}/assets/js/motion.js?v=20261109" defer></script>
    </head>

    <body class="lt-body d-flex flex-column min-vh-100">

        <!-- ======================================================================
             HEADER (STITCH COMPATIBLE WITH ACCOUNT DROPDOWN)
             ====================================================================== -->
        <jsp:include page="/WEB-INF/views/common/site-header.jsp">
            <jsp:param name="active" value="tickets"/>
        </jsp:include>

        <!-- ======================================================================
             MAIN CONTENT
             ====================================================================== -->
        <main class="container-xl py-4 flex-grow-1">

            <c:choose>
                <c:when test="${not empty errorMessage}">
                    <!-- Error State -->
                    <div class="lt-card p-4 text-center my-4">
                        <div class="d-inline-flex p-3 rounded-circle mb-3" style="background:var(--lt-danger-bg);color:var(--lt-danger);">
                            <i class="ph ph-warning-circle" style="font-size:36px;" aria-hidden="true"></i>
                        </div>
                        <h2 class="h5 fw-bold text-dark mb-2">Không thể tải chi tiết đơn hàng</h2>
                        <p class="text-secondary small mb-3"><c:out value="${errorMessage}"/></p>
                        <a href="${ctx}/customer/booking-history" class="btn-lt-secondary btn-sm">
                            <i class="ph ph-arrow-left" style="font-size:16px;" aria-hidden="true"></i>
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
                                <i class="ph ph-house" style="font-size:16px;" aria-hidden="true"></i>
                                Trang chủ
                            </a>
                            <i class="ph ph-caret-right separator" aria-hidden="true"></i>
                            <a href="${ctx}/customer/booking-history">Vé của tôi</a>
                            <i class="ph ph-caret-right separator" aria-hidden="true"></i>
                            <span class="active">Chi tiết đơn hàng #<c:out value="${booking.orderCode}"/></span>
                        </nav>

                        <a href="${ctx}/customer/booking-history" class="btn-lt-secondary btn-sm">
                            <i class="ph ph-arrow-left" style="font-size:16px;" aria-hidden="true"></i>
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
                                            <span class="lt-pill lt-pill-lg lt-pill-paid">
                                                <i class="ph ph-check-circle" style="font-size:18px;" aria-hidden="true"></i>
                                                Đã thanh toán thành công
                                            </span>
                                        </c:when>
                                        <c:when test="${booking.status eq 'Pending'}">
                                            <span class="lt-pill lt-pill-lg lt-pill-pending">
                                                <i class="ph ph-hourglass-high" style="font-size:18px;" aria-hidden="true"></i>
                                                Chờ thanh toán
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="lt-pill lt-pill-lg lt-pill-cancelled">
                                                <i class="ph ph-x-circle" style="font-size:18px;" aria-hidden="true"></i>
                                                Đã hủy
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="d-flex flex-wrap align-items-center gap-3 small text-secondary">
                                    <span class="d-flex align-items-center gap-1">
                                        <i class="ph ph-clock" style="font-size:16px;" aria-hidden="true"></i>
                                        Thời gian đặt: <strong><c:out value="${createdText}"/></strong>
                                    </span>
                                    <c:if test="${not empty booking.payment}">
                                        <span class="d-flex align-items-center gap-1">
                                            <i class="ph ph-money" style="font-size:16px;" aria-hidden="true"></i>
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
                                            <i class="ph ph-ticket" style="font-size:18px;" aria-hidden="true"></i>
                                            Xem E-Ticket &amp; QR Code
                                        </button>
                                    </c:when>
                                    <c:when test="${booking.status eq 'Pending'}">
                                        <a href="${ctx}/booking/payment?orderId=${booking.bookingId}" class="btn-lt-primary">
                                            <i class="ph ph-credit-card" style="font-size:18px;" aria-hidden="true"></i>
                                            Thanh toán ngay
                                        </a>
                                    </c:when>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Khung trạng thái lớn: nhìn vào là biết đơn đã thành công hay chưa -->
                    <c:choose>
                        <c:when test="${booking.status eq 'Paid'}">
                            <c:set var="stBg" value="#e7f6ee"/><c:set var="stBorder" value="#bfe3cf"/><c:set var="stColor" value="#0e6b3e"/>
                            <c:set var="stIcon" value="ph-check-circle"/>
                            <c:set var="stTitle" value="Thanh toán thành công"/>
                            <c:set var="stText" value="Vé của bạn đã được xác nhận. Mở E-Ticket để lấy mã QR check-in tại cổng sự kiện."/>
                        </c:when>
                        <c:when test="${booking.status eq 'Pending'}">
                            <c:set var="stBg" value="#fff4dc"/><c:set var="stBorder" value="#f5d9a0"/><c:set var="stColor" value="#b42e1d"/>
                            <c:set var="stIcon" value="ph-hourglass-high"/>
                            <c:set var="stTitle" value="Chờ thanh toán"/>
                            <c:set var="stText" value="Đơn chưa được thanh toán. Hoàn tất thanh toán trước khi hết thời gian giữ vé, nếu không đơn sẽ tự động bị hủy."/>
                        </c:when>
                        <c:when test="${fn:startsWith(booking.status, 'Refund')}">
                            <c:set var="stBg" value="#f5f5f6"/><c:set var="stBorder" value="#d4d4d8"/><c:set var="stColor" value="#77777e"/>
                            <c:set var="stIcon" value="ph-arrow-counter-clockwise"/>
                            <c:set var="stTitle" value="${booking.status eq 'Refunded' ? 'Đã hoàn tiền' : 'Đang xử lý hoàn tiền'}"/>
                            <c:set var="stText" value="Đơn đã bị hủy sau khi thanh toán. Khoản tiền sẽ được hoàn lại theo phương thức thanh toán ban đầu."/>
                        </c:when>
                        <c:otherwise>
                            <c:set var="stBg" value="#fafafa"/><c:set var="stBorder" value="#f5c2b9"/><c:set var="stColor" value="#b42e1d"/>
                            <c:set var="stIcon" value="ph-x-circle"/>
                            <c:set var="stTitle" value="Đơn hàng đã bị hủy - chưa thanh toán thành công"/>
                            <c:set var="stText" value="Đơn bị hủy do thanh toán không thành công hoặc hết thời gian giữ vé. Bạn không bị trừ tiền; vé và ghế đã được trả lại. Hãy đặt lại nếu vẫn muốn tham gia."/>
                        </c:otherwise>
                    </c:choose>
                    <div class="d-flex align-items-center gap-3 p-4 mb-4 rounded-4" role="status"
                         style="background:${stBg};border:2px solid ${stBorder};color:${stColor};">
                        <i class="ph-fill ${stIcon} flex-shrink-0" style="font-size:48px;" aria-hidden="true"></i>
                        <div class="flex-grow-1">
                            <div class="fw-bold" style="font-size:1.45rem;line-height:1.3;"><c:out value="${stTitle}"/></div>
                            <div class="mt-1" style="font-size:1rem;color:#36363b;"><c:out value="${stText}"/></div>
                        </div>
                        <c:if test="${booking.status ne 'Paid' and booking.status ne 'Pending' and not fn:startsWith(booking.status, 'Refund')}">
                            <a href="${ctx}/home#events" class="btn-lt-primary flex-shrink-0 d-none d-md-inline-flex">Đặt lại vé</a>
                        </c:if>
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
                                                <img src="<c:out value='${booking.eventImage}'/>" alt="Event Poster" class="w-100 h-100 object-fit-cover" onerror="this.parentElement.innerHTML='<div class=\'d-flex align-items-center justify-content-center w-100 h-100 text-muted\'><i class=\'ph ph-ticket\'></i></div>';">
                                            </c:when>
                                            <c:when test="${not empty booking.eventImage}">
                                                <img src="${ctx}/<c:out value='${booking.eventImage}'/>" alt="Event Poster" class="w-100 h-100 object-fit-cover" onerror="this.parentElement.innerHTML='<div class=\'d-flex align-items-center justify-content-center w-100 h-100 text-muted\'><i class=\'ph ph-ticket\'></i></div>';">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="d-flex align-items-center justify-content-center w-100 h-100 text-muted">
                                                    <i class="ph ph-ticket" style="font-size:32px;" aria-hidden="true"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="flex-grow-1">
                                        <div class="d-flex align-items-center gap-1 text-success small fw-bold mb-1">
                                            <i class="ph ph-seal-check" style="font-size:16px;" aria-hidden="true"></i>
                                            <span>Sự kiện trực tiếp chính hãng</span>
                                        </div>
                                        <h2 class="h5 fw-bold text-dark mb-2">
                                            <c:out value="${booking.eventName}" default="Sự kiện âm nhạc"/>
                                        </h2>
                                        <div class="d-flex flex-column gap-1 small text-secondary">
                                            <div class="d-flex align-items-start gap-1">
                                                <i class="ph ph-calendar-blank text-primary mt-0.5" style="font-size:16px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
                                                <span><strong><c:out value="${eventStartText}" default="Chưa cập nhật"/></strong><c:if test="${not empty eventEndText}"> – <c:out value="${eventEndText}"/></c:if></span>
                                                </div>
                                                <div class="d-flex align-items-start gap-1">
                                                    <i class="ph ph-map-pin text-muted mt-0.5" style="font-size:16px;" aria-hidden="true"></i>
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
                                        <i class="ph ph-ticket text-primary" style="font-size:22px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
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
                                                <i class="ph ph-chair text-primary" style="font-size:16px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
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
                                    <i class="ph ph-user text-primary" style="font-size:22px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
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
                                    <i class="ph ph-receipt text-primary" style="font-size:22px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
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
                                    <i class="ph ph-scan text-primary" style="font-size:22px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
                                    <h3 class="h6 fw-bold text-dark mb-0">Hướng dẫn check-in sự kiện</h3>
                                </div>
                                <p class="small text-secondary mb-3">
                                    Chuẩn bị mã QR vé điện tử E-Ticket khi đến địa điểm. Nhân viên sẽ quét vé tại cửa soát vé để bạn vào khán phòng.
                                </p>
                                <ul class="list-unstyled d-flex flex-column gap-2 small text-secondary mb-0">
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="ph ph-check text-success mt-0.5" style="font-size:16px;" aria-hidden="true"></i>
                                        <span>Mở vé điện tử trên điện thoại hoặc tải file PDF trước khi đến.</span>
                                    </li>
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="ph ph-check text-success mt-0.5" style="font-size:16px;" aria-hidden="true"></i>
                                        <span>Mỗi vé chỉ sử dụng check-in 01 lần tại cổng sự kiện.</span>
                                    </li>
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="ph ph-check text-success mt-0.5" style="font-size:16px;" aria-hidden="true"></i>
                                        <span>Có mặt trước giờ biểu diễn ít nhất 30 phút để ổn định chỗ ngồi.</span>
                                    </li>
                                </ul>
                            </div>

                            <!-- Support Hotline Card -->
                            <div class="lt-card p-3 d-flex align-items-center gap-3">
                                <div class="d-flex align-items-center justify-content-center rounded-circle p-2" style="background:var(--lt-primary-fixed);color:var(--lt-primary);">
                                    <i class="ph ph-headset" style="font-size:24px;" aria-hidden="true"></i>
                                </div>
                                <div>
                                    <span class="d-block small text-muted">Cần hỗ trợ đơn hàng?</span>
                                    <strong class="text-dark">Hotline: <a href="tel:19006868" class="text-decoration-none" style="color:var(--lt-primary);">1900 6868</a></strong>
                                </div>
                            </div>

                        </aside>
                    </div>

                    <!-- Customer Review Section -->
                    <div>
                        <section class="lt-card p-4 mb-4" id="booking-review">

                            <h3 class="h5 fw-bold mb-2">
                                <i class="ph ph-star text-warning"></i>
                                Đánh giá sự kiện
                            </h3>

                            <p class="text-secondary small">
                                Chia sẻ trải nghiệm của bạn sau khi tham gia sự kiện.
                            </p>

                            <c:if test="${not empty reviewMessage}">
                                <div class="alert ${reviewOk ? 'alert-success' : 'alert-warning'}">
                                    <c:out value="${reviewMessage}"/>
                                </div>
                            </c:if>

                            <c:choose>

                                <c:when test="${not empty myReview}">
                                    <div class="alert alert-success">
                                        Bạn đã đánh giá sự kiện này:
                                        <strong>${myReview.rating}/5 sao</strong>
                                        <c:if test="${myReview.status eq 'HIDDEN'}">
                                            (Đánh giá đang bị ẩn)
                                        </c:if>
                                    </div>
                                </c:when>

                                <c:when test="${canReview}">
                                    <form method="post"
                                          action="${ctx}/customer/review">

                                        <input type="hidden"
                                               name="csrfToken"
                                               value="${csrfToken}"/>

                                        <input type="hidden"
                                               name="eventId"
                                               value="${reviewEventId}"/>

                                        <input type="hidden"
                                               name="orderId"
                                               value="${booking.bookingId}"/>

                                        <div class="mb-3">
                                            <label class="form-label fw-semibold">
                                                Chấm điểm sự kiện
                                            </label>

                                            <select name="rating"
                                                    class="form-select" required>
                                                <option value="">Chọn số sao</option>
                                                <option value="5">★★★★★ - Tuyệt vời</option>
                                                <option value="4">★★★★ - Tốt</option>
                                                <option value="3">★★★ - Bình thường</option>
                                                <option value="2">★★ - Chưa tốt</option>
                                                <option value="1">★ - Tệ</option>
                                            </select>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-semibold">
                                                Nhận xét
                                            </label>

                                            <textarea name="comment"
                                                      class="form-control"
                                                      rows="4"
                                                      maxlength="1000"
                                                      placeholder="Chia sẻ trải nghiệm của bạn..."></textarea>
                                        </div>

                                        <button type="submit" class="btn-lt-primary">
                                            <i class="ph ph-paper-plane-tilt"></i>
                                            Gửi đánh giá
                                        </button>
                                    </form>
                                </c:when>

                                <c:otherwise>
                                    <div class="alert alert-light border">
                                        Bạn chỉ có thể đánh giá khi đơn hàng đã
                                        thanh toán, vé đã check-in và sự kiện
                                        đã kết thúc.
                                    </div>
                                </c:otherwise>

                            </c:choose>
                        </section>
                    </div>
                    
                    <!-- E-Ticket Modal -->
                    <div class="modal fade" id="eTicketModal" tabindex="-1" aria-labelledby="eTicketModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content border-0 shadow-lg" style="border-radius: var(--lt-radius-lg);">
                                <div class="modal-header border-0 pb-0">
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="lt-brand-icon" style="width:32px;height:32px;border-radius:8px;">
                                            <i class="ph ph-ticket" style="font-size:18px;" aria-hidden="true"></i>
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

                                    <!-- Mỗi vé có mã QR riêng (ticket_code) ở trang Vé điện tử; mã đơn không dùng để soát vé -->
                                    <div class="p-3 bg-light rounded-3 border mb-3">
                                        <i class="ph ph-qr-code" style="font-size:48px;color:var(--lt-primary);" aria-hidden="true"></i>
                                        <p class="small text-secondary mb-2">Mỗi vé có một mã QR riêng để soát vé tại cổng.</p>
                                        <a class="btn btn-sm btn-outline-primary"
                                           href="${pageContext.request.contextPath}/customer/e-tickets?orderId=${booking.bookingId}">
                                            Xem mã QR các vé
                                        </a>
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
                                    <a class="btn-lt-primary btn-sm text-decoration-none"
                                       href="${pageContext.request.contextPath}/customer/e-tickets?orderId=${booking.bookingId}&amp;print=1">
                                        In vé / Tải về
                                    </a>

                                </div>
                            </div>
                        </div>
                    </div>

                </c:when>

                <c:otherwise>
                    <div class="lt-card p-5 text-center my-4">
                        <i class="ph ph-receipt text-muted" style="font-size:48px;" aria-hidden="true"></i>
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
        <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>

        <!-- Bootstrap 5 JS Bundle -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
