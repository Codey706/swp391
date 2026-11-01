<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Vé điện tử | Light Ticket</title>

        <style>
            :root {
                --primary: #ff7043;
                --primary-dark: #e85d32;
                --primary-light: #fff0e9;
                --background: #f7f8fc;
                --text: #242424;
                --muted: #777;
                --border: #ececec;
                --success: #16834a;
            }

            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                font-family: Arial, Helvetica, sans-serif;
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
                border-radius: 18px;
                overflow: hidden;
                box-shadow: 0 5px 22px rgba(30, 30, 30, 0.045);
                transition: box-shadow 0.2s ease,
                    transform 0.2s ease;
            }

            .ticket:hover {
                box-shadow: 0 9px 28px rgba(30, 30, 30, 0.08);
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
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
            }

            .status {
                display: inline-flex;
                align-items: center;
                padding: 5px 11px;
                border-radius: 20px;
                background: #e9f8ef;
                color: var(--success);
                font-size: 12px;
                font-weight: 700;
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
                background: #fffaf7;
                border-left: 1px dashed #f0c7b8;
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
                border-radius: 18px;
                padding: 54px 24px;
                text-align: center;
                box-shadow: 0 5px 22px rgba(30, 30, 30, 0.04);
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
                    border-top: 1px dashed #f0c7b8;
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

            @media (prefers-reduced-motion: reduce) {
                *,
                *::before,
                *::after {
                    transition: none !important;
                }
            }
        </style>
    </head>

    <body>
        <jsp:include page="booking-header.jsp"/>

        <main class="page-container">
            <header class="page-heading">
                <p class="eyebrow">Light Ticket · Tài khoản của tôi</p>
                <h1>Vé điện tử của tôi</h1>
                <p>Xem thông tin vé và sử dụng mã QR khi check-in sự kiện.</p>
            </header>

            <c:choose>
                <c:when test="${empty tickets}">
                    <section class="empty-state">
                        <div class="empty-icon" aria-hidden="true">&#127915;</div>
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
                            <article class="ticket">
                                <div class="ticket-info">
                                    <div class="ticket-topline">
                                        <span class="ticket-label">
                                            VÉ ĐIỆN TỬ
                                        </span>
                                        <span class="status">
                                            <c:out value="${ticket.ticketStatus}"/>
                                        </span>
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
                                                <c:out value="${ticket.eventStartTime}"/>
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
                                        <img
                                            src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&amp;data=${ticket.ticketCode}"
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
    </body>
</html>