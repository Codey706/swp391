<%-- 
    Document   : staff-checkin
    Created on : Oct 23, 2026, 1:02:42 PM
    Author     : BT
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Check-in vé QR - Light Ticket</title>

        <link rel="stylesheet" href="${ctx}/assets/css/bootstrap.min.css"/>
        <link rel="stylesheet" href="${ctx}/assets/css/staff-checkin.css"/>

        <link rel="stylesheet"
              href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined"/>
    </head>

    <body class="qr-page">

        <header class="qr-header">
            <a class="qr-back" href="${ctx}/staff">
                <span class="material-symbols-outlined">arrow_back</span>
                <span>Về trang nhân viên</span>
            </a>

            <div class="qr-brand">
                <span class="material-symbols-outlined">qr_code_scanner</span>
                Light Ticket
            </div>

            <span class="qr-status">
                <span class="qr-status-dot"></span>
                Cổng soát vé
            </span>
        </header>

        <main class="qr-main">
            <div class="qr-heading">
                <span class="qr-icon material-symbols-outlined">
                    qr_code_scanner
                </span>
                <h1>Check-in vé bằng QR</h1>
                <p>Đưa mã QR trên vé vào giữa khung camera để xác nhận vé.</p>
            </div>

            <section class="qr-scanner-card">
                <div class="qr-card-header">
                    <div>
                        <h2>Quét mã vé</h2>
                        <p>Giữ mã QR rõ nét trước camera.</p>
                    </div>

                    <span class="qr-live">
                        <span class="qr-status-dot"></span>
                        Camera
                    </span>
                </div>

                <div id="qr-reader"></div>

                <p id="qrMessage" class="qr-message"
                   role="status" aria-live="polite">
                    Bấm “Bật camera” để bắt đầu quét vé.
                </p>

                <div class="qr-buttons">
                    <button type="button" id="openQrScanner"
                            class="qr-button qr-button-primary">
                        <span class="material-symbols-outlined">videocam</span>
                        Bật camera
                    </button>

                    <button type="button" id="closeQrScanner"
                            class="qr-button qr-button-secondary">
                        <span class="material-symbols-outlined">stop_circle</span>
                        Dừng quét
                    </button>
                </div>
            </section>

            <p class="qr-note">
                <span class="material-symbols-outlined">info</span>
                Chỉ check-in vé thuộc sự kiện được phân công cho bạn.
            </p>
        </main>

        <form id="qrCheckinForm"
              method="post"
              action="${ctx}/staff/customers"
              hidden>
            <input type="hidden" name="ticketCode" id="qrTicketCode">
        </form>

        <script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>
        <script src="${ctx}/assets/js/staff-qr-scanner.js"></script>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const params = new URLSearchParams(window.location.search);
                const result = params.get("checkin");
                const message = document.getElementById("qrMessage");

                if (!message || !result)
                    return;

                switch (result) {
                    case "success":
                        message.textContent = "✅ Check-in vé thành công!";
                        break;

                    case "already":
                        message.textContent = "⚠️ Vé này đã được check-in trước đó!";
                        break;

                    case "notfound":
                        message.textContent = "❌ Không tìm thấy vé hoặc vé không hợp lệ!";
                        break;

                    case "invalid":
                        message.textContent = "❌ Mã vé không hợp lệ!";
                        break;

                    case "failed":
                        message.textContent = "❌ Check-in thất bại. Vui lòng thử lại!";
                        break;
                }
            });
        </script>
    </body>
</html>
