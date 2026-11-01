<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Nếu server không có sẵn JSTL (Tomcat), thêm dependency jakarta.servlet.jsp.jstl --%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<c:set var="orgInitial" value="${fn:toUpperCase(fn:substring(orgName, 0, 1))}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Tạo sự kiện mới - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
        <link rel="stylesheet" href="${ctx}/assets/css/seatmap.css">
        <link rel="stylesheet" href="${ctx}/assets/css/image-cropper.css">
    </head>
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/organizer/_header.jsp">
            <jsp:param name="active" value="events"/>
            <jsp:param name="crumb2" value="Quản lý sự kiện"/>
            <jsp:param name="current" value="Tạo sự kiện mới"/>
        </jsp:include>

        <main class="org-container org-main">

            <%-- Toolbar tiêu đề + nút hành động --%>
            <section class="org-card ce-toolbar">
                <div class="ce-toolbar-title">
                    <a class="ce-back" href="${ctx}/organizer/event/list" aria-label="Quay lại danh sách sự kiện">
                        <span class="material-symbols-outlined">arrow_back</span>
                    </a>
                    <h1>Tạo sự kiện mới</h1>
                    <span class="ce-pill">Lưu nháp hoặc gửi Admin duyệt ở bước cuối</span>
                </div>
                <div class="ce-toolbar-actions">
                    <button type="submit" form="create-event-form" name="submitAction" value="draft" class="btn-soft">
                        <span class="material-symbols-outlined">save</span> Lưu bản nháp
                    </button>
                    <button type="button" class="btn-soft btn-preview" id="scrollPreviewBtn">
                        <span class="material-symbols-outlined">visibility</span> Xem trước
                    </button>
                    <button type="button" class="btn-cta" data-step-nav="next-header">
                        <span class="material-symbols-outlined">rocket_launch</span> Hoàn tất &amp; tạo sự kiện
                    </button>
                </div>
            </section>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success"><span class="material-symbols-outlined">check_circle</span><span><c:out value="${successMessage}"/></span></div>
            </c:if>
            <c:if test="${not empty errors.general}">
                <div class="lt-alert error"><span class="material-symbols-outlined">error</span><span><c:out value="${errors.general}"/></span></div>
            </c:if>

            <%-- Các bước --%>
            <div class="org-card stepper" id="stepper">
                <button type="button" class="step-item active" data-step-target="1">
                    <span class="step-num">1</span>
                    <span class="step-text"><small>Bước 1</small><span>Thông tin cơ bản</span></span>
                </button>
                <button type="button" class="step-item" data-step-target="2">
                    <span class="step-num">2</span>
                    <span class="step-text"><small>Bước 2</small><span>Thời gian &amp; Địa điểm</span></span>
                </button>
                <button type="button" class="step-item" data-step-target="3">
                    <span class="step-num">3</span>
                    <span class="step-text"><small>Bước 3</small><span>Hạng vé &amp; Sơ đồ ghế</span></span>
                </button>
                <button type="button" class="step-item" data-step-target="4">
                    <span class="step-num">4</span>
                    <span class="step-text"><small>Bước 4</small><span>Xác nhận &amp; Hoàn tất</span></span>
                </button>
            </div>

            <div class="ce-layout">
                <%-- ================= CỘT TRÁI: FORM ================= --%>
                <div class="ce-main">
                    <form id="create-event-form" method="post" enctype="multipart/form-data" novalidate
                          action="${ctx}/organizer/event/create">

                        <%-- ============ BƯỚC 1 ============ --%>
                        <section class="org-card form-card active" data-step-pane="1">
                            <div class="form-card-head">
                                <span class="ico"><span class="material-symbols-outlined">info</span></span>
                                <div>
                                    <h2>1. Thông tin chung sự kiện</h2>
                                </div>
                                <span class="req-badge">Bắt buộc</span>
                            </div>

                            <div class="form-grid">
                                <div class="lt-field full">
                                    <div class="ce-label-row">
                                        <label for="eventName" class="lt-label">Tên sự kiện <span class="req">*</span></label>
                                        <span class="ce-counter" id="nameCounter"><span id="nameCount">0</span> / 200 ký tự</span>
                                    </div>
                                    <input type="text" id="eventName" name="eventName" maxlength="200"
                                           class="lt-input ${not empty errors.eventName ? 'is-invalid' : ''}"
                                           placeholder="Ví dụ: Lễ hội Âm nhạc Hoàng Hôn 2025"
                                           value="<c:out value='${event.eventName}'/>">
                                    <div class="invalid-feedback"><c:out value="${errors.eventName}"/></div>
                                    <div class="lt-help">Tên sự kiện cần rõ ràng, từ 5 đến 200 ký tự để tối ưu tìm kiếm.</div>
                                </div>

                                <div class="lt-field">
                                    <label for="categoryId" class="lt-label">Thể loại sự kiện <span class="req">*</span></label>
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

                                <div class="lt-field">
                                    <span class="lt-label">Đơn vị tổ chức đại diện</span>
                                    <div class="ce-org">
                                        <span class="l">
                                            <span class="av"><c:out value="${orgInitial}"/></span>
                                            <strong><c:out value="${orgName}"/></strong>
                                        </span>
                                        <span class="ok"><span class="material-symbols-outlined">verified</span>Đã xác minh</span>
                                    </div>
                                </div>

                                <div class="lt-field full">
                                    <div class="label-row">
                                        <label for="eventImage" class="lt-label">Ảnh poster bìa ngang (Tỷ lệ 16:9, tối ưu 1920x1080px)</label>
                                        <span class="tag opt">Bắt buộc khi gửi duyệt</span>
                                    </div>
                                    <label class="drop-zone" id="dropZone" for="eventImage">
                                        <img alt="Xem trước poster" id="posterPreview">
                                        <span class="dz-overlay">
                                            <span class="material-symbols-outlined">cloud_upload</span>
                                            <strong>Kéo thả ảnh hoặc nhấn để chọn poster bìa</strong>
                                            <span>Định dạng JPG, PNG, WEBP tối đa 5MB · chỉnh khung 16:9 sau khi chọn</span>
                                        </span>
                                        <span class="dz-meta" id="posterMeta"></span>
                                        <input type="file" id="eventImage" name="eventImage" accept=".jpg,.jpeg,.png,.webp">
                                    </label>
                                    <div class="invalid-feedback"><c:out value="${errors.eventImage}"/></div>
                                </div>

                                <div class="lt-field full mb-0">
                                    <label for="description" class="lt-label">Mô tả chi tiết nội dung sự kiện <span class="req">*</span></label>
                                    <textarea id="description" name="description" rows="7" maxlength="5000"
                                              class="lt-input ${not empty errors.description ? 'is-invalid' : ''}"
                                              placeholder="Giới thiệu chương trình, nghệ sĩ, lịch trình và các lưu ý cho khán giả (tối thiểu 20 ký tự)..."><c:out value="${event.description}"/></textarea>
                                    <div class="invalid-feedback"><c:out value="${errors.description}"/></div>
                                    <div class="char-count"><span id="descCount">0</span> / 5000 ký tự</div>
                                </div>
                            </div>
                        </section>

                        <%-- ============ BƯỚC 2 ============ --%>
                        <section class="org-card form-card" data-step-pane="2">
                            <div class="form-card-head">
                                <span class="ico"><span class="material-symbols-outlined">calendar_today</span></span>
                                <div>
                                    <h2>2. Thời gian &amp; Địa điểm tổ chức</h2>
                                </div>
                                <span class="req-badge">Bắt buộc</span>
                            </div>
                            <div class="form-grid">
                                <div class="lt-field">
                                    <label for="startTime" class="lt-label">Thời gian bắt đầu <span class="req">*</span></label>
                                    <div class="lt-icon-wrap">
                                        <span class="material-symbols-outlined">calendar_month</span>
                                        <input type="datetime-local" id="startTime" name="startTime"
                                               class="lt-input ${not empty errors.startTime ? 'is-invalid' : ''}"
                                               value="${fn:substring(event.startTime, 0, 16)}">
                                    </div>
                                    <div class="invalid-feedback"><c:out value="${errors.startTime}"/></div>
                                </div>
                                <div class="lt-field">
                                    <label for="endTime" class="lt-label">Thời gian kết thúc <span class="req">*</span></label>
                                    <div class="lt-icon-wrap">
                                        <span class="material-symbols-outlined">schedule</span>
                                        <input type="datetime-local" id="endTime" name="endTime"
                                               class="lt-input ${not empty errors.endTime ? 'is-invalid' : ''}"
                                               value="${fn:substring(event.endTime, 0, 16)}">
                                    </div>
                                    <div class="invalid-feedback"><c:out value="${errors.endTime}"/></div>
                                </div>
                                <div class="lt-field full mb-0">
                                    <label for="venueId" class="lt-label">Địa điểm tổ chức <span class="req">*</span></label>
                                    <div class="lt-icon-wrap accent">
                                        <span class="material-symbols-outlined">location_on</span>
                                        <select id="venueId" name="venueId"
                                                class="lt-input ${not empty errors.venueId ? 'is-invalid' : ''}">
                                            <option value="">-- Chọn địa điểm --</option>
                                            <c:forEach var="venue" items="${venues}">
                                                <option value="${venue.key}" ${event.venueId == venue.key ? 'selected' : ''}>
                                                    <c:out value="${venue.value}"/>
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="invalid-feedback"><c:out value="${errors.venueId}"/></div>
                                    <div class="lt-help">Hệ thống tự kiểm tra trùng lịch với các sự kiện khác tại cùng địa điểm.</div>
                                </div>
                            </div>
                        </section>

                        <%-- ============ BƯỚC 3 ============ --%>
                        <section class="org-card form-card" data-step-pane="3">
                            <div class="form-card-head">
                                <span class="ico"><span class="material-symbols-outlined">confirmation_number</span></span>
                                <div>
                                    <h2>3. Hạng vé &amp; Sơ đồ ghế</h2>
                                    <p>Chọn cách bán vé cho sự kiện, có thể bổ sung sau khi lưu nháp</p>
                                </div>
                            </div>

                            <c:if test="${not empty errors.tickets}">
                                <div class="lt-alert error"><span class="material-symbols-outlined">error</span><span><c:out value="${errors.tickets}"/></span></div>
                            </c:if>
                            <c:if test="${not empty seatErrors}">
                                <div class="lt-alert error">
                                    <span class="material-symbols-outlined">error</span>
                                    <ul class="sm-server-errors">
                                        <c:forEach var="msg" items="${seatErrors}"><li><c:out value="${msg}"/></li></c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                            <div class="lt-alert error" id="seatStepAlert" hidden>
                                <span class="material-symbols-outlined">error</span><span id="seatStepAlertText"></span>
                            </div>

                            <div class="sale-modes" role="radiogroup" aria-label="Hình thức bán vé">
                                <label class="mode-card" data-mode-card>
                                    <input type="radio" name="ticketMode" value="GENERAL" ${ticketMode != 'SEATED' ? 'checked' : ''}>
                                    <span class="material-symbols-outlined">confirmation_number</span>
                                    <span><strong>Vé theo số lượng</strong>
                                        <small>Không chọn chỗ ngồi. Khán giả mua theo hạng vé, phù hợp sự kiện đứng hoặc tự do.</small></span>
                                </label>
                                <label class="mode-card" data-mode-card>
                                    <input type="radio" name="ticketMode" value="SEATED" ${ticketMode == 'SEATED' ? 'checked' : ''}>
                                    <span class="material-symbols-outlined">event_seat</span>
                                    <span><strong>Vé theo sơ đồ ghế</strong>
                                        <small>Vẽ sơ đồ sân khấu, khu ngồi, khu đứng; mỗi khu một hạng vé và giá, giống Ticketbox.</small></span>
                                </label>
                            </div>

                            <%-- ---- Cách 1: hạng vé theo số lượng (module ltTickets trong event.js) ---- --%>
                            <div id="modeGeneral">
                                <div class="tk-block" id="ticketBlock" data-max-types="10">
                                    <div class="tk-head">
                                        <h3><span class="material-symbols-outlined">confirmation_number</span> Thiết lập các hạng vé (Ticket Classes)</h3>
                                    </div>
                                    <p class="tk-note">Không bắt buộc khi lưu nháp. Cần ít nhất một hạng vé khi gửi Admin duyệt. Tổng số vé không vượt quá sức chứa của địa điểm.</p>
                                    <div class="lt-alert error" id="ticketAlert" style="display:none">
                                        <span class="material-symbols-outlined">error</span><span id="ticketAlertText"></span>
                                    </div>
                                    <div class="tk-list" id="ticketList">
                                        <c:forEach var="t" items="${tickets}">
                                            <c:set var="row" value="${t}" scope="request"/>
                                            <jsp:include page="/WEB-INF/views/organizer/_ticket-row.jsp"/>
                                        </c:forEach>
                                    </div>
                                    <div class="tk-empty" id="ticketEmpty">Chưa có hạng vé nào. Nhấn “Thêm hạng vé mới” để bắt đầu.</div>
                                    <div class="tk-actions">
                                        <button type="button" class="btn-soft" id="addTicketBtn">
                                            <span class="material-symbols-outlined" style="font-size:18px">add_circle</span> Thêm hạng vé mới
                                        </button>
                                        <span class="tk-summary">Tổng số vé: <b id="tkTotalQty">0</b> &nbsp;·&nbsp; Doanh thu kỳ vọng: <b id="tkTotalRevenue">0 đ</b></span>
                                    </div>
                                    <span id="ticketSummary" hidden></span>
                                    <template id="ticketRowTemplate">
                                        <c:remove var="row" scope="request"/>
                                        <jsp:include page="/WEB-INF/views/organizer/_ticket-row.jsp"/>
                                    </template>
                                </div>
                            </div>

                            <%-- ---- Cách 2: sơ đồ ghế (seatmap.js) ---- --%>
                            <div id="modeSeated" hidden>
                                <c:set var="embedded" value="true" scope="request"/>
                                <jsp:include page="/WEB-INF/views/organizer/_seatmap-designer.jsp"/>
                            </div>
                            <input type="hidden" name="layoutJson" id="layoutJson" value="">
                        </section>

                        <%-- ============ BƯỚC 4 ============ --%>
                        <section class="org-card form-card" data-step-pane="4">
                            <div class="form-card-head">
                                <span class="ico"><span class="material-symbols-outlined">rocket_launch</span></span>
                                <div>
                                    <h2>4. Xác nhận &amp; Hoàn tất</h2>
                                    <p>Kiểm tra lại thông tin rồi chọn lưu nháp hoặc gửi Admin duyệt</p>
                                </div>
                            </div>
                            <dl class="summary-list mb-4">
                                <dt>Tên sự kiện</dt><dd data-summary="eventName">—</dd>
                                <dt>Thể loại</dt><dd data-summary="categoryId">—</dd>
                                <dt>Địa điểm</dt><dd data-summary="venueId">—</dd>
                                <dt>Bắt đầu</dt><dd data-summary="startTime">—</dd>
                                <dt>Kết thúc</dt><dd data-summary="endTime">—</dd>
                                <dt>Poster</dt><dd data-summary="eventImage">Chưa chọn ảnh</dd>
                                <dt>Hạng vé</dt><dd id="sumTickets">—</dd>
                            </dl>
                            <div class="publish-choice" role="radiogroup" aria-label="Cách hoàn tất">
                                <label class="mode-card">
                                    <input type="radio" name="publishChoice" value="draft" ${publishChoice != 'submit' ? 'checked' : ''}>
                                    <span class="material-symbols-outlined">draft</span>
                                    <span><strong>Lưu bản nháp</strong>
                                        <small>Chưa hiển thị với khán giả và chưa gửi Admin. Bạn có thể chỉnh sửa rồi gửi duyệt sau.</small></span>
                                </label>
                                <label class="mode-card">
                                    <input type="radio" name="publishChoice" value="submit" ${publishChoice == 'submit' ? 'checked' : ''}>
                                    <span class="material-symbols-outlined">send</span>
                                    <span><strong>Gửi Admin duyệt</strong>
                                        <small>Sự kiện chuyển sang “Chờ duyệt”; trong lúc chờ bạn không sửa hoặc xóa được. Cần có ảnh poster và ít nhất một hạng vé.</small></span>
                                </label>
                            </div>
                            <div class="note-box">
                                <span class="ico"><span class="material-symbols-outlined">verified_user</span></span>
                                <div>
                                    <h3>Sự kiện chỉ được công khai sau khi Admin duyệt</h3>
                                    <p>Dù chọn cách nào, sự kiện mới chưa bán vé ngay. Sau khi được duyệt, sự kiện sẽ chuyển sang “Đang mở bán”.</p>
                                </div>
                            </div>
                        </section>

                        <%-- Thanh điều hướng --%>
                        <div class="org-card action-bar">
                            <div class="group">
                                <a class="btn-ghost" href="${ctx}/organizer/event/list">Hủy bỏ &amp; Thoát</a>
                                <button type="button" class="btn-soft" data-step-nav="prev">
                                    <span class="material-symbols-outlined">arrow_back</span> Bước trước
                                </button>
                            </div>
                            <div class="group">
                                <button type="submit" name="submitAction" value="draft" class="btn-soft">Lưu tạm bản thảo</button>
                                <button type="button" class="btn-cta" data-step-nav="next" id="nextBtn">
                                    <span id="nextLabel">Tiếp tục sang bước tiếp theo</span>
                                    <span class="material-symbols-outlined">arrow_forward</span>
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <%-- ================= CỘT PHẢI: LIVE PREVIEW (sticky) ================= --%>
                <aside class="ce-aside" id="livePreview" aria-label="Xem trước hiển thị trực tiếp">
                    <section class="org-card pv-card">
                        <div class="pv-head">
                            <h3><span class="material-symbols-outlined">preview</span> Xem trước hiển thị trực tiếp</h3>
                        </div>

                        <div class="pv-event">
                            <div class="pv-media" id="pvMedia">
                                <span class="material-symbols-outlined ph">image</span>
                                <img alt="" id="pvImg">
                                <div class="pv-chips"><span class="pv-chip is-empty" id="pvCategory"></span></div>
                            </div>
                            <div class="pv-body">
                                <h4 class="pv-title is-empty" id="pvTitle">Tên sự kiện của bạn sẽ hiển thị tại đây</h4>
                                <div class="pv-by">
                                    <span>Bởi:</span><b><c:out value="${orgName}"/></b>
                                    <span class="material-symbols-outlined">verified</span>
                                </div>
                                <div class="pv-meta">
                                    <div class="d">
                                        <span class="material-symbols-outlined">calendar_month</span>
                                        <span class="is-empty" id="pvDate">Chưa chọn thời gian</span>
                                    </div>
                                    <div class="v">
                                        <span class="material-symbols-outlined">stadium</span>
                                        <span id="pvVenue">Chưa chọn địa điểm</span>
                                    </div>
                                </div>
                                <div class="pv-price">
                                    <div class="p"><small id="pvPriceLabel">Giá vé</small><strong id="pvPrice">Chưa cấu hình</strong></div>
                                    <span class="pv-buy" aria-hidden="true">Mua vé <span class="material-symbols-outlined">arrow_forward</span></span>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="org-card ck-card">
                        <div class="ck-head">
                            <h3><span class="material-symbols-outlined">checklist</span> Độ sẵn sàng xuất bản</h3>
                            <span class="ck-pct" id="ckPct">0%</span>
                        </div>
                        <div class="ck-bar"><span id="ckBar"></span></div>
                        <div class="ck-list">
                            <div class="ck-item" data-ck="name">
                                <span class="l"><span class="material-symbols-outlined ck-ico">radio_button_unchecked</span><span>Tên sự kiện</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="category">
                                <span class="l"><span class="material-symbols-outlined ck-ico">radio_button_unchecked</span><span>Thể loại</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="description">
                                <span class="l"><span class="material-symbols-outlined ck-ico">radio_button_unchecked</span><span>Mô tả chi tiết</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="time">
                                <span class="l"><span class="material-symbols-outlined ck-ico">radio_button_unchecked</span><span>Thời gian tổ chức</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="venue">
                                <span class="l"><span class="material-symbols-outlined ck-ico">radio_button_unchecked</span><span>Địa điểm</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="image">
                                <span class="l"><span class="material-symbols-outlined ck-ico">image</span><span>Ảnh poster</span></span>
                                <span class="ck-status">Cần khi gửi duyệt</span>
                            </div>
                            <div class="ck-item is-info" data-ck="tickets">
                                <span class="l"><span class="material-symbols-outlined ck-ico">pending</span><span>Hạng vé &amp; giá</span></span>
                                <span class="ck-status">Không bắt buộc</span>
                            </div>
                        </div>
                        <div class="ck-help">
                            <span class="material-symbols-outlined">help</span>
                            <span>Cần hỗ trợ? Hotline BTC: 1900 xxxx</span>
                        </div>
                    </section>
                </aside>
            </div>
        </main>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script type="application/json" id="smData"><c:out value="${seatMapJson}" escapeXml="false"/></script>
        <script src="${ctx}/assets/js/image-cropper.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
        <script src="${ctx}/assets/js/seatmap.js"></script>
    </body>
</html>
