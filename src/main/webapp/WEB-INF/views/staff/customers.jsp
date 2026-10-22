<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Đường dẫn cho "Thao tác nhanh": các trang này chưa có trong project nên để trống (hiện dạng vô hiệu).
     Khi có trang, gán URL, ví dụ: ${ctx}/staff/checkin?eventId=${selectedEvent.eventId} --%>
<c:set var="qrUrl" value=""/>
<c:set var="verifyUrl" value=""/>
<c:set var="seatUrl" value=""/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thông tin khách hàng - Light Ticket</title>
    <jsp:include page="/WEB-INF/views/staff/_head.jsp"/>
    <link rel="stylesheet" href="${ctx}/assets/css/staff-customers.css">
</head>
<body class="org-body">
    <jsp:include page="/WEB-INF/views/staff/_header.jsp">
        <jsp:param name="active" value="customers"/>
        <jsp:param name="current" value="Customer Information"/>
    </jsp:include>

    <main class="org-main">
        <div class="sc-page">
            <div class="sc-head">
                <h1>Thông tin khách hàng</h1>
                <p>Xem thông tin khách hàng và vé liên quan đến sự kiện được phân công.</p>
            </div>

            <div class="sc-layout">

                <%-- ===================== Trái: danh sách khách hàng ===================== --%>
                <aside>
                    <section class="sc-panel">
                        <form class="sc-search" method="get" action="${ctx}/staff/customers">
                            <input type="hidden" name="tab" value="${selectedTab}">
                            <input type="text" name="keyword" class="sc-input" maxlength="100"
                                   placeholder="Tìm kiếm khách hàng (tên, SĐT, email...)" value="<c:out value='${keyword}'/>">
                            <button type="submit" class="sc-icon-btn" aria-label="Tìm kiếm"><span class="material-symbols-outlined">search</span></button>
                        </form>

                        <nav class="sc-tabs" aria-label="Lọc theo trạng thái check-in">
                            <c:forEach var="t" items="${tabLabels}">
                                <c:url var="tabUrl" value="/staff/customers">
                                    <c:param name="tab" value="${t.key}"/>
                                    <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                                </c:url>
                                <a class="sc-tab ${selectedTab == t.key ? 'is-active' : ''}" href="${tabUrl}">
                                    <c:out value="${t.value}"/> (${tabCounts[t.key]})
                                </a>
                            </c:forEach>
                        </nav>

                        <c:forEach var="c" items="${customers}">
                            <c:url var="selectUrl" value="/staff/customers">
                                <c:param name="customerId" value="${c.userId}"/>
                                <c:param name="tab" value="${selectedTab}"/>
                                <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                                <c:if test="${currentPage > 1}"><c:param name="page" value="${currentPage}"/></c:if>
                            </c:url>
                            <c:set var="sk" value="${c.statusKey}"/>
                            <a class="sc-row ${not empty customer && customer.userId == c.userId ? 'is-active' : ''}" href="${selectUrl}"
                               ${not empty customer && customer.userId == c.userId ? 'aria-current="true"' : ''}>
                                <span class="sc-avatar ${sk == 'CHECKED_IN' || sk == 'PARTIAL' ? 'is-ok' : ''}"><c:out value="${c.initials}"/></span>
                                <span class="sc-row-main">
                                    <span class="sc-row-name d-block"><c:out value="${c.fullName}"/></span>
                                    <span class="sc-row-sub">
                                        <span>
                                            <span class="material-symbols-outlined">${not empty c.phone ? 'call' : 'mail'}</span>
                                            <c:out value="${not empty c.phone ? c.phone : c.email}"/>
                                        </span>
                                    </span>
                                    <span class="sc-row-sub">
                                        <span>
                                            <span class="material-symbols-outlined">confirmation_number</span>
                                            ${c.activeTickets} vé<c:if test="${c.eventCount > 1}"> · ${c.eventCount} sự kiện</c:if>
                                        </span>
                                        <c:choose>
                                            <c:when test="${sk == 'CHECKED_IN'}"><span class="sc-badge is-ok">Đã check-in</span></c:when>
                                            <c:when test="${sk == 'NOT_CHECKED_IN'}"><span class="sc-badge is-none">Chưa check-in</span></c:when>
                                            <c:when test="${sk == 'PARTIAL'}"><span class="sc-badge is-partial">${c.checkedIn}/${c.activeTickets} đã check-in</span></c:when>
                                            <c:otherwise><span class="sc-badge is-cancelled">Vé đã hủy</span></c:otherwise>
                                        </c:choose>
                                    </span>
                                </span>
                                <span class="material-symbols-outlined sc-chevron">chevron_right</span>
                            </a>
                        </c:forEach>

                        <c:if test="${empty customers}">
                            <div class="sc-empty">
                                <span class="material-symbols-outlined">person_search</span>
                                <c:choose>
                                    <c:when test="${totalAll == 0}">Chưa có khách hàng nào có vé trong các sự kiện được phân công cho bạn.</c:when>
                                    <c:otherwise>Không tìm thấy khách hàng phù hợp.</c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>

                        <c:if test="${totalPages > 1}">
                            <c:url var="pageBase" value="/staff/customers">
                                <c:param name="tab" value="${selectedTab}"/>
                                <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                            </c:url>
                            <div class="sc-foot">
                                <nav class="pager" aria-label="Phân trang">
                                    <a class="${currentPage <= 1 ? 'disabled' : ''}" href="${pageBase}&page=${currentPage - 1}" aria-label="Trang trước"><span class="material-symbols-outlined" style="font-size:20px">chevron_left</span></a>
                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                        <a class="${i == currentPage ? 'active' : ''}" href="${pageBase}&page=${i}">${i}</a>
                                    </c:forEach>
                                    <a class="${currentPage >= totalPages ? 'disabled' : ''}" href="${pageBase}&page=${currentPage + 1}" aria-label="Trang sau"><span class="material-symbols-outlined" style="font-size:20px">chevron_right</span></a>
                                </nav>
                                <span>${totalResults} khách hàng</span>
                            </div>
                        </c:if>
                    </section>
                </aside>

                <%-- ===================== Giữa: chi tiết khách hàng ===================== --%>
                <section class="sc-main">
                    <c:choose>
                        <c:when test="${empty customer}">
                            <div class="sc-panel">
                                <div class="sc-empty">
                                    <span class="material-symbols-outlined">badge</span>
                                    Chọn một khách hàng trong danh sách để xem thông tin và vé.
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <%-- Thông tin khách hàng + thống kê vé --%>
                            <div class="sc-panel">
                                <div class="sc-profile">
                                    <span class="sc-avatar is-lg ${contextStatus == 'CHECKED_IN' || contextStatus == 'PARTIAL' ? 'is-ok' : ''}"><c:out value="${customer.initials}"/></span>
                                    <div>
                                        <div>
                                            <h2><c:out value="${customer.fullName}"/></h2>
                                            <c:choose>
                                                <c:when test="${contextStatus == 'CHECKED_IN'}"><span class="sc-badge is-ok">Đã check-in</span></c:when>
                                                <c:when test="${contextStatus == 'NOT_CHECKED_IN'}"><span class="sc-badge is-none">Chưa check-in</span></c:when>
                                                <c:when test="${contextStatus == 'PARTIAL'}"><span class="sc-badge is-partial">${ticketChecked}/${ticketActive} đã check-in</span></c:when>
                                                <c:otherwise><span class="sc-badge is-cancelled">Vé đã hủy</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                        <span class="sc-line"><span class="material-symbols-outlined">call</span><c:out value="${empty customer.phone ? 'Chưa cập nhật' : customer.phone}"/></span>
                                        <span class="sc-line"><span class="material-symbols-outlined">mail</span><c:out value="${empty customer.email ? 'Chưa cập nhật' : customer.email}"/></span>
                                        <span class="sc-line"><span class="material-symbols-outlined">location_on</span><c:out value="${empty customer.address ? 'Chưa cập nhật' : customer.address}"/></span>
                                    </div>
                                </div>

                                <div class="sc-stats">
                                    <div class="sc-stat"><span>Tổng số vé</span><b>${ticketActive}</b></div>
                                    <div class="sc-stat"><span>Đã check-in</span><b>${ticketChecked}</b></div>
                                    <div class="sc-stat"><span>Chưa check-in</span><b>${ticketNotChecked}</b></div>
                                </div>
                                <c:if test="${ticketCancelled > 0}">
                                    <p class="sc-note">Chưa tính ${ticketCancelled} vé đã hủy.</p>
                                </c:if>

                                <c:if test="${fn:length(customerEvents) > 1}">
                                    <div class="sc-events">
                                        <span>Khách có vé ở ${fn:length(customerEvents)} sự kiện, chọn sự kiện:</span>
                                        <c:forEach var="ev" items="${customerEvents}">
                                            <c:url var="evUrl" value="/staff/customers">
                                                <c:param name="customerId" value="${customer.userId}"/>
                                                <c:param name="eventId" value="${ev.eventId}"/>
                                                <c:param name="tab" value="${selectedTab}"/>
                                                <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
                                                <c:if test="${currentPage > 1}"><c:param name="page" value="${currentPage}"/></c:if>
                                            </c:url>
                                            <a class="sc-event-pill ${ev.eventId == selectedEvent.eventId ? 'is-active' : ''}" href="${evUrl}"><c:out value="${ev.eventName}"/></a>
                                        </c:forEach>
                                    </div>
                                </c:if>
                            </div>

                            <%-- Thông tin vé --%>
                            <div class="sc-panel">
                                <h3 class="sc-title">Thông tin vé</h3>
                                <c:choose>
                                    <c:when test="${empty tickets}">
                                        <div class="sc-empty"><span class="material-symbols-outlined">confirmation_number</span>Khách hàng chưa có vé trong sự kiện này.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="sc-table-wrap">
                                            <table class="sc-table">
                                                <thead>
                                                    <tr>
                                                        <th>Mã vé</th><th>Loại vé</th><th>Sự kiện</th><th>Thời gian</th><th>Trạng thái</th><th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="t" items="${tickets}">
                                                        <c:set var="ts" value="${fn:toLowerCase(t.status)}"/>
                                                        <c:set var="es" value="${t.eventStartTime}"/>
                                                        <c:set var="ci" value="${t.checkInTime}"/>
                                                        <c:set var="statusText" value="${ts == 'checkedin' ? 'Đã check-in' : (ts == 'valid' ? 'Chưa check-in' : (ts == 'cancelled' ? 'Đã hủy' : t.status))}"/>
                                                        <tr>
                                                            <td><b><c:out value="${t.ticketCode}"/></b></td>
                                                            <td><c:out value="${t.ticketName}"/></td>
                                                            <td><c:out value="${t.eventName}"/></td>
                                                            <td>${fn:substring(es, 8, 10)}/${fn:substring(es, 5, 7)}/${fn:substring(es, 0, 4)} ${fn:substring(es, 11, 16)}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ts == 'checkedin'}"><span class="sc-badge is-ok">Đã check-in</span></c:when>
                                                                    <c:when test="${ts == 'valid'}"><span class="sc-badge is-none">Chưa check-in</span></c:when>
                                                                    <c:when test="${ts == 'cancelled'}"><span class="sc-badge is-cancelled">Đã hủy</span></c:when>
                                                                    <c:otherwise><span class="sc-badge is-none"><c:out value="${t.status}"/></span></c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <button type="button" class="sc-btn" data-bs-toggle="modal" data-bs-target="#ticketModal"
                                                                        data-code="<c:out value='${t.ticketCode}'/>"
                                                                        data-type="<c:out value='${t.ticketName}'/>"
                                                                        data-seat="<c:out value='${t.seatLabel}'/>"
                                                                        data-order="<c:out value='${t.orderCode}'/>"
                                                                        data-event="<c:out value='${t.eventName}'/>"
                                                                        data-status="<c:out value='${statusText}'/>"
                                                                        data-checkin="<c:if test='${not empty ci}'>${fn:substring(ci, 11, 16)} - ${fn:substring(ci, 8, 10)}/${fn:substring(ci, 5, 7)}/${fn:substring(ci, 0, 4)}</c:if>">Xem</button>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <%-- Lịch sử check-in (từ Tickets.check_in_time) --%>
                            <div class="sc-panel">
                                <h3 class="sc-title">Lịch sử check-in</h3>
                                <c:choose>
                                    <c:when test="${empty history}">
                                        <div class="sc-empty"><span class="material-symbols-outlined">history</span>Chưa có lượt check-in nào.</div>
                                    </c:when>
                                    <c:otherwise>
                                        <ul class="sc-timeline">
                                            <c:forEach var="h" items="${history}">
                                                <c:set var="hc" value="${h.checkInTime}"/>
                                                <li class="sc-tl-item">
                                                    <span class="sc-tl-dot"><span class="material-symbols-outlined">check</span></span>
                                                    <div class="sc-tl-body">
                                                        <div>
                                                            <b><c:out value="${h.eventName}"/></b>
                                                            <small><span class="material-symbols-outlined" style="font-size:14px;vertical-align:-2px">location_on</span> <c:out value="${h.venueName}"/>
                                                                · <c:out value="${h.ticketCode}"/> (<c:out value="${h.ticketName}"/>)</small>
                                                        </div>
                                                        <div class="sc-tl-time">
                                                            ${fn:substring(hc, 8, 10)}/${fn:substring(hc, 5, 7)}/${fn:substring(hc, 0, 4)} ${fn:substring(hc, 11, 16)}
                                                            <span class="ok">Check-in thành công</span>
                                                        </div>
                                                    </div>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>

                <%-- ===================== Phải: sự kiện + thao tác nhanh ===================== --%>
                <aside class="sc-side">
                    <c:if test="${not empty selectedEvent}">
                        <c:set var="st" value="${selectedEvent.startTime}"/>
                        <c:set var="en" value="${selectedEvent.endTime}"/>
                        <div class="sc-panel">
                            <h3 class="sc-title">Thông tin sự kiện</h3>
                            <div class="sc-event-img">
                                <c:choose>
                                    <c:when test="${not empty selectedEvent.eventImage}">
                                        <img alt="" src="${ctx}/<c:out value='${selectedEvent.eventImage}'/>">
                                    </c:when>
                                    <c:otherwise><span class="material-symbols-outlined" style="font-size:44px">image</span></c:otherwise>
                                </c:choose>
                                <span class="sc-badge"><c:out value="${selectedEvent.categoryName}"/></span>
                            </div>
                            <h4 class="sc-event-name"><c:out value="${selectedEvent.eventName}"/></h4>
                            <span class="sc-line"><span class="material-symbols-outlined">schedule</span>${fn:substring(st, 11, 16)} - ${fn:substring(en, 11, 16)} (${fn:substring(st, 8, 10)}/${fn:substring(st, 5, 7)}/${fn:substring(st, 0, 4)})</span>
                            <span class="sc-line"><span class="material-symbols-outlined">location_on</span><c:out value="${selectedEvent.venueName}"/></span>
                            <div class="mt-3">
                                <c:choose>
                                    <c:when test="${selectedEvent.timeStatus == 'UPCOMING'}"><span class="sc-badge is-soon">Sắp diễn ra</span></c:when>
                                    <c:when test="${selectedEvent.timeStatus == 'ONGOING'}"><span class="sc-badge is-live">Đang diễn ra</span></c:when>
                                    <c:when test="${selectedEvent.timeStatus == 'CANCELLED'}"><span class="sc-badge is-cancelled">Đã hủy</span></c:when>
                                    <c:otherwise><span class="sc-badge is-ended">Đã kết thúc</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>

                    <div class="sc-panel">
                        <h3 class="sc-title">Thao tác nhanh</h3>

                        <c:choose>
                            <c:when test="${not empty qrUrl}"><a class="sc-action" href="${qrUrl}"><span class="material-symbols-outlined">qr_code_scanner</span>Quét mã QR<span class="material-symbols-outlined go">chevron_right</span></a></c:when>
                            <c:otherwise><span class="sc-action is-disabled" aria-disabled="true"><span class="material-symbols-outlined">qr_code_scanner</span>Quét mã QR<small>Sắp ra mắt</small></span></c:otherwise>
                        </c:choose>
                        <c:choose>
                            <c:when test="${not empty verifyUrl}"><a class="sc-action" href="${verifyUrl}"><span class="material-symbols-outlined">fact_check</span>Kiểm tra mã vé<span class="material-symbols-outlined go">chevron_right</span></a></c:when>
                            <c:otherwise><span class="sc-action is-disabled" aria-disabled="true"><span class="material-symbols-outlined">fact_check</span>Kiểm tra mã vé<small>Sắp ra mắt</small></span></c:otherwise>
                        </c:choose>
                        <c:choose>
                            <c:when test="${not empty seatUrl}"><a class="sc-action" href="${seatUrl}"><span class="material-symbols-outlined">event_seat</span>Xem sơ đồ chỗ ngồi<span class="material-symbols-outlined go">chevron_right</span></a></c:when>
                            <c:otherwise><span class="sc-action is-disabled" aria-disabled="true"><span class="material-symbols-outlined">event_seat</span>Xem sơ đồ chỗ ngồi<small>Sắp ra mắt</small></span></c:otherwise>
                        </c:choose>
                        <c:choose>
                            <c:when test="${not empty selectedEvent}">
                                <a class="sc-action" href="${ctx}/staff/event-detail?eventId=${selectedEvent.eventId}"><span class="material-symbols-outlined">event_note</span>Chi tiết sự kiện<span class="material-symbols-outlined go">chevron_right</span></a>
                            </c:when>
                            <c:otherwise>
                                <a class="sc-action" href="${ctx}/staff"><span class="material-symbols-outlined">calendar_month</span>Sự kiện được phân công<span class="material-symbols-outlined go">chevron_right</span></a>
                            </c:otherwise>
                        </c:choose>

                        <div class="sc-warning">
                            <span class="material-symbols-outlined">info</span>
                            <div><b>Lưu ý</b>Chỉ xem được thông tin khách hàng của các sự kiện được phân công cho bạn.</div>
                        </div>
                    </div>
                </aside>
            </div>
        </div>
    </main>

    <%-- Modal xem vé (dữ liệu điền từ nút "Xem" bằng staff-customers.js) --%>
    <div class="modal fade" id="ticketModal" tabindex="-1" aria-labelledby="ticketModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius:16px">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="ticketModalLabel">Thông tin vé</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body">
                    <div class="sc-modal-row"><span>Mã vé</span><b data-field="code"></b></div>
                    <div class="sc-modal-row"><span>Loại vé</span><b data-field="type"></b></div>
                    <div class="sc-modal-row"><span>Ghế</span><b data-field="seat"></b></div>
                    <div class="sc-modal-row"><span>Mã đơn hàng</span><b data-field="order"></b></div>
                    <div class="sc-modal-row"><span>Sự kiện</span><b data-field="event"></b></div>
                    <div class="sc-modal-row"><span>Trạng thái</span><b data-field="status"></b></div>
                    <div class="sc-modal-row"><span>Thời gian check-in</span><b data-field="checkin"></b></div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/staff/_footer.jsp"/>
    <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
    <script src="${ctx}/assets/js/event.js"></script>
    <script src="${ctx}/assets/js/staff-customers.js"></script>
</body>
</html>
