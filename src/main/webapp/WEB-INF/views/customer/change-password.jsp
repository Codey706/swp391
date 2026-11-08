<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- requireOld = false: tài khoản Google chưa có mật khẩu -> "Thiết lập mật khẩu", không hỏi mật khẩu hiện tại --%>
<c:set var="pwTitle" value="${requireOld ? 'Đổi mật khẩu' : 'Thiết lập mật khẩu'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pwTitle} - Light Ticket</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Material Symbols -->

    <style>
        :root {
            --o: #d93a27;
            --o-light: #fff4f2;
            --bs-body-font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
            --bs-body-font-size: 16px;
            --bs-body-line-height: 1.5;
            --bs-body-color: #1f1f22;
        }
        body { min-height: 100vh; background: #fafafa; }
        h1, h2, h3, p { margin: 0; }
        a { color: inherit; text-decoration: none; }
        .t-xs { font-size: 12px; line-height: 16px; }
        .t-sm { font-size: 14px; line-height: 20px; }
        .t-lg { font-size: 18px; line-height: 28px; }
        .t-xl { font-size: 20px; line-height: 28px; }
        .fw-medium { font-weight: 500; }
        .g-3px { gap: 12px; } .g-2px { gap: 8px; } .g-4px { gap: 16px; }
        .c-o { color: var(--o); } .c-g400 { color: #9a9aa1; } .c-g500 { color: #66666d; }
        .c-g800 { color: #1f1f22; } .c-g900 { color: #141414; }
        .bg-o { background: var(--o); } .bg-ol { background: var(--o-light); }
        .circle { border-radius: 50%; }
        .ico-box { display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .ms-18 { font-size: 18px; line-height: 28px; } .ms-14 { font-size: 14px; line-height: 20px; } .ms-36 { font-size: 36px; line-height: 40px; }

        .p-container { max-width: 80rem; margin: 0 auto; padding-left: 24px; padding-right: 24px; }
        @media (min-width: 1024px) { .p-container { padding-left: 40px; padding-right: 40px; } }
        .p-header { background: #fff; border-bottom: 1px solid #efeff1; position: sticky; top: 0; z-index: 40; }
        .p-header-in { height: 80px; }
        .p-nav a { font-size: 14px; line-height: 20px; font-weight: 500; color: #66666d; transition: color .15s; }
        .p-nav a:hover { color: var(--o); }
        .p-nav a.on { color: var(--o); }
        .bell { width: 40px; height: 40px; border: 0; border-radius: 50%; background: #f5f5f6; align-items: center; justify-content: center; transition: background .15s; }
        .bell:hover { background: var(--o-light); }
        .vline { width: 1px; height: 36px; background: #e4e4e7; }
        .p-main { padding-top: 40px; padding-bottom: 40px; }
        .p-h1 { font-size: 30px; line-height: 36px; font-weight: 700; color: #141414; }
        @media (min-width: 1024px) { .p-h1 { font-size: 36px; line-height: 40px; } }
        .p-sec { padding: 24px; }
        @media (min-width: 1024px) { .p-sec { padding: 32px; } }
        .p-card { background: #fff; border: 1px solid #efeff1; border-radius: 12px; box-shadow: 0 1px 2px 0 rgb(0 0 0 / .05); }
        .cover { height: 112px; background: #141414; position: relative; }
        .cover-av { position: absolute; left: 50%; bottom: -40px; transform: translateX(-50%); width: 80px; height: 80px;
                    border-radius: 50%; background: #fff; padding: 4px; box-shadow: 0 10px 15px -3px rgb(0 0 0 / .1); }
        .pill-ok { display: inline-flex; align-items: center; gap: 8px; padding: 6px 12px; border-radius: 9999px;
                   background: #e7f6ee; color: #13804b; font-size: 12px; line-height: 16px; font-weight: 600; }
        .dot { display: inline-block; border-radius: 50%; background: #2e9e63; }
        .sep { border-top: 1px solid #efeff1; margin: 24px 0; }
        .menu-title { padding: 8px 12px; font-size: 12px; line-height: 16px; font-weight: 600; color: #9a9aa1;
                      text-transform: uppercase; letter-spacing: .05em; }
        .menu-item { display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 12px;
                     font-size: 14px; line-height: 20px; color: #66666d; transition: background .15s, color .15s; }
        .menu-item:hover { background: #f5f5f6; color: var(--o); }
        .menu-item.on, .menu-item.on:hover { background: var(--o-light); color: var(--o); font-weight: 600; }

        /* Form Controls */
        .f-label { display: block; font-size: 14px; font-weight: 600; color: #36363b; margin-bottom: 8px; }
        .f-input-group {
            display: flex; align-items: center;
            background: #fff; border: 1px solid #e4e4e7; border-radius: 10px;
            overflow: hidden; transition: all .2s;
        }
        .f-input-group:focus-within {
            border-color: var(--o);
            box-shadow: 0 0 0 3px rgba(217, 58, 39, 0.18);
        }
        .f-prefix { padding-left: 14px; color: #9a9aa1; display: flex; align-items: center; }
        .f-input {
            width: 100%; border: none; outline: none; padding: 12px 14px;
            font-size: 15px; color: #141414; background: transparent;
        }
        .f-eye {
            border: none; background: transparent; padding: 0 14px;
            color: #9a9aa1; cursor: pointer; display: flex; align-items: center;
        }
        .f-eye:hover { color: #36363b; }

        /* Password strength */
        .strength-meter { height: 4px; border-radius: 2px; background: #e4e4e7; overflow: hidden; margin-top: 8px; }
        .strength-bar { height: 100%; width: 0; transition: all 0.3s ease; }
        .strength-text { font-size: 12px; font-weight: 600; margin-top: 4px; text-align: right; }
        .rule-item { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #66666d; margin-bottom: 4px; }
        .rule-item.valid { color: #13804b; font-weight: 600; }

        .pbtn { padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 12px; transition: all .15s; border: none; }
        .pbtn-fill { background: var(--o); color: #fff; }
        .pbtn-fill:hover { background: #ff5b49; color: #fff; transform: translateY(-1px); }
        .p-footer { background: #fff; border-top: 1px solid #efeff1; margin-top: 40px; }
    </style>
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
<body>

    <!-- HEADER -->
    <jsp:include page="/WEB-INF/views/common/site-header.jsp"/>

    <!-- MAIN -->
    <main class="p-container p-main">
        <div style="margin-bottom:32px">
            <div class="d-flex align-items-center g-2px t-sm c-g400" style="margin-bottom:12px">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a>
                <i class="ph ph-caret-right ms-14" aria-hidden="true"></i>
                <a href="${pageContext.request.contextPath}/CustomerProfileController">Hồ sơ cá nhân</a>
                <i class="ph ph-caret-right ms-14" aria-hidden="true"></i>
                <span class="c-o">${pwTitle}</span>
            </div>
            <h1 class="p-h1">${pwTitle}</h1>
            <p class="c-g500" style="margin-top:8px">
                <c:choose>
                    <c:when test="${requireOld}">Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản của bạn.</c:when>
                    <c:otherwise>Tài khoản của bạn được tạo bằng Google nên chưa có mật khẩu. Đặt mật khẩu để có thể đăng nhập bằng email hoặc username, ngoài đăng nhập Google.</c:otherwise>
                </c:choose>
            </p>
        </div>

        <div class="row" style="--bs-gutter-x:24px;--bs-gutter-y:24px">
            <!-- LEFT SIDEBAR -->
            <aside class="col-lg-4">
                <div class="p-card overflow-hidden">
                    <div class="cover">
                        <div class="cover-av">
                            <div class="ico-box circle bg-ol w-100 h-100">
                                <i class="ph ph-user c-o ms-36" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                    <div class="text-center" style="padding:56px 24px 24px">
                        <h2 class="t-xl fw-bold c-g900">${fn:escapeXml(sessionScope.user.fullName)}</h2>
                        <p class="t-sm c-g400" style="margin-top:4px">@${fn:escapeXml(sessionScope.user.username)}</p>
                        <div class="pill-ok" style="margin-top:16px">
                            <span class="dot" style="width:8px;height:8px"></span> ${sessionScope.user.status}
                        </div>
                    </div>
                </div>

                <div class="p-card" style="margin-top:24px;padding:12px">
                    <div class="menu-title">Tài khoản</div>
                    <a href="${pageContext.request.contextPath}/CustomerProfileController" class="menu-item">
                        <i class="ph ph-user" aria-hidden="true"></i> Thông tin cá nhân
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/booking-history" class="menu-item">
                        <i class="ph ph-ticket" aria-hidden="true"></i> Vé của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/Auth?action=changePassword" class="menu-item on">
                        <i class="ph ph-lock-key" aria-hidden="true"></i> ${pwTitle}
                    </a>
                </div>
            </aside>

            <!-- RIGHT FORM -->
            <section class="col-lg-8">
                <div class="p-card p-sec">
                    <div class="d-flex align-items-center g-3px mb-4">
                        <div class="ico-box bg-ol" style="width:44px;height:44px;border-radius:12px">
                            <i class="ph ph-shield c-o" aria-hidden="true"></i>
                        </div>
                        <div>
                            <h2 class="t-xl fw-bold c-g900">${requireOld ? 'Thiết lập mật khẩu mới' : 'Đặt mật khẩu cho tài khoản'}</h2>
                            <p class="t-sm c-g400">Yêu cầu tối thiểu 8 ký tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
                        </div>
                    </div>

                    <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger py-2 px-3 mb-4 small d-flex align-items-center gap-2">
                        <i class="ph ph-warning"></i>
                        <span><%= request.getAttribute("error") %></span>
                    </div>
                    <% } %>
                    <% if (request.getAttribute("success") != null) { %>
                    <div class="alert alert-success py-2 px-3 mb-4 small d-flex align-items-center gap-2">
                        <i class="ph ph-check-circle"></i>
                        <span><%= request.getAttribute("success") %></span>
                    </div>
                    <% } %>

                    <form method="post" action="${pageContext.request.contextPath}/Auth">
                        <input type="hidden" name="action" value="changePassword"/>

                        <c:if test="${requireOld}">
                        <div class="mb-4">
                            <label class="f-label" for="oldPassword">Mật khẩu hiện tại</label>
                            <div class="f-input-group">
                                <span class="f-prefix"><i class="ph ph-lock"></i></span>
                                <input class="f-input" id="oldPassword" name="oldPassword" required type="password" placeholder="Nhập mật khẩu hiện tại"/>
                                <button class="f-eye" type="button" onclick="togglePass('oldPassword', 'eyeOld')">
                                    <i class="ph ph-eye" id="eyeOld"></i>
                                </button>
                            </div>
                        </div>
                        </c:if>

                        <div class="mb-4">
                            <label class="f-label" for="newPassword">Mật khẩu mới</label>
                            <div class="f-input-group">
                                <span class="f-prefix"><i class="ph ph-lock"></i></span>
                                <input class="f-input" id="newPassword" minlength="8" name="newPassword" required type="password" placeholder="Nhập mật khẩu mới" oninput="checkStrength(this.value)"/>
                                <button class="f-eye" type="button" onclick="togglePass('newPassword', 'eyeNew')">
                                    <i class="ph ph-eye" id="eyeNew"></i>
                                </button>
                            </div>

                            <div class="strength-meter">
                                <div class="strength-bar" id="strengthBar"></div>
                            </div>
                            <div class="strength-text text-muted" id="strengthText">Độ mạnh: Chưa nhập</div>

                            <div class="mt-3 p-3 rounded" style="background:#f5f5f6; border: 1px solid #efeff1;">
                                <div class="rule-item" id="rule-len"><i class="ph ph-circle"></i> Ít nhất 8 ký tự</div>
                                <div class="rule-item" id="rule-num"><i class="ph ph-circle"></i> Có ít nhất một chữ số</div>
                                <div class="rule-item" id="rule-case"><i class="ph ph-circle"></i> Có chữ hoa và chữ thường</div>
                                <div class="rule-item" id="rule-special"><i class="ph ph-circle"></i> Có ít nhất một ký tự đặc biệt (!@#$%^&*...)</div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="f-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                            <div class="f-input-group">
                                <span class="f-prefix"><i class="ph ph-shield-check"></i></span>
                                <input class="f-input" id="confirmPassword" name="confirmPassword" required type="password" placeholder="Nhập lại mật khẩu mới"/>
                                <button class="f-eye" type="button" onclick="togglePass('confirmPassword', 'eyeConfirm')">
                                    <i class="ph ph-eye" id="eyeConfirm"></i>
                                </button>
                            </div>
                        </div>

                        <div class="d-flex align-items-center gap-3 pt-2">
                            <button class="pbtn pbtn-fill d-inline-flex align-items-center gap-2" type="submit">
                                <i class="ph ph-check-circle ms-18" aria-hidden="true"></i>
                                <span>${requireOld ? 'Lưu mật khẩu mới' : 'Đặt mật khẩu'}</span>
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
    <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>

    <script>
        function togglePass(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'ph ph-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'ph ph-eye';
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
                bar.style.backgroundColor = '#e4e4e7';
                text.innerText = 'Độ mạnh: Chưa nhập';
                text.style.color = '#66666d';
            } else if (score <= 1) {
                bar.style.width = '25%';
                bar.style.backgroundColor = '#ff5b49';
                text.innerText = 'Độ mạnh: Yếu';
                text.style.color = '#d93a27';
            } else if (score === 2) {
                bar.style.width = '50%';
                bar.style.backgroundColor = '#e09a1a';
                text.innerText = 'Độ mạnh: Trung bình';
                text.style.color = '#e09a1a';
            } else if (score === 3) {
                bar.style.width = '75%';
                bar.style.backgroundColor = '#9a9aa1';
                text.innerText = 'Độ mạnh: Khá';
                text.style.color = '#9a9aa1';
            } else {
                bar.style.width = '100%';
                bar.style.backgroundColor = '#13804b';
                text.innerText = 'Độ mạnh: Rất mạnh';
                text.style.color = '#13804b';
            }
        }

        function updateRule(elem, isValid) {
            const icon = elem.querySelector('i');
            if (isValid) {
                elem.classList.add('valid');
                icon.className = 'ph-fill ph-check-circle';
            } else {
                elem.classList.remove('valid');
                icon.className = 'ph ph-circle';
            }
        }
    </script>
</body>
</html>