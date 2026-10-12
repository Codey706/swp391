<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.user}"/>
<c:set var="initial" value="${empty user.fullName ? 'K' : fn:toUpperCase(fn:substring(user.fullName, 0, 1))}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đơn hàng - Light Ticket</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/booking-detail.css">
</head>
<body class="detail-page">
<header class="detail-header">
    <div class="detail-header-inner">
        <a class="detail-brand" href="${ctx}/" aria-label="Light Ticket - Trang chủ">
            <span class="detail-brand-icon"><span class="material-symbols-outlined">confirmation_number</span></span>
            <span>Light <strong>Ticketbox</strong></span>
        </a>
        <nav class="detail-nav" aria-label="Điều hướng chính">
            <a href="${ctx}/">Trang chủ</a>
            <a href="${ctx}/">Khám phá sự kiện</a>
            <a href="${ctx}/customer/booking-history" class="active">Đơn hàng của tôi</a>
        </nav>
        <a class="detail-account" href="${ctx}/CustomerProfileController">
            <span class="detail-avatar"><c:out value="${initial}"/></span>
            <span class="detail-account-name"><c:out value="${user.fullName}"/></span>
            <span class="material-symbols-outlined account-chevron">expand_more</span>
        </a>
    </div>
</header>

<main class="detail-main">
    <c:choose>
        <c:when test="${not empty errorMessage}">
            <section class="detail-error" role="alert">
                <span class="material-symbols-outlined">error</span>
                <div><h1>Không thể tải chi tiết đơn hàng</h1><p><c:out value="${errorMessage}"/></p></div>
            </section>
            <a class="detail-button detail-button-secondary" href="${ctx}/customer/booking-history"><span class="material-symbols-outlined">arrow_back</span> Quay lại danh sách đơn hàng</a>
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
            <fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0" var="totalText"/>
            <fmt:formatNumber value="${booking.discountAmount}" pattern="#,##0" var="discountText"/>
            <fmt:formatNumber value="${booking.finalAmount}" pattern="#,##0" var="finalText"/>
            <c:set var="statusLabel" value="${booking.status}"/>
            <c:choose>
                <c:when test="${booking.status == 'Paid'}"><c:set var="statusLabel" value="Đã thanh toán thành công"/><c:set var="statusClass" value="status-paid"/></c:when>
                <c:when test="${booking.status == 'Pending'}"><c:set var="statusLabel" value="Chờ thanh toán"/><c:set var="statusClass" value="status-pending"/></c:when>
                <c:when test="${booking.status == 'Cancelled'}"><c:set var="statusLabel" value="Đã hủy"/><c:set var="statusClass" value="status-cancelled"/></c:when>
                <c:otherwise><c:set var="statusClass" value="status-default"/></c:otherwise>
            </c:choose>

            <div class="detail-topbar">
                <nav class="detail-breadcrumb" aria-label="Breadcrumb">
                    <a href="${ctx}/"><span class="material-symbols-outlined">home</span> Trang chủ</a>
                    <span class="material-symbols-outlined crumb-arrow">chevron_right</span>
                    <a href="${ctx}/customer/booking-history">Đơn hàng của tôi</a>
                    <span class="material-symbols-outlined crumb-arrow">chevron_right</span>
                    <span class="crumb-current">Chi tiết đơn hàng</span>
                </nav>
                <a class="detail-button detail-button-secondary" href="${ctx}/customer/booking-history"><span class="material-symbols-outlined">arrow_back</span> Quay lại danh sách đơn hàng</a>
            </div>

            <section class="order-hero">
                <div class="order-hero-info">
                    <div class="order-title-line">
                        <h1>Đơn hàng <span>#<c:out value="${booking.orderCode}"/></span></h1>
                        <span class="order-status ${statusClass}"><span class="material-symbols-outlined">${booking.status == 'Paid' ? 'check_circle' : booking.status == 'Pending' ? 'schedule' : 'info'}</span><c:out value="${statusLabel}"/></span>
                    </div>
                    <div class="order-meta">
                        <span><span class="material-symbols-outlined">schedule</span>Thời gian đặt: <strong><c:out value="${createdText}"/></strong></span>
                        <c:if test="${not empty booking.payment}">
                            <span><span class="material-symbols-outlined">payments</span>Kênh thanh toán: <strong><c:out value="${booking.payment.paymentMethod}"/></strong></span>
                            <c:if test="${not empty booking.payment.transactionCode}"><span class="transaction-code">Mã GD: <c:out value="${booking.payment.transactionCode}"/></span></c:if>
                        </c:if>
                    </div>
                </div>
                <div class="order-actions">
                    <button class="detail-button detail-button-primary" id="open-ticket-btn" type="button" <c:if test="${booking.status != 'Paid'}">disabled title="Vé điện tử chỉ khả dụng sau khi thanh toán thành công"</c:if>>
                        <span class="material-symbols-outlined">confirmation_number</span> Xem thông tin vé
                    </button>
                    <button class="detail-button detail-button-secondary" type="button" disabled title="Chức năng đánh giá chưa được kết nối"><span class="material-symbols-outlined">star</span> Đánh giá sự kiện</button>
                </div>
            </section>

            <div class="detail-grid">
                <div class="detail-main-column">
                    <section class="detail-card event-card">
                        <div class="section-heading"><span class="material-symbols-outlined">event</span><h2>Thông tin sự kiện</h2></div>
                        <div class="event-info">
                            <div class="event-poster">
                                <c:choose>
                                    <c:when test="${not empty booking.eventImage and fn:startsWith(booking.eventImage, 'http')}"><img src="<c:out value='${booking.eventImage}'/>" alt="Ảnh sự kiện" onerror="this.parentElement.classList.add('image-fallback');this.remove();"></c:when>
                                    <c:when test="${not empty booking.eventImage}"><img src="${ctx}/<c:out value='${booking.eventImage}'/>" alt="Ảnh sự kiện" onerror="this.parentElement.classList.add('image-fallback');this.remove();"></c:when>
                                    <c:otherwise><span class="material-symbols-outlined">confirmation_number</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="event-copy">
                                <span class="event-kicker"><span class="material-symbols-outlined">verified</span>Thông tin đơn đặt vé</span>
                                <h2><c:out value="${booking.eventName}" default="Sự kiện"/></h2>
                                <div class="event-detail-line"><span class="material-symbols-outlined">calendar_month</span><span><strong>Thời gian</strong><br><c:out value="${eventStartText}" default="Chưa cập nhật"/><c:if test="${not empty eventEndText}"> – <c:out value="${eventEndText}"/></c:if></span></div>
                                <div class="event-detail-line"><span class="material-symbols-outlined">location_on</span><span><strong><c:out value="${booking.venueName}" default="Địa điểm sự kiện"/></strong><br><c:out value="${booking.venueAddress}" default="Địa chỉ chưa được cập nhật"/></span></div>
                            </div>
                        </div>
                    </section>

                    <section class="detail-card ticket-card">
                        <div class="section-heading section-heading-between">
                            <div class="section-heading-title"><span class="material-symbols-outlined">confirmation_number</span><h2>Chi tiết vé</h2></div>
                            <span class="ticket-count"><c:out value="${booking.ticketQuantity}"/> vé</span>
                        </div>
                        <c:choose>
                            <c:when test="${not empty booking.items}">
                                <c:forEach var="item" items="${booking.items}" varStatus="loop">
                                    <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0" var="unitPriceText"/>
                                    <fmt:formatNumber value="${item.subtotal}" pattern="#,##0" var="subtotalText"/>
                                    <article class="ticket-row">
                                        <div class="ticket-icon"><span class="material-symbols-outlined">local_activity</span></div>
                                        <div class="ticket-copy"><h3><c:out value="${item.ticketName}"/></h3><p>Đơn giá: <c:out value="${unitPriceText}"/> đ <span class="ticket-multiply">×</span> <c:out value="${item.quantity}"/> vé</p></div>
                                        <strong class="ticket-price"><c:out value="${subtotalText}"/> đ</strong>
                                    </article>
                                </c:forEach>
                            </c:when>
                            <c:otherwise><p class="detail-muted">Không có thông tin hạng vé trong đơn hàng này.</p></c:otherwise>
                        </c:choose>
                        <c:if test="${not empty booking.seatLabels}">
                            <div class="seat-block"><h3><span class="material-symbols-outlined">event_seat</span> Ghế đã đặt</h3><div class="seat-tags"><c:forEach var="seat" items="${booking.seatLabels}"><span><c:out value="${seat}"/></span></c:forEach></div></div>
                        </c:if>
                    </section>

                    <section class="detail-card attendee-card">
                        <div class="section-heading"><span class="material-symbols-outlined">person</span><h2>Thông tin khách hàng</h2></div>
                        <div class="attendee-grid">
                            <div><span>Họ và tên</span><strong><c:out value="${user.fullName}" default="Chưa cập nhật"/></strong></div>
                            <div><span>Email nhận vé</span><strong><c:out value="${user.email}" default="Chưa cập nhật"/></strong></div>
                            <div><span>Số điện thoại</span><strong><c:out value="${user.phone}" default="Chưa cập nhật"/></strong></div>
                        </div>
                    </section>
                </div>

                <aside class="detail-side-column">
                    <section class="detail-card payment-card">
                        <div class="section-heading"><span class="material-symbols-outlined">receipt_long</span><h2>Tóm tắt thanh toán</h2></div>
                        <div class="payment-line"><span>Tạm tính</span><strong><c:out value="${totalText}"/> đ</strong></div>
                        <div class="payment-line discount-line"><span>Giảm giá</span><strong>- <c:out value="${discountText}"/> đ</strong></div>
                        <c:if test="${not empty booking.voucherCode}"><div class="voucher-chip"><span class="material-symbols-outlined">sell</span><span>Voucher: <strong><c:out value="${booking.voucherCode}"/></strong><c:if test="${not empty booking.voucherName}"> – <c:out value="${booking.voucherName}"/></c:if></span></div></c:if>
                        <div class="payment-total"><span>Tổng thanh toán</span><strong><c:out value="${finalText}"/> đ</strong></div>
                        <div class="payment-status-note ${statusClass}"><span class="material-symbols-outlined">${booking.status == 'Paid' ? 'verified' : booking.status == 'Pending' ? 'hourglass_top' : 'info'}</span><span><c:out value="${statusLabel}"/></span></div>
                        <c:if test="${not empty booking.payment}">
                            <div class="payment-method"><span>Phương thức</span><strong><c:out value="${booking.payment.paymentMethod}"/></strong></div>
                            <c:if test="${not empty booking.payment.paidAt}">
                                <fmt:parseDate value="${fn:substring(booking.payment.paidAt, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="paidDate" type="both"/>
                                <fmt:formatDate value="${paidDate}" pattern="HH:mm • dd/MM/yyyy" var="paidText"/>
                                <div class="payment-method"><span>Thời gian thanh toán</span><strong><c:out value="${paidText}"/></strong></div>
                            </c:if>
                            <c:if test="${not empty booking.payment.transactionCode}"><div class="payment-method"><span>Mã giao dịch</span><strong class="break-word"><c:out value="${booking.payment.transactionCode}"/></strong></div></c:if>
                        </c:if>
                    </section>
                    <section class="detail-card checkin-card">
                        <div class="checkin-icon"><span class="material-symbols-outlined">qr_code_scanner</span></div>
                        <h2>Hướng dẫn check-in</h2>
                        <p>Chuẩn bị vé điện tử khi đến địa điểm tổ chức. Nhân viên sẽ kiểm tra vé tại cổng vào.</p>
                        <ul><li>Mở vé điện tử trên điện thoại khi được yêu cầu.</li><li>Mỗi vé chỉ sử dụng để check-in theo quy định của sự kiện.</li><li>Liên hệ bộ phận hỗ trợ nếu thông tin vé có sai sót.</li></ul>
                    </section>
                    <section class="detail-support"><span class="material-symbols-outlined">support_agent</span><div><strong>Cần hỗ trợ đơn hàng?</strong><p>Hotline: <a href="tel:19006868">1900 6868</a></p></div></section>
                </aside>
            </div>
        </c:when>
        <c:otherwise>
            <section class="detail-error" role="alert"><span class="material-symbols-outlined">receipt_long</span><div><h1>Không có dữ liệu đơn hàng</h1><p>Vui lòng quay lại lịch sử đặt vé và chọn đơn hàng bạn muốn xem.</p></div></section>
            <a class="detail-button detail-button-secondary" href="${ctx}/customer/booking-history"><span class="material-symbols-outlined">arrow_back</span> Quay lại danh sách đơn hàng</a>
        </c:otherwise>
    </c:choose>
