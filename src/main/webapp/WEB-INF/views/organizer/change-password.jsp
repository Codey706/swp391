<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đổi mật khẩu Ban Tổ Chức - Light Ticket</title>
    <jsp:include page="_head.jsp"/>
    <style>
        .org-card {
            background: #ffffff;
            border: 1px solid #e4e4e7;
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            max-width: 650px;
            margin: 0 auto;
        }
        .f-label { display: block; font-size: 14px; font-weight: 600; color: #36363b; margin-bottom: 8px; }
        .f-input-group {
            display: flex; align-items: center;
            background: #fff; border: 1px solid #d4d4d8; border-radius: 10px;
            overflow: hidden; transition: all .2s;
        }
        .f-input-group:focus-within {
            border-color: #d93a27;
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
        .strength-meter { height: 4px; border-radius: 2px; background: #e4e4e7; overflow: hidden; margin-top: 8px; }
        .strength-bar { height: 100%; width: 0; transition: all 0.3s ease; }
        .strength-text { font-size: 12px; font-weight: 600; margin-top: 4px; text-align: right; }
        .rule-item { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #66666d; margin-bottom: 4px; }
        .rule-item.valid { color: #13804b; font-weight: 600; }
        .btn-org-submit {
            background: #d93a27; color: #fff; font-weight: 600;
            padding: 12px 24px; border-radius: 10px; border: none;
            display: inline-flex; align-items: center; gap: 8px;
            transition: all 0.2s;
        }
        .btn-org-submit:hover { background: #b42e1d; color: #fff; transform: translateY(-1px); }
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
<body class="org-body">
    <jsp:include page="_header.jsp">
        <jsp:param name="active" value="password"/>
        <jsp:param name="current" value="Đổi mật khẩu"/>
        <jsp:param name="crumb2" value="Hồ sơ"/>
    </jsp:include>

    <main class="org-main">
        <div class="org-container" style="max-width: 1000px; margin: 0 auto; padding: 32px 20px;">
            <div class="org-card">
                <div class="d-flex align-items-center gap-3 mb-4 pb-3 border-bottom">
                    <div class="d-flex align-items-center justify-content-center text-white rounded-circle" 
                         style="width: 48px; height: 48px; background: #d93a27;">
                        <i class="ph ph-lock-key" aria-hidden="true"></i>
                    </div>
                    <div>
                        <h1 class="h5 fw-bold mb-1 text-dark">Đổi mật khẩu Ban Tổ Chức</h1>
                        <p class="text-muted small mb-0">Cập nhật mật khẩu quản trị gian sự kiện</p>
                    </div>
                </div>

                <c:if test="${not empty error}">
                <div class="alert alert-danger py-2 px-3 mb-4 small d-flex align-items-center gap-2">
                    <i class="ph ph-warning"></i>
                    <span><c:out value="${error}"/></span>
                </div>
                </c:if>
                <c:if test="${not empty success}">
                <div class="alert alert-success py-2 px-3 mb-4 small d-flex align-items-center gap-2">
                    <i class="ph ph-check-circle"></i>
                    <span><c:out value="${success}"/></span>
                </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/Auth">
                    <input type="hidden" name="action" value="changePassword"/>

                    <div class="mb-3">
                        <label class="f-label" for="oldPassword">Mật khẩu hiện tại</label>
                        <div class="f-input-group">
                            <span class="f-prefix"><i class="ph ph-lock"></i></span>
                            <input class="f-input" id="oldPassword" name="oldPassword" required type="password" placeholder="Nhập mật khẩu hiện tại"/>
                            <button class="f-eye" type="button" onclick="togglePass('oldPassword', 'eyeOld')">
                                <i class="ph ph-eye" id="eyeOld"></i>
                            </button>
                        </div>
                    </div>

                    <div class="mb-3">
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
                        <button class="btn-org-submit" type="submit">
                            <i class="ph ph-check-circle" style="font-size: 20px;" aria-hidden="true"></i>
                            <span>Cập nhật mật khẩu</span>
                        </button>
                        <a href="${pageContext.request.contextPath}/organizer/profile" class="btn btn-light px-3 py-2 rounded-3 text-secondary fw-semibold">
                            Hủy bỏ
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <jsp:include page="_footer.jsp"/>

    <%-- Cần cho menu ☰ (mobile) và dropdown tài khoản trong _header.jsp --%>
    <script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/event.js"></script>
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