<%-- 
    Document   : payment-result
    Created on : Oct 22, 2026, 11:04:12 PM
    Author     : ADMIN
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %><fmt:setLocale value="vi_VN"/>
<c:set var="ok" value="${paymentSuccess eq true}"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${ok ? 'Đặt vé thành công' : 'Thanh toán chưa thành công'} | Light Ticket</title>


        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/payment-result.css">

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
        <jsp:include page="/WEB-INF/views/common/site-header.jsp"/>
        <main class="payment-page">

            <!-- Thanh tiến trình -->
            <section class="booking-steps" aria-label="Tiến trình đặt vé">
                <div class="booking-step completed">
                    <div class="step-icon">✓</div>
                    <div class="step-text">
                        <span class="step-label">BƯỚC 1</span>
                        <span class="step-name">Chọn vé</span>
                    </div>
                </div>

                <div class="booking-step completed">
                    <div class="step-icon">✓</div>
                    <div class="step-text">
                        <span class="step-label">BƯỚC 2</span>
                        <span class="step-name">Thông tin</span>
                    </div>
                </div>

                <div class="booking-step completed">
                    <div class="step-icon">✓</div>
                    <div class="step-text">
                        <span class="step-label">BƯỚC 3</span>
                        <span class="step-name">Thanh toán</span>
                    </div>
                </div>

                <div class="booking-step active">
                    <div class="step-icon">✓</div>
                    <div class="step-text">
                        <span class="step-label">BƯỚC 4</span>
                        <span class="step-name">Hoàn tất</span>
                    </div>
                </div>
            </section>

            <!-- Kết quả thanh toán: đọc từ VNPayReturnServlet (paymentSuccess / paymentMessage) -->
            <section class="success-heading">
                <c:choose>
                    <c:when test="${ok}">
                        <div class="success-icon">✓</div>
                        <h1>Đặt vé thành công!</h1>
                    </c:when>
                    <c:otherwise>
                        <div class="success-icon" style="background:#d93a27;border-color:#ffe7e2;box-shadow:0 5px 14px rgba(217, 58, 39,.18);">✕</div>
                        <h1>Thanh toán chưa thành công</h1>
                    </c:otherwise>
                </c:choose>
                <p><c:out value="${not empty paymentMessage ? paymentMessage : 'Cảm ơn bạn đã đặt vé.'}"/></p>
            </section>

            <!-- Thông tin đơn hàng -->
            <section class="payment-card">
                <h2 class="card-title">
                    <span class="title-mark">▣</span>
                    Thông tin đơn hàng
                </h2>

                <div class="order-code">
                    <span class="label">Mã đơn hàng</span>
                    <strong><c:out value="${orderCode}" default="Không tìm thấy"/></strong>
                </div>

                <div class="info-row">
                    <span class="label">Trạng thái thanh toán</span>
                    <span class="value">
                        <c:choose>
                            <c:when test="${ok}"><span class="status-success">✓ Thanh toán thành công</span></c:when>
                            <c:otherwise><span class="status-success" style="background:#fafafa;color:#b42e1d;">✕ Chưa thanh toán</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <div class="info-row">
                    <span class="label">Mã giao dịch VNPay</span>
                    <span class="value">
                        <c:out value="${transactionCode}" default="Không có"/><c:if test="${not empty transactionCode and not empty bankCode}"> (<c:out value="${bankCode}"/>)</c:if>
                    </span>
                </div>

                <div class="info-row">
                    <span class="label">${ok ? 'Tổng thanh toán' : 'Giá trị đơn hàng'}</span>
                    <span class="value total-amount">
                        <c:choose>
                            <c:when test="${not empty finalAmount}"><fmt:formatNumber value="${finalAmount}" pattern="#,##0"/> đ</c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </section>

            <!-- Các nút điều hướng -->
            <div class="payment-actions">
                <c:choose>
                    <c:when test="${not empty orderId}">
                        <a class="btn btn-primary"
                           href="${pageContext.request.contextPath}/customer/booking-detail?orderId=${orderId}">
                            ${ok ? 'Xem vé điện tử' : 'Xem đơn hàng'} <span aria-hidden="true">→</span>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-primary"
                           href="${pageContext.request.contextPath}/customer/booking-history">
                            Vé của tôi <span aria-hidden="true">→</span>
                        </a>
                    </c:otherwise>
                </c:choose>

                <a class="btn btn-outline"
                   href="${pageContext.request.contextPath}/">
                    <span aria-hidden="true">←</span> Về trang chủ
                </a>
            </div>

            <!-- Lưu ý -->
            <section class="notice">
                <h2>
                    <span class="notice-icon">ⓘ</span>
                    ${ok ? 'Lưu ý sau khi đặt vé' : 'Lưu ý'}
                </h2>

                <c:choose>
                    <c:when test="${ok}">
                        <p>Vui lòng kiểm tra thông tin đơn hàng và email xác nhận.</p>
                        <p>Hãy lưu mã đơn hàng để tiện tra cứu khi cần hỗ trợ.</p>
                        <p>Vui lòng chuẩn bị vé điện tử khi tham gia sự kiện.</p>
                    </c:when>
                    <c:otherwise>
                        <p>Bạn chưa bị trừ tiền cho đơn này (trừ khi có thông báo hoàn tiền ở trên).</p>
                        <p>Nếu đơn còn trong thời gian giữ vé, bạn có thể vào "Xem đơn hàng" để thanh toán lại.</p>
                        <p>Hết thời gian giữ vé, đơn sẽ tự động hủy và vé được trả lại.</p>
                    </c:otherwise>
                </c:choose>
            </section>

            <div class="footer-note">
                Light Ticket - Chúc bạn có một trải nghiệm âm nhạc tuyệt vời!
            </div>

        </main>


    </div>

    <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>


</body>
</html>