</main>

<footer class="detail-footer">
    <div class="detail-footer-inner">
        <div class="footer-brand"><span class="detail-brand-icon"><span class="material-symbols-outlined">confirmation_number</span></span><span>Light <strong>Ticketbox</strong></span></div>
        <p>Nền tảng đặt vé sự kiện trực tuyến. Nếu cần hỗ trợ, vui lòng liên hệ hotline 1900 6868.</p>
        <span class="footer-copy">© 2026 Light Ticket. Bản quyền thuộc Light Ticket.</span>
    </div>
</footer>

<div class="detail-modal-backdrop" id="ticket-info-modal" hidden>
    <section class="detail-modal" role="dialog" aria-modal="true" aria-labelledby="ticket-modal-title">
        <button type="button" class="modal-close" id="close-ticket-modal" aria-label="Đóng"><span class="material-symbols-outlined">close</span></button>
        <div class="modal-icon"><span class="material-symbols-outlined">confirmation_number</span></div>
        <h2 id="ticket-modal-title">Thông tin vé điện tử</h2>
        <p class="modal-order-code">Đơn hàng #<c:out value="${booking.orderCode}"/></p>
        <c:choose>
            <c:when test="${booking.status == 'Paid'}">
                <p class="modal-note">Thông tin hạng vé trong đơn hàng:</p>
                <ul class="modal-ticket-list"><c:forEach var="item" items="${booking.items}"><li><span><c:out value="${item.ticketName}"/></span><strong><c:out value="${item.quantity}"/> vé</strong></li></c:forEach></ul>
                <p class="modal-disclaimer">Mã QR check-in chưa được cung cấp bởi dữ liệu chi tiết đơn hàng hiện tại. Vui lòng sử dụng vé điện tử được hệ thống phát hành khi tính năng này khả dụng.</p>
            </c:when>
            <c:otherwise><p class="modal-note">Đơn hàng chưa được thanh toán thành công nên vé điện tử chưa khả dụng.</p></c:otherwise>
        </c:choose>
        <button type="button" class="detail-button detail-button-primary modal-done" id="done-ticket-modal">Đã hiểu</button>
    </section>
</div>
<script src="${ctx}/assets/js/booking-detail.js"></script>
</body>
</html>
