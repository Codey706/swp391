<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đổi mật khẩu Ban Tổ Chức - Light Ticket</title>
    <jsp:include page="_head.jsp"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        .org-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            max-width: 650px;
            margin: 0 auto;
        }
        .f-label { display: block; font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 8px; }
        .f-input-group {
            display: flex; align-items: center;
            background: #fff; border: 1px solid #cbd5e1; border-radius: 10px;
            overflow: hidden; transition: all .2s;
        }
        .f-input-group:focus-within {
            border-color: #ff7043;
            box-shadow: 0 0 0 3px rgba(255, 112, 67, 0.18);
        }
        .f-prefix { padding-left: 14px; color: #94a3b8; display: flex; align-items: center; }
        .f-input {
            width: 100%; border: none; outline: none; padding: 12px 14px;
            font-size: 15px; color: #0f172a; background: transparent;
        }
        .f-eye {
            border: none; background: transparent; padding: 0 14px;
            color: #94a3b8; cursor: pointer; display: flex; align-items: center;
        }
        .f-eye:hover { color: #334155; }
        .strength-meter { height: 4px; border-radius: 2px; background: #e2e8f0; overflow: hidden; margin-top: 8px; }
        .strength-bar { height: 100%; width: 0; transition: all 0.3s ease; }
        .strength-text { font-size: 12px; font-weight: 600; margin-top: 4px; text-align: right; }
        .rule-item { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #64748b; margin-bottom: 4px; }
        .rule-item.valid { color: #059669; font-weight: 600; }
        .btn-org-submit {
            background: #ff7043; color: #fff; font-weight: 600;
            padding: 12px 24px; border-radius: 10px; border: none;
            display: inline-flex; align-items: center; gap: 8px;
            transition: all 0.2s;
        }
        .btn-org-submit:hover { background: #f4511e; color: #fff; transform: translateY(-1px); }
    </style>
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
                         style="width: 48px; height: 48px; background: #ff7043;">
                        <span class="material-symbols-outlined">lock_reset</span>
                    </div>
                    <div>
                        <h1 class="h5 fw-bold mb-1 text-dark">Đổi mật khẩu Ban Tổ Chức</h1>
                        <p class="text-muted small mb-0">Cập nhật mật khẩu quản trị gian sự kiện</p>
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

                    <div class="mb-3">
                        <label class="f-label" for="oldPassword">Mật khẩu hiện tại</label>
                        <div class="f-input-group">
                            <span class="f-prefix"><i class="bi bi-lock"></i></span>
                            <input class="f-input" id="oldPassword" name="oldPassword" required type="password" placeholder="Nhập mật khẩu hiện tại"/>
                            <button class="f-eye" type="button" onclick="togglePass('oldPassword', 'eyeOld')">
                                <i class="bi bi-eye" id="eyeOld"></i>
                            </button>
                        </div>
                    </div>

                    <div class="mb-3">
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

                        <div class="mt-3 p-3 rounded" style="background:#f8fafc; border: 1px solid #f1f5f9;">
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
                        <button class="btn-org-submit" type="submit">
                            <span class="material-symbols-outlined" style="font-size: 20px;">check_circle</span>
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
                text.style.color = '#64748b';
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