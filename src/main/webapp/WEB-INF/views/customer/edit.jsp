<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="userInitial" value="${empty user.fullName ? 'U' : fn:toUpperCase(fn:substring(user.fullName, 0, 1))}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa hồ sơ cá nhân - Light Ticket</title>

    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com" rel="preconnect"/>
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>

    <!-- Material Symbols Outlined -->

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Stitch Design System CSS -->
    <link rel="stylesheet" href="${ctx}/assets/css/stitch-custom.css">
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

<body class="lt-body d-flex flex-column min-vh-100">

    <!-- ======================================================================
         HEADER (STITCH COMPATIBLE)
         ====================================================================== -->
    <jsp:include page="/WEB-INF/views/common/site-header.jsp"/>

    <!-- ======================================================================
         MAIN CONTENT
         ====================================================================== -->
    <main class="container-xl py-4 flex-grow-1">

        <!-- Top Breadcrumb & Quick Back Navigation -->
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3">
            <nav aria-label="Breadcrumb" class="lt-breadcrumb mb-0">
                <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                    <i class="ph ph-house" style="font-size:16px;" aria-hidden="true"></i>
                    Trang chủ
                </a>
                <i class="ph ph-caret-right separator" aria-hidden="true"></i>
                <a href="${ctx}/CustomerProfileController">Tài khoản của tôi</a>
                <i class="ph ph-caret-right separator" aria-hidden="true"></i>
                <span class="active">Chỉnh sửa hồ sơ</span>
            </nav>

            <div class="d-flex align-items-center gap-2">
                <a href="${ctx}/home#events" class="btn-lt-primary btn-sm">
                    <i class="ph ph-ticket" style="font-size:18px;" aria-hidden="true"></i>
                    Mua vé ngay
                </a>
                <a href="${ctx}/CustomerProfileController" class="btn-lt-secondary btn-sm">
                    <i class="ph ph-arrow-left" style="font-size:18px;" aria-hidden="true"></i>
                    Quay lại Hồ sơ
                </a>
            </div>
        </div>

        <!-- Header Card -->
        <div class="lt-card p-4 mb-4">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
                <div>
                    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                        <h1 class="h3 fw-bold text-dark mb-0">Chỉnh sửa hồ sơ cá nhân</h1>
                        <span class="lt-pill lt-pill-vip">
                            <i class="ph ph-medal" style="font-size:14px;" aria-hidden="true"></i>
                            Thành viên <c:out value="${user.role}"/>
                        </span>
                    </div>
                    <p class="text-secondary mb-0 small">
                        Cập nhật thông tin định danh nhận vé điện tử E-Ticket, hóa đơn VAT và thông tin bảo mật tài khoản.
                    </p>
                </div>
            </div>
        </div>

        <!-- 2-Column Layout -->
        <div class="row g-4 align-items-start">

            <!-- LEFT COLUMN: Account Sidebar (col-lg-4) -->
            <aside class="col-lg-4">
                <!-- User Summary Card -->
                <div class="lt-card p-4 text-center mb-4">
                    <div class="position-relative d-inline-block mb-3">
                        <div class="lt-avatar-round shadow-sm mx-auto" style="width: 86px; height: 86px; font-size: 2rem;">
                            <span>${userInitial}</span>
                        </div>
                    </div>

                    <h2 class="h5 fw-bold text-dark mb-1">
                        <c:out value="${user.fullName}"/>
                        <i class="ph ph-seal-check text-primary align-middle" style="font-size:18px;color:var(--lt-primary)!important;" title="Tài khoản đã xác thực" aria-hidden="true"></i>
                    </h2>
                    <p class="text-secondary small mb-3"><c:out value="${user.email}"/></p>

                    <div class="p-3 rounded-3 text-start mb-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                        <div class="d-flex justify-content-between small fw-bold text-secondary mb-1">
                            <span>Hạng tài khoản</span>
                            <span class="text-primary" style="color:var(--lt-primary)!important;"><c:out value="${user.role}"/></span>
                        </div>
                        <span class="text-muted small d-block">Tài khoản định danh nhận vé điện tử E-Ticket và soát vé QR tại sự kiện.</span>
                    </div>
                </div>

                <!-- Account Navigation Menu -->
                <div class="lt-card p-3">
                    <div class="lt-sidebar-nav-title">Danh mục tài khoản</div>
                    <nav class="lt-sidebar-nav">
                        <a href="${ctx}/CustomerProfileController" class="lt-sidebar-item">
                            <div class="item-left">
                                <i class="ph ph-user" style="font-size:19px;" aria-hidden="true"></i>
                                <span>Hồ sơ của tôi</span>
                            </div>
                            <i class="ph ph-caret-right text-muted" style="font-size:16px;" aria-hidden="true"></i>
                        </a>

                        <a href="${ctx}/UpdateCustomerProfileController" class="lt-sidebar-item active">
                            <div class="item-left">
                                <i class="ph ph-pencil-simple-line" style="font-size:19px;" aria-hidden="true"></i>
                                <span>Chỉnh sửa thông tin</span>
                            </div>
                            <span class="badge bg-danger rounded-pill" style="font-size:10px;background:var(--lt-primary)!important;">Đang sửa</span>
                        </a>

                        <a href="${ctx}/customer/booking-history" class="lt-sidebar-item">
                            <div class="item-left">
                                <i class="ph ph-ticket" style="font-size:19px;" aria-hidden="true"></i>
                                <span>Vé của tôi</span>
                            </div>
                            <i class="ph ph-caret-right text-muted" style="font-size:16px;" aria-hidden="true"></i>
                        </a>

                        <a href="${ctx}/Auth?action=changePassword" class="lt-sidebar-item">
                            <div class="item-left">
                                <i class="ph ph-lock" style="font-size:19px;" aria-hidden="true"></i>
                                <span>${sessionScope.user.passwordSet ? 'Đổi mật khẩu' : 'Thiết lập mật khẩu'}</span>
                            </div>
                            <i class="ph ph-arrow-square-out text-muted" style="font-size:16px;" aria-hidden="true"></i>
                        </a>
                    </nav>
                </div>
            </aside>

            <!-- RIGHT COLUMN: Form Edit (col-lg-8) -->
            <section class="col-lg-8">
                <div class="lt-card p-4">
                    <div class="d-flex align-items-center gap-3 pb-3 mb-4 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                        <div class="d-flex align-items-center justify-content-center rounded-3 p-2" style="background: var(--lt-primary-fixed); color: var(--lt-primary);">
                            <i class="ph ph-note-pencil" style="font-size:22px;" aria-hidden="true"></i>
                        </div>
                        <div>
                            <h3 class="h6 fw-bold text-dark mb-0">Biểu mẫu cập nhật hồ sơ</h3>
                            <p class="text-secondary small mb-0">Vui lòng điền đúng thông tin chính xác của bạn</p>
                        </div>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger py-2 px-3 mb-4 small" role="alert">
                            <c:out value="${errorMessage}"/>
                        </div>
                    </c:if>

                    <form action="${ctx}/UpdateCustomerProfileController" method="post">
                        <div class="row g-3">
                            <!-- Họ và tên -->
                            <div class="col-md-6">
                                <label for="fullName" class="form-label small fw-bold text-dark">
                                    Họ và tên <span class="text-danger">*</span>
                                </label>
                                <input type="text" id="fullName" name="fullName" value="${fn:escapeXml(user.fullName)}" required class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm);">
                            </div>

                            <!-- Tên đăng nhập -->
                            <div class="col-md-6">
                                <label for="username" class="form-label small fw-bold text-secondary">
                                    Tên đăng nhập
                                </label>
                                <input type="text" id="username" value="${fn:escapeXml(user.username)}" disabled class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm); background-color: var(--lt-surface-low); cursor: not-allowed;">
                                <div class="form-text text-muted small" style="font-size: 11px;">Tên đăng nhập được dùng cố định cho tài khoản.</div>
                            </div>

                            <!-- Email nhận vé -->
                            <div class="col-md-6">
                                <label for="email" class="form-label small fw-bold text-dark">
                                    Email nhận vé điện tử <span class="text-danger">*</span>
                                </label>
                                <input type="email" id="email" name="email" value="${fn:escapeXml(user.email)}" required class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm);">
                                <div class="form-text text-muted small" style="font-size: 11px;">Vé và mã QR check-in sẽ được gửi tới email này.</div>
                            </div>

                            <!-- Số điện thoại -->
                            <div class="col-md-6">
                                <label for="phone" class="form-label small fw-bold text-dark">
                                    Số điện thoại liên hệ
                                </label>
                                <input type="tel" id="phone" name="phone" value="${fn:escapeXml(user.phone)}" class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm);">
                            </div>

                            <!-- Địa chỉ -->
                            <div class="col-12">
                                <label for="address" class="form-label small fw-bold text-dark">
                                    Địa chỉ liên hệ
                                </label>
                                <textarea id="address" name="address" rows="3" class="form-control" style="border-radius: var(--lt-radius-sm);"><c:out value="${user.address}"/></textarea>
                            </div>

                            <!-- Notice -->
                            <div class="col-12">
                                <div class="p-3 rounded-3 d-flex align-items-start gap-2" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                    <i class="ph ph-shield-check text-primary mt-0.5" style="font-size:20px;color:var(--lt-primary)!important;" aria-hidden="true"></i>
                                    <p class="small text-secondary mb-0">
                                        Hệ thống Light Ticket lưu trữ danh tính điện tử mã hóa đối chiếu vé điện tử tại cửa soát vé QR code. Hãy cập nhật chính xác để đối soát danh tính khi tham gia các sự kiện lớn.
                                    </p>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="col-12 pt-3 border-top d-flex flex-wrap align-items-center justify-content-between gap-2" style="border-color: var(--lt-surface-border)!important;">
                                <a href="${ctx}/home#events" class="btn-lt-secondary">
                                    <i class="ph ph-ticket" style="font-size:18px;" aria-hidden="true"></i>
                                    Mua vé sự kiện
                                </a>

                                <div class="d-flex align-items-center gap-2">
                                    <a href="${ctx}/CustomerProfileController" class="btn btn-light" style="font-weight:600;font-size:0.875rem;padding:0.6rem 1.25rem;border-radius:var(--lt-radius-sm);">
                                        Hủy bỏ
                                    </a>
                                    <button type="submit" class="btn-lt-primary">
                                        <i class="ph ph-floppy-disk" style="font-size:18px;" aria-hidden="true"></i>
                                        Lưu thay đổi
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </section>
        </div>
    </main>

    <!-- ======================================================================
         FOOTER
         ====================================================================== -->
    <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
