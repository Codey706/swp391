<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Vé điện tử | Light Ticket</title>
        <%-- checkout.css chứa style của header dùng chung (booking-header.jsp) --%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkout.css">

        <style>
            :root {
                --primary: #d93a27;
                --primary-dark: #ff5b49;
                --primary-light: #fafafa;
                --background: #f5f5f6;
                --text: #1f1f22;
                --muted: #77777e;
                --border: #efeff1;
                --success: #13804b;
            }

            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                font-family: 'Inter', Arial, sans-serif;
                color: var(--text);
                background: var(--background);
                line-height: 1.6;
            }

            a {
                color: inherit;
            }

            .page-container {
                width: min(1100px, calc(100% - 40px));
                margin: 38px auto 60px;
            }

            .page-heading {
                margin-bottom: 26px;
            }

            .page-heading .eyebrow {
                color: var(--primary-dark);
                font-size: 13px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1.2px;
                margin: 0 0 5px;
            }

            .page-heading h1 {
                font-size: clamp(26px, 4vw, 34px);
                line-height: 1.25;
                margin: 0 0 10px;
                font-weight: 750;
            }

            .page-heading p {
                margin: 0;
                color: var(--muted);
                font-size: 15px;
            }

            .ticket-list {
                display: grid;
                gap: 22px;
            }

            .ticket {
                display: grid;
                grid-template-columns: minmax(0, 1fr) 225px;
                background: #fff;
                border: 1px solid var(--border);
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 5px 22px rgba(31, 31, 34, 0.045);
                transition: box-shadow 0.2s ease,
                    transform 0.2s ease;
            }

            .ticket:hover {
                box-shadow: 0 9px 28px rgba(31, 31, 34, 0.08);
                transform: translateY(-2px);
            }

            .ticket-info {
                padding: 28px 30px;
                min-width: 0;
            }

            .ticket-topline {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 12px;
                flex-wrap: wrap;
                margin-bottom: 12px;
            }

            .ticket-label {
                display: inline-flex;
                align-items: center;
                padding: 5px 11px;
                background: var(--primary-light);
                color: var(--primary-dark);
                border-radius: 12px;
                font-size: 12px;
                font-weight: 700;
            }

            .status {
                display: inline-flex;
                align-items: center;
                padding: 5px 11px;
                border-radius: 12px;
                background: #e7f6ee;
                color: var(--success);
                font-size: 12px;
                font-weight: 700;
            }

            .status.is-checked-in {
                background: #efeff1;
                color: #4b4b52;
            }

            .status.is-cancelled {
                background: #fff4f2;
                color: #b42e1d;
            }

            .ticket.is-used .ticket-qr img,
            .ticket.is-cancelled .ticket-qr img {
                opacity: 0.35;
                filter: grayscale(1);
            }

            .ticket-info h2 {
                color: var(--text);
                font-size: 23px;
                line-height: 1.4;
                margin: 0 0 22px;
                overflow-wrap: anywhere;
            }

            .ticket-details {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 18px 24px;
            }

            .detail-item {
                min-width: 0;
            }

            .detail-label {
                display: block;
                color: var(--muted);
                font-size: 12px;
                margin-bottom: 3px;
            }

            .detail-value {
                display: block;
                font-size: 14px;
                font-weight: 600;
                overflow-wrap: anywhere;
            }

            .ticket-code {
                color: var(--primary-dark);
                letter-spacing: 0.3px;
            }

            .ticket-qr {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                text-align: center;
                padding: 24px 18px;
                background: #fafafa;
                border-left: 1px dashed #ffd6cf;
                position: relative;
            }

            .ticket-qr::before,
            .ticket-qr::after {
                content: "";
                position: absolute;
                left: -11px;
                width: 22px;
                height: 22px;
                border-radius: 50%;
                background: var(--background);
            }

            .ticket-qr::before {
                top: -11px;
            }

            .ticket-qr::after {
                bottom: -11px;
            }

            .qr-title {
                margin: 0 0 12px;
                font-size: 14px;
                font-weight: 700;
            }

            .qr-image-wrap {
                width: 164px;
                height: 164px;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 9px;
                background: white;
                border: 1px solid var(--border);
                border-radius: 12px;
            }

            .qr-image-wrap img {
                display: block;
                width: 100%;
                height: 100%;
                object-fit: contain;
            }

            .qr-note {
                color: var(--muted);
                font-size: 12px;
                margin: 12px 0 0;
            }

            .empty-state {
                background: #fff;
                border: 1px solid var(--border);
                border-radius: 12px;
                padding: 54px 24px;
                text-align: center;
                box-shadow: 0 5px 22px rgba(31, 31, 34, 0.04);
            }

            .empty-icon {
                width: 76px;
                height: 76px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 18px;
                background: var(--primary-light);
                border-radius: 50%;
                color: var(--primary-dark);
                font-size: 34px;
            }

            .empty-state h2 {
                font-size: 22px;
                margin: 0 0 8px;
            }

            .empty-state p {
                color: var(--muted);
                font-size: 14px;
                margin: 0 auto 23px;
                max-width: 430px;
            }

            .primary-button {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 22px;
                background: var(--primary);
                color: #fff;
                text-decoration: none;
                border-radius: 9px;
                font-size: 14px;
                font-weight: 700;
                transition: background 0.2s ease,
                    transform 0.2s ease;
            }

            .primary-button:hover {
                background: var(--primary-dark);
                transform: translateY(-1px);
            }

            .page-footer-note {
                color: var(--muted);
                font-size: 12px;
                text-align: center;
                margin-top: 26px;
            }

            @media (max-width: 700px) {
                .page-container {
                    width: min(100% - 24px, 520px);
                    margin-top: 25px;
                }

                .ticket {
                    grid-template-columns: minmax(0, 1fr);
                }

                .ticket-info {
                    padding: 22px 20px;
                }

                .ticket-info h2 {
                    font-size: 20px;
                }

                .ticket-qr {
                    border-left: none;
                    border-top: 1px dashed #ffd6cf;
                    padding: 24px 18px;
                }

                .ticket-qr::before,
                .ticket-qr::after {
                    top: -11px;
                    bottom: auto;
                }

                .ticket-qr::before {
                    left: -11px;
                }

                .ticket-qr::after {
                    left: auto;
                    right: -11px;
                }

                .ticket-details {
                    grid-template-columns: minmax(0, 1fr);
                    gap: 13px;
                }

                .empty-state {
                    padding: 38px 18px;
                }
            }

            /* ---- Nút in vé ---- */
            .page-heading-row {
                display: flex;
                align-items: flex-end;
                justify-content: space-between;
                gap: 16px;
                flex-wrap: wrap;
            }

            .print-button {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                height: 42px;
                padding: 0 18px;
                border: 0;
                border-radius: 10px;
                background: var(--primary);
                color: #fff;
                font: inherit;
                font-weight: 700;
                cursor: pointer;
            }

            .print-button:hover {
                background: #b42e1d;
            }

            .print-only {
                display: none;
            }

            /* ---- Bản in: chỉ in e-ticket, mỗi vé một trang ---- */
            @media print {
                @page {
                    size: A4 portrait;
                    margin: 14mm;
                }

                html,
                body {
                    background: #fff !important;
                }

                body * {
                    -webkit-print-color-adjust: exact;
                    print-color-adjust: exact;
                }

                .sh-header,
                .page-heading,
                .print-button,
                .page-footer-note,
                .empty-state,
                .modal,
                .modal-backdrop,
                .ticket.is-cancelled {
                    display: none !important;
                }

                .page-container {
                    width: auto;
                    margin: 0;
                    padding: 0;
                }

                .ticket-list {
                    display: block;
                }

                .ticket {
                    display: block;
                    box-shadow: none !important;
                    transform: none !important;
                    border: 1.5px solid #1f1f22;
                    border-radius: 14px;
                    overflow: hidden;
                    break-inside: avoid;
                    page-break-inside: avoid;
                    break-after: page;
                    page-break-after: always;
                }

                .ticket:last-child {
                    break-after: auto;
                    page-break-after: auto;
                }

                .print-only {
                    display: block;
                }

                .print-brand {
                    padding: 14px 28px;
                    border-bottom: 1.5px dashed #9a9aa1;
                    font-size: 14px;
                    font-weight: 700;
                    letter-spacing: .04em;
                }

                .ticket-info {
                    padding: 24px 28px;
                }

                .ticket-info h2 {
                    font-size: 26px;
                }

                .ticket-details {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }

                .ticket-qr {
                    border-left: none;
                    border-top: 1.5px dashed #9a9aa1;
                    padding: 24px 28px 28px;
                    text-align: center;
                }

                .ticket-qr::before,
                .ticket-qr::after {
                    display: none;
                }

                .qr-image-wrap {
                    width: 64mm;
                    height: 64mm;
                    margin: 0 auto;
                    padding: 3mm;
                }

                .ticket-qr img {
                    width: 100%;
                    height: 100%;
                    filter: none !important;
                    opacity: 1 !important;
                }
            }

            @media (prefers-reduced-motion: reduce) {
                *,
                *::before,
                *::after {
                    transition: none !important;
                }
            }
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
        <jsp:include page="booking-header.jsp"/>

        <main class="page-container">
            <header class="page-heading page-heading-row">
                <div>
                    <p class="eyebrow">Light Ticket · Tài khoản của tôi</p>
                    <h1>Vé điện tử của tôi</h1>
                    <p>Xem thông tin vé và sử dụng mã QR khi check-in sự kiện.</p>
                </div>
                <c:if test="${not empty tickets}">
                    <button type="button" class="print-button" onclick="window.print()">
                        <i class="ph ph-printer" aria-hidden="true"></i> In vé
                    </button>
                </c:if>
            </header>

            <c:choose>
                <c:when test="${empty tickets}">
                    <section class="empty-state">
                        <div class="empty-icon" aria-hidden="true">&#13804b;</div>
                        <h2>Bạn chưa có vé điện tử</h2>
                        <p>
                            Vé điện tử sẽ hiển thị tại đây sau khi bạn hoàn tất
                            thanh toán thành công.
                        </p>
                        <a class="primary-button"
                           href="${pageContext.request.contextPath}/home">
                            Khám phá sự kiện
                        </a>
                    </section>
                </c:when>

                <c:otherwise>
                    <div class="ticket-list">
                        <c:forEach var="ticket" items="${tickets}">
                            <c:set var="st" value="${ticket.ticketStatus}"/>
                            <article class="ticket ${st == 'CheckedIn' ? 'is-used' : (st == 'Cancelled' ? 'is-cancelled' : '')}">
                                <div class="print-only print-brand">LIGHT TICKET · VÉ ĐIỆN TỬ</div>
                                <div class="ticket-info">
                                    <div class="ticket-topline">
                                        <span class="ticket-label">
                                            VÉ ĐIỆN TỬ
                                        </span>
                                        <c:choose>
                                            <c:when test="${st == 'Valid'}"><span class="status">Còn hiệu lực</span></c:when>
                                            <c:when test="${st == 'CheckedIn'}"><span class="status is-checked-in">Đã check-in</span></c:when>
                                            <c:when test="${st == 'Cancelled'}"><span class="status is-cancelled">Đã huỷ</span></c:when>
                                            <c:otherwise><span class="status"><c:out value="${st}"/></span></c:otherwise>
                                        </c:choose>
                                    </div>

                                    <h2>
                                        <c:out value="${ticket.eventName}"/>
                                    </h2>

                                    <div class="ticket-details">
                                        <div class="detail-item">
                                            <span class="detail-label">Mã vé</span>
                                            <span class="detail-value ticket-code">
                                                <c:out value="${ticket.ticketCode}"/>
                                            </span>
                                        </div>

                                        <div class="detail-item">
                                            <span class="detail-label">Loại vé</span>
                                            <span class="detail-value">
                                                <c:out value="${ticket.ticketName}"/>
                                            </span>
                                        </div>

                                        <div class="detail-item">
                                            <span class="detail-label">Địa điểm</span>
                                            <span class="detail-value">
                                                <c:out value="${ticket.venueName}"/>
                                            </span>
                                        </div>

                                        <div class="detail-item">
                                            <span class="detail-label">
                                                Thời gian bắt đầu
                                            </span>
                                            <span class="detail-value">
                                                <c:out value="${ticket.eventStartLabel}"/>
                                            </span>
                                        </div>

                                        <div class="detail-item">
                                            <span class="detail-label">Ghế</span>
                                            <span class="detail-value">
                                                <c:choose>
                                                    <c:when test="${not empty ticket.seatLabel}">
                                                        <c:out value="${ticket.seatLabel}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        Không có ghế cố định
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <aside class="ticket-qr">
                                    <p class="qr-title">Mã QR check-in</p>

                                    <div class="qr-image-wrap">
                                        <c:url var="qrUrl" value="/customer/ticket-qr">
                                            <c:param name="code" value="${ticket.ticketCode}"/>
                                        </c:url>
                                        <img src="${qrUrl}" width="180" height="180"
                                             alt="Mã QR của vé điện tử">
                                    </div>

                                    <p class="qr-note">
                                        Xuất trình mã QR tại cổng sự kiện
                                    </p>
                                </aside>
                            </article>
                        </c:forEach>
                    </div>

                    <p class="page-footer-note">
                        Vui lòng kiểm tra thông tin vé trước khi tham dự sự kiện.
                    </p>
                </c:otherwise>
            </c:choose>
        </main>
        <script>
            // Mở từ "In vé" ở trang chi tiết đơn (?print=1): đợi ảnh QR tải xong rồi mở hộp thoại in.
            (function () {
                if (!/[?&]print=1(&|$)/.test(location.search)) return;
                window.addEventListener('load', function () { window.print(); });
            })();
        </script>
    <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>
</body>
</html>