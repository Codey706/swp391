<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- Nếu server không có sẵn JSTL (Tomcat), thêm dependency jakarta.servlet.jsp.jstl --%>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<c:set var="createdStr" value="${event.createdAt}"/>
<c:set var="updatedStr" value="${event.updatedAt}"/>
<c:set var="startStr" value="${event.startTime}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Cập nhật sự kiện - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
    </head>
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/organizer/_header.jsp">
            <jsp:param name="active" value="events"/>
            <jsp:param name="crumb2" value="Quản lý sự kiện"/>
            <jsp:param name="current" value="Chỉnh sửa nội dung"/>
        </jsp:include>

        <main class="org-container org-main">

            <section class="org-page-head" style="padding:0 0 1.25rem;margin:0;">
                <div>
                    <h1 class="org-title" style="max-width:640px;"><c:out value="${event.eventName}"/></h1>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <c:choose>
                            <c:when test="${event.status == 'REJECTED'}"><span class="st-pill st-danger">Bị từ chối</span></c:when>
                            <c:otherwise><span class="st-pill st-draft">Bản nháp (Draft)</span></c:otherwise>
                        </c:choose>
                        <span class="ev-code mt-0">Mã: <b>#EV-${fn:substring(startStr, 0, 4)}-<fmt:formatNumber value="${event.eventId}" pattern="000"/></b></span>
                    </div>
                </div>
                <div class="org-head-actions">
                    <a class="btn-soft" href="${ctx}/organizer/event/list">
                        <span class="material-symbols-outlined">undo</span> Hủy thay đổi
                    </a>
                    <button type="submit" form="edit-event-form" class="btn-cta">
                        <span class="material-symbols-outlined">save</span> Lưu cập nhật
                    </button>
                </div>
            </section>

            <c:if test="${not empty errors.general}">
                <div class="lt-alert error"><span class="material-symbols-outlined">error</span><span><c:out value="${errors.general}"/></span></div>
            </c:if>

            <%-- Banner lưu ý --%>
            <c:choose>
                <c:when test="${event.status == 'REJECTED'}">
                    <div class="note-box danger mb-4">
                        <span class="ico"><span class="material-symbols-outlined">report</span></span>
                        <div>
                            <h3>Sự kiện đã bị từ chối</h3>
                            <p>
                                <c:choose>
                                    <c:when test="${not empty event.cancellationReason}"><c:out value="${event.cancellationReason}"/></c:when>
                                    <c:otherwise>Vui lòng rà soát lại nội dung.</c:otherwise>
                                </c:choose>
                                Sau khi lưu, sự kiện sẽ quay về trạng thái <em>Nháp</em> để bạn gửi duyệt lại.
                            </p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="note-box mb-4">
                        <span class="ico"><span class="material-symbols-outlined">edit_note</span></span>
                        <div>
                            <h3>Đang chỉnh sửa bản nháp</h3>
                            <p>Sự kiện chưa được công khai nên mọi thay đổi chỉ áp dụng nội bộ. Chỉ sự kiện <em>Nháp</em> hoặc <em>Bị từ chối</em> mới được sửa hoặc xóa.</p>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- Tabs --%>
            <div class="org-card tabs-bar" id="stepper">
                <button type="button" class="tab-item active" data-step-target="1"><span class="material-symbols-outlined">dashboard</span> 1. Thông tin sự kiện</button>
                <button type="button" class="tab-item" data-step-target="2"><span class="material-symbols-outlined">calendar_month</span> 2. Lịch trình &amp; Địa điểm</button>
                <button type="button" class="tab-item" data-step-target="3"><span class="material-symbols-outlined">confirmation_number</span> 3. Quản lý hạng vé &amp; Giá <span class="count">${event.ticketTotal > 0 ? event.ticketTotal : 0} vé</span></button>
                <button type="button" class="tab-item" data-step-target="4"><span class="material-symbols-outlined">tune</span> 4. Cài đặt bán vé &amp; Quy định</button>
            </div>

            <form id="edit-event-form" method="post" enctype="multipart/form-data" novalidate
                  action="${ctx}/organizer/event/update">
                <input type="hidden" name="eventId" value="${event.eventId}">

                <%-- ============ TAB 1 ============ --%>
                <div data-step-pane="1" class="active">
                    <div class="edit-layout">
                        <div>
                            <section class="org-card form-card">
                                <div class="form-card-head">
                                    <span class="ico"><span class="material-symbols-outlined">info</span></span>
                                    <div><h2>Thông tin định danh sự kiện</h2></div>
                                </div>

                                <div class="lt-field">
                                    <label for="eventName" class="lt-label">Tên sự kiện công khai <span class="req">*</span></label>
                                    <input type="text" id="eventName" name="eventName" maxlength="200"
                                           class="lt-input ${not empty errors.eventName ? 'is-invalid' : ''}"
                                           value="<c:out value='${event.eventName}'/>">
                                    <div class="invalid-feedback"><c:out value="${errors.eventName}"/></div>
                                    <div class="lt-help">Tên sẽ hiển thị chính thức trên trang sự kiện và trang thanh toán.</div>
                                </div>

                                <div class="lt-field">
                                    <label for="categoryId" class="lt-label">Thể loại biểu diễn <span class="req">*</span></label>
                                    <select id="categoryId" name="categoryId"
                                            class="lt-input ${not empty errors.categoryId ? 'is-invalid' : ''}">
                                        <option value="">-- Chọn thể loại --</option>
                                        <c:forEach var="category" items="${categories}">
                                            <option value="${category.key}" ${event.categoryId == category.key ? 'selected' : ''}>
                                                <c:out value="${category.value}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <div class="invalid-feedback"><c:out value="${errors.categoryId}"/></div>
                                </div>

                                <div class="lt-field mb-0">
                                    <label for="description" class="lt-label">Giới thiệu &amp; Nội dung chương trình <span class="req">*</span></label>
                                    <textarea id="description" name="description" rows="9" maxlength="5000"
                                              class="lt-input ${not empty errors.description ? 'is-invalid' : ''}"><c:out value="${event.description}"/></textarea>
                                    <div class="invalid-feedback"><c:out value="${errors.description}"/></div>
                                    <div class="char-count"><span id="descCount">0</span> / 5000 ký tự</div>
                                </div>
                            </section>
                        </div>

                        <aside>
                            <section class="org-card side-card">
                                <div class="head">
                                    <h3>Poster sân khấu chính thức</h3>
                                    <span class="ratio-chip">16:9 HD</span>
                                </div>
                                <label class="drop-zone ${not empty event.eventImage ? 'has-image' : ''}" id="dropZone" for="eventImage">
                                    <img alt="Poster sự kiện" id="posterPreview"
                                         <c:if test="${not empty event.eventImage}">src="${ctx}/<c:out value='${event.eventImage}'/>"</c:if>>
                                         <span class="dz-overlay">
                                             <span class="material-symbols-outlined">add_photo_alternate</span>
                                             <strong>Thay đổi poster</strong>
                                             <span>JPG, PNG, WEBP · tối đa 5MB</span>
                                         </span>
                                         <input type="file" id="eventImage" name="eventImage" accept=".jpg,.jpeg,.png,.webp">
                                    </label>
                                    <div class="invalid-feedback"><c:out value="${errors.eventImage}"/></div>
                                <div class="lt-help text-center mt-3">Khuyến nghị tỉ lệ 16:9. Để trống nếu muốn giữ ảnh hiện tại.</div>
                            </section>

                            <section class="org-card side-card">
                                <h3>Thông số sự kiện</h3>
                                <div class="op-row"><span>Mã sự kiện:</span><b class="orange">#EV-${fn:substring(startStr, 0, 4)}-<fmt:formatNumber value="${event.eventId}" pattern="000"/></b></div>
                                <div class="op-row"><span>Đơn vị tổ chức:</span><b><c:out value="${orgName}"/></b></div>
                                <div class="op-row"><span>Ngày tạo:</span><b>${fn:substring(createdStr, 8, 10)}/${fn:substring(createdStr, 5, 7)}/${fn:substring(createdStr, 0, 4)}</b></div>
                                <div class="op-row"><span>Cập nhật gần nhất:</span><b>${fn:substring(updatedStr, 8, 10)}/${fn:substring(updatedStr, 5, 7)}/${fn:substring(updatedStr, 0, 4)}</b></div>
                                <div class="op-row"><span>Tài khoản bảo chứng BTC:</span><b class="good">Đã xác minh KYC</b></div>
                            </section>
                        </aside>
                    </div>
                </div>

                <%-- ============ TAB 2 ============ --%>
                <div data-step-pane="2">
                    <section class="org-card form-card">
                        <div class="form-card-head">
                            <span class="ico"><span class="material-symbols-outlined">event</span></span>
                            <div><h2>Lịch trình &amp; Địa điểm</h2><p>Thời điểm diễn ra và địa điểm tổ chức</p></div>
                        </div>
                        <div class="form-grid">
                            <div class="lt-field">
                                <label for="startTime" class="lt-label">Thời gian bắt đầu <span class="req">*</span></label>
                                <input type="datetime-local" id="startTime" name="startTime"
                                       class="lt-input ${not empty errors.startTime ? 'is-invalid' : ''}"
                                       value="${fn:substring(event.startTime, 0, 16)}">
                                <div class="invalid-feedback"><c:out value="${errors.startTime}"/></div>
                            </div>
                            <div class="lt-field">
                                <label for="endTime" class="lt-label">Thời gian kết thúc <span class="req">*</span></label>
                                <input type="datetime-local" id="endTime" name="endTime"
                                       class="lt-input ${not empty errors.endTime ? 'is-invalid' : ''}"
                                       value="${fn:substring(event.endTime, 0, 16)}">
                                <div class="invalid-feedback"><c:out value="${errors.endTime}"/></div>
                            </div>
                            <div class="lt-field full mb-0">
                                <label for="venueId" class="lt-label">Địa điểm tổ chức <span class="req">*</span></label>
                                <select id="venueId" name="venueId"
                                        class="lt-input ${not empty errors.venueId ? 'is-invalid' : ''}">
                                    <option value="">-- Chọn địa điểm --</option>
                                    <c:forEach var="venue" items="${venues}">
                                        <option value="${venue.key}" ${event.venueId == venue.key ? 'selected' : ''}>
                                            <c:out value="${venue.value}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="invalid-feedback"><c:out value="${errors.venueId}"/></div>
                                <div class="lt-help">Hệ thống tự kiểm tra trùng lịch với các sự kiện khác tại cùng địa điểm.</div>
                            </div>
                        </div>
                    </section>
                </div>

                <%-- ============ TAB 3 ============ --%>
                <div data-step-pane="3">
                    <section class="org-card form-card">
                        <div class="form-card-head">
                            <span class="ico"><span class="material-symbols-outlined">confirmation_number</span></span>
                            <div><h2>Quản lý hạng vé &amp; Giá</h2><p>Tổng quan vé đã phát hành của sự kiện</p></div>
                        </div>
                        <dl class="summary-list mb-4">
                            <dt>Tổng vé phát hành</dt><dd><fmt:formatNumber value="${event.ticketTotal}" pattern="#,##0"/> vé</dd>
                            <dt>Đã bán</dt><dd><fmt:formatNumber value="${event.ticketSold}" pattern="#,##0"/> vé (${event.soldPercent}%)</dd>
                            <dt>Doanh thu tạm tính</dt><dd><fmt:formatNumber value="${event.revenue}" pattern="#,##0"/> đ</dd>
                        </dl>
                        <div class="note-box blue">
                            <span class="ico"><span class="material-symbols-outlined">lightbulb</span></span>
                            <div>
                                <h3>Cấu hình hạng vé</h3>
                                <p>Việc thêm / sửa hạng vé và giá bán được thực hiện ở mục quản lý hạng vé, không nằm trong biểu mẫu này.</p>
                            </div>
                        </div>
                    </section>
                </div>

                <%-- ============ TAB 4 ============ --%>
                <div data-step-pane="4">
                    <section class="org-card form-card">
                        <div class="form-card-head">
                            <span class="ico"><span class="material-symbols-outlined">tune</span></span>
                            <div><h2>Cài đặt bán vé &amp; Quy định</h2><p>Quy tắc áp dụng cho sự kiện này</p></div>
                        </div>
                        <div class="note-box">
                            <span class="ico"><span class="material-symbols-outlined">verified_user</span></span>
                            <div>
                                <h3>Quy định chỉnh sửa</h3>
                                <p>Sự kiện chỉ được sửa hoặc xóa khi ở trạng thái Nháp hoặc Bị từ chối. Sự kiện đã phát sinh đơn hàng, vé hoặc đánh giá sẽ không thể xóa.</p>
                            </div>
                        </div>
                    </section>
                </div>
            </form>

            <%-- ============ DANGER ZONE ============ --%>
            <section class="danger-zone">
                <h2><span class="material-symbols-outlined">warning</span> Khu vực nguy hiểm (Danger Zone)</h2>
                <p>Các hành động tại khu vực này có thể ảnh hưởng trực tiếp đến người đã mua vé hoặc xóa vĩnh viễn dữ liệu của ban tổ chức.</p>
                <div class="danger-grid">
                    <div class="danger-item">
                        <h4>Tạm dừng nhận đơn hàng mới</h4>
                        <p>Đóng trang mua vé tạm thời, các đơn đã giữ chỗ vẫn thanh toán bình thường.</p>
                        <button type="button" class="btn-block outline" disabled>Chỉ khả dụng khi sự kiện đang mở bán</button>
                    </div>
                    <div class="danger-item">
                        <h4 class="red">Hủy sự kiện (Cancel Event)</h4>
                        <p>Kích hoạt quy trình thông báo và hoàn tiền tự động đến khán giả đã mua vé.</p>
                        <button type="button" class="btn-block outline" disabled>
                            <span class="material-symbols-outlined" style="font-size:18px">event_busy</span> Chỉ khả dụng khi sự kiện đã công khai
                        </button>
                    </div>
                    <div class="danger-item">
                        <h4 class="red">Xóa sự kiện này khỏi hệ thống</h4>
                        <p>Xóa hoàn toàn sự kiện và lưu trữ hồ sơ. Không thể hoàn tác; sự kiện đã có đơn hàng/vé sẽ không xóa được.</p>
                        <form method="post" class="js-confirm-delete m-0 mt-auto" action="${ctx}/organizer/event/delete"
                              data-event-name="<c:out value='${event.eventName}'/>">
                            <input type="hidden" name="eventId" value="${event.eventId}">
                            <button type="submit" class="btn-block solid">
                                <span class="material-symbols-outlined" style="font-size:18px">delete</span> Xóa sự kiện
                            </button>
                        </form>
                    </div>
                </div>
            </section>
        </main>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
    </body>
</html>
