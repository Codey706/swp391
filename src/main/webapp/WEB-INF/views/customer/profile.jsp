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
    <title>Hồ sơ cá nhân - Light Ticket</title>

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
        
        <!-- Breadcrumb -->
        <nav aria-label="Breadcrumb" class="lt-breadcrumb">
            <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                <i class="ph ph-house" style="font-size:16px;" aria-hidden="true"></i>
                Trang chủ
            </a>
            <i class="ph ph-caret-right separator" aria-hidden="true"></i>
            <span class="active">Hồ sơ cá nhân</span>
        </nav>

        <!-- Page Header Card -->
        <div class="lt-card p-4 mb-4">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
                <div>
                    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                        <h1 class="h3 fw-bold text-dark mb-0">Hồ sơ cá nhân của tôi</h1>
                        <span class="lt-pill lt-pill-vip">
                            <i class="ph ph-medal" style="font-size:14px;" aria-hidden="true"></i>
                            Thành viên <c:out value="${user.role}"/>
                        </span>
                    </div>
                    <p class="text-secondary mb-0 small">
                        Quản lý thông tin định danh khách hàng, cập nhật tài khoản và bảo mật mật khẩu.
                    </p>
                </div>
                <div class="d-flex flex-wrap align-items-center gap-2">
                    <a href="${ctx}/UpdateCustomerProfileController" class="btn-lt-primary">
                        <i class="ph ph-pencil-simple" style="font-size:18px;" aria-hidden="true"></i>
                        Chỉnh sửa hồ sơ
                    </a>
                    <a href="${ctx}/Auth?action=changePassword" class="btn-lt-secondary">
                        <i class="ph ph-lock-key" style="font-size:18px;" aria-hidden="true"></i>
                        ${sessionScope.user.passwordSet ? 'Đổi mật khẩu' : 'Thiết lập mật khẩu'}
                    </a>
                </div>
            </div>
        </div>

        <!-- 2-Column Desktop Grid Layout -->
        <div class="row g-4 align-items-start">
            
            <!-- LEFT COLUMN: Account Sidebar Navigation & ID Summary Card -->
            <aside class="col-lg-4">
                <!-- User ID Card -->
                <div class="lt-card overflow-hidden text-center mb-4">
                    <div style="height: 90px; background: #141414; position: relative;"></div>
                    
                    <div class="position-relative px-4 pb-4">
                        <!-- Avatar -->
                        <div class="position-relative d-inline-block" style="margin-top: -45px; margin-bottom: 12px;">
                            <div class="lt-avatar-round border border-4 border-white shadow-sm" style="width: 86px; height: 86px; font-size: 2rem;">
                                <span>${userInitial}</span>
                            </div>
                            <a href="${ctx}/UpdateCustomerProfileController" class="position-absolute bottom-0 end-0 btn btn-sm btn-primary rounded-circle p-1 d-flex align-items-center justify-content-center text-white shadow" style="width:28px;height:28px;background:var(--lt-primary);border:2px solid #fff;" title="Chỉnh sửa thông tin">
                                <i class="ph ph-camera" style="font-size:15px;" aria-hidden="true"></i>
                            </a>
                        </div>

                        <!-- Name & Role -->
                        <h2 class="h5 fw-bold text-dark mb-1">
                            <c:out value="${user.fullName}"/>
                            <i class="ph ph-seal-check text-primary align-middle" style="font-size:18px;color:var(--lt-primary)!important;" title="Tài khoản chính thức" aria-hidden="true"></i>
                        </h2>
                        <p class="text-secondary small mb-2"><c:out value="${user.email}"/></p>
                        
                        <div class="mb-3">
                            <span class="lt-pill lt-pill-paid">
                                <i class="ph ph-check-circle" style="font-size:13px;" aria-hidden="true"></i>
                                Trạng thái: <c:out value="${user.status}"/>
                            </span>
                        </div>

                        <hr class="my-3" style="border-color: var(--lt-surface-border);">

                        <!-- Contact Quick Info -->
                        <div class="text-start d-flex flex-column gap-2 small">
                            <div class="d-flex align-items-center gap-2 text-secondary">
                                <i class="ph ph-envelope-simple text-muted" style="font-size:18px;" aria-hidden="true"></i>
                                <span class="text-break"><c:out value="${user.email}"/></span>
                            </div>
                            <div class="d-flex align-items-center gap-2 text-secondary">
                                <i class="ph ph-phone text-muted" style="font-size:18px;" aria-hidden="true"></i>
                                <span><c:out value="${empty user.phone ? 'Chưa cập nhật SĐT' : user.phone}"/></span>
                            </div>
                            <div class="d-flex align-items-start gap-2 text-secondary">
                                <i class="ph ph-map-pin text-muted mt-1" style="font-size:18px;" aria-hidden="true"></i>
                                <span><c:out value="${empty user.address ? 'Chưa cập nhật địa chỉ' : user.address}"/></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Account Navigation Menu Card -->
                <div class="lt-card p-3">
                    <div class="lt-sidebar-nav-title">Danh mục tài khoản</div>
                    <nav class="lt-sidebar-nav">
                        <a href="${ctx}/CustomerProfileController" class="lt-sidebar-item active">
                            <div class="item-left">
                                <i class="ph ph-user" style="font-size:19px;" aria-hidden="true"></i>
                                <span>Hồ sơ của tôi</span>
                            </div>
                            <i class="ph ph-caret-right text-muted" style="font-size:16px;" aria-hidden="true"></i>
                        </a>

                        <a href="${ctx}/UpdateCustomerProfileController" class="lt-sidebar-item">
                            <div class="item-left">
                                <i class="ph ph-pencil-simple-line" style="font-size:19px;" aria-hidden="true"></i>
                                <span>Chỉnh sửa thông tin</span>
                            </div>
                            <i class="ph ph-caret-right text-muted" style="font-size:16px;" aria-hidden="true"></i>
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

            <!-- RIGHT COLUMN: Account Details & Security Cards -->
            <section class="col-lg-8 d-flex flex-column gap-4">
                
                <!-- Welcome Banner Card -->
                <div class="lt-card p-4 text-white position-relative overflow-hidden" style="background: #141414;">
                    <div class="position-relative" style="z-index: 2;">
                        <div class="d-flex align-items-center gap-2 mb-2 opacity-75 small">
                            <i class="ph ph-hand-waving" style="font-size:18px;" aria-hidden="true"></i>
                            <span>Xin chào trở lại!</span>
                        </div>
                        <h2 class="h4 fw-bold mb-2">Xin chào, <c:out value="${user.fullName}"/>!</h2>
                        <p class="mb-0 opacity-90 small" style="max-width: 32rem;">
                            Đây là khu vực quản lý thông tin định danh khách hàng trên Light Ticket. Hãy đảm bảo thông tin của bạn luôn chính xác để việc nhận vé điện tử và check-in sự kiện diễn ra thuận tiện.
                        </p>
                    </div>
                    <i class="ph ph-identification-badge position-absolute" style="right: 20px; bottom: 10px; font-size: 110px; opacity: 0.12; pointer-events: none;" aria-hidden="true"></i>
                </div>

                <!-- Personal Information Grid Card -->
                <div class="lt-card p-4">
                    <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-3 pb-3 mb-3 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                        <div class="d-flex align-items-center gap-3">
                            <div class="d-flex align-items-center justify-content-center rounded-3 p-2" style="background: var(--lt-primary-fixed); color: var(--lt-primary);">
                                <i class="ph ph-identification-badge" style="font-size:22px;" aria-hidden="true"></i>
                            </div>
                            <div>
                                <h3 class="h6 fw-bold text-dark mb-0">Thông tin cá nhân</h3>
                                <p class="text-secondary small mb-0">Chi tiết tài khoản hiện tại trên hệ thống</p>
                            </div>
                        </div>
                        <a href="${ctx}/UpdateCustomerProfileController" class="btn-lt-secondary btn-sm">
                            <i class="ph ph-pencil-simple" style="font-size:16px;" aria-hidden="true"></i>
                            Chỉnh sửa
                        </a>
                    </div>

                    <div class="row g-3">
                        <!-- Họ và tên -->
                        <div class="col-md-6">
                            <div class="p-3 rounded-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                <span class="text-secondary d-block small mb-1">Họ và tên</span>
                                <strong class="text-dark"><c:out value="${user.fullName}"/></strong>
                            </div>
                        </div>

                        <!-- Tên đăng nhập -->
                        <div class="col-md-6">
                            <div class="p-3 rounded-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                <span class="text-secondary d-block small mb-1">Tên đăng nhập</span>
                                <strong class="text-dark"><c:out value="${user.username}"/></strong>
                            </div>
                        </div>

                        <!-- Email nhận vé -->
                        <div class="col-md-6">
                            <div class="p-3 rounded-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                <span class="text-secondary d-block small mb-1">Email nhận vé điện tử</span>
                                <strong class="text-dark text-break"><c:out value="${user.email}"/></strong>
                            </div>
                        </div>

                        <!-- Số điện thoại -->
                        <div class="col-md-6">
                            <div class="p-3 rounded-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                <span class="text-secondary d-block small mb-1">Số điện thoại liên hệ</span>
                                <strong class="text-dark"><c:out value="${empty user.phone ? 'Chưa cập nhật' : user.phone}"/></strong>
                            </div>
                        </div>

                        <!-- Địa chỉ -->
                        <div class="col-12">
                            <div class="p-3 rounded-3" style="background-color: var(--lt-surface-low); border: 1px solid var(--lt-surface-border);">
                                <span class="text-secondary d-block small mb-1">Địa chỉ</span>
                                <strong class="text-dark"><c:out value="${empty user.address ? 'Chưa cập nhật địa chỉ' : user.address}"/></strong>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Security & Notice Card -->
                <div class="lt-card p-3 p-md-4 d-flex align-items-start gap-3" style="background-color: #e7f6ee; border-color: #bfe3cf;">
                    <i class="ph ph-shield-check text-success mt-1" style="font-size:24px;" aria-hidden="true"></i>
                    <div class="small text-secondary">
                        <strong class="text-dark d-block mb-1">Bảo mật thông tin & Định danh vé điện tử</strong>
                        Hệ thống Light Ticket bảo vệ an toàn thông tin khách hàng, sử dụng dữ liệu định danh để đối chiếu và phát hành mã QR check-in tại cổng sự kiện.
                    </div>
                </div>

                <!-- Quick Navigation Action Banner -->
                <div class="lt-card p-4 d-flex flex-column flex-sm-row align-items-center justify-content-between gap-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="d-flex align-items-center justify-content-center rounded-circle p-3" style="background: var(--lt-primary-fixed); color: var(--lt-primary);">
                            <i class="ph ph-ticket" style="font-size:24px;" aria-hidden="true"></i>
                        </div>
                        <div>
                            <h4 class="h6 fw-bold text-dark mb-1">Bạn muốn kiểm tra vé hoặc đặt vé mới?</h4>
                            <p class="text-secondary small mb-0">Xem danh sách các đơn hàng đã mua hoặc khám phá sự kiện hot đang mở bán.</p>
                        </div>
                    </div>
                    <div class="d-flex gap-2 flex-shrink-0">
                        <a href="${ctx}/customer/booking-history" class="btn-lt-secondary btn-sm">Vé của tôi</a>
                        <a href="${ctx}/home#events" class="btn-lt-primary btn-sm">Mua vé ngay</a>
                    </div>
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
