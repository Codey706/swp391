<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>Sự kiện được phân công | Light Ticket</title>

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
              rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined"
              rel="stylesheet">

        <style>
            :root {
                --primary: #f45b35;
                --primary-hover: #df4825;
                --primary-light: #fff0e9;
                --text: #20242c;
                --muted: #737b89;
                --border: #e8ebf0;
                --background: #f5f7fb;
                --white: #ffffff;
                --green: #16834a;
                --green-light: #e8f7ee;
                --shadow: 0 5px 20px rgba(28, 39, 60, 0.04);
            }

            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                font-family: 'Inter', sans-serif;
                color: var(--text);
                background: var(--background);
                line-height: 1.5;
            }

            a {
                color: inherit;
                text-decoration: none;
            }

            button,
            a {
                font-family: inherit;
            }

            .material-symbols-outlined {
                font-size: 21px;
                line-height: 1;
                vertical-align: middle;
            }

            /* ===== HEADER ===== */

            .topbar {
                height: 72px;
                background: var(--white);
                border-bottom: 1px solid var(--border);
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 0 32px;
            }

            .brand {
                font-size: 24px;
                font-weight: 800;
                letter-spacing: -1px;
                color: var(--primary);
            }

            .brand span {
                color: var(--text);
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 11px;
                font-size: 13px;
                font-weight: 600;
            }

            .avatar {
                width: 40px;
                height: 40px;
                border-radius: 12px;
                background: var(--primary-light);
                color: var(--primary);
                display: grid;
                place-items: center;
            }

            /* ===== MAIN LAYOUT ===== */

            .container {
                width: 100%;
                max-width: 1200px;
                margin: 0 auto;
                padding: 32px 28px 56px;
            }

            .breadcrumb {
                color: var(--muted);
                font-size: 13px;
                margin-bottom: 25px;
            }

            .breadcrumb strong {
                color: var(--text);
                font-weight: 600;
            }

            .page-heading {
                margin-bottom: 28px;
            }

            h1 {
                font-size: 30px;
                line-height: 1.3;
                letter-spacing: -0.8px;
                margin: 0 0 8px;
                font-weight: 800;
            }

            .subtitle {
                color: var(--muted);
                font-size: 14px;
                margin: 0;
            }

            /* ===== SUMMARY ===== */

            .summary {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 18px;
                max-width: 700px;
                margin-bottom: 36px;
            }

            .summary-card {
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: 15px;
                padding: 22px 24px;
                box-shadow: var(--shadow);
            }

            .summary-label {
                display: flex;
                align-items: center;
                gap: 9px;
                color: var(--muted);
                font-size: 13px;
                font-weight: 500;
                margin-bottom: 14px;
            }

            .summary-label .material-symbols-outlined {
                color: var(--primary);
                font-size: 20px;
            }

            .summary-number {
                font-size: 34px;
                font-weight: 800;
                line-height: 1.1;
                letter-spacing: -1px;
            }

            /* ===== EVENT LIST HEADER ===== */

            .section-heading {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
                margin-bottom: 18px;
            }

            .section-heading h2 {
                font-size: 19px;
                font-weight: 700;
                letter-spacing: -0.3px;
                margin: 0;
            }

            .event-count {
                padding: 6px 12px;
                border-radius: 20px;
                background: #eceff4;
                color: #596170;
                font-size: 12px;
                font-weight: 600;
                white-space: nowrap;
            }

            /* ===== EVENT CARDS ===== */

            .event-list {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 22px;
                align-items: stretch;
            }

            .event-card {
                display: flex;
                flex-direction: column;
                min-width: 0;
                background: var(--white);
                border: 1px solid var(--border);
                border-radius: 16px;
                padding: 24px;
                box-shadow: var(--shadow);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }

            .event-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 28px rgba(28, 39, 60, 0.07);
            }

            .event-top {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 12px;
                padding-bottom: 20px;
                margin-bottom: 21px;
                border-bottom: 1px solid var(--border);
            }

            .event-heading {
                min-width: 0;
            }

            .event-id {
                display: inline-flex;
                align-items: center;
                background: var(--primary-light);
                color: var(--primary);
                padding: 5px 9px;
                border-radius: 6px;
                font-size: 11px;
                font-weight: 700;
                margin-bottom: 11px;
            }

            .event-name {
                font-size: 17px;
                line-height: 1.55;
                font-weight: 700;
                letter-spacing: -0.2px;
                overflow-wrap: anywhere;
            }

            .status {
                flex-shrink: 0;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 10px;
                border-radius: 20px;
                background: var(--green-light);
                color: var(--green);
                font-size: 11px;
                font-weight: 700;
                white-space: nowrap;
            }

            .status-dot {
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background: currentColor;
            }

            /* ===== EVENT DETAILS ===== */

            .event-details {
                display: grid;
                gap: 20px;
                flex: 1;
            }

            .detail-row {
                display: flex;
                align-items: flex-start;
                gap: 13px;
            }

            .detail-icon {
                flex-shrink: 0;
                width: 40px;
                height: 40px;
                display: grid;
                place-items: center;
                background: #f3f5f8;
                color: #616a79;
                border-radius: 11px;
            }

            .detail-row:first-child .detail-icon {
                background: var(--primary-light);
                color: var(--primary);
            }

            .detail-content {
                min-width: 0;
                padding-top: 2px;
            }

            .detail-label {
                color: var(--muted);
                font-size: 12px;
                font-weight: 500;
                margin-bottom: 5px;
            }

            .detail-value {
                color: var(--text);
                font-size: 13px;
                font-weight: 600;
                line-height: 1.65;
                overflow-wrap: anywhere;
            }

            /* ===== ACTION BUTTONS ===== */

            .event-actions {
                display: grid;
                grid-template-columns: 1.15fr 1fr;
                gap: 10px;
                margin-top: 25px;
                padding-top: 20px;
                border-top: 1px solid var(--border);
            }

            .btn {
                min-height: 44px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 7px;
                padding: 10px 12px;
                border: 1px solid transparent;
                border-radius: 9px;
                font-size: 12px;
                font-weight: 700;
                text-align: center;
                cursor: pointer;
                transition: background 0.2s ease, border-color 0.2s ease;
            }

            .btn .material-symbols-outlined {
                font-size: 19px;
            }

            .btn-primary {
                color: var(--white);
                background: var(--primary);
                border-color: var(--primary);
                box-shadow: 0 3px 7px rgba(244, 91, 53, 0.15);
            }

            .btn-primary:hover {
                color: var(--white);
                background: var(--primary-hover);
                border-color: var(--primary-hover);
            }

            .btn-secondary {
                color: #454c59;
                background: var(--white);
                border-color: #dfe3e9;
            }

            .btn-secondary:hover {
                background: #f7f8fa;
                border-color: #cbd1db;
            }

            /* ===== EMPTY STATE ===== */

            .empty-state {
                background: var(--white);
                border: 1px dashed #d4d9e2;
                border-radius: 16px;
                padding: 62px 24px;
                text-align: center;
            }

            .empty-icon {
                display: block;
                font-size: 46px;
                color: #a1a8b4;
                margin-bottom: 15px;
            }

            .empty-state h3 {
                font-size: 18px;
                margin: 0 0 8px;
            }

            .empty-state p {
                font-size: 14px;
                color: var(--muted);
                margin: 0;
            }

            /* ===== FOOTER ===== */

            footer {
                text-align: center;
                color: var(--muted);
                font-size: 12px;
                padding: 23px;
                border-top: 1px solid var(--border);
                background: var(--white);
            }

            /* ===== RESPONSIVE ===== */

            @media (max-width: 900px) {
                .event-list {
                    grid-template-columns: 1fr;
                }

                .summary {
                    max-width: 100%;
                }

                .event-card {
                    padding: 23px;
                }
            }

            @media (max-width: 560px) {
                .topbar {
                    height: 64px;
                    padding: 0 17px;
                }

                .brand {
                    font-size: 21px;
                }

                .user-info {
                    gap: 8px;
                    font-size: 12px;
                }

                .avatar {
                    width: 35px;
                    height: 35px;
                }

                .container {
                    padding: 25px 16px 40px;
                }

                h1 {
                    font-size: 25px;
                }

                .summary {
                    gap: 12px;
                    margin-bottom: 29px;
                }

                .summary-card {
                    padding: 17px 14px;
                    border-radius: 12px;
                }

                .summary-label {
                    align-items: flex-start;
                    font-size: 11px;
                    line-height: 1.5;
                    gap: 6px;
                }

                .summary-number {
                    font-size: 29px;
                }

                .section-heading h2 {
                    font-size: 17px;
                }

                .event-card {
                    padding: 18px;
                    border-radius: 14px;
                }

                .event-top {
                    gap: 9px;
                }

                .event-name {
                    font-size: 16px;
                }

                .status {
                    padding: 5px 8px;
                    font-size: 10px;
                }

                .event-actions {
                    grid-template-columns: 1fr;
                }

                .btn {
                    min-height: 45px;
                    font-size: 13px;
                }
            }
        </style>
    </head>

    <body>
        <header class="topbar">
            <a class="brand"
               href="${pageContext.request.contextPath}/staff">
                Light <span>Ticket</span>
            </a>

            <div class="user-info">
                <div class="avatar">
                    <span class="material-symbols-outlined">person</span>
                </div>
                <span>Nhân viên sự kiện</span>
            </div>
        </header>

        <main class="container">
            <div class="breadcrumb">
                Trang chủ / <strong>Sự kiện được phân công</strong>
            </div>

            <section class="page-heading">
                <h1>Sự kiện được phân công</h1>
                <p class="subtitle">
                    Xem thông tin các sự kiện bạn phụ trách.
                </p>
            </section>

            <%-- Calculate summary values --%>
            <c:set var="eventCount" value="${empty events ? 0 : events.size()}" />
            <c:set var="activeCount" value="0" />

            <c:forEach var="event" items="${events}">
                <c:if test="${event.status eq 'Active'}">
                    <c:set var="activeCount" value="${activeCount + 1}" />
                </c:if>
            </c:forEach>

            <section class="summary">
                <div class="summary-card">
                    <div class="summary-label">
                        <span class="material-symbols-outlined">event_note</span>
                        Tổng sự kiện được giao
                    </div>
                    <div class="summary-number">${eventCount}</div>
                </div>

                <div class="summary-card">
                    <div class="summary-label">
                        <span class="material-symbols-outlined">event_available</span>
                        Sự kiện đang hoạt động
                    </div>
                    <div class="summary-number">${activeCount}</div>
                </div>
            </section>

            <section class="event-section">
                <div class="section-heading">
                    <h2>Danh sách sự kiện</h2>
                    <span class="event-count">${eventCount} sự kiện</span>
                </div>

                <c:choose>
                    <c:when test="${not empty events}">
                        <div class="event-list">
                            <c:forEach var="event" items="${events}">
                                <article class="event-card">

                                    <div class="event-top">
                                        <div class="event-heading">
                                            <div class="event-id">
                                                Mã sự kiện #<c:out value="${event.eventId}" />
                                            </div>

                                            <div class="event-name">
                                                <c:out value="${event.eventName}" />
                                            </div>
                                        </div>

                                        <span class="status">
                                            <span class="status-dot"></span>
                                            <c:out value="${event.status}" />
                                        </span>
                                    </div>

                                    <div class="event-details">
                                        <div class="detail-row">
                                            <span class="material-symbols-outlined detail-icon">
                                                location_on
                                            </span>

                                            <div class="detail-content">
                                                <div class="detail-label">Địa điểm</div>
                                                <div class="detail-value">
                                                    <c:out value="${event.venueName}" />
                                                </div>
                                            </div>
                                        </div>

                                        <div class="detail-row">
                                            <span class="material-symbols-outlined detail-icon">
                                                calendar_month
                                            </span>

                                            <div class="detail-content">
                                                <div class="detail-label">Thời gian bắt đầu</div>
                                                <div class="detail-value">
                                                    <c:out value="${event.startTime}" />
                                                </div>
                                            </div>
                                        </div>

                                        <div class="detail-row">
                                            <span class="material-symbols-outlined detail-icon">
                                                event_available
                                            </span>

                                            <div class="detail-content">
                                                <div class="detail-label">Thời gian kết thúc</div>
                                                <div class="detail-value">
                                                    <c:out value="${event.endTime}" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="event-actions">
                                        <a class="btn btn-primary"
                                           href="${pageContext.request.contextPath}/staff/check-in?eventId=${event.eventId}">
                                            <span class="material-symbols-outlined">
                                                qr_code_scanner
                                            </span>
                                            Quét vé QR
                                        </a>

                                        <a class="btn btn-secondary"
                                           href="${pageContext.request.contextPath}/staff/event-detail?eventId=${event.eventId}">
                                            <span class="material-symbols-outlined">
                                                info
                                            </span>
                                            Chi tiết sự kiện
                                        </a>
                                    </div>

                                </article>
                            </c:forEach>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="empty-state">
                            <span class="material-symbols-outlined empty-icon">
                                event_busy
                            </span>

                            <h3>Chưa có sự kiện được phân công</h3>
                            <p>Các sự kiện được giao cho bạn sẽ hiển thị tại đây.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>
        </main>

        <footer>
            Light Ticket
        </footer>
    </body>
</html>