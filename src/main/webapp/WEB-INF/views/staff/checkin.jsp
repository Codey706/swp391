<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- result: StaffCheckInDAO.Result, hoặc chuỗi "INVALID_CODE" --%>
<c:set var="resultKind" value="${empty result ? '' : (result eq 'INVALID_CODE' ? result : result.outcomeName)}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Check-in vé - Light Ticket</title>
        <jsp:include page="/WEB-INF/views/staff/_head.jsp"/>
        <link rel="stylesheet" href="${ctx}/assets/css/staff-seats.css">
        <style>
            .ci-form { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 12px; }
            .ci-form input[type=text] { flex: 1 1 260px; min-height: 48px; border: 1px solid #d4d4d8; border-radius: 10px; padding: 10px 14px; font: inherit; font-size: 16px; letter-spacing: .03em; }
            .ci-form input[type=text]:focus { outline: 2px solid var(--staff-accent); border-color: transparent; }
            .ci-result { display: flex; gap: 14px; align-items: flex-start; border-radius: 12px; padding: 16px 18px; margin-bottom: 18px; border: 1px solid; }
            .ci-result .ph { font-size: 32px; }
            .ci-result h3 { font-size: 17px; margin: 0 0 4px; }
            .ci-result p { margin: 0; }
            .ci-ok { background: #e7f6ee; border-color: #bfe3cf; color: #0e6b3e; }
            .ci-warn { background: #fff4dc; border-color: #f5d9a0; color: #8a2315; }
            .ci-bad { background: #fafafa; border-color: #ffd6cf; color: #b42e1d; }
            .ci-stats { display: flex; gap: 24px; flex-wrap: wrap; margin-top: 10px; }
            .ci-stats b { display: block; font-size: 22px; color: #141414; }
            .ci-table { width: 100%; border-collapse: collapse; font-size: 14px; }
            .ci-table th, .ci-table td { text-align: left; padding: 10px 8px; border-bottom: 1px solid #e4e4e7; }
            .ci-table th { color: #66666d; font-weight: 600; font-size: 12px; text-transform: uppercase; letter-spacing: .04em; }
            .ci-video { width: 100%; max-width: 360px; border-radius: 12px; margin-top: 12px; background: #000; }
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
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/staff/_header.jsp">
            <jsp:param name="active" value="checkin"/>
            <jsp:param name="current" value="Check-in"/>
        </jsp:include>

        <main class="org-main">
            <div class="ss-page">
                <div class="ss-head">
                    <h1>Check-in vé</h1>
                    <p>Quét mã QR trên vé điện tử hoặc nhập mã vé để xác nhận khách vào cổng.</p>
                </div>

                <c:choose>
                    <c:when test="${empty events}">
                        <div class="ss-panel ss-empty">
                            <i class="ph ph-calendar-x" aria-hidden="true"></i>
                            <p>Hôm nay bạn không có sự kiện được phân công cần soát vé.</p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <%-- ===== Kết quả lượt quét gần nhất ===== --%>
                        <c:if test="${not empty resultKind}">
                            <c:choose>
                                <c:when test="${resultKind eq 'CHECKED_IN'}"><c:set var="ciClass" value="ci-ok"/><c:set var="ciIcon" value="check-circle"/><c:set var="ciTitle" value="Check-in thành công"/></c:when>
                                <c:when test="${resultKind eq 'ALREADY_CHECKED_IN'}"><c:set var="ciClass" value="ci-warn"/><c:set var="ciIcon" value="warning"/><c:set var="ciTitle" value="Vé đã được check-in trước đó"/></c:when>
                                <c:when test="${resultKind eq 'WRONG_EVENT'}"><c:set var="ciClass" value="ci-bad"/><c:set var="ciIcon" value="prohibit"/><c:set var="ciTitle" value="Vé không thuộc sự kiện này"/></c:when>
                                <c:when test="${resultKind eq 'CANCELLED'}"><c:set var="ciClass" value="ci-bad"/><c:set var="ciIcon" value="prohibit"/><c:set var="ciTitle" value="Vé đã bị hủy"/></c:when>
                                <c:when test="${resultKind eq 'NOT_PAID'}"><c:set var="ciClass" value="ci-bad"/><c:set var="ciIcon" value="prohibit"/><c:set var="ciTitle" value="Đơn hàng của vé chưa thanh toán"/></c:when>
                                <c:when test="${resultKind eq 'NOT_FOUND'}"><c:set var="ciClass" value="ci-bad"/><c:set var="ciIcon" value="magnifying-glass"/><c:set var="ciTitle" value="Không tìm thấy vé"/></c:when>
                                <c:when test="${resultKind eq 'INVALID_CODE'}"><c:set var="ciClass" value="ci-bad"/><c:set var="ciIcon" value="warning-circle"/><c:set var="ciTitle" value="Mã vé không hợp lệ"/></c:when>
                                <c:otherwise><c:set var="ciClass" value="ci-bad"/><c:set var="ciIcon" value="warning-circle"/><c:set var="ciTitle" value="Hệ thống đang gặp sự cố. Vui lòng thử lại."/></c:otherwise>
                            </c:choose>
                            <div class="ci-result ${ciClass}" role="status" aria-live="polite">
                                <i class="ph ph-${ciIcon}" aria-hidden="true"></i>
                                <div>
                                    <h3><c:out value="${ciTitle}"/></h3>
                                    <c:if test="${resultKind ne 'INVALID_CODE'}">
                                        <p>Mã vé: <b><c:out value="${result.ticketCode}"/></b></p>
                                        <c:if test="${resultKind ne 'NOT_FOUND'}">
                                            <p>
                                                <c:out value="${result.customerName}"/> · <c:out value="${result.ticketName}"/>
                                                <c:if test="${not empty result.seatLabel}"> · Ghế <c:out value="${result.seatLabel}"/></c:if>
                                            </p>
                                        </c:if>
                                        <c:if test="${resultKind eq 'ALREADY_CHECKED_IN' and not empty result.checkInTime}">
                                            <p>Đã vào cổng lúc <c:out value="${fn:replace(fn:substring(result.checkInTime, 0, 16), 'T', ' ')}"/></p>
                                        </c:if>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>

                        <%-- ===== Sự kiện + ô nhập mã ===== --%>
                        <section class="ss-panel ss-event">
                            <div class="ss-event-main">
                                <div class="ss-title-row">
                                    <h2><c:out value="${event.eventName}"/></h2>
                                    <span class="ss-badge ${event.timeStatus eq 'ONGOING' ? 'is-live' : ''}">${event.timeStatus eq 'ONGOING' ? 'Đang diễn ra' : 'Sắp diễn ra'}</span>
                                </div>
                                <div class="ss-meta"><i class="ph ph-map-pin" aria-hidden="true"></i><span><c:out value="${event.venueName}"/></span></div>
                                <div class="ci-stats">
                                    <div><b><fmt:formatNumber value="${event.checkedIn}" pattern="#,##0"/></b>Đã check-in</div>
                                    <div><b><fmt:formatNumber value="${event.ticketIssued}" pattern="#,##0"/></b>Vé đã phát hành</div>
                                </div>

                                <form method="post" action="${ctx}/staff/checkin" class="ci-form" autocomplete="off">
                                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                                    <input type="hidden" name="eventId" value="${event.eventId}">
                                    <input type="text" name="ticketCode" id="ticketCode" maxlength="${maxCodeLength}"
                                           placeholder="Quét QR hoặc nhập mã vé, ví dụ TKT-..." required autofocus
                                           aria-label="Mã vé">
                                    <button type="submit" class="btn btn-primary" style="background:var(--staff-accent);border:0;min-height:48px;padding:0 22px;">Check-in</button>
                                    <button type="button" class="btn btn-outline-secondary" id="ciCameraBtn" style="min-height:48px;" hidden>
                                        <i class="ph ph-camera" style="vertical-align:middle;" aria-hidden="true"></i> Quét bằng camera
                                    </button>
                                </form>
                                <video id="ciVideo" class="ci-video" playsinline muted hidden></video>
                            </div>

                            <c:if test="${fn:length(events) > 1}">
                                <div class="ss-event-side">
                                    <form method="get" action="${ctx}/staff/checkin" id="ciEventForm" class="ss-switch">
                                        <label for="ciEventSelect">Sự kiện đang soát vé</label>
                                        <select id="ciEventSelect" name="eventId" onchange="this.form.submit()">
                                            <c:forEach var="e" items="${events}">
                                                <option value="${e.eventId}" ${e.eventId == event.eventId ? 'selected' : ''}><c:out value="${e.eventName}"/></option>
                                            </c:forEach>
                                        </select>
                                        <noscript><button type="submit" class="ss-btn">Chọn</button></noscript>
                                    </form>
                                </div>
                            </c:if>
                        </section>

                        <%-- ===== Lượt check-in gần đây ===== --%>
                        <section class="ss-panel">
                            <h3 style="font-size:16px;margin:0 0 12px;">Lượt check-in gần đây</h3>
                            <c:choose>
                                <c:when test="${empty recent}">
                                    <p class="text-secondary mb-0">Chưa có vé nào được check-in.</p>
                                </c:when>
                                <c:otherwise>
                                    <div style="overflow-x:auto;">
                                        <table class="ci-table">
                                            <thead><tr><th>Thời gian</th><th>Mã vé</th><th>Khách hàng</th><th>Hạng vé</th><th>Ghế</th></tr></thead>
                                            <tbody>
                                                <c:forEach var="r" items="${recent}">
                                                    <tr>
                                                        <td><c:out value="${empty r.checkInTime ? '' : fn:substring(r.checkInTime, 11, 16)}"/></td>
                                                        <td><c:out value="${r.ticketCode}"/></td>
                                                        <td><c:out value="${r.customerName}"/></td>
                                                        <td><c:out value="${r.ticketName}"/></td>
                                                        <td><c:out value="${r.seatLabel}" default="-"/></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </section>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>

        <jsp:include page="/WEB-INF/views/staff/_footer.jsp"/>
        <script>
            // Quét QR bằng camera nếu trình duyệt hỗ trợ BarcodeDetector; máy quét cầm tay vẫn nhập thẳng vào ô mã vé.
            (function () {
                var btn = document.getElementById('ciCameraBtn');
                var video = document.getElementById('ciVideo');
                var input = document.getElementById('ticketCode');
                if (!btn || !('BarcodeDetector' in window) || !navigator.mediaDevices) {
                    return;
                }
                btn.hidden = false;
                btn.addEventListener('click', function () {
                    var detector = new BarcodeDetector({formats: ['qr_code']});
                    navigator.mediaDevices.getUserMedia({video: {facingMode: 'environment'}}).then(function (stream) {
                        video.srcObject = stream;
                        video.hidden = false;
                        video.play();
                        btn.disabled = true;
                        var scan = function () {
                            detector.detect(video).then(function (codes) {
                                if (codes.length) {
                                    stream.getTracks().forEach(function (t) { t.stop(); });
                                    input.value = codes[0].rawValue;
                                    input.form.submit();
                                } else {
                                    requestAnimationFrame(scan);
                                }
                            }).catch(function () { requestAnimationFrame(scan); });
                        };
                        scan();
                    }).catch(function () {
                        btn.hidden = true;
                    });
                });
            })();
        </script>
    <%-- Cần cho menu ☰ (mobile) và dropdown tài khoản trong _header.jsp --%>
    <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
    <script src="${ctx}/assets/js/event.js"></script>
    </body>
</html>
