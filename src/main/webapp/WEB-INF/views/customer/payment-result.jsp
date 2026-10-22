<%-- 
    Document   : payment-result
    Created on : Oct 22, 2026, 11:04:12 PM
    Author     : ADMIN
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đặt vé thành công | Light Ticketbox</title>


        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/payment-result.css">

    </head>

    <body>
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

            <!-- Thông báo thành công -->
            <section class="success-heading">
                <div class="success-icon">✓</div>
                <h1>Đặt vé thành công!</h1>
                <p>Cảm ơn bạn đã đặt vé. Chúc bạn có trải nghiệm tuyệt vời.</p>
            </section>

            <!-- Thông tin đơn hàng -->
            <section class="payment-card">
                <h2 class="card-title">
                    <span class="title-mark">▣</span>
                    Thông tin đơn hàng
                </h2>

                <div class="order-code">
                    <span class="label">Mã đơn hàng</span>
                    <strong>
                        <%= request.getAttribute("orderCode") != null
                                ? request.getAttribute("orderCode") : "Đang cập nhật"%>
                    </strong>
                </div>

                <div class="info-row">
                    <span class="label">Trạng thái thanh toán</span>
                    <span class="value">
                        <span class="status-success">✓ Thanh toán thành công</span>
                    </span>
                </div>

                <div class="info-row">
                    <span class="label">Mã giao dịch VNPay</span>
                    <span class="value">
                        <%= request.getAttribute("transactionCode") != null
                                ? request.getAttribute("transactionCode") : "Không có thông tin"%>
                    </span>
                </div>

                <div class="info-row">
                    <span class="label">Tổng thanh toán</span>
                    <span class="value total-amount">
                        <%= request.getAttribute("finalAmount") != null
                                ? request.getAttribute("finalAmount") : "0"%> VNĐ
                    </span>
                </div>
            </section>

            <!-- Các nút điều hướng -->
            <div class="payment-actions">
                <a class="btn btn-primary"
                   href="${pageContext.request.contextPath}/customer/booking-history">
                    Vé của tôi <span aria-hidden="true">→</span>
                </a>

                <a class="btn btn-outline"
                   href="${pageContext.request.contextPath}/">
                    <span aria-hidden="true">←</span> Về trang chủ
                </a>
            </div>

            <!-- Lưu ý -->
            <section class="notice">
                <h2>
                    <span class="notice-icon">ⓘ</span>
                    Lưu ý sau khi đặt vé
                </h2>

                <p>Vui lòng kiểm tra thông tin đơn hàng và email xác nhận.</p>
                <p>Hãy lưu mã đơn hàng để tiện tra cứu khi cần hỗ trợ.</p>
                <p>Vui lòng chuẩn bị vé điện tử khi tham gia sự kiện.</p>
            </section>

            <div class="footer-note">
                Light Ticketbox — Chúc bạn có một trải nghiệm âm nhạc tuyệt vời!
            </div>

        </main>


    </div>

    <footer class="simple-footer">
        <a class="simple-footer-brand"
           href="${pageContext.request.contextPath}/">
            Light Ticketbox
        </a>

        <nav class="simple-footer-nav">
            <a href="${pageContext.request.contextPath}/">Trang chủ</a>

            <a href="${pageContext.request.contextPath}/customer/booking-history">
                Vé của tôi
            </a>

            <a href="${pageContext.request.contextPath}/customer/profile">
                Hồ sơ cá nhân
            </a>
        </nav>

        <p class="simple-footer-copyright">
            © 2026 Light Ticket. All rights reserved.
        </p>
    </footer>


</body>
</html>