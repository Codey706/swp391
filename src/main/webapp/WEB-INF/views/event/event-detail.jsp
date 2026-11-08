<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %><fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:if test="${not empty event.startTime}"><fmt:parseDate value="${fn:substring(event.startTime, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="startDate" type="both"/><fmt:formatDate value="${startDate}" pattern="HH:mm, dd/MM/yyyy" var="startText"/></c:if>
<c:if test="${not empty event.endTime}"><fmt:parseDate value="${fn:substring(event.endTime, 0, 16)}" pattern="yyyy-MM-dd'T'HH:mm" var="endDate" type="both"/><fmt:formatDate value="${endDate}" pattern="HH:mm, dd/MM/yyyy" var="endText"/></c:if>
<c:set var="minPrice" value="${null}"/>
<c:forEach var="t" items="${tickets}"><c:if test="${empty minPrice or t.price lt minPrice}"><c:set var="minPrice" value="${t.price}"/></c:if></c:forEach>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${event.eventName}"/> | Light Ticket</title>
    <link rel="stylesheet" href="${ctx}/assets/css/checkout.css">
    <c:if test="${not empty seatMapJson}"><link rel="stylesheet" href="${ctx}/assets/css/staff-seats.css"></c:if>
    <style>
        .ev-desc { white-space: pre-line; margin: 0; }
        .ev-meta { display: grid; gap: 4px; margin-top: 10px; }
        .ev-meta span { color: var(--ck-muted); margin-right: 6px; }
        .ev-badge { display: inline-block; padding: 3px 10px; border-radius: 999px; background: #fafafa; color: var(--ck-orange); font-size: 12px; font-weight: 700; }
        .ev-ticket-row { display: flex; justify-content: space-between; gap: 14px; padding: 15px 0; border-top: 1px solid var(--ck-line); }
        .ev-ticket-row p { margin: 3px 0 0; color: var(--ck-muted); font-size: 13px; }
        .ev-ticket-row strong { color: var(--ck-orange); white-space: nowrap; }
        .ev-soldout { color: #b4b4ba !important; }
        .ev-review-form { display: grid; gap: 10px; margin-bottom: 18px; }
        .ev-review-form select, .ev-review-form textarea { border: 1px solid var(--ck-line); border-radius: 8px; padding: 10px 12px; font: inherit; }
    </style>
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
<body>
<jsp:include page="../customer/booking-header.jsp"/>
<main class="ck-wrap">
    <section class="ck-event-hero">
        <div class="ck-event-image">
            <c:choose>
                <c:when test="${not empty event.eventImage}">
                    <img src="${fn:startsWith(event.eventImage, 'http') ? '' : ctx.concat('/')}<c:out value='${event.eventImage}'/>"
                         alt="<c:out value='${event.eventName}'/>" onerror="this.remove();">
                </c:when>
                <c:otherwise><i class="ph ph-ticket" style="font-size:40px" aria-hidden="true"></i></c:otherwise>
            </c:choose>
        </div>
        <div>
            <c:if test="${not empty event.categoryName}"><span class="ev-badge"><c:out value="${event.categoryName}"/></span></c:if>
            <h1><c:out value="${event.eventName}"/></h1>
            <div class="ev-meta">
                <div><span>Địa điểm:</span><c:out value="${event.venueName}"/></div>
                <c:if test="${not empty venueAddress}"><div><span>Địa chỉ:</span><c:out value="${venueAddress}"/></div></c:if>
                <div><span>Bắt đầu:</span><c:out value="${startText}"/></div>
                <c:if test="${not empty endText}"><div><span>Kết thúc:</span><c:out value="${endText}"/></div></c:if>
            </div>
        </div>
    </section>

    <div class="ck-layout">
        <section class="ck-panel">
            <p class="ck-eyebrow">GIỚI THIỆU</p>
            <h2>Thông tin sự kiện</h2>
            <p class="ev-desc"><c:out value="${event.description}" default="Ban tổ chức chưa cập nhật mô tả."/></p>

            <div class="ck-panel-title ck-seat-heading">
                <div><p class="ck-eyebrow">HẠNG VÉ</p><h2>Giá vé</h2></div>
            </div>
            <c:choose>
                <c:when test="${empty tickets}">
                    <p class="ck-muted">Sự kiện chưa mở bán loại vé nào.</p>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${tickets}">
                        <div class="ev-ticket-row">
                            <div>
                                <b><c:out value="${t.ticketName}"/></b>
                                <c:if test="${not empty t.description}"><p><c:out value="${t.description}"/></p></c:if>
                            </div>
                            <div style="text-align:right">
                                <strong class="${t.availableQuantity le 0 ? 'ev-soldout' : ''}"><fmt:formatNumber value="${t.price}" pattern="#,##0"/> đ</strong>
                                <p>${t.availableQuantity le 0 ? 'Hết vé' : 'Còn vé'}</p>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </section>

        <aside class="ck-panel ck-summary">
            <p class="ck-eyebrow">ĐẶT VÉ</p>
            <h2>Giá từ</h2>
            <div class="ck-summary-total">
                <span>Chỉ từ</span>
                <strong><c:choose><c:when test="${not empty minPrice}"><fmt:formatNumber value="${minPrice}" pattern="#,##0"/> đ</c:when><c:otherwise>-</c:otherwise></c:choose></strong>
            </div>
            <c:choose>
                <c:when test="${bookable and event.remainingTickets gt 0}">
                    <a class="ck-button" style="width:100%" href="${ctx}/booking/select-ticket?eventId=${event.eventId}">Đặt vé ngay <span>→</span></a>
                    <p class="ck-note">Bạn cần đăng nhập bằng tài khoản khách hàng để đặt vé.</p>
                </c:when>
                <c:when test="${not bookable}">
                    <button class="ck-button" style="width:100%" type="button" disabled>Sự kiện đã diễn ra</button>
                </c:when>
                <c:otherwise>
                    <button class="ck-button" style="width:100%" type="button" disabled>Đã hết vé</button>
                </c:otherwise>
            </c:choose>
            <a class="ck-button ck-button-secondary" style="width:100%;margin-top:10px" href="${ctx}/home">← Xem sự kiện khác</a>
        </aside>
    </div>

    <%-- ===== UC-11: Sơ đồ ghế (chỉ xem) ===== --%>
    <c:if test="${not empty seatMapJson}">
        <section class="ck-panel" id="seatmap" style="margin-top:22px">
            <div class="ck-panel-title">
                <div><p class="ck-eyebrow">SƠ ĐỒ</p><h2>Sơ đồ chỗ ngồi</h2></div>
                <span class="ck-muted">Còn trống <fmt:formatNumber value="${seatAvailable}" pattern="#,##0"/> / <fmt:formatNumber value="${seatTotal}" pattern="#,##0"/> ghế</span>
            </div>
            <ul class="ss-legend" aria-label="Chú thích">
                <li><i class="st-0"></i>Còn trống</li>
                <li><i class="st-2"></i>Đã bán</li>
                <li><i class="st-4"></i>Không khả dụng</li>
                <li><i class="st-vip"></i>Ghế VIP</li>
            </ul>
            <div class="ss-canvas" id="ssCanvas">
                <svg id="ssSvg" role="img" aria-label="Sơ đồ chỗ ngồi, chỉ xem"></svg>
            </div>
            <p class="ck-note">Chọn ghế cụ thể ở bước đặt vé.</p>
            <script type="application/json" id="ssData">${seatMapJson}</script>
        </section>
    </c:if>

    <%-- ===== UC-19: Đánh giá ===== --%>
    <section class="ck-panel" id="reviews" style="margin-top:22px">
        <div class="ck-panel-title">
            <div><p class="ck-eyebrow">ĐÁNH GIÁ</p><h2>Khán giả nói gì</h2></div>
            <c:if test="${reviewCount gt 0}">
                <span class="ev-badge">★ <fmt:formatNumber value="${reviewAverage}" maxFractionDigits="1" minFractionDigits="1"/> / 5 · ${reviewCount} đánh giá</span>
            </c:if>
        </div>

        <c:if test="${not empty reviewMessage}">
            <div class="${reviewOk ? 'ck-info-note' : 'ck-alert'}" role="status"><c:out value="${reviewMessage}"/></div>
        </c:if>

        <c:choose>
            <c:when test="${canReview}">
                <form method="post" action="${ctx}/customer/review" class="ev-review-form">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <input type="hidden" name="eventId" value="${event.eventId}">
                    <label for="rating"><b>Đánh giá của bạn</b></label>
                    <select id="rating" name="rating" required>
                        <option value="">-- Chọn số sao --</option>
                        <option value="5">★★★★★ Tuyệt vời</option>
                        <option value="4">★★★★ Tốt</option>
                        <option value="3">★★★ Bình thường</option>
                        <option value="2">★★ Chưa tốt</option>
                        <option value="1">★ Tệ</option>
                    </select>
                    <textarea name="comment" rows="3" maxlength="1000" placeholder="Chia sẻ cảm nhận của bạn (không bắt buộc, tối đa 1000 ký tự)"></textarea>
                    <button type="submit" class="ck-button">Gửi đánh giá</button>
                </form>
            </c:when>
            <c:when test="${not empty myReview}">
                <p class="ck-note">Bạn đã đánh giá sự kiện này <b>${myReview.rating}★</b><c:if test="${myReview.status eq 'HIDDEN'}"> (đánh giá đã bị quản trị viên ẩn)</c:if>.</p>
            </c:when>
            <c:when test="${sessionScope.user.role eq 'Customer'}">
                <p class="ck-note">Bạn có thể đánh giá sau khi đã check-in tham dự sự kiện.</p>
            </c:when>
        </c:choose>

        <c:choose>
            <c:when test="${empty reviews}">
                <p class="ck-muted">Chưa có đánh giá nào.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="r" items="${reviews}">
                    <div class="ev-ticket-row">
                        <div>
                            <b><c:out value="${r.customerName}"/></b>
                            <c:if test="${not empty r.comment}"><p class="ev-desc"><c:out value="${r.comment}"/></p></c:if>
                        </div>
                        <div style="text-align:right">
                            <strong>${r.rating}★</strong>
                            <p><c:out value="${empty r.createdAt ? '' : fn:substring(r.createdAt, 0, 10)}"/></p>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>
</main>
<jsp:include page="../customer/booking-footer.jsp"/>
<c:if test="${not empty seatMapJson}"><script src="${ctx}/assets/js/staff-seats.js"></script></c:if>
</body>
</html>
