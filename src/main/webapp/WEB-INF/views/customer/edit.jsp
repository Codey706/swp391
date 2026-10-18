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
    <title>Chỉnh sửa hồ sơ cá nhân - Light Ticketbox</title>

    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com" rel="preconnect"/>
    <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>

    <!-- Material Symbols Outlined -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Stitch Design System CSS -->
    <link rel="stylesheet" href="${ctx}/assets/css/stitch-custom.css">
</head>

<body class="lt-body d-flex flex-column min-vh-100">

    <!-- ======================================================================
         HEADER (STITCH COMPATIBLE)
         ====================================================================== -->
    <header class="lt-navbar">
        <div class="container-xl d-flex align-items-center justify-content-between gap-3">
            <!-- Brand Logo -->
            <a class="lt-brand-logo" href="${ctx}/">
                <div class="lt-brand-icon">
                    <span class="material-symbols-outlined">confirmation_number</span>
                </div>
                <span class="lt-brand-title">Light <span>Ticketbox</span></span>
            </a>

            <!-- Navigation Links -->
            <nav class="d-none d-lg-flex align-items-center gap-1">
                <a class="lt-nav-link" href="${ctx}/">Trang chủ</a>
                <a class="lt-nav-link" href="${ctx}/home#events">Khám phá sự kiện</a>
                <a class="lt-nav-link" href="${ctx}/customer/booking-history">Vé của tôi</a>
            </nav>

            <!-- Search Bar -->
            <div class="lt-search-box d-none d-md-block">
                <span class="material-symbols-outlined search-icon">search</span>
                <input type="search" placeholder="Tìm kiếm sự kiện, nghệ sĩ, địa điểm...">
            </div>

            <!-- User Menu -->
            <div class="dropdown">
                <button class="lt-user-btn" type="button" id="userMenuDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <div class="lt-avatar-round">
                        <span>${userInitial}</span>
                    </div>
                    <div class="lt-user-info-text d-none d-sm-block">
                        <span class="lt-user-name"><c:out value="${empty user.fullName ? user.username : user.fullName}"/></span>
                        <span class="lt-user-tier"><c:out value="${empty user.role ? 'Khách hàng' : user.role}"/></span>
                    </div>
                    <span class="material-symbols-outlined text-secondary d-none d-sm-inline" style="font-size:18px;">expand_more</span>
                </button>

                <ul class="dropdown-menu dropdown-menu-end lt-dropdown-menu" aria-labelledby="userMenuDropdown">
                    <li class="lt-dropdown-header d-sm-none">
                        <p class="fw-bold mb-0 text-dark small"><c:out value="${user.fullName}"/></p>
                        <span class="text-secondary small"><c:out value="${user.role}"/></span>
                    </li>
                    <li>
                        <a class="lt-dropdown-item" href="${ctx}/CustomerProfileController">
                            <span class="material-symbols-outlined text-secondary" style="font-size:18px;">account_circle</span>
                            Hồ sơ của tôi
                        </a>
                    </li>
                    <li>
                        <a class="lt-dropdown-item" href="${ctx}/customer/booking-history">
                            <span class="material-symbols-outlined text-secondary" style="font-size:18px;">local_activity</span>
                            Vé của tôi
                        </a>
                    </li>
                    <li><hr class="dropdown-divider my-1"></li>
                    <li>
                        <form action="${ctx}/logout" method="POST" class="m-0">
                            <button type="submit" class="lt-dropdown-item danger border-0 bg-transparent w-100 text-start">
                                <span class="material-symbols-outlined" style="font-size:18px;">logout</span>
                                Đăng xuất
                            </button>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </header>

    <!-- ======================================================================
         MAIN CONTENT
         ====================================================================== -->
    <main class="container-xl py-4 flex-grow-1">

        <!-- Top Breadcrumb & Quick Back Navigation -->
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3">
            <nav aria-label="Breadcrumb" class="lt-breadcrumb mb-0">
                <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                    <span class="material-symbols-outlined" style="font-size:16px;">home</span>
                    Trang chủ
                </a>
                <span class="material-symbols-outlined separator">chevron_right</span>
                <a href="${ctx}/CustomerProfileController">Tài khoản của tôi</a>
                <span class="material-symbols-outlined separator">chevron_right</span>
                <span class="active">Chỉnh sửa hồ sơ</span>
            </nav>

            <div class="d-flex align-items-center gap-2">
                <a href="${ctx}/home#events" class="btn-lt-primary btn-sm">
                    <span class="material-symbols-outlined" style="font-size:18px;">local_activity</span>
                    Mua vé ngay
                </a>
                <a href="${ctx}/CustomerProfileController" class="btn-lt-secondary btn-sm">
                    <span class="material-symbols-outlined" style="font-size:18px;">arrow_back</span>
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
                            <span class="material-symbols-outlined" style="font-size:14px;">workspace_premium</span>
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
                        <span class="material-symbols-outlined text-primary align-middle" style="font-size:18px;color:var(--lt-primary)!important;" title="Tài khoản đã xác thực">verified</span>
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
                                <span class="material-symbols-outlined" style="font-size:19px;">person</span>
                                <span>Hồ sơ của tôi</span>
                            </div>
                            <span class="material-symbols-outlined text-muted" style="font-size:16px;">chevron_right</span>
                        </a>

                        <a href="${ctx}/UpdateCustomerProfileController" class="lt-sidebar-item active">
                            <div class="item-left">
                                <span class="material-symbols-outlined" style="font-size:19px;">edit_square</span>
                                <span>Chỉnh sửa thông tin</span>
                            </div>
                            <span class="badge bg-danger rounded-pill" style="font-size:10px;background:var(--lt-primary)!important;">Đang sửa</span>
                        </a>

                        <a href="${ctx}/customer/booking-history" class="lt-sidebar-item">
                            <div class="item-left">
                                <span class="material-symbols-outlined" style="font-size:19px;">confirmation_number</span>
                                <span>Vé của tôi</span>
                            </div>
                            <span class="material-symbols-outlined text-muted" style="font-size:16px;">chevron_right</span>
                        </a>

                        <a href="${ctx}/change-password" class="lt-sidebar-item">
                            <div class="item-left">
                                <span class="material-symbols-outlined" style="font-size:19px;">lock</span>
                                <span>Đổi mật khẩu</span>
                            </div>
                            <span class="material-symbols-outlined text-muted" style="font-size:16px;">open_in_new</span>
                        </a>
                    </nav>
                </div>
            </aside>

            <!-- RIGHT COLUMN: Form Edit (col-lg-8) -->
            <section class="col-lg-8">
                <div class="lt-card p-4">
                    <div class="d-flex align-items-center gap-3 pb-3 mb-4 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                        <div class="d-flex align-items-center justify-content-center rounded-3 p-2" style="background: var(--lt-primary-fixed); color: var(--lt-primary);">
                            <span class="material-symbols-outlined" style="font-size:22px;">edit_note</span>
                        </div>
                        <div>
                            <h3 class="h6 fw-bold text-dark mb-0">Biểu mẫu cập nhật hồ sơ</h3>
                            <p class="text-secondary small mb-0">Vui lòng điền đúng thông tin chính xác của bạn</p>
                        </div>
                    </div>

                    <form action="${ctx}/UpdateCustomerProfileController" method="post">
                        <div class="row g-3">
                            <!-- Họ và tên -->
                            <div class="col-md-6">
                                <label for="fullName" class="form-label small fw-bold text-dark">
                                    Họ và tên <span class="text-danger">*</span>
                                </label>
                                <input type="text" id="fullName" name="fullName" value="${user.fullName}" required class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm);">
                            </div>

                            <!-- Tên đăng nhập -->
                            <div class="col-md-6">
                                <label for="username" class="form-label small fw-bold text-secondary">
                                    Tên đăng nhập
                                </label>
                                <input type="text" id="username" value="${user.username}" disabled class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm); background-color: var(--lt-surface-low); cursor: not-allowed;">
                                <div class="form-text text-muted small" style="font-size: 11px;">Tên đăng nhập được dùng cố định cho tài khoản.</div>
                            </div>

                            <!-- Email nhận vé -->
                            <div class="col-md-6">
                                <label for="email" class="form-label small fw-bold text-dark">
                                    Email nhận vé điện tử <span class="text-danger">*</span>
                                </label>
                                <input type="email" id="email" name="email" value="${user.email}" required class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm);">
                                <div class="form-text text-muted small" style="font-size: 11px;">Vé và mã QR check-in sẽ được gửi tới email này.</div>
                            </div>

                            <!-- Số điện thoại -->
                            <div class="col-md-6">
                                <label for="phone" class="form-label small fw-bold text-dark">
                                    Số điện thoại liên hệ
                                </label>
                                <input type="tel" id="phone" name="phone" value="${user.phone}" class="form-control" style="height: 44px; border-radius: var(--lt-radius-sm);">
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
                                    <span class="material-symbols-outlined text-primary mt-0.5" style="font-size:20px;color:var(--lt-primary)!important;">security</span>
                                    <p class="small text-secondary mb-0">
                                        Hệ thống Light Ticketbox lưu trữ danh tính điện tử mã hóa đối chiếu vé điện tử tại cửa soát vé QR code. Hãy cập nhật chính xác để đối soát danh tính khi tham gia các sự kiện lớn.
                                    </p>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="col-12 pt-3 border-top d-flex flex-wrap align-items-center justify-content-between gap-2" style="border-color: var(--lt-surface-border)!important;">
                                <a href="${ctx}/home#events" class="btn-lt-secondary">
                                    <span class="material-symbols-outlined" style="font-size:18px;">confirmation_number</span>
                                    Mua vé sự kiện
                                </a>

                                <div class="d-flex align-items-center gap-2">
                                    <a href="${ctx}/CustomerProfileController" class="btn btn-light" style="font-weight:600;font-size:0.875rem;padding:0.6rem 1.25rem;border-radius:var(--lt-radius-sm);">
                                        Hủy bỏ
                                    </a>
                                    <button type="submit" class="btn-lt-primary">
                                        <span class="material-symbols-outlined" style="font-size:18px;">save</span>
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
    <footer class="lt-footer">
        <div class="container-xl d-flex flex-column flex-md-row align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <div class="lt-brand-icon" style="width:30px;height:30px;border-radius:8px;">
                    <span class="material-symbols-outlined" style="font-size:18px;">confirmation_number</span>
                </div>
                <span class="fw-bold text-dark">Light Ticketbox</span>
            </div>
            <div class="d-flex align-items-center gap-4 small">
                <a href="${ctx}/">Trang chủ</a>
                <a href="${ctx}/customer/booking-history">Vé của tôi</a>
                <a href="${ctx}/CustomerProfileController">Hồ sơ cá nhân</a>
            </div>
            <span class="text-secondary small">© 2026 Light Ticket. All rights reserved.</span>
        </div>
    </footer>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
