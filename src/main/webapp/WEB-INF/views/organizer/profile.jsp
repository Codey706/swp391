<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="orgInitial" value="${fn:toUpperCase(fn:substring(organizer.fullName, 0, 1))}"/>
<%--
  Hồ sơ Nhà tổ chức - bám sát thiết kế Stitch:
  toolbar > 4 huy hiệu trạng thái > (4 nhóm form | xem trước + checklist) > modal hồ sơ công khai.
  Sidebar/topbar dùng chung _header.jsp, footer dùng _footer.jsp.
--%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Hồ sơ Nhà tổ chức - Light Ticket Organizer Portal</title>
        <jsp:include page="/WEB-INF/views/organizer/_head.jsp"/>
        <link rel="stylesheet" href="${ctx}/assets/css/organizer-profile.css">
    </head>
    <body class="org-body op-body">
        <jsp:include page="/WEB-INF/views/organizer/_header.jsp">
            <jsp:param name="active" value="profile"/>
            <jsp:param name="current" value="Hồ sơ Nhà tổ chức"/>
        </jsp:include>

        <%-- Toast thành công (giống Stitch): hiện một lần sau khi lưu --%>
        <c:if test="${not empty successMessage}">
            <div class="op-toast" id="opToast" role="status" aria-live="polite">
                <span class="op-toast-ico"><span class="material-symbols-outlined">check_circle</span></span>
                <span class="op-toast-text">
                    <strong>Cập nhật thành công!</strong>
                    <small><c:out value="${successMessage}"/></small>
                </span>
                <button type="button" class="op-toast-close" id="opToastClose" aria-label="Đóng thông báo">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
        </c:if>

        <main class="org-container org-main op-main">

            <%-- Toolbar --%>
            <section class="op-toolbar">
                <div class="op-toolbar-title">
                    <a class="op-back" href="${ctx}/organizer/event/list" aria-label="Quay lại danh sách sự kiện">
                        <span class="material-symbols-outlined">arrow_back</span>
                    </a>
                    <div>
                        <h1>Hồ sơ Nhà tổ chức</h1>
                        <p>
                            <c:if test="${not empty memberSince}">Thành viên từ <c:out value="${memberSince}"/> • </c:if>
                            Tên đăng nhập: <strong><c:out value="${organizer.username}"/></strong>
                        </p>
                    </div>
                </div>
                <div class="op-toolbar-actions">
                    <button type="button" class="op-btn op-btn-soft" id="opOpenPublic">
                        <span class="material-symbols-outlined">visibility</span>
                        <span>Xem trước hồ sơ công khai</span>
                    </button>
                    <button type="submit" form="opProfileForm" class="op-btn op-btn-primary">
                        <span class="material-symbols-outlined">save</span>
                        <span>Lưu thay đổi</span>
                    </button>
                </div>
            </section>

            <c:if test="${not empty errorMessage}">
                <div class="lt-alert error" role="alert">
                    <span class="material-symbols-outlined">error</span>
                    <div><c:out value="${errorMessage}"/></div>
                </div>
            </c:if>

            <%-- 4 huy hiệu trạng thái --%>
            <section class="op-status" aria-label="Trạng thái hồ sơ">
                <div class="op-status-item ${profile.kycLevel > 0 ? 'is-active' : ''}">
                    <span class="op-status-ico ${profile.kycLevel > 0 ? 'is-primary' : ''}"><span class="material-symbols-outlined">verified</span></span>
                    <span class="op-status-text">
                        <c:choose>
                            <c:when test="${profile.kycLevel >= 2}">
                                <small class="is-primary">KYC Cấp độ 2</small><strong>Doanh nghiệp uy tín</strong>
                            </c:when>
                            <c:when test="${profile.kycLevel == 1}">
                                <small class="is-primary">KYC Cấp độ 1</small><strong>Đã định danh cơ bản</strong>
                            </c:when>
                            <c:otherwise>
                                <small>Chưa định danh KYC</small>
                                <strong>${profile.verificationStatus == 'REJECTED' ? 'Bị từ chối xác minh' : 'Đang chờ xác minh'}</strong>
                            </c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="op-status-item">
                    <span class="op-status-ico is-ok"><span class="material-symbols-outlined">task_alt</span></span>
                    <span class="op-status-text">
                        <small>Độ hoàn thiện hồ sơ</small>
                        <strong class="is-ok"><c:out value="${profileCompletion}"/>% Hoàn tất</strong>
                    </span>
                </div>
                <div class="op-status-item">
                    <span class="op-status-ico"><span class="material-symbols-outlined">payments</span></span>
                    <span class="op-status-text">
                        <small>Hạn mức rút doanh thu</small>
                        <strong>
                            <c:choose>
                                <c:when test="${empty profile.withdrawalLimit}">Không giới hạn (24/7)</c:when>
                                <c:otherwise><fmt:formatNumber value="${profile.withdrawalLimit}" pattern="#,##0"/> đ</c:otherwise>
                            </c:choose>
                        </strong>
                    </span>
                </div>
                <div class="op-status-item">
                    <span class="op-status-ico"><span class="material-symbols-outlined">${organizer.status == 'ACTIVE' ? 'lock_open' : 'lock'}</span></span>
                    <span class="op-status-text">
                        <small>Quyền phát hành vé</small>
                        <strong class="is-muted">${organizer.status == 'ACTIVE' ? 'Đang kích hoạt' : 'Tạm khóa'}</strong>
                    </span>
                </div>
            </section>

            <div class="op-layout">

                <%-- ============ CỘT TRÁI: 4 NHÓM FORM ============ --%>
                <form id="opProfileForm" class="op-form" method="post" action="${ctx}/organizer/profile"
                      enctype="multipart/form-data" data-cancel-url="${ctx}/organizer/profile" novalidate>
                    <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">

                    <%-- NHÓM 1: THƯƠNG HIỆU & GIỚI THIỆU --%>
                    <section class="op-section" id="opFormSection">
                        <header class="op-section-head">
                            <div class="op-section-title">
                                <span class="op-section-ico"><span class="material-symbols-outlined">domain</span></span>
                                <h2>1. Thông tin thương hiệu &amp; Giới thiệu</h2>
                            </div>
                            <span class="op-tag is-required">Bắt buộc</span>
                        </header>

                        <div class="op-grid-2">
                            <div class="op-field">
                                <label class="op-label" for="fullName">Tên tổ chức / Thương hiệu <span class="req">*</span></label>
                                <input class="op-input ${not empty errors.fullName ? 'is-invalid' : ''}" id="fullName" name="fullName" type="text"
                                       maxlength="100" value="<c:out value='${form.fullName}'/>" autocomplete="organization">
                                <div class="op-error" data-error-for="fullName"><c:out value="${errors.fullName}"/></div>
                            </div>
                            <div class="op-field">
                                <span class="op-label">Trạng thái xác minh sàn vé</span>
                                <div class="op-verify-box">
                                    <span class="op-verify-name">
                                        <span class="op-mini-avatar"><c:out value="${orgInitial}"/></span>
                                        <span><c:out value="${organizer.fullName}"/></span>
                                    </span>
                                    <c:choose>
                                        <c:when test="${profile.verified}">
                                            <span class="op-pill is-ok"><span class="material-symbols-outlined">verified</span>Đã xác minh ✓</span>
                                        </c:when>
                                        <c:when test="${profile.verificationStatus == 'REJECTED'}">
                                            <span class="op-pill is-error"><span class="material-symbols-outlined">block</span>Bị từ chối</span>
                                        </c:when>
                                        <c:otherwise>
                                            <c:choose>
                                                <c:when test="${licenseState == 'MISSING' || licenseState == 'REJECTED'}">
                                                    <span class="op-pill is-warn"><span class="material-symbols-outlined">warning</span>Thiếu giấy phép KD</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="op-pill is-warn"><span class="material-symbols-outlined">schedule</span>Chờ xác minh</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="op-field">
                            <span class="op-label">Thể loại sự kiện chuyên trách chính <span class="req">*</span></span>
                            <div class="op-checks" id="opCategories">
                                <c:forEach var="category" items="${categories}">
                                    <label class="op-check">
                                        <input type="checkbox" name="categoryIds" value="${category.categoryId}"
                                               ${selectedCategoryIds.contains(category.categoryId) ? 'checked' : ''}>
                                        <span><c:out value="${category.categoryName}"/></span>
                                    </label>
                                </c:forEach>
                            </div>
                            <div class="op-error" data-error-for="categories"><c:out value="${errors.categories}"/></div>
                        </div>

                        <div class="op-field">
                            <div class="op-label-row">
                                <label class="op-label" for="summary">Mô tả ngắn giới thiệu đơn vị tổ chức</label>
                                <span class="op-hint"><span id="opSummaryCount">0</span>/300 ký tự</span>
                            </div>
                            <textarea class="op-input ${not empty errors.summary ? 'is-invalid' : ''}" id="summary" name="summary" rows="3"
                                      maxlength="300"><c:out value="${profileForm.summary}"/></textarea>
                            <div class="op-error" data-error-for="summary"><c:out value="${errors.summary}"/></div>
                        </div>

                        <div class="op-media">
                            <div class="op-media-cover">
                                <div class="op-label-row">
                                    <span class="op-label">Ảnh bìa hồ sơ chính (Khuyên dùng: 16:9 - 1920x1080px)</span>
                                    <span class="op-hint">JPG, PNG, WEBP • tối đa 5MB</span>
                                </div>
                                <div class="op-media-box op-ratio-16-9">
                                    <img id="opCoverImg" alt="Ảnh bìa hồ sơ" src="<c:out value='${ctx}/${profile.coverUrl}'/>" ${empty profile.coverUrl ? 'hidden' : ''}>
                                    <span class="op-media-empty" id="opCoverEmpty" ${empty profile.coverUrl ? '' : 'hidden'}>
                                        <span class="material-symbols-outlined">image</span>Chưa có ảnh bìa
                                    </span>
                                    <label class="op-media-overlay">
                                        <input class="op-file" type="file" name="cover" id="cover" accept="image/jpeg,image/png,image/webp">
                                        <span class="op-media-btn"><span class="material-symbols-outlined">cached</span>Thay đổi ảnh bìa</span>
                                    </label>
                                    <span class="op-media-badge">Banner Cover 16:9</span>
                                </div>
                                <div class="op-error" data-error-for="cover"><c:out value="${errors.cover}"/></div>
                            </div>
                            <div class="op-media-logo">
                                <div class="op-label-row">
                                    <span class="op-label">Logo tổ chức (1:1)</span>
                                    <span class="op-hint">tối đa 5MB</span>
                                </div>
                                <div class="op-media-box op-ratio-1-1 is-white">
                                    <img id="opLogoImg" alt="Logo tổ chức" src="<c:out value='${ctx}/${profile.logoUrl}'/>" ${empty profile.logoUrl ? 'hidden' : ''}>
                                    <span class="op-media-empty" id="opLogoEmpty" ${empty profile.logoUrl ? '' : 'hidden'}>
                                        <span class="material-symbols-outlined">add_photo_alternate</span>Chưa có logo
                                    </span>
                                    <label class="op-media-overlay">
                                        <input class="op-file" type="file" name="logo" id="logo" accept="image/jpeg,image/png,image/webp">
                                        <span class="op-media-btn is-small"><span class="material-symbols-outlined">cached</span>Đổi Logo</span>
                                    </label>
                                    <span class="op-media-badge">Chuẩn 1:1 • PNG/JPG</span>
                                </div>
                                <div class="op-error" data-error-for="logo"><c:out value="${errors.logo}"/></div>
                            </div>
                        </div>
                    </section>

                    <%-- NHÓM 2: ĐỊNH DANH PHÁP LÝ & NGƯỜI ĐẠI DIỆN --%>
                    <section class="op-section">
                        <header class="op-section-head">
                            <div class="op-section-title">
                                <span class="op-section-ico"><span class="material-symbols-outlined">badge</span></span>
                                <h2>2. Định danh pháp lý &amp; Người đại diện</h2>
                            </div>
                            <span class="op-tag ${approvedDocTypes >= 3 ? 'is-ok' : 'is-muted'}">Đã thẩm định <c:out value="${approvedDocTypes}"/>/3</span>
                        </header>

                        <div class="op-grid-2">
                            <div class="op-field">
                                <label class="op-label" for="taxCode">Mã số thuế doanh nghiệp (MST) <span class="req">*</span></label>
                                <div class="op-input-wrap has-right">
                                    <c:choose>
                                        <c:when test="${profile.verified}">
                                            <input class="op-input" id="taxCode" type="text" readonly value="<c:out value='${profile.taxCode}'/>">
                                            <span class="material-symbols-outlined op-ico-right is-ok">verified</span>
                                        </c:when>
                                        <c:otherwise>
                                            <input class="op-input ${not empty errors.taxCode ? 'is-invalid' : ''}" id="taxCode" name="taxCode" type="text"
                                                   maxlength="14" inputmode="numeric" value="<c:out value='${profileForm.taxCode}'/>">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${profile.verified}"><span class="op-hint">MST đã xác minh nên không thể thay đổi. Liên hệ hỗ trợ nếu cần chỉnh sửa.</span></c:if>
                                <div class="op-error" data-error-for="taxCode"><c:out value="${errors.taxCode}"/></div>
                            </div>
                            <div class="op-field">
                                <label class="op-label" for="legalRepresentative">Người đại diện pháp luật &amp; Chức vụ <span class="req">*</span></label>
                                <input class="op-input ${not empty errors.legalRepresentative ? 'is-invalid' : ''}" id="legalRepresentative" name="legalRepresentative"
                                       type="text" maxlength="150" value="<c:out value='${profileForm.legalRepresentative}'/>">
                                <div class="op-error" data-error-for="legalRepresentative"><c:out value="${errors.legalRepresentative}"/></div>
                            </div>
                        </div>

                        <div class="op-grid-2">
                            <div class="op-field">
                                <label class="op-label" for="phone">Hotline liên hệ tổ chức <span class="req">*</span></label>
                                <div class="op-input-wrap has-left">
                                    <span class="material-symbols-outlined op-ico-left">call</span>
                                    <input class="op-input ${not empty errors.phone ? 'is-invalid' : ''}" id="phone" name="phone" type="tel"
                                           maxlength="20" value="<c:out value='${form.phone}'/>" autocomplete="tel">
                                </div>
                                <div class="op-error" data-error-for="phone"><c:out value="${errors.phone}"/></div>
                            </div>
                            <div class="op-field">
                                <label class="op-label" for="email">Email hợp tác phát hành vé <span class="req">*</span></label>
                                <div class="op-input-wrap has-left">
                                    <span class="material-symbols-outlined op-ico-left">mail</span>
                                    <input class="op-input ${not empty errors.email ? 'is-invalid' : ''}" id="email" name="email" type="email"
                                           maxlength="255" value="<c:out value='${form.email}'/>" autocomplete="email">
                                </div>
                                <div class="op-error" data-error-for="email"><c:out value="${errors.email}"/></div>
                            </div>
                        </div>

                        <div class="op-field">
                            <label class="op-label" for="address">Địa chỉ trụ sở đăng ký kinh doanh <span class="req">*</span></label>
                            <div class="op-input-wrap has-left">
                                <span class="material-symbols-outlined op-ico-left is-accent">location_on</span>
                                <input class="op-input ${not empty errors.address ? 'is-invalid' : ''}" id="address" name="address" type="text"
                                       maxlength="255" value="<c:out value='${form.address}'/>" autocomplete="street-address">
                            </div>
                            <div class="op-error" data-error-for="address"><c:out value="${errors.address}"/></div>
                        </div>

                        <div class="op-field">
                            <span class="op-label">Tài liệu pháp lý đã tải lên &amp; phê duyệt</span>
                            <c:choose>
                                <c:when test="${licenseState == 'MISSING'}">
                                    <div class="op-notice is-warn">
                                        <span class="material-symbols-outlined">warning</span>
                                        <div><strong>Cần có Giấy phép kinh doanh mới được duyệt.</strong> Hãy tải lên Giấy phép kinh doanh (loại "Giấy phép kinh doanh") để tổ chức được xác minh.</div>
                                    </div>
                                </c:when>
                                <c:when test="${licenseState == 'REJECTED'}">
                                    <div class="op-notice is-error">
                                        <span class="material-symbols-outlined">block</span>
                                        <div><strong>Giấy phép kinh doanh đã bị từ chối.</strong> Vui lòng tải lên bản hợp lệ khác để được xét duyệt lại.</div>
                                    </div>
                                </c:when>
                                <c:when test="${licenseState == 'PENDING'}">
                                    <div class="op-notice is-info">
                                        <span class="material-symbols-outlined">schedule</span>
                                        <div>Giấy phép kinh doanh đang chờ quản trị viên duyệt.</div>
                                    </div>
                                </c:when>
                            </c:choose>
                            <c:choose>
                                <c:when test="${empty documents}">
                                    <div class="op-empty">Chưa có tài liệu nào. Tải lên giấy ĐKKD, giấy phép biểu diễn hoặc hợp đồng tác quyền để được thẩm định.</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="op-docs">
                                        <c:forEach var="doc" items="${documents}">
                                            <a class="op-doc" target="_blank" rel="noopener" href="${ctx}/organizer/profile/document?id=${doc.documentId}" title="<c:out value='${doc.typeLabel}'/>">
                                                <span class="op-doc-name">
                                                    <span class="material-symbols-outlined ${doc.status == 'APPROVED' ? 'is-ok' : ''}"><c:out value="${doc.icon}"/></span>
                                                    <span><c:out value="${doc.docName}"/></span>
                                                </span>
                                                <span class="op-pill ${doc.status == 'APPROVED' ? 'is-ok' : (doc.status == 'REJECTED' ? 'is-error' : 'is-warn')}"><c:out value="${doc.statusLabel}"/></span>
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div class="op-upload">
                                <select class="op-input" name="docType" id="docType" aria-label="Loại tài liệu">
                                    <option value="BUSINESS_LICENSE">Giấy phép kinh doanh</option>
                                    <option value="PERFORMANCE_PERMIT">Giấy phép biểu diễn</option>
                                    <option value="COPYRIGHT_CONTRACT">Hợp đồng tác quyền</option>
                                    <option value="OTHER">Tài liệu khác</option>
                                </select>
                                <input class="op-input" type="file" name="document" id="document" accept="application/pdf,image/jpeg,image/png" aria-label="Tệp tài liệu">
                            </div>
                            <span class="op-hint">PDF, JPG hoặc PNG, tối đa 5MB. Chỉ khi có Giấy phép kinh doanh được duyệt, tổ chức mới được xác minh. Tài liệu được lưu riêng tư, chỉ bạn và quản trị viên xem được.</span>
                            <div class="op-error" data-error-for="document"><c:out value="${errors.document}"/></div>
                        </div>
                    </section>

                    <%-- NHÓM 3: TÀI KHOẢN NGÂN HÀNG & ĐỐI SOÁT --%>
                    <c:set var="bankLocked" value="${profile.bankComplete && empty errors.bankName && empty errors.bankAccountNumber && empty errors.bankAccountHolder}"/>
                    <section class="op-section" id="opBankSection">
                        <header class="op-section-head">
                            <div class="op-section-title">
                                <span class="op-section-ico"><span class="material-symbols-outlined">account_balance</span></span>
                                <h2>3. Tài khoản ngân hàng nhận thanh toán &amp; Đối soát vé</h2>
                            </div>
                            <button type="button" class="op-btn op-btn-small op-btn-soft" id="opBankToggle" ${bankLocked ? '' : 'hidden'}>
                                <span class="material-symbols-outlined">edit</span>Thay đổi số tài khoản
                            </button>
                        </header>

                        <c:if test="${profile.bankComplete}">
                            <div class="op-bank-card">
                                <div class="op-bank-main">
                                    <span class="op-bank-ico"><span class="material-symbols-outlined">account_balance</span></span>
                                    <div>
                                        <div class="op-bank-title">
                                            <strong><c:out value="${profile.bankName}"/></strong>
                                            <span class="op-pill is-ok-solid">Tài khoản chính</span>
                                        </div>
                                        <div class="op-bank-number"><c:out value="${profile.bankAccountDisplay}"/></div>
                                        <small>Chủ TK: <c:out value="${profile.bankAccountHolder}"/></small>
                                    </div>
                                </div>
                                <span class="op-pill is-ok"><span class="material-symbols-outlined">check_circle</span>Đã có thông tin nhận thanh toán</span>
                            </div>
                        </c:if>

                        <div class="op-bank-fields" id="opBankFields" ${bankLocked ? 'hidden' : ''}>
                            <div class="op-field">
                                <label class="op-label" for="bankName">Ngân hàng - Chi nhánh</label>
                                <input class="op-input ${not empty errors.bankName ? 'is-invalid' : ''}" id="bankName" name="bankName" type="text"
                                       maxlength="150" placeholder="Ví dụ: Vietcombank - CN Tân Định, TP.HCM" value="<c:out value='${profileForm.bankName}'/>">
                                <div class="op-error" data-error-for="bankName"><c:out value="${errors.bankName}"/></div>
                            </div>
                            <div class="op-grid-2">
                                <div class="op-field">
                                    <label class="op-label" for="bankAccountNumber">Số tài khoản</label>
                                    <input class="op-input ${not empty errors.bankAccountNumber ? 'is-invalid' : ''}" id="bankAccountNumber" name="bankAccountNumber"
                                           type="text" maxlength="30" inputmode="numeric" autocomplete="off" value="<c:out value='${profileForm.bankAccountNumber}'/>">
                                    <div class="op-error" data-error-for="bankAccountNumber"><c:out value="${errors.bankAccountNumber}"/></div>
                                </div>
                                <div class="op-field">
                                    <label class="op-label" for="bankAccountHolder">Chủ tài khoản</label>
                                    <input class="op-input ${not empty errors.bankAccountHolder ? 'is-invalid' : ''}" id="bankAccountHolder" name="bankAccountHolder"
                                           type="text" maxlength="150" autocomplete="off" value="<c:out value='${profileForm.bankAccountHolder}'/>">
                                    <div class="op-error" data-error-for="bankAccountHolder"><c:out value="${errors.bankAccountHolder}"/></div>
                                </div>
                            </div>
                        </div>

                        <div class="op-money">
                            <div>
                                <span class="material-symbols-outlined">savings</span>
                                Doanh thu khả dụng (sự kiện đã kết thúc):
                                <strong class="is-accent"><fmt:formatNumber value="${revenueSettled}" pattern="#,##0"/> đ</strong>
                            </div>
                            <div>
                                Tạm giữ chờ diễn:
                                <strong><fmt:formatNumber value="${revenueEscrow}" pattern="#,##0"/> đ</strong>
                            </div>
                        </div>
                    </section>

                    <%-- NHÓM 4: KÊNH TRUYỀN THÔNG --%>
                    <section class="op-section">
                        <header class="op-section-head">
                            <div class="op-section-title">
                                <span class="op-section-ico"><span class="material-symbols-outlined">share</span></span>
                                <h2>4. Kênh truyền thông &amp; Mạng xã hội</h2>
                            </div>
                            <span class="op-tag is-muted">Tùy chọn</span>
                        </header>

                        <div class="op-grid-2">
                            <div class="op-field">
                                <label class="op-label" for="websiteUrl">Website chính thức</label>
                                <div class="op-input-wrap has-left">
                                    <span class="material-symbols-outlined op-ico-left">language</span>
                                    <input class="op-input ${not empty errors.websiteUrl ? 'is-invalid' : ''}" id="websiteUrl" name="websiteUrl" type="url"
                                           maxlength="500" placeholder="https://" value="<c:out value='${profileForm.websiteUrl}'/>">
                                </div>
                                <div class="op-error" data-error-for="websiteUrl"><c:out value="${errors.websiteUrl}"/></div>
                            </div>
                            <div class="op-field">
                                <label class="op-label" for="facebookUrl">Fanpage Facebook</label>
                                <div class="op-input-wrap has-left">
                                    <span class="material-symbols-outlined op-ico-left">public</span>
                                    <input class="op-input ${not empty errors.facebookUrl ? 'is-invalid' : ''}" id="facebookUrl" name="facebookUrl" type="url"
                                           maxlength="500" placeholder="https://facebook.com/..." value="<c:out value='${profileForm.facebookUrl}'/>">
                                </div>
                                <div class="op-error" data-error-for="facebookUrl"><c:out value="${errors.facebookUrl}"/></div>
                            </div>
                        </div>
                        <div class="op-grid-2">
                            <div class="op-field">
                                <label class="op-label" for="youtubeUrl">Kênh YouTube / TikTok</label>
                                <div class="op-input-wrap has-left">
                                    <span class="material-symbols-outlined op-ico-left">smart_display</span>
                                    <input class="op-input ${not empty errors.youtubeUrl ? 'is-invalid' : ''}" id="youtubeUrl" name="youtubeUrl" type="url"
                                           maxlength="500" placeholder="https://youtube.com/@..." value="<c:out value='${profileForm.youtubeUrl}'/>">
                                </div>
                                <div class="op-error" data-error-for="youtubeUrl"><c:out value="${errors.youtubeUrl}"/></div>
                            </div>
                            <div class="op-field">
                                <label class="op-label" for="spotifyUrl">Trang Spotify Nghệ sĩ / Label</label>
                                <div class="op-input-wrap has-left">
                                    <span class="material-symbols-outlined op-ico-left">graphic_eq</span>
                                    <input class="op-input ${not empty errors.spotifyUrl ? 'is-invalid' : ''}" id="spotifyUrl" name="spotifyUrl" type="url"
                                           maxlength="500" placeholder="https://open.spotify.com/..." value="<c:out value='${profileForm.spotifyUrl}'/>">
                                </div>
                                <div class="op-error" data-error-for="spotifyUrl"><c:out value="${errors.spotifyUrl}"/></div>
                            </div>
                        </div>
                    </section>
                </form>

                <%-- ============ CỘT PHẢI: XEM TRƯỚC + CHECKLIST ============ --%>
                <aside class="op-aside">
                    <div class="op-panel">
                        <div class="op-panel-head">
                            <span class="material-symbols-outlined is-accent">preview</span>
                            <strong>Xem trước hiển thị trực tiếp</strong>
                        </div>
                        <div class="op-card">
                            <div class="op-card-cover op-ratio-16-9">
                                <img id="opPvCover" alt="" src="<c:out value='${ctx}/${profile.coverUrl}'/>" ${empty profile.coverUrl ? 'hidden' : ''}>
                                <span class="op-card-cover-empty" id="opPvCoverEmpty" ${empty profile.coverUrl ? '' : 'hidden'}><span class="material-symbols-outlined">image</span></span>
                                <span class="op-card-tags">
                                    <span class="op-chip is-accent">Nhà tổ chức</span>
                                    <c:if test="${not empty profile.partnerTier}"><span class="op-chip is-dark"><c:out value="${profile.partnerTier}"/></span></c:if>
                                </span>
                                <c:if test="${profile.kycLevel > 0}">
                                    <span class="op-card-kyc"><span class="material-symbols-outlined">verified</span>Đã định danh KYC</span>
                                </c:if>
                            </div>
                            <div class="op-card-body">
                                <div class="op-card-id">
                                    <span class="op-card-logo">
                                        <img id="opPvLogo" alt="" src="<c:out value='${ctx}/${profile.logoUrl}'/>" ${empty profile.logoUrl ? 'hidden' : ''}>
                                        <span id="opPvLogoEmpty" ${empty profile.logoUrl ? '' : 'hidden'}><c:out value="${orgInitial}"/></span>
                                    </span>
                                    <div class="op-card-name">
                                        <div>
                                            <h3 id="opPvName" data-empty="Tên tổ chức"><c:out value="${form.fullName}"/></h3>
                                            <c:if test="${profile.verified}"><span class="material-symbols-outlined is-ok">verified</span></c:if>
                                        </div>
                                        <small>Trụ sở: <span id="opPvAddress" data-empty="Chưa cập nhật"><c:out value="${empty form.address ? 'Chưa cập nhật' : form.address}"/></span></small>
                                    </div>
                                </div>
                                <p class="op-card-summary" id="opPvSummary" data-empty="Chưa có mô tả giới thiệu."><c:out value="${empty profileForm.summary ? 'Chưa có mô tả giới thiệu.' : profileForm.summary}"/></p>
                                <div class="op-card-stats">
                                    <span><span class="material-symbols-outlined is-accent">celebration</span><strong><c:out value="${totalEvents}"/> sự kiện</strong></span>
                                    <span class="op-rating">
                                        <span class="material-symbols-outlined is-star">grade</span>
                                        <c:choose>
                                            <c:when test="${ratingCount > 0}">
                                                <strong><fmt:formatNumber value="${ratingAvg}" minFractionDigits="1" maxFractionDigits="1"/></strong>
                                                <small>(<c:out value="${ratingCount}"/> đánh giá)</small>
                                            </c:when>
                                            <c:otherwise><small>Chưa có đánh giá</small></c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <button type="button" class="op-btn op-btn-primary op-btn-block op-btn-small" id="opOpenPublicCard">
                                    <span>Xem hồ sơ công khai</span>
                                    <span class="material-symbols-outlined">arrow_forward</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="op-panel">
                        <div class="op-panel-head is-between">
                            <span class="op-panel-head-title"><span class="material-symbols-outlined is-ok">checklist</span><strong>Độ sẵn sàng xuất bản hồ sơ</strong></span>
                            <span class="op-pill is-ok"><c:out value="${profileCompletion}"/>%</span>
                        </div>
                        <div class="op-progress"><span style="width: ${profileCompletion}%"></span></div>
                        <ul class="op-checklist">
                            <li class="${ckBrand ? 'is-done' : ''}">
                                <span><span class="material-symbols-outlined">${ckBrand ? 'check_circle' : 'radio_button_unchecked'}</span>Tên thương hiệu &amp; Thể loại</span>
                                <small>${ckBrand ? 'Hoàn tất' : 'Chưa xong'}</small>
                            </li>
                            <li class="${ckMedia ? 'is-done' : ''}">
                                <span><span class="material-symbols-outlined">${ckMedia ? 'check_circle' : 'radio_button_unchecked'}</span>Logo chuẩn &amp; Ảnh bìa 16:9</span>
                                <small>${ckMedia ? 'Hoàn tất' : 'Chưa xong'}</small>
                            </li>
                            <li class="${ckLegal ? 'is-done' : ''}">
                                <span><span class="material-symbols-outlined">${ckLegal ? 'check_circle' : 'radio_button_unchecked'}</span>MST, đại diện &amp; Giấy phép KD</span>
                                <small>${licenseState == 'APPROVED' ? 'Đã duyệt' : (licenseState == 'PENDING' ? 'Chờ duyệt' : (licenseState == 'REJECTED' ? 'Bị từ chối' : 'Thiếu GPKD'))}</small>
                            </li>
                            <li class="${ckBank ? 'is-done' : ''}">
                                <span><span class="material-symbols-outlined">${ckBank ? 'verified_user' : 'radio_button_unchecked'}</span>Tài khoản nhận thanh toán</span>
                                <small>${ckBank ? 'Đã có' : 'Chưa xong'}</small>
                            </li>
                            <li class="${ckSocial ? 'is-done' : ''}">
                                <span><span class="material-symbols-outlined">${ckSocial ? 'check_circle' : 'radio_button_unchecked'}</span>Kênh truyền thông &amp; Mạng xã hội</span>
                                <small>${ckSocial ? 'Hoàn tất' : 'Chưa xong'}</small>
                            </li>
                        </ul>
                        <div class="op-panel-actions">
                            <button type="submit" form="opProfileForm" class="op-btn op-btn-primary op-btn-block" id="opSave">
                                <span>Lưu &amp; Cập nhật hồ sơ</span>
                                <span class="material-symbols-outlined">arrow_forward</span>
                            </button>
                            <button type="button" class="op-btn op-btn-soft op-btn-block" id="opCancel">
                                <span class="material-symbols-outlined">undo</span>
                                <span>Hủy thay đổi</span>
                            </button>
                        </div>
                        <div class="op-support">
                            <span class="material-symbols-outlined">help</span>
                            Cần hỗ trợ duyệt nhanh? Hotline BTC: 1900 xxxx
                        </div>
                    </div>
                </aside>
            </div>
        </main>

        <%-- Modal hồ sơ công khai --%>
        <div class="op-modal" id="opPublicModal" role="dialog" aria-modal="true" aria-labelledby="opModalTitle" hidden>
            <div class="op-modal-backdrop" data-close-modal></div>
            <div class="op-modal-dialog">
                <div class="op-modal-cover">
                    <c:if test="${not empty profile.coverUrl}"><img alt="" src="<c:out value='${ctx}/${profile.coverUrl}'/>"></c:if>
                    <button type="button" class="op-modal-close" data-close-modal aria-label="Đóng"><span class="material-symbols-outlined">close</span></button>
                </div>
                <div class="op-modal-body">
                    <div class="op-modal-id">
                        <span class="op-modal-logo">
                            <c:choose>
                                <c:when test="${not empty profile.logoUrl}"><img alt="" src="<c:out value='${ctx}/${profile.logoUrl}'/>"></c:when>
                                <c:otherwise><span><c:out value="${orgInitial}"/></span></c:otherwise>
                            </c:choose>
                        </span>
                        <c:if test="${profile.kycLevel > 0}"><span class="op-chip is-ok-solid">Đã thẩm duyệt KYC</span></c:if>
                    </div>
                    <h2 id="opModalTitle"><c:out value="${organizer.fullName}"/></h2>
                    <p class="op-modal-meta">
                        <c:out value="${empty organizer.address ? 'Chưa cập nhật địa chỉ' : organizer.address}"/>
                        <c:if test="${not empty organizer.phone}"> • Hotline: <c:out value="${organizer.phone}"/></c:if>
                    </p>
                    <c:if test="${not empty profile.summary}"><p class="op-modal-summary"><c:out value="${profile.summary}"/></p></c:if>
                    <div class="op-modal-stats">
                        <div><strong><c:out value="${totalEvents}"/></strong><span>Sự kiện tổ chức</span></div>
                        <div><strong><fmt:formatNumber value="${ticketSold}" pattern="#,##0"/></strong><span>Vé phục vụ</span></div>
                        <div>
                            <strong class="is-star"><c:choose>
                                <c:when test="${ratingCount > 0}"><fmt:formatNumber value="${ratingAvg}" minFractionDigits="1" maxFractionDigits="1"/>★</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose></strong>
                            <span><c:out value="${ratingCount}"/> Đánh giá</span>
                        </div>
                    </div>
                    <div class="op-modal-actions">
                        <button type="button" class="op-btn op-btn-soft" data-close-modal>Đóng cửa sổ</button>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/organizer/_footer.jsp"/>

        <script src="${ctx}/assets/js/bootstrap.bundle.js"></script>
        <script src="${ctx}/assets/js/event.js"></script>
        <script src="${ctx}/assets/js/organizer-profile.js"></script>
    </body>
</html>
