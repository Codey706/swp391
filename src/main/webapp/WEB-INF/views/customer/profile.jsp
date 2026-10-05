<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Light Ticket</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Material Symbols -->
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">

    <style>
        /* ===== Giữ nguyên số đo của giao diện Tailwind cũ ===== */
        :root {
            --o: #ff7043;
            --o-light: #fff1ec;
            --bs-body-font-family: ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
            --bs-body-font-size: 16px;
            --bs-body-line-height: 1.5;
            --bs-body-color: #1f2937;
        }
        body { min-height: 100vh; }
        h1, h2, h3 { font-size: inherit; font-weight: inherit; line-height: inherit; }
        h1, h2, h3, p { margin: 0; }
        a { color: inherit; text-decoration: none; }
        .t-xs { font-size: 12px; line-height: 16px; }
        .t-sm { font-size: 14px; line-height: 20px; }
        .t-lg { font-size: 18px; line-height: 28px; }
        .t-xl { font-size: 20px; line-height: 28px; }
        .fw-medium { font-weight: 500; }
        .g-3px { gap: 12px; } .g-2px { gap: 8px; } .g-4px { gap: 16px; }
        .shadow-tw { box-shadow: 0 1px 2px 0 rgb(0 0 0 / .05); }
        .c-o { color: var(--o); } .c-g400 { color: #9ca3af; } .c-g500 { color: #6b7280; }
        .c-g800 { color: #1f2937; } .c-g900 { color: #111827; }
        .bg-o { background: var(--o); } .bg-ol { background: var(--o-light); }
        .circle { border-radius: 50%; }
        .ico-box { display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .ms-18 { font-size: 18px; line-height: 28px; } .ms-14 { font-size: 14px; line-height: 20px; } .ms-36 { font-size: 36px; line-height: 40px; }

        body { background: #f8f9fc; }
        .p-container { max-width: 80rem; margin: 0 auto; padding-left: 24px; padding-right: 24px; }
        @media (min-width: 1024px) { .p-container { padding-left: 40px; padding-right: 40px; } }
        .p-header { background: #fff; border-bottom: 1px solid #f3f4f6; position: sticky; top: 0; z-index: 40; }
        .p-header-in { height: 80px; }
        .p-nav a { font-size: 14px; line-height: 20px; font-weight: 500; color: #6b7280; transition: color .15s; }
        .p-nav a:hover { color: var(--o); }
        .p-nav a.on { color: var(--o); }
        .md-flex, .sm-flex, .sm-block { display: none !important; }
        @media (min-width: 640px) { .sm-flex { display: flex !important; } .sm-block { display: block !important; } }
        @media (min-width: 768px) { .md-flex { display: flex !important; } }
        .bell { width: 40px; height: 40px; border: 0; border-radius: 50%; background: #f9fafb; align-items: center; justify-content: center; transition: background .15s; }
        .bell:hover { background: var(--o-light); }
        .vline { width: 1px; height: 36px; background: #e5e7eb; }
        .p-main { padding-top: 40px; padding-bottom: 40px; }
        .p-h1 { font-size: 30px; line-height: 36px; font-weight: 700; color: #111827; }
        @media (min-width: 1024px) { .p-h1 { font-size: 36px; line-height: 40px; } }
        .p-sec { padding: 24px; }
        @media (min-width: 1024px) { .p-sec { padding: 32px; } }
        .p-card { background: #fff; border: 1px solid #f3f4f6; border-radius: 16px; box-shadow: 0 1px 2px 0 rgb(0 0 0 / .05); }
        .cover { height: 112px; background: linear-gradient(to right, #ff7043, #ff9678); position: relative; }
        .cover-av { position: absolute; left: 50%; bottom: -40px; transform: translateX(-50%); width: 80px; height: 80px;
                    border-radius: 50%; background: #fff; padding: 4px; box-shadow: 0 10px 15px -3px rgb(0 0 0 / .1), 0 4px 6px -4px rgb(0 0 0 / .1); }
        .pill-ok { display: inline-flex; align-items: center; gap: 8px; padding: 6px 12px; border-radius: 9999px;
                   background: #ecfdf5; color: #059669; font-size: 12px; line-height: 16px; font-weight: 600; }
        .dot { display: inline-block; border-radius: 50%; background: #10b981; }
        .sep { border-top: 1px solid #f3f4f6; margin: 24px 0; }
        .menu-title { padding: 8px 12px; font-size: 12px; line-height: 16px; font-weight: 600; color: #9ca3af;
                      text-transform: uppercase; letter-spacing: .05em; }
        .menu-item { display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 12px;
                     font-size: 14px; line-height: 20px; color: #6b7280; transition: background .15s, color .15s; }
        .menu-item:hover { background: #f9fafb; color: var(--o); }
        .menu-item.on, .menu-item.on:hover { background: var(--o-light); color: var(--o); font-weight: 600; }
        .banner { position: relative; overflow: hidden; border-radius: 16px; padding: 28px; color: #fff;
                  background: linear-gradient(to right, #ff7043, #ff9678); }
        .banner .deco { position: absolute; border-radius: 50%; background: rgb(255 255 255 / .1); }
        .info { border: 1px solid #f3f4f6; background: rgb(249 250 251 / .7); border-radius: 12px; padding: 16px; height: 100%; }
        .info-label { font-size: 12px; line-height: 16px; font-weight: 600; color: #9ca3af; text-transform: uppercase; }
        .sec-item { display: flex; align-items: center; justify-content: space-between; padding: 16px; border-radius: 12px;
                    background: #f9fafb; border: 1px solid #f3f4f6; }
        .quick { background: #fff8f5; border: 1px solid #ffe0d6; border-radius: 16px; padding: 24px; }
        .pbtn { --bs-btn-padding-x: 16px; --bs-btn-padding-y: 10px; --bs-btn-font-size: 14px; --bs-btn-font-weight: 600;
                --bs-btn-line-height: 20px; --bs-btn-border-radius: 12px; transition: background-color .15s, color .15s; }
        .pbtn-fill { --bs-btn-color: #fff; --bs-btn-bg: var(--o); --bs-btn-border-width: 0;
                     --bs-btn-hover-color: #fff; --bs-btn-hover-bg: #e85d32; --bs-btn-active-color: #fff; --bs-btn-active-bg: #e85d32;
                     box-shadow: 0 1px 2px 0 rgb(0 0 0 / .05); }
        .pbtn-line { --bs-btn-padding-x: 20px; --bs-btn-color: var(--o); --bs-btn-bg: #fff; --bs-btn-border-color: var(--o);
                     --bs-btn-hover-color: #fff; --bs-btn-hover-bg: var(--o); --bs-btn-hover-border-color: var(--o);
                     --bs-btn-active-color: #fff; --bs-btn-active-bg: var(--o); --bs-btn-active-border-color: var(--o); }
        .p-footer { background: #fff; border-top: 1px solid #f3f4f6; margin-top: 40px; }
        .p-footer a { font-size: 12px; line-height: 16px; color: #9ca3af; }
        .p-footer a:hover { color: var(--o); }
    </style>
</head>

<body>

    <!-- ========================================================= HEADER ========================================================= -->
    <header class="p-header">
        <div class="p-container">
            <div class="p-header-in d-flex align-items-center justify-content-between">

                <!-- LOGO -->
                <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center g-3px">
                    <div class="ico-box bg-o text-white" style="width:40px;height:40px;border-radius:12px;box-shadow:0 1px 2px 0 rgb(0 0 0 / .05)">
                        <span class="material-symbols-outlined">confirmation_number</span>
                    </div>
                    <div>
                        <div class="t-xl fw-bold c-g900">Light Ticket</div>
                        <div class="t-xs c-g400">Event Ticket Platform</div>
                    </div>
                </a>

                <!-- NAVIGATION -->
                <nav class="p-nav md-flex align-items-center" style="gap:32px">
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                    <a href="#">Sự kiện</a>
                    <a href="#">Vé của tôi</a>
                    <a href="#" class="on">Hồ sơ</a>
                </nav>

                <!-- USER -->
                <div class="d-flex align-items-center g-3px">
                    <button type="button" class="bell sm-flex">
                        <span class="material-symbols-outlined" style="color:#4b5563">notifications</span>
                    </button>
                    <div class="vline sm-block"></div>
                    <div class="d-flex align-items-center g-3px">
                        <div class="ico-box circle bg-o text-white" style="width:40px;height:40px">
                            <span class="material-symbols-outlined">person</span>
                        </div>
                        <div class="sm-block">
                            <p class="t-sm fw-semibold">${user.fullName}</p>
                            <p class="t-xs c-g400">${user.role}</p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </header>


    <!-- ========================================================= MAIN ========================================================= -->
    <main class="p-container p-main">

        <!-- PAGE HEADER -->
        <div style="margin-bottom:32px">
            <div class="d-flex align-items-center g-2px t-sm c-g400" style="margin-bottom:12px">
                <span>Trang chủ</span>
                <span class="material-symbols-outlined ms-14">chevron_right</span>
                <span class="c-o">Hồ sơ cá nhân</span>
            </div>
            <h1 class="p-h1">Hồ sơ cá nhân</h1>
            <p class="c-g500" style="margin-top:8px">Quản lý và xem thông tin tài khoản của bạn.</p>
        </div>


        <!-- ===================================================== PROFILE LAYOUT ====================================================== -->
        <div class="row" style="--bs-gutter-x:24px;--bs-gutter-y:24px">

            <!-- ================================================= LEFT SIDEBAR ================================================== -->
            <aside class="col-lg-4">

                <!-- PROFILE SUMMARY -->
                <div class="p-card overflow-hidden">
                    <div class="cover">
                        <div class="cover-av">
                            <div class="ico-box circle bg-ol w-100 h-100">
                                <span class="material-symbols-outlined c-o ms-36">person</span>
                            </div>
                        </div>
                    </div>

                    <div class="text-center" style="padding:56px 24px 24px">
                        <h2 class="t-xl fw-bold c-g900">${user.fullName}</h2>
                        <p class="t-sm c-g400" style="margin-top:4px">@${user.username}</p>

                        <div class="pill-ok" style="margin-top:16px">
                            <span class="dot" style="width:8px;height:8px"></span> ${user.status}
                        </div>

                        <div class="sep"></div>

                        <div class="text-start d-flex flex-column g-4px">
                        <div class="d-flex align-items-start g-3px">
                            <div class="ico-box bg-ol" style="width:36px;height:36px;border-radius:8px">
                                <span class="material-symbols-outlined c-o ms-18">mail</span>
                            </div>
                            <div style="min-width:0">
                                <p class="t-xs c-g400">Email</p>
                                <p class="t-sm fw-medium c-g800 text-break">${user.email}</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-start g-3px">
                            <div class="ico-box bg-ol" style="width:36px;height:36px;border-radius:8px">
                                <span class="material-symbols-outlined c-o ms-18">phone</span>
                            </div>
                            <div style="min-width:0">
                                <p class="t-xs c-g400">Số điện thoại</p>
                                <p class="t-sm fw-medium c-g800">${empty user.phone ? "Chưa cập nhật" : user.phone}</p>
                            </div>
                        </div>
                        <div class="d-flex align-items-start g-3px">
                            <div class="ico-box bg-ol" style="width:36px;height:36px;border-radius:8px">
                                <span class="material-symbols-outlined c-o ms-18">location_on</span>
                            </div>
                            <div style="min-width:0">
                                <p class="t-xs c-g400">Địa chỉ</p>
                                <p class="t-sm fw-medium c-g800">${empty user.address ? "Chưa cập nhật" : user.address}</p>
                            </div>
                        </div>
                        </div>
                    </div>
                </div>

                <!-- ACCOUNT MENU -->
                <div class="p-card" style="margin-top:24px;padding:12px">
                    <div class="menu-title">Tài khoản</div>
                    <a href="#" class="menu-item on">
                        <span class="material-symbols-outlined">person</span> Thông tin cá nhân
                    </a>
                    <a href="#" class="menu-item">
                        <span class="material-symbols-outlined">confirmation_number</span> Vé của tôi
                    </a>
                    <a href="#" class="menu-item">
                        <span class="material-symbols-outlined">favorite</span> Sự kiện yêu thích
                    </a>
                    <a href="#" class="menu-item">
                        <span class="material-symbols-outlined">settings</span> Cài đặt
                    </a>
                </div>

            </aside>


            <!-- ================================================= RIGHT CONTENT ================================================== -->
            <section class="col-lg-8 d-flex flex-column" style="gap:24px">

                <!-- WELCOME BANNER -->
                <div class="banner">
                    <div class="position-relative" style="z-index:10">
                        <div class="d-flex align-items-center g-2px t-sm" style="opacity:.9;margin-bottom:8px">
                            <span class="material-symbols-outlined ms-18">waving_hand</span> Chào mừng trở lại!
                        </div>
                        <h2 class="fw-bold" style="font-size:24px;line-height:32px">Xin chào, ${user.fullName}!</h2>
                        <p class="t-sm" style="margin-top:8px;opacity:.9;max-width:32rem">
                            Đây là khu vực quản lý thông tin cá nhân của bạn trên Light Ticket.
                        </p>
                    </div>
                    <div class="deco" style="width:192px;height:192px;right:-40px;bottom:-64px"></div>
                    <div class="deco" style="width:112px;height:112px;right:80px;top:-48px"></div>
                    <span class="material-symbols-outlined position-absolute" style="right:32px;bottom:28px;font-size:72px;line-height:1;color:rgb(255 255 255 / .2)">confirmation_number</span>
                </div>

                <!-- PERSONAL INFORMATION -->
                <section class="p-card p-sec">
                    <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-sm-between g-4px" style="margin-bottom:28px">
                        <div class="d-flex align-items-center g-3px">
                            <div class="ico-box bg-ol" style="width:40px;height:40px;border-radius:12px">
                                <span class="material-symbols-outlined c-o">badge</span>
                            </div>
                            <div>
                                <h2 class="t-xl fw-bold c-g900">Thông tin cá nhân</h2>
                                <p class="t-sm c-g400" style="margin-top:2px">Thông tin tài khoản hiện tại</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/UpdateCustomerProfileController"
                           class="btn pbtn pbtn-fill d-inline-flex align-items-center justify-content-center g-2px">
                            <span class="material-symbols-outlined ms-18">edit</span> Chỉnh sửa thông tin
                        </a>
                    </div>

                    <div class="row" style="--bs-gutter-x:20px;--bs-gutter-y:20px">
                        <div class="col-md-6">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">person</span>
                                    <p class="info-label">Họ và tên</p>
                                </div>
                                <p class="fw-semibold c-g800">${user.fullName}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">alternate_email</span>
                                    <p class="info-label">Tên đăng nhập</p>
                                </div>
                                <p class="fw-semibold c-g800">${user.username}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">mail</span>
                                    <p class="info-label">Email</p>
                                </div>
                                <p class="fw-semibold c-g800 text-break">${user.email}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">phone</span>
                                    <p class="info-label">Số điện thoại</p>
                                </div>
                                <p class="fw-semibold c-g800">${empty user.phone ? "Chưa cập nhật" : user.phone}</p>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">location_on</span>
                                    <p class="info-label">Địa chỉ</p>
                                </div>
                                <p class="fw-semibold c-g800">${empty user.address ? "Chưa cập nhật" : user.address}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">manage_accounts</span>
                                    <p class="info-label">Vai trò</p>
                                </div>
                                <p class="fw-semibold c-g800">${user.role}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info">
                                <div class="d-flex align-items-center g-2px" style="margin-bottom:8px">
                                    <span class="material-symbols-outlined c-g400 ms-18">verified_user</span>
                                    <p class="info-label">Trạng thái</p>
                                </div>
                                <div class="d-flex align-items-center g-2px"><span class="dot" style="width:10px;height:10px"></span><p class="fw-semibold" style="color:#059669">${user.status}</p></div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- ACCOUNT SECURITY -->
                <section class="p-card p-sec">
                    <div class="d-flex align-items-center g-3px" style="margin-bottom:24px">
                        <div class="ico-box" style="width:40px;height:40px;border-radius:12px;background:#eff6ff">
                            <span class="material-symbols-outlined" style="color:#3b82f6">security</span>
                        </div>
                        <div>
                            <h2 class="t-lg fw-bold c-g900">Bảo mật tài khoản</h2>
                            <p class="t-sm c-g400">Thông tin liên quan đến tài khoản của bạn.</p>
                        </div>
                    </div>

                    <div class="row" style="--bs-gutter-x:16px;--bs-gutter-y:16px">
                        <div class="col-md-6">
                            <div class="sec-item">
                                <div class="d-flex align-items-center g-3px">
                                    <span class="material-symbols-outlined c-g500">lock</span>
                                    <div>
                                        <p class="t-sm fw-semibold">Mật khẩu</p>
                                        <p class="t-xs c-g400">Được bảo vệ</p>
                                    </div>
                                </div>
                                <span class="t-xs fw-semibold" style="color:#059669">Đã thiết lập</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="sec-item">
                                <div class="d-flex align-items-center g-3px">
                                    <span class="material-symbols-outlined c-g500">verified</span>
                                    <div>
                                        <p class="t-sm fw-semibold">Tài khoản</p>
                                        <p class="t-xs c-g400">Trạng thái hiện tại</p>
                                    </div>
                                </div>
                                <span class="t-xs fw-semibold" style="color:#059669">${user.status}</span>
                            </div>
                        </div>
                    </div>
                </section>            

            </section>
        </div>
    </main>


    <!-- ========================================================= FOOTER ========================================================= -->
    <footer class="p-footer">
        <div class="p-container" style="padding-top:32px;padding-bottom:32px">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-md-between g-4px">
                <div class="d-flex align-items-center g-2px">
                    <div class="ico-box bg-o text-white" style="width:32px;height:32px;border-radius:8px">
                        <span class="material-symbols-outlined ms-18">confirmation_number</span>
                    </div>
                    <span class="fw-bold c-g800">Light Ticket</span>
                </div>
                <p class="t-xs c-g400">© 2025 Light Ticket Joint Stock Co. Bảo lưu mọi quyền.</p>
                <div class="d-flex align-items-center" style="gap:20px">
                    <a href="#">Điều khoản</a>
                    <a href="#">Chính sách bảo mật</a>
                    <a href="#">Liên hệ</a>
                </div>
            </div>
        </div>
    </footer>

</body>
</html>
