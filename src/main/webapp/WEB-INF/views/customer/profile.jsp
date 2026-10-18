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
    <title>Hồ sơ cá nhân - Light Ticketbox</title>

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
                <input type="search" placeholder="Tìm concert, kịch, workshop...">
            </div>

            <!-- Actions & User Profile -->
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-sm btn-light rounded-circle p-2 d-none d-sm-flex align-items-center justify-content-center text-secondary" title="Thông báo" style="width:38px;height:38px;">
                    <span class="material-symbols-outlined" style="font-size:20px;">notifications</span>
                </button>

                <!-- Avatar Dropdown -->
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
        </div>
    </header>

    <!-- ======================================================================
         MAIN CONTENT
         ====================================================================== -->
    <main class="container-xl py-4 flex-grow-1">
        
        <!-- Breadcrumb -->
        <nav aria-label="Breadcrumb" class="lt-breadcrumb">
            <a href="${ctx}/" class="d-inline-flex align-items-center gap-1">
                <span class="material-symbols-outlined" style="font-size:16px;">home</span>
                Trang chủ
            </a>
            <span class="material-symbols-outlined separator">chevron_right</span>
            <span class="active">Hồ sơ cá nhân</span>
        </nav>

        <!-- Page Header Card -->
        <div class="lt-card p-4 mb-4">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3">
                <div>
                    <div class="d-flex flex-wrap align-items-center gap-2 mb-1">
                        <h1 class="h3 fw-bold text-dark mb-0">Hồ sơ cá nhân của tôi</h1>
                        <span class="lt-pill lt-pill-vip">
                            <span class="material-symbols-outlined" style="font-size:14px;">workspace_premium</span>
                            Thành viên <c:out value="${user.role}"/>
                        </span>
                    </div>
                    <p class="text-secondary mb-0 small">
                        Quản lý thông tin định danh khách hàng, cập nhật tài khoản và bảo mật mật khẩu.
                    </p>
                </div>
                <div class="d-flex flex-wrap align-items-center gap-2">
                    <a href="${ctx}/UpdateCustomerProfileController" class="btn-lt-primary">
                        <span class="material-symbols-outlined" style="font-size:18px;">edit</span>
                        Chỉnh sửa hồ sơ
                    </a>
                    <a href="${ctx}/change-password" class="btn-lt-secondary">
                        <span class="material-symbols-outlined" style="font-size:18px;">lock_reset</span>
                        Đổi mật khẩu
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
                    <div style="height: 90px; background: linear-gradient(135deg, #ff7043, #ff9678); position: relative;"></div>
                    
                    <div class="position-relative px-4 pb-4">
                        <!-- Avatar -->
                        <div class="position-relative d-inline-block" style="margin-top: -45px; margin-bottom: 12px;">
                            <div class="lt-avatar-round border border-4 border-white shadow-sm" style="width: 86px; height: 86px; font-size: 2rem;">
                                <span>${userInitial}</span>
                            </div>
                            <a href="${ctx}/UpdateCustomerProfileController" class="position-absolute bottom-0 end-0 btn btn-sm btn-primary rounded-circle p-1 d-flex align-items-center justify-content-center text-white shadow" style="width:28px;height:28px;background:var(--lt-primary);border:2px solid #fff;" title="Chỉnh sửa thông tin">
                                <span class="material-symbols-outlined" style="font-size:15px;">photo_camera</span>
                            </a>
                        </div>

                        <!-- Name & Role -->
                        <h2 class="h5 fw-bold text-dark mb-1">
                            <c:out value="${user.fullName}"/>
                            <span class="material-symbols-outlined text-primary align-middle" style="font-size:18px;color:var(--lt-primary)!important;" title="Tài khoản chính thức">verified</span>
                        </h2>
                        <p class="text-secondary small mb-2"><c:out value="${user.email}"/></p>
                        
                        <div class="mb-3">
                            <span class="lt-pill lt-pill-paid">
                                <span class="material-symbols-outlined" style="font-size:13px;">check_circle</span>
                                Trạng thái: <c:out value="${user.status}"/>
                            </span>
                        </div>

                        <hr class="my-3" style="border-color: var(--lt-surface-border);">

                        <!-- Contact Quick Info -->
                        <div class="text-start d-flex flex-column gap-2 small">
                            <div class="d-flex align-items-center gap-2 text-secondary">
                                <span class="material-symbols-outlined text-muted" style="font-size:18px;">mail</span>
                                <span class="text-break"><c:out value="${user.email}"/></span>
                            </div>
                            <div class="d-flex align-items-center gap-2 text-secondary">
                                <span class="material-symbols-outlined text-muted" style="font-size:18px;">phone</span>
                                <span><c:out value="${empty user.phone ? 'Chưa cập nhật SĐT' : user.phone}"/></span>
                            </div>
                            <div class="d-flex align-items-start gap-2 text-secondary">
                                <span class="material-symbols-outlined text-muted mt-1" style="font-size:18px;">location_on</span>
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
                                <span class="material-symbols-outlined" style="font-size:19px;">person</span>
                                <span>Hồ sơ của tôi</span>
                            </div>
                            <span class="material-symbols-outlined text-muted" style="font-size:16px;">chevron_right</span>
                        </a>

                        <a href="${ctx}/UpdateCustomerProfileController" class="lt-sidebar-item">
                            <div class="item-left">
                                <span class="material-symbols-outlined" style="font-size:19px;">edit_square</span>
                                <span>Chỉnh sửa thông tin</span>
                            </div>
                            <span class="material-symbols-outlined text-muted" style="font-size:16px;">chevron_right</span>
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

            <!-- RIGHT COLUMN: Account Details & Security Cards -->
            <section class="col-lg-8 d-flex flex-column gap-4">
                
                <!-- Welcome Banner Card -->
                <div class="lt-card p-4 text-white position-relative overflow-hidden" style="background: linear-gradient(135deg, #ff5722 0%, #b02f00 100%);">
                    <div class="position-relative" style="z-index: 2;">
                        <div class="d-flex align-items-center gap-2 mb-2 opacity-75 small">
                            <span class="material-symbols-outlined" style="font-size:18px;">waving_hand</span>
                            <span>Xin chào trở lại!</span>
                        </div>
                        <h2 class="h4 fw-bold mb-2">Xin chào, <c:out value="${user.fullName}"/>!</h2>
                        <p class="mb-0 opacity-90 small" style="max-width: 32rem;">
                            Đây là khu vực quản lý thông tin định danh khách hàng trên Light Ticketbox. Hãy đảm bảo thông tin của bạn luôn chính xác để việc nhận vé điện tử và check-in sự kiện diễn ra thuận tiện.
                        </p>
                    </div>
                    <span class="material-symbols-outlined position-absolute" style="right: 20px; bottom: 10px; font-size: 110px; opacity: 0.12; pointer-events: none;">
                        badge
                    </span>
                </div>

                <!-- Personal Information Grid Card -->
                <div class="lt-card p-4">
                    <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between gap-3 pb-3 mb-3 border-bottom" style="border-color: var(--lt-surface-border)!important;">
                        <div class="d-flex align-items-center gap-3">
                            <div class="d-flex align-items-center justify-content-center rounded-3 p-2" style="background: var(--lt-primary-fixed); color: var(--lt-primary);">
                                <span class="material-symbols-outlined" style="font-size:22px;">badge</span>
                            </div>
                            <div>
                                <h3 class="h6 fw-bold text-dark mb-0">Thông tin cá nhân</h3>
                                <p class="text-secondary small mb-0">Chi tiết tài khoản hiện tại trên hệ thống</p>
                            </div>
                        </div>
                        <a href="${ctx}/UpdateCustomerProfileController" class="btn-lt-secondary btn-sm">
                            <span class="material-symbols-outlined" style="font-size:16px;">edit</span>
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
                <div class="lt-card p-3 p-md-4 d-flex align-items-start gap-3" style="background-color: #f0fdf4; border-color: #bbf7d0;">
                    <span class="material-symbols-outlined text-success mt-1" style="font-size:24px;">security</span>
                    <div class="small text-secondary">
                        <strong class="text-dark d-block mb-1">Bảo mật thông tin & Định danh vé điện tử</strong>
                        Hệ thống Light Ticketbox bảo vệ an toàn thông tin khách hàng, sử dụng dữ liệu định danh để đối chiếu và phát hành mã QR check-in tại cổng sự kiện.
                    </div>
                </div>

                <!-- Quick Navigation Action Banner -->
                <div class="lt-card p-4 d-flex flex-column flex-sm-row align-items-center justify-content-between gap-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="d-flex align-items-center justify-content-center rounded-circle p-3" style="background: var(--lt-primary-fixed); color: var(--lt-primary);">
                            <span class="material-symbols-outlined" style="font-size:24px;">confirmation_number</span>
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
