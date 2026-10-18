<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - Light Ticket</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <!-- Material Symbols -->
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">

    <style>
        :root {
            --o: #ff7043;
            --o-light: #fff1ec;
            --bs-body-font-family: 'Plus Jakarta Sans', ui-sans-serif, system-ui, sans-serif;
            --bs-body-font-size: 16px;
            --bs-body-line-height: 1.5;
            --bs-body-color: #1f2937;
        }
        body { min-height: 100vh; background: #f8f9fc; }
        h1, h2, h3, p { margin: 0; }
        a { color: inherit; text-decoration: none; }
        .t-xs { font-size: 12px; line-height: 16px; }
        .t-sm { font-size: 14px; line-height: 20px; }
        .t-lg { font-size: 18px; line-height: 28px; }
        .t-xl { font-size: 20px; line-height: 28px; }
        .fw-medium { font-weight: 500; }
        .g-3px { gap: 12px; } .g-2px { gap: 8px; } .g-4px { gap: 16px; }
        .c-o { color: var(--o); } .c-g400 { color: #9ca3af; } .c-g500 { color: #6b7280; }
        .c-g800 { color: #1f2937; } .c-g900 { color: #111827; }
        .bg-o { background: var(--o); } .bg-ol { background: var(--o-light); }
        .circle { border-radius: 50%; }
        .ico-box { display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .ms-18 { font-size: 18px; line-height: 28px; } .ms-14 { font-size: 14px; line-height: 20px; } .ms-36 { font-size: 36px; line-height: 40px; }

        .p-container { max-width: 80rem; margin: 0 auto; padding-left: 24px; padding-right: 24px; }
        @media (min-width: 1024px) { .p-container { padding-left: 40px; padding-right: 40px; } }
        .p-header { background: #fff; border-bottom: 1px solid #f3f4f6; position: sticky; top: 0; z-index: 40; }
        .p-header-in { height: 80px; }
        .p-nav a { font-size: 14px; line-height: 20px; font-weight: 500; color: #6b7280; transition: color .15s; }
        .p-nav a:hover { color: var(--o); }
        .p-nav a.on { color: var(--o); }
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
                    border-radius: 50%; background: #fff; padding: 4px; box-shadow: 0 10px 15px -3px rgb(0 0 0 / .1); }
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

        /* Form Controls */
        .f-label { display: block; font-size: 14px; font-weight: 600; color: #374151; margin-bottom: 8px; }
        .f-input-group {
            display: flex; align-items: center;
            background: #fff; border: 1px solid #e5e7eb; border-radius: 10px;
            overflow: hidden; transition: all .2s;
        }
        .f-input-group:focus-within {
            border-color: var(--o);
            box-shadow: 0 0 0 3px rgba(255, 112, 67, 0.18);
        }
        .f-prefix { padding-left: 14px; color: #9ca3af; display: flex; align-items: center; }
        .f-input {
            width: 100%; border: none; outline: none; padding: 12px 14px;
            font-size: 15px; color: #111827; background: transparent;
        }
        .f-eye {
            border: none; background: transparent; padding: 0 14px;
            color: #9ca3af; cursor: pointer; display: flex; align-items: center;
        }
        .f-eye:hover { color: #374151; }

        /* Password strength */
        .strength-meter { height: 4px; border-radius: 2px; background: #e2e8f0; overflow: hidden; margin-top: 8px; }
        .strength-bar { height: 100%; width: 0; transition: all 0.3s ease; }
        .strength-text { font-size: 12px; font-weight: 600; margin-top: 4px; text-align: right; }
        .rule-item { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #6b7280; margin-bottom: 4px; }
        .rule-item.valid { color: #059669; font-weight: 600; }

        .pbtn { padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 12px; transition: all .15s; border: none; }
        .pbtn-fill { background: var(--o); color: #fff; }
        .pbtn-fill:hover { background: #e85d32; color: #fff; transform: translateY(-1px); }
        .p-footer { background: #fff; border-top: 1px solid #f3f4f6; margin-top: 40px; }
    </style>
</head>
<body>

    <!-- HEADER -->
    <header class="p-header">
        <div class="p-container">
            <div class="p-header-in d-flex align-items-center justify-content-between">
                <a href="${pageContext.request.contextPath}/" class="d-flex align-items-center g-3px">
                    <div class="ico-box bg-o text-white" style="width:40px;height:40px;border-radius:12px">
                        <span class="material-symbols-outlined">confirmation_number</span>
                    </div>
                    <div>
                        <div class="t-xl fw-bold c-g900">Light Ticket</div>
                        <div class="t-xs c-g400">Event Ticket Platform</div>
                    </div>
                </a>
                <nav class="p-nav d-none d-md-flex align-items-center" style="gap:32px">
                    <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                    <a href="#">Sự kiện</a>
                    <a href="#">Vé của tôi</a>
                    <a href="${pageContext.request.contextPath}/CustomerProfileController" class="on">Hồ sơ</a>
                </nav>
                <div class="d-flex align-items-center g-3px">
                    <div class="d-flex align-items-center g-3px">
                        <div class="ico-box circle bg-o text-white" style="width:40px;height:40px">
                            <span class="material-symbols-outlined">person</span>
                        </div>
                        <div class="d-none d-sm-block">
                            <p class="t-sm fw-semibold">${sessionScope.user.fullName}</p>
                            <p class="t-xs c-g400">${sessionScope.user.role}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <!-- MAIN -->
    <main class="p-container p-main">
        <div style="margin-bottom:32px">
            <div class="d-flex align-items-center g-2px t-sm c-g400" style="margin-bottom:12px">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <span class="material-symbols-outlined ms-14">chevron_right</span>
                <a href="${pageContext.request.contextPath}/CustomerProfileController">Hồ sơ cá nhân</a>
                <span class="material-symbols-outlined ms-14">chevron_right</span>
                <span class="c-o">Đổi mật khẩu</span>
            </div>
            <h1 class="p-h1">Đổi mật khẩu</h1>
            <p class="c-g500" style="margin-top:8px">Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản của bạn.</p>
        </div>

        <div class="row" style="--bs-gutter-x:24px;--bs-gutter-y:24px">
            <!-- LEFT SIDEBAR -->
            <aside class="col-lg-4">
                <div class="p-card overflow-hidden">
                    <div class="cover">
                        <div class="cover-av">
                            <div class="ico-box circle bg-ol w-100 h-100">
                                <span class="material-symbols-outlined c-o ms-36">person</span>
                            </div>
                        </div>
                    </div>
                    <div class="text-center" style="padding:56px 24px 24px">
                        <h2 class="t-xl fw-bold c-g900">${sessionScope.user.fullName}</h2>
                        <p class="t-sm c-g400" style="margin-top:4px">@${sessionScope.user.username}</p>
                        <div class="pill-ok" style="margin-top:16px">
                            <span class="dot" style="width:8px;height:8px"></span> ${sessionScope.user.status}
                        </div>
                    </div>
                </div>

                <div class="p-card" style="margin-top:24px;padding:12px">
                    <div class="menu-title">Tài khoản</div>
                    <a href="${pageContext.request.contextPath}/CustomerProfileController" class="menu-item">
                        <span class="material-symbols-outlined">person</span> Thông tin cá nhân
                    </a>
                    <a href="${pageContext.request.contextPath}/BookingHistoryController" class="menu-item">
                        <span class="material-symbols-outlined">confirmation_number</span> Vé của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/Auth?action=changePassword" class="menu-item on">
                        <span class="material-symbols-outlined">lock_reset</span> Đổi mật khẩu
                    </a>
                </div>
            </aside>

            <!-- RIGHT FORM -->
            <section class="col-lg-8">
                <div class="p-card p-sec">
                    <div class="d-flex align-items-center g-3px mb-4">
                        <div class="ico-box bg-ol" style="width:44px;height:44px;border-radius:12px">
                            <span class="material-symbols-outlined c-o">shield</span>
                        </div>
                        <div>
                            <h2 class="t-xl fw-bold c-g900">Thiết lập mật khẩu mới</h2>
                            <p class="t-sm c-g400">Yêu cầu tối thiểu 8 ký tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
                        </div>
                    </div>

                    <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger py-2 px-3 mb-4 small d-flex align-items-center gap-2">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <span><%= request.getAttribute("error") %></span>
                    </div>
                    <% } %>
                    <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success py-2 px-3 mb-4 small d-flex align-items-center gap-2">
                        <i class="bi bi-check-circle-fill"></i>
                        <span><%= request.getAttribute("success") %></span>
                    </div>
                    <% } %>

                    <form method="post" action="${pageContext.request.contextPath}/Auth">
                        <input type="hidden" name="action" value="changePassword"/>

                        <div class="mb-4">
                            <label class="f-label" for="oldPassword">Mật khẩu hiện tại</label>
                            <div class="f-input-group">
                                <span class="f-prefix"><i class="bi bi-lock"></i></span>
                                <input class="f-input" id="oldPassword" name="oldPassword" required type="password" placeholder="Nhập mật khẩu hiện tại"/>
                                <button class="f-eye" type="button" onclick="togglePass('oldPassword', 'eyeOld')">
                                    <i class="bi bi-eye" id="eyeOld"></i>
                                </button>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="f-label" for="newPassword">Mật khẩu mới</label>
                            <div class="f-input-group">
                                <span class="f-prefix"><i class="bi bi-lock-fill"></i></span>
                                <input class="f-input" id="newPassword" minlength="8" name="newPassword" required type="password" placeholder="Nhập mật khẩu mới" oninput="checkStrength(this.value)"/>
                                <button class="f-eye" type="button" onclick="togglePass('newPassword', 'eyeNew')">
                                    <i class="bi bi-eye" id="eyeNew"></i>
                                </button>
                            </div>

                            <div class="strength-meter">
                                <div class="strength-bar" id="strengthBar"></div>
                            </div>
                            <div class="strength-text text-muted" id="strengthText">Độ mạnh: Chưa nhập</div>

                            <div class="mt-3 p-3 rounded" style="background:#f9fafb; border: 1px solid #f3f4f6;">
                                <div class="rule-item" id="rule-len"><i class="bi bi-circle"></i> Ít nhất 8 ký tự</div>
                                <div class="rule-item" id="rule-num"><i class="bi bi-circle"></i> Có ít nhất một chữ số</div>
                                <div class="rule-item" id="rule-case"><i class="bi bi-circle"></i> Có chữ hoa và chữ thường</div>
                                <div class="rule-item" id="rule-special"><i class="bi bi-circle"></i> Có ít nhất một ký tự đặc biệt (!@#$%^&*...)</div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="f-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                            <div class="f-input-group">
                                <span class="f-prefix"><i class="bi bi-shield-check"></i></span>
                                <input class="f-input" id="confirmPassword" name="confirmPassword" required type="password" placeholder="Nhập lại mật khẩu mới"/>
                                <button class="f-eye" type="button" onclick="togglePass('confirmPassword', 'eyeConfirm')">
                                    <i class="bi bi-eye" id="eyeConfirm"></i>
                                </button>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3 pt-2">
                            <button class="pbtn pbtn-fill d-inline-flex align-items-center gap-2" type="submit">
                                <span class="material-symbols-outlined ms-18">check_circle</span>
                                <span>Lưu mật khẩu mới</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/CustomerProfileController" class="btn btn-light px-3 py-2 rounded-3 text-secondary fw-semibold">
                                Hủy bỏ
                            </a>
                        </div>
                    </form>
                </div>
            </section>
        </div>
    </main>

    <!-- FOOTER -->
    <footer class="p-footer">
        <div class="p-container" style="padding-top:32px;padding-bottom:32px">
            <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-md-between g-4px">
                <div class="d-flex align-items-center g-2px">
                    <div class="ico-box bg-o text-white" style="width:32px;height:32px;border-radius:8px">
                        <span class="material-symbols-outlined ms-18">confirmation_number</span>
                    </div>
                    <span class="fw-bold c-g800">Light Ticket</span>
                </div>
                <p class="t-xs c-g400">© 2026 Light Ticket Platform. Bảo lưu mọi quyền.</p>
                <div class="d-flex align-items-center" style="gap:20px">
                    <a href="#">Điều khoản</a>
                    <a href="#">Chính sách bảo mật</a>
                    <a href="#">Liên hệ</a>
                </div>
            </div>
        </div>
    </footer>

    <script>
        function togglePass(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'bi bi-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'bi bi-eye';
            }
        }

        function checkStrength(pwd) {
            const bar = document.getElementById('strengthBar');
            const text = document.getElementById('strengthText');
            const isLen = pwd.length >= 8;
            const isNum = /\d/.test(pwd);
            const isCase = /[a-z]/.test(pwd) && /[A-Z]/.test(pwd);
            const isSpecial = /[^A-Za-z0-9]/.test(pwd);

            updateRule(document.getElementById('rule-len'), isLen);
            updateRule(document.getElementById('rule-num'), isNum);
            updateRule(document.getElementById('rule-case'), isCase);
            updateRule(document.getElementById('rule-special'), isSpecial);

            let score = 0;
            if (isLen) score++;
            if (isNum) score++;
            if (isCase) score++;
            if (isSpecial) score++;

            if (pwd.length === 0) {
                bar.style.width = '0%';
                bar.style.backgroundColor = '#e2e8f0';
                text.innerText = 'Độ mạnh: Chưa nhập';
                text.style.color = '#6b7280';
            } else if (score <= 1) {
                bar.style.width = '25%';
                bar.style.backgroundColor = '#ef4444';
                text.innerText = 'Độ mạnh: Yếu';
                text.style.color = '#ef4444';
            } else if (score === 2) {
                bar.style.width = '50%';
                bar.style.backgroundColor = '#f59e0b';
                text.innerText = 'Độ mạnh: Trung bình';
                text.style.color = '#f59e0b';
            } else if (score === 3) {
                bar.style.width = '75%';
                bar.style.backgroundColor = '#3b82f6';
                text.innerText = 'Độ mạnh: Khá';
                text.style.color = '#3b82f6';
            } else {
                bar.style.width = '100%';
                bar.style.backgroundColor = '#059669';
                text.innerText = 'Độ mạnh: Rất mạnh';
                text.style.color = '#059669';
            }
        }

        function updateRule(elem, isValid) {
            const icon = elem.querySelector('i');
            if (isValid) {
                elem.classList.add('valid');
                icon.className = 'bi bi-check-circle-fill';
            } else {
                elem.classList.remove('valid');
                icon.className = 'bi bi-circle';
            }
        }
    </script>
</body>
</html>