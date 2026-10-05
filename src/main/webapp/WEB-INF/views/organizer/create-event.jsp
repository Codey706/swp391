<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Nếu server không có sẵn JSTL (Tomcat), thêm dependency jakarta.servlet.jsp.jstl --%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgName" value="${not empty sessionScope.user && not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Mây Lang Thang Production'}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Tạo sự kiện mới - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
    </head>
    <body class="org-body">
        <jsp:include page="/WEB-INF/views/organizer/_header.jsp">
            <jsp:param name="active" value="events"/>
            <jsp:param name="crumb2" value="Quản lý sự kiện"/>
            <jsp:param name="current" value="Tạo sự kiện mới"/>
        </jsp:include>

        <main class="org-container org-main">

            <section class="org-page-head" style="padding:0 0 1.25rem;margin:0;">
                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <h1 class="org-title mb-0">Tạo sự kiện mới</h1>
                    <span class="org-badge-pill ok mb-0">Sự kiện sẽ được lưu ở trạng thái Nháp</span>
                </div>
                <div class="org-head-actions">
                    <button type="submit" form="create-event-form" class="btn-soft">
                        <span class="material-symbols-outlined">save</span> Lưu bản nháp
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
                    <span class="step-text"><small>Bước 3</small><span>Hạng vé &amp; Giá bán</span></span>
                </button>
                <button type="button" class="step-item" data-step-target="4">
                    <span class="step-num">4</span>
                    <span class="step-text"><small>Bước 4</small><span>Quy định &amp; Xuất bản</span></span>
                </button>
            </div>

            <form id="create-event-form" method="post" enctype="multipart/form-data" novalidate
                  action="${ctx}/organizer/event/create">

                <%-- ============ BƯỚC 1 ============ --%>
                <section class="org-card form-card active" data-step-pane="1">
                    <div class="form-card-head">
                        <span class="ico"><span class="material-symbols-outlined">info</span></span>
                        <div>
                            <h2>Thông tin đại cương sự kiện</h2>
                            <p>Nhập các thuộc tính tiêu đề, thể loại và hình ảnh đại diện biểu diễn</p>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="lt-field">
                            <label for="eventName" class="lt-label">Tên sự kiện <span class="req">*</span></label>
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

                        <div class="lt-field full">
                            <span class="lt-label">Đơn vị tổ chức độc quyền</span>
                            <div class="lt-verified">
                                <span class="material-symbols-outlined fill">verified</span>
                                <span><c:out value="${orgName}"/></span>
                                <small>Đã xác minh</small>
                            </div>
                        </div>

                        <div class="lt-field full">
                            <div class="label-row">
                                <label for="eventImage" class="lt-label">Ảnh poster bìa ngang (Tỷ lệ 16:9, tối ưu 1920x1080px)</label>
                                <span class="tag opt">Không bắt buộc</span>
                            </div>
                            <label class="drop-zone" id="dropZone" for="eventImage">
                                <img alt="Xem trước poster" id="posterPreview">
                                <span class="dz-overlay">
                                    <span class="material-symbols-outlined">cloud_upload</span>
                                    <strong>Kéo thả ảnh hoặc nhấn để chọn poster bìa</strong>
                                    <span>Định dạng JPG, PNG, WEBP tối đa 5MB</span>
                                </span>
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
                        <span class="ico"><span class="material-symbols-outlined">event</span></span>
                        <div>
                            <h2>Thời gian &amp; Địa điểm tổ chức</h2>
                            <p>Chọn thời điểm diễn ra và địa điểm đã được hệ thống xác minh</p>
                        </div>
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

                <%-- ============ BƯỚC 3 ============ --%>
                <section class="org-card form-card" data-step-pane="3">
                    <div class="form-card-head">
                        <span class="ico"><span class="material-symbols-outlined">confirmation_number</span></span>
                        <div>
                            <h2>Hạng vé &amp; Giá bán</h2>
                            <p>Thiết lập các hạng vé, số lượng phát hành và giá bán</p>
                        </div>
                    </div>
                    <div class="note-box blue">
                        <span class="ico"><span class="material-symbols-outlined">lightbulb</span></span>
                        <div>
                            <h3>Cấu hình hạng vé sau khi tạo sự kiện</h3>
                            <p>Sau khi lưu, sự kiện nằm trong mục “Sự kiện của tôi” ở trạng thái Nháp. Bạn có thể bổ sung hạng vé, giá bán và số lượng phát hành rồi mới gửi duyệt.</p>
                        </div>
                    </div>
                </section>

                <%-- ============ BƯỚC 4 ============ --%>
                <section class="org-card form-card" data-step-pane="4">
                    <div class="form-card-head">
                        <span class="ico"><span class="material-symbols-outlined">rocket_launch</span></span>
                        <div>
                            <h2>Quy định &amp; Xuất bản</h2>
                            <p>Kiểm tra lại thông tin trước khi tạo sự kiện</p>
                        </div>
                    </div>
                    <dl class="summary-list mb-4">
                        <dt>Tên sự kiện</dt><dd data-summary="eventName">—</dd>
                        <dt>Thể loại</dt><dd data-summary="categoryId">—</dd>
                        <dt>Địa điểm</dt><dd data-summary="venueId">—</dd>
                        <dt>Bắt đầu</dt><dd data-summary="startTime">—</dd>
                        <dt>Kết thúc</dt><dd data-summary="endTime">—</dd>
                        <dt>Poster</dt><dd data-summary="eventImage">Chưa chọn ảnh</dd>
                    </dl>
                    <div class="note-box">
                        <span class="ico"><span class="material-symbols-outlined">verified_user</span></span>
                        <div>
                            <h3>Sự kiện được lưu ở trạng thái Nháp</h3>
                            <p>Sự kiện chưa hiển thị với khán giả. Bạn có thể chỉnh sửa hoặc xóa khi còn ở trạng thái Nháp, và gửi duyệt khi đã sẵn sàng.</p>
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
                        <button type="submit" class="btn-soft">Lưu tạm bản thảo</button>
                        <button type="button" class="btn-cta" data-step-nav="next" id="nextBtn">
                            <span id="nextLabel">Tiếp tục sang bước tiếp theo</span>
                            <span class="material-symbols-outlined">arrow_forward</span>
                        </button>
                    </div>
                </div>
            </form>
        </main>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>
        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
    </body>
</html>
