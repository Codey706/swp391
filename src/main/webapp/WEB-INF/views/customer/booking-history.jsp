<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %><fmt:setLocale value="vi_VN"/>
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
    <title>Vé của tôi - Lịch sử đơn hàng & Vé điện tử - Light Ticket</title>

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
         HEADER (STITCH COMPATIBLE)
         ====================================================================== -->
    <jsp:include page="/WEB-INF/views/common/site-header.jsp">
        <jsp:param name="active" value="tickets"/>
    </jsp:include>

    <!-- ======================================================================
         MAIN CONTENT
         ====================================================================== -->
    <main class="container-xl py-4 flex-grow-1">

        <!-- Breadcrumb Navigation -->
        <nav aria-label="Breadcrumb" class="lt-breadcrumb mb-3">
            <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                <i class="ph ph-house" style="font-size:16px;" aria-hidden="true"></i>
                Trang chủ
            </a>
            <i class="ph ph-caret-right separator" aria-hidden="true"></i>
            <a href="${ctx}/CustomerProfileController">Tài khoản của tôi</a>
            <i class="ph ph-caret-right separator" aria-hidden="true"></i>
            <span class="active">Vé của tôi</span>
        </nav>

        <!-- Page Header & Overview Metric Bento -->
        <div class="d-flex flex-column flex-md-row align-items-md-end justify-content-between gap-3 mb-4">
            <div>
                <div class="d-inline-flex align-items-center gap-1 mb-2 px-2 py-1 rounded-pill" style="background: var(--lt-primary-fixed); color: var(--lt-on-primary-fixed); font-size: 12px; font-weight: 600;">
                    <i class="ph ph-receipt" style="font-size:14px;" aria-hidden="true"></i>
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
                        <i class="ph ph-check-circle" style="font-size:18px;" aria-hidden="true"></i>
                    </div>
                    <div>
                        <span class="d-block text-muted" style="font-size:11px;">Thành công</span>
                        <strong class="text-dark small">${paidCount} đơn</strong>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2 px-3 py-1 bg-white rounded-3 shadow-sm">
                    <div class="d-flex align-items-center justify-content-center rounded-circle" style="width:32px;height:32px;background:var(--lt-warning-bg);color:var(--lt-warning);">
                        <i class="ph ph-hourglass" style="font-size:18px;" aria-hidden="true"></i>
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
                            <i class="ph ph-magnifying-glass" style="font-size:16px;" aria-hidden="true"></i>
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
                            <i class="ph ph-receipt" style="font-size: 48px;" aria-hidden="true"></i>
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
                                        <i class="ph ph-ticket text-primary" style="font-size:20px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
                                        <span class="small fw-bold text-dark">Mã đơn: <span style="color:var(--lt-primary); font-family:monospace; font-size:1rem;">#<c:out value="${booking.orderCode}"/></span></span>
                                    </div>
                                    <div class="d-flex align-items-center gap-1 text-secondary small">
                                        <i class="ph ph-clock" style="font-size:16px;" aria-hidden="true"></i>
                                        <span>Ngày đặt: <c:out value="${createdText}"/></span>
                                    </div>
                                </div>

                                <!-- Status Badge -->
                                <div>
                                    <c:choose>
                                        <c:when test="${booking.status eq 'Paid'}">
                                            <span class="lt-pill lt-pill-paid">
                                                <i class="ph ph-check-circle" style="font-size:14px;" aria-hidden="true"></i>
                                                Đã thanh toán thành công
                                            </span>
                                        </c:when>
                                        <c:when test="${booking.status eq 'Pending'}">
                                            <span class="lt-pill lt-pill-pending">
                                                <i class="ph ph-hourglass-high" style="font-size:14px;" aria-hidden="true"></i>
                                                Chờ thanh toán
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="lt-pill lt-pill-cancelled">
                                                <i class="ph ph-x-circle" style="font-size:14px;" aria-hidden="true"></i>
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
                                                <i class="ph ph-calendar-blank text-primary" style="font-size:16px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
                                                <span><c:out value="${startText}" default="Thời gian chưa cập nhật"/></span>
                                            </div>
                                            <div class="d-flex align-items-center gap-1">
                                                <i class="ph ph-map-pin text-muted" style="font-size:16px;" aria-hidden="true"></i>
                                                <span class="text-truncate"><c:out value="${booking.venueName}" default="Địa điểm sự kiện"/></span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Ticket Quantity Chip -->
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="px-2 py-1 rounded-2 small" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                            <i class="ph ph-chair text-success align-middle" style="font-size:15px;" aria-hidden="true"></i>
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
                                            <i class="ph ph-shield-check text-success" style="font-size:16px;" aria-hidden="true"></i>
                                            <span>Vé chính hãng đã kích hoạt mã định danh bảo mật</span>
                                        </c:when>
                                        <c:when test="${booking.status eq 'Pending'}">
                                            <i class="ph ph-timer text-danger" style="font-size:16px;" aria-hidden="true"></i>
                                            <span class="text-danger">Đơn hàng đang giữ vé, vui lòng thanh toán sớm</span>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="ph ph-info text-muted" style="font-size:16px;" aria-hidden="true"></i>
                                            <span>Đơn hàng đã hết hạn hoặc bị hủy</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="d-flex flex-wrap align-items-center gap-2">
                                    <c:if test="${booking.status eq 'Pending'}">
                                        <a href="${ctx}/booking/payment?orderId=${booking.bookingId}" class="btn-lt-primary btn-sm">
                                            <i class="ph ph-credit-card" style="font-size:16px;" aria-hidden="true"></i>
                                            Thanh toán ngay
                                        </a>
                                    </c:if>

                                    <!-- CTA Direct into Order Detail Screen (UC-07.1) -->
                                    <a href="${ctx}/customer/booking-detail?orderId=${booking.bookingId}" class="btn-lt-secondary btn-sm">
                                        Xem chi tiết đơn
                                        <i class="ph ph-arrow-right" style="font-size:16px;" aria-hidden="true"></i>
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
    <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
