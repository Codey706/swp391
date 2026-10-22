<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Trạng thái chỗ ngồi - Light Ticket</title>
        <jsp:include page="/WEB-INF/views/staff/_head.jsp"/>
        <link rel="stylesheet" href="${ctx}/assets/css/staff-seats.css">
    </head>
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/staff/_header.jsp">
            <jsp:param name="active" value="seats"/>
            <jsp:param name="current" value="Seat Status"/>
        </jsp:include>

        <main class="org-main">
            <div class="ss-page">
                <div class="ss-head">
                    <h1>Trạng thái chỗ ngồi</h1>
                    <p>Xem sơ đồ chỗ ngồi và trạng thái vé của sự kiện được phân công diễn ra trong ngày hôm nay.</p>
                </div>

                <div class="ss-notice" role="note">
                    <span class="material-symbols-outlined">info</span>
                    <span>Bạn chỉ có thể xem sự kiện được phân công diễn ra trong ngày hôm nay. Không có quyền chỉnh sửa sơ đồ chỗ ngồi.</span>
                </div>

                <c:choose>
                    <c:when test="${not empty loadError}">
                        <div class="ss-panel ss-empty" role="alert">
                            <span class="material-symbols-outlined">error</span>
                            <p><c:out value="${loadError}"/></p>
                        </div>
                    </c:when>

                    <c:when test="${empty events}">
                        <div class="ss-panel ss-empty">
                            <span class="material-symbols-outlined">event_busy</span>
                            <p>Hiện chưa có sự kiện được phân công đang diễn ra trong hôm nay.</p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <%-- ===== Thông tin sự kiện ===== --%>
                        <section class="ss-panel ss-event">
                            <c:choose>
                                <c:when test="${not empty event.eventImage}">
                                    <img class="ss-thumb" alt="" src="${ctx}/<c:out value='${event.eventImage}'/>">
                                </c:when>
                                <c:otherwise>
                                    <span class="ss-thumb ss-thumb-empty"><span class="material-symbols-outlined">image</span></span>
                                </c:otherwise>
                            </c:choose>

                            <div class="ss-event-main">
                                <div class="ss-title-row">
                                    <h2><c:out value="${event.eventName}"/></h2>
                                    <span class="ss-badge is-live">Đang diễn ra</span>
                                </div>
                                <div class="ss-meta"><span class="material-symbols-outlined">category</span><span><c:out value="${event.categoryName}"/></span></div>
                                <c:if test="${not empty timeText}">
                                    <div class="ss-meta"><span class="material-symbols-outlined">schedule</span><span><c:out value="${timeText}"/></span></div>
                                </c:if>
                                <div class="ss-meta"><span class="material-symbols-outlined">location_on</span>
                                    <span><c:out value="${event.venueName}"/><c:if test="${not empty event.venueAddress}"> - <c:out value="${event.venueAddress}"/></c:if></span></div>
                                </div>

                                <div class="ss-event-side">
                                    <h3>Thông tin phân công</h3>
                                <c:if test="${not empty assignedText}">
                                    <div class="ss-meta"><span class="material-symbols-outlined">assignment_ind</span><span>Được phân công ngày <c:out value="${assignedText}"/></span></div>
                                </c:if>
                                <c:if test="${fn:length(events) > 1}">
                                    <form method="get" action="${ctx}/staff/seats" id="ssEventForm" class="ss-switch">
                                        <label for="ssEventSelect">Sự kiện đang xem</label>
                                        <select id="ssEventSelect" name="eventId">
                                            <c:forEach var="e" items="${events}">
                                                <option value="${e.eventId}" ${e.eventId == event.eventId ? 'selected' : ''}><c:out value="${e.eventName}"/></option>
                                            </c:forEach>
                                        </select>
                                        <noscript><button type="submit" class="ss-btn">Xem</button></noscript>
                                    </form>
                                </c:if>
                            </div>
                        </section>

                        <div class="ss-grid">
                            <%-- ===== Cột chính: tab + sơ đồ / khu đứng ===== --%>
                            <section class="ss-panel ss-main">
                                <div class="ss-tabs" role="tablist" aria-label="Chế độ xem">
                                    <button type="button" class="ss-tab ${hasSeated || !hasStanding ? 'is-active' : ''}" role="tab"
                                            id="ssTabSeated" data-target="ssPaneSeated" aria-selected="${hasSeated || !hasStanding}">Khu vực ghế ngồi</button>
                                    <button type="button" class="ss-tab ${!hasSeated && hasStanding ? 'is-active' : ''}" role="tab"
                                            id="ssTabStanding" data-target="ssPaneStanding" aria-selected="${!hasSeated && hasStanding}">Khu vực đứng</button>
                                </div>

                                <%-- Khu ghế ngồi --%>
                                <div class="ss-pane" id="ssPaneSeated" role="tabpanel" aria-labelledby="ssTabSeated" ${hasSeated || !hasStanding ? '' : 'hidden'}>
                                    <c:choose>
                                        <c:when test="${noLayout}">
                                            <div class="ss-empty"><span class="material-symbols-outlined">grid_off</span><p>Sự kiện này chưa có sơ đồ chỗ ngồi.</p></div>
                                        </c:when>
                                        <c:when test="${!hasSeated}">
                                            <div class="ss-empty"><span class="material-symbols-outlined">event_seat</span><p>Sự kiện này không có khu vực ghế ngồi.</p></div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="ss-toolbar">
                                                <ul class="ss-legend" aria-label="Chú thích">
                                                    <li><i class="st-0"></i>Còn trống</li>
                                                    <li><i class="st-3"></i>Đã sử dụng</li>
                                                    <li><i class="st-2"></i>Đã đặt</li>
                                                    <li><i class="st-1"></i>Đang giữ chỗ</li>
                                                    <li><i class="st-4"></i>Không khả dụng</li>
                                                    <li><i class="st-vip"></i>Ghế VIP</li>
                                                </ul>
                                                <div class="ss-zoom" aria-label="Thu phóng sơ đồ">
                                                    <button type="button" class="ss-icon-btn" id="ssZoomIn" title="Phóng to" aria-label="Phóng to"><span class="material-symbols-outlined">add</span></button>
                                                    <button type="button" class="ss-icon-btn" id="ssZoomOut" title="Thu nhỏ" aria-label="Thu nhỏ"><span class="material-symbols-outlined">remove</span></button>
                                                    <button type="button" class="ss-icon-btn" id="ssZoomReset" title="Vừa khung" aria-label="Vừa khung"><span class="material-symbols-outlined">center_focus_strong</span></button>
                                                </div>
                                            </div>
                                            <div class="ss-canvas" id="ssCanvas">
                                                <svg id="ssSvg" role="img" aria-label="Sơ đồ chỗ ngồi, chỉ xem"></svg>
                                            </div>
                                            <c:if test="${unassignedSeats > 0 || unmappedSeats > 0}">
                                                <p class="ss-hint">
                                                    <span class="material-symbols-outlined">info</span>
                                                    <span><c:if test="${unassignedSeats > 0}"><fmt:formatNumber value="${unassignedSeats}" pattern="#,##0"/> ghế chưa gắn khu vực nên không hiển thị trên sơ đồ. </c:if>
                                                        <c:if test="${unmappedSeats > 0}"><fmt:formatNumber value="${unmappedSeats}" pattern="#,##0"/> ghế có nhãn hàng/số ghế không khớp lưới của khu nên không vẽ được (vẫn được tính trong thống kê).</c:if></span>
                                                    </p>
                                            </c:if>
                                            <script type="application/json" id="ssData">${mapJson}</script>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <%-- Khu đứng --%>
                                <div class="ss-pane" id="ssPaneStanding" role="tabpanel" aria-labelledby="ssTabStanding" ${hasSeated || !hasStanding ? 'hidden' : ''}>
                                    <c:choose>
                                        <c:when test="${noLayout}">
                                            <div class="ss-empty"><span class="material-symbols-outlined">grid_off</span><p>Sự kiện này chưa có khu vực nào được thiết lập.</p></div>
                                        </c:when>
                                        <c:when test="${!hasStanding}">
                                            <div class="ss-empty"><span class="material-symbols-outlined">groups</span><p>Sự kiện này không có khu vực đứng.</p></div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="ss-standing-grid">
                                                <c:forEach var="z" items="${standingZones}">
                                                    <article class="ss-zone-card">
                                                        <header>
                                                            <h3><c:out value="${z.zoneName}"/></h3>
                                                            <c:choose>
                                                                <c:when test="${z.statusKey == 'OPEN'}"><span class="ss-badge is-open">Còn chỗ</span></c:when>
                                                                <c:when test="${z.statusKey == 'NEAR_FULL'}"><span class="ss-badge is-near">Gần đầy</span></c:when>
                                                                <c:when test="${z.statusKey == 'FULL'}"><span class="ss-badge is-full">Đã đầy</span></c:when>
                                                                <c:when test="${z.statusKey == 'NO_CAPACITY'}"><span class="ss-badge is-muted">Chưa có sức chứa</span></c:when>
                                                                <c:otherwise><span class="ss-badge is-muted">Chưa xác định</span></c:otherwise>
                                                            </c:choose>
                                                        </header>
                                                        <dl class="ss-stats">
                                                            <div><dt>Sức chứa</dt><dd><fmt:formatNumber value="${z.capacity}" pattern="#,##0"/></dd></div>
                                                            <div><dt>Vé đã bán</dt><dd><c:choose><c:when test="${z.ticketsSold != null}"><fmt:formatNumber value="${z.ticketsSold}" pattern="#,##0"/></c:when><c:otherwise>—</c:otherwise></c:choose></dd></div>
                                                            <div><dt>Đã vào (check-in)</dt><dd><c:choose><c:when test="${z.ticketsCheckedIn != null}"><fmt:formatNumber value="${z.ticketsCheckedIn}" pattern="#,##0"/></c:when><c:otherwise>—</c:otherwise></c:choose></dd></div>
                                                            <div><dt>Còn lại</dt><dd class="is-strong"><c:choose><c:when test="${z.remaining != null}"><fmt:formatNumber value="${z.remaining}" pattern="#,##0"/></c:when><c:otherwise>—</c:otherwise></c:choose></dd></div>
                                                                </dl>
                                                        <c:if test="${z.ticketsCheckedIn != null && z.capacity > 0}">
                                                            <div class="ss-bar" title="${z.standingPercent}% sức chứa đã vào"><span class="${z.statusKey == 'FULL' ? 'is-full' : (z.statusKey == 'NEAR_FULL' ? 'is-near' : '')}" style="width:${z.standingPercent}%"></span></div>
                                                            </c:if>
                                                    </article>
                                                </c:forEach>
                                            </div>
                                            <c:if test="${standingUnknown}">
                                                <p class="ss-hint"><span class="material-symbols-outlined">info</span>
                                                    <span>Một số khu đứng dùng chung hạng vé với khu khác (hoặc chưa gắn hạng vé) nên không tách được số vé và số người đã vào riêng từng khu.</span></p>
                                                </c:if>
                                            <p class="ss-hint"><span class="material-symbols-outlined">info</span>
                                                <span>Khu đứng chỉ hiển thị số lượng, không có sơ đồ chỗ ngồi riêng lẻ.</span></p>
                                            </c:otherwise>
                                        </c:choose>
                                </div>
                            </section>

                            <%-- ===== Cột phải: thông tin khu vực ===== --%>
                            <aside class="ss-side">
                                <section class="ss-panel ss-card">
                                    <h3>Thông tin khu vực</h3>
                                    <c:choose>
                                        <c:when test="${hasSeated}">
                                            <div class="ss-table-wrap">
                                                <table class="ss-table">
                                                    <thead><tr><th>Khu vực</th><th class="n">Tổng ghế</th><th class="n">Đã đặt</th><th class="n">Còn trống</th></tr></thead>
                                                    <tbody>
                                                        <c:forEach var="z" items="${seatedZones}">
                                                            <tr>
                                                                <td><c:out value="${z.zoneName}"/></td>
                                                                <td class="n"><fmt:formatNumber value="${z.totalSeats}" pattern="#,##0"/></td>
                                                                <td class="n"><fmt:formatNumber value="${z.soldSeats}" pattern="#,##0"/><c:if test="${z.heldSeats > 0}"><small class="ss-sub">+<fmt:formatNumber value="${z.heldSeats}" pattern="#,##0"/> giữ</small></c:if></td>
                                                                <td class="n"><fmt:formatNumber value="${z.availableSeats}" pattern="#,##0"/></td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                    <tfoot>
                                                        <tr>
                                                            <th>Tổng cộng</th>
                                                            <th class="n"><fmt:formatNumber value="${seatedTotal}" pattern="#,##0"/></th>
                                                            <th class="n"><fmt:formatNumber value="${seatedSold}" pattern="#,##0"/><c:if test="${seatedHeld > 0}"><small class="ss-sub">+<fmt:formatNumber value="${seatedHeld}" pattern="#,##0"/> giữ</small></c:if></th>
                                                            <th class="n"><fmt:formatNumber value="${seatedAvailable}" pattern="#,##0"/></th>
                                                        </tr>
                                                    </tfoot>
                                                </table>
                                            </div>
                                            <p class="ss-note">Đã đặt gồm cả ghế đã sử dụng (đã check-in).</p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="ss-note">Chưa có dữ liệu khu vực ghế ngồi.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </section>

                                <section class="ss-panel ss-card">
                                    <h3><span class="material-symbols-outlined">groups</span> Khu vực đứng</h3>
                                    <c:choose>
                                        <c:when test="${hasStanding}">
                                            <div class="ss-table-wrap">
                                                <table class="ss-table">
                                                    <thead><tr><th>Khu vực</th><th class="n">Sức chứa</th><th class="n">Đã vào</th><th class="n">Còn trống</th><th></th></tr></thead>
                                                    <tbody>
                                                        <c:forEach var="z" items="${standingZones}">
                                                            <tr>
                                                                <td><c:out value="${z.zoneName}"/></td>
                                                                <td class="n"><fmt:formatNumber value="${z.capacity}" pattern="#,##0"/></td>
                                                                <td class="n"><c:choose><c:when test="${z.ticketsCheckedIn != null}"><fmt:formatNumber value="${z.ticketsCheckedIn}" pattern="#,##0"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                                                <td class="n"><c:choose><c:when test="${z.remaining != null}"><fmt:formatNumber value="${z.remaining}" pattern="#,##0"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                                                        <td>
                                                                    <c:choose>
                                                                        <c:when test="${z.statusKey == 'OPEN'}"><span class="ss-badge is-open">Còn chỗ</span></c:when>
                                                                        <c:when test="${z.statusKey == 'NEAR_FULL'}"><span class="ss-badge is-near">Gần đầy</span></c:when>
                                                                        <c:when test="${z.statusKey == 'FULL'}"><span class="ss-badge is-full">Đã đầy</span></c:when>
                                                                        <c:otherwise><span class="ss-badge is-muted">—</span></c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                            <p class="ss-note"><span class="material-symbols-outlined">info</span> Khu đứng chỉ hiển thị số lượng, không có sơ đồ chỗ ngồi riêng lẻ.</p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="ss-note">Sự kiện này không có khu vực đứng.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </section>

                                <section class="ss-panel ss-card ss-info">
                                    <span class="material-symbols-outlined">lock</span>
                                    <p>Chỉ xem được thông tin chỗ ngồi của các sự kiện được phân công cho bạn đang diễn ra trong hôm nay.</p>
                                </section>
                            </aside>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>

        <jsp:include page="/WEB-INF/views/staff/_footer.jsp"/>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
        <script src="${ctx}/assets/js/staff-seats.js"></script>
    </body>
</html>
