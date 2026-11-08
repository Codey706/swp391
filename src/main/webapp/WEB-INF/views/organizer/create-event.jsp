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
                        <i class="ph ph-arrow-left" aria-hidden="true"></i>
                    </a>
                    <h1>Tạo sự kiện mới</h1>
                    <span class="ce-pill">Lưu nháp hoặc gửi Admin duyệt ở bước cuối</span>
                </div>
                <div class="ce-toolbar-actions">
                    <button type="submit" form="create-event-form" name="submitAction" value="draft" class="btn-soft">
                        <i class="ph ph-floppy-disk" aria-hidden="true"></i> Lưu bản nháp
                    </button>
                    <button type="button" class="btn-soft btn-preview" id="scrollPreviewBtn">
                        <i class="ph ph-eye" aria-hidden="true"></i> Xem trước
                    </button>
                    <button type="button" class="btn-cta" data-step-nav="next-header">
                        <i class="ph ph-rocket-launch" aria-hidden="true"></i> Hoàn tất &amp; tạo sự kiện
                    </button>
                </div>
            </section>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success"><i class="ph ph-check-circle" aria-hidden="true"></i><span><c:out value="${successMessage}"/></span></div>
            </c:if>
            <c:if test="${not empty errors.general}">
                <div class="lt-alert error"><i class="ph ph-warning-circle" aria-hidden="true"></i><span><c:out value="${errors.general}"/></span></div>
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
                                <span class="ico"><i class="ph ph-info" aria-hidden="true"></i></span>
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
                                        <span class="ok"><i class="ph ph-seal-check" aria-hidden="true"></i>Đã xác minh</span>
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
                                            <i class="ph ph-cloud-arrow-up" aria-hidden="true"></i>
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
                                <span class="ico"><i class="ph ph-calendar-blank" aria-hidden="true"></i></span>
                                <div>
                                    <h2>2. Thời gian &amp; Địa điểm tổ chức</h2>
                                </div>
                                <span class="req-badge">Bắt buộc</span>
                            </div>
                            <div class="form-grid">
                                <div class="lt-field">
                                    <label for="startTime" class="lt-label">Thời gian bắt đầu <span class="req">*</span></label>
                                    <div class="lt-icon-wrap">
                                        <i class="ph ph-calendar" aria-hidden="true"></i>
                                        <input type="datetime-local" id="startTime" name="startTime"
                                               class="lt-input ${not empty errors.startTime ? 'is-invalid' : ''}"
                                               value="${fn:substring(event.startTime, 0, 16)}">
                                    </div>
                                    <div class="invalid-feedback"><c:out value="${errors.startTime}"/></div>
                                </div>
                                <div class="lt-field">
                                    <label for="endTime" class="lt-label">Thời gian kết thúc <span class="req">*</span></label>
                                    <div class="lt-icon-wrap">
                                        <i class="ph ph-clock" aria-hidden="true"></i>
                                        <input type="datetime-local" id="endTime" name="endTime"
                                               class="lt-input ${not empty errors.endTime ? 'is-invalid' : ''}"
                                               value="${fn:substring(event.endTime, 0, 16)}">
                                    </div>
                                    <div class="invalid-feedback"><c:out value="${errors.endTime}"/></div>
                                </div>
                                <div class="lt-field full mb-0">
                                    <label for="venueId" class="lt-label">Địa điểm tổ chức <span class="req">*</span></label>
                                    <div class="lt-icon-wrap accent">
                                        <i class="ph ph-map-pin" aria-hidden="true"></i>
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
                                <span class="ico"><i class="ph ph-ticket" aria-hidden="true"></i></span>
                                <div>
                                    <h2>3. Hạng vé &amp; Sơ đồ ghế</h2>
                                    <p>Chọn cách bán vé cho sự kiện, có thể bổ sung sau khi lưu nháp</p>
                                </div>
                            </div>

                            <c:if test="${not empty errors.tickets}">
                                <div class="lt-alert error"><i class="ph ph-warning-circle" aria-hidden="true"></i><span><c:out value="${errors.tickets}"/></span></div>
                            </c:if>
                            <c:if test="${not empty seatErrors}">
                                <div class="lt-alert error">
                                    <i class="ph ph-warning-circle" aria-hidden="true"></i>
                                    <ul class="sm-server-errors">
                                        <c:forEach var="msg" items="${seatErrors}"><li><c:out value="${msg}"/></li></c:forEach>
                                    </ul>
                                </div>
                            </c:if>
                            <div class="lt-alert error" id="seatStepAlert" hidden>
                                <i class="ph ph-warning-circle" aria-hidden="true"></i><span id="seatStepAlertText"></span>
                            </div>

                            <div class="sale-modes" role="radiogroup" aria-label="Hình thức bán vé">
                                <label class="mode-card" data-mode-card>
                                    <input type="radio" name="ticketMode" value="GENERAL" ${ticketMode != 'SEATED' ? 'checked' : ''}>
                                    <i class="ph ph-ticket" aria-hidden="true"></i>
                                    <span><strong>Vé theo số lượng</strong>
                                        <small>Không chọn chỗ ngồi. Khán giả mua theo hạng vé, phù hợp sự kiện đứng hoặc tự do.</small></span>
                                </label>
                                <label class="mode-card" data-mode-card>
                                    <input type="radio" name="ticketMode" value="SEATED" ${ticketMode == 'SEATED' ? 'checked' : ''}>
                                    <i class="ph ph-armchair" aria-hidden="true"></i>
                                    <span><strong>Vé theo sơ đồ ghế</strong>
                                        <small>Vẽ sơ đồ sân khấu, khu ngồi, khu đứng; mỗi khu một hạng vé và giá.</small></span>
                                </label>
                            </div>

                            <%-- ---- Cách 1: hạng vé theo số lượng (module ltTickets trong event.js) ---- --%>
                            <div id="modeGeneral">
                                <div class="tk-block" id="ticketBlock" data-max-types="10">
                                    <div class="tk-head">
                                        <h3><i class="ph ph-ticket" aria-hidden="true"></i> Thiết lập các hạng vé (Ticket Classes)</h3>
                                    </div>
                                    <p class="tk-note">Không bắt buộc khi lưu nháp. Cần ít nhất một hạng vé khi gửi Admin duyệt. Tổng số vé không vượt quá sức chứa của địa điểm.</p>
                                    <div class="lt-alert error" id="ticketAlert" style="display:none">
                                        <i class="ph ph-warning-circle" aria-hidden="true"></i><span id="ticketAlertText"></span>
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
                                            <i class="ph ph-plus-circle" style="font-size:18px" aria-hidden="true"></i> Thêm hạng vé mới
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
                                <span class="ico"><i class="ph ph-rocket-launch" aria-hidden="true"></i></span>
                                <div>
                                    <h2>4. Xác nhận &amp; Hoàn tất</h2>
                                    <p>Kiểm tra lại thông tin rồi chọn lưu nháp hoặc gửi Admin duyệt</p>
                                </div>
                            </div>
                            <dl class="summary-list mb-4">
                                <dt>Tên sự kiện</dt><dd data-summary="eventName">-</dd>
                                <dt>Thể loại</dt><dd data-summary="categoryId">-</dd>
                                <dt>Địa điểm</dt><dd data-summary="venueId">-</dd>
                                <dt>Bắt đầu</dt><dd data-summary="startTime">-</dd>
                                <dt>Kết thúc</dt><dd data-summary="endTime">-</dd>
                                <dt>Poster</dt><dd data-summary="eventImage">Chưa chọn ảnh</dd>
                                <dt>Hạng vé</dt><dd id="sumTickets">-</dd>
                            </dl>
                            <div class="publish-choice" role="radiogroup" aria-label="Cách hoàn tất">
                                <label class="mode-card">
                                    <input type="radio" name="publishChoice" value="draft" ${publishChoice != 'submit' ? 'checked' : ''}>
                                    <i class="ph ph-file-dashed" aria-hidden="true"></i>
                                    <span><strong>Lưu bản nháp</strong>
                                        <small>Chưa hiển thị với khán giả và chưa gửi Admin. Bạn có thể chỉnh sửa rồi gửi duyệt sau.</small></span>
                                </label>
                                <label class="mode-card">
                                    <input type="radio" name="publishChoice" value="submit" ${publishChoice == 'submit' ? 'checked' : ''}>
                                    <i class="ph ph-paper-plane-tilt" aria-hidden="true"></i>
                                    <span><strong>Gửi Admin duyệt</strong>
                                        <small>Sự kiện chuyển sang “Chờ duyệt”; trong lúc chờ bạn không sửa hoặc xóa được. Cần có ảnh poster và ít nhất một hạng vé.</small></span>
                                </label>
                            </div>
                            <div class="note-box">
                                <span class="ico"><i class="ph ph-shield-check" aria-hidden="true"></i></span>
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
                                    <i class="ph ph-arrow-left" aria-hidden="true"></i> Bước trước
                                </button>
                            </div>
                            <div class="group">
                                <button type="submit" name="submitAction" value="draft" class="btn-soft">Lưu tạm bản thảo</button>
                                <button type="button" class="btn-cta" data-step-nav="next" id="nextBtn">
                                    <span id="nextLabel">Tiếp tục sang bước tiếp theo</span>
                                    <i class="ph ph-arrow-right" aria-hidden="true"></i>
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <%-- ================= CỘT PHẢI: LIVE PREVIEW (sticky) ================= --%>
                <aside class="ce-aside" id="livePreview" aria-label="Xem trước hiển thị trực tiếp">
                    <section class="org-card pv-card">
                        <div class="pv-head">
                            <h3><i class="ph ph-eye" aria-hidden="true"></i> Xem trước hiển thị trực tiếp</h3>
                        </div>

                        <div class="pv-event">
                            <div class="pv-media" id="pvMedia">
                                <i class="ph ph-image ph" aria-hidden="true"></i>
                                <img alt="" id="pvImg">
                                <div class="pv-chips"><span class="pv-chip is-empty" id="pvCategory"></span></div>
                            </div>
                            <div class="pv-body">
                                <h4 class="pv-title is-empty" id="pvTitle">Tên sự kiện của bạn sẽ hiển thị tại đây</h4>
                                <div class="pv-by">
                                    <span>Bởi:</span><b><c:out value="${orgName}"/></b>
                                    <i class="ph ph-seal-check" aria-hidden="true"></i>
                                </div>
                                <div class="pv-meta">
                                    <div class="d">
                                        <i class="ph ph-calendar" aria-hidden="true"></i>
                                        <span class="is-empty" id="pvDate">Chưa chọn thời gian</span>
                                    </div>
                                    <div class="v">
                                        <i class="ph ph-buildings" aria-hidden="true"></i>
                                        <span id="pvVenue">Chưa chọn địa điểm</span>
                                    </div>
                                </div>
                                <div class="pv-price">
                                    <div class="p"><small id="pvPriceLabel">Giá vé</small><strong id="pvPrice">Chưa cấu hình</strong></div>
                                    <span class="pv-buy" aria-hidden="true">Mua vé <i class="ph ph-arrow-right" aria-hidden="true"></i></span>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="org-card ck-card">
                        <div class="ck-head">
                            <h3><i class="ph ph-list-checks" aria-hidden="true"></i> Độ sẵn sàng xuất bản</h3>
                            <span class="ck-pct" id="ckPct">0%</span>
                        </div>
                        <div class="ck-bar"><span id="ckBar"></span></div>
                        <div class="ck-list">
                            <div class="ck-item" data-ck="name">
                                <span class="l"><i class="ph ph-circle ck-ico" aria-hidden="true"></i><span>Tên sự kiện</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="category">
                                <span class="l"><i class="ph ph-circle ck-ico" aria-hidden="true"></i><span>Thể loại</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="description">
                                <span class="l"><i class="ph ph-circle ck-ico" aria-hidden="true"></i><span>Mô tả chi tiết</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="time">
                                <span class="l"><i class="ph ph-circle ck-ico" aria-hidden="true"></i><span>Thời gian tổ chức</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="venue">
                                <span class="l"><i class="ph ph-circle ck-ico" aria-hidden="true"></i><span>Địa điểm</span></span>
                                <span class="ck-status">Chưa hoàn tất</span>
                            </div>
                            <div class="ck-item" data-ck="image">
                                <span class="l"><i class="ph ph-image ck-ico" aria-hidden="true"></i><span>Ảnh poster</span></span>
                                <span class="ck-status">Cần khi gửi duyệt</span>
                            </div>
                            <div class="ck-item is-info" data-ck="tickets">
                                <span class="l"><i class="ph ph-clock-countdown ck-ico" aria-hidden="true"></i><span>Hạng vé &amp; giá</span></span>
                                <span class="ck-status">Không bắt buộc</span>
                            </div>
                        </div>
                        <div class="ck-help">
                            <i class="ph ph-question" aria-hidden="true"></i>
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
