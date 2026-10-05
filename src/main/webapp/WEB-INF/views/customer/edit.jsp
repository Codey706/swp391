<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa hồ sơ - Light Ticket</title>

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

        body { background: #f9fafb; }
        .e-header { background: #fff; border-bottom: 1px solid #e5e7eb; }
        .e-wrap { max-width: 80rem; margin: 0 auto; padding: 16px 24px; }
        .e-brand { font-size: 24px; line-height: 32px; font-weight: 700; color: var(--o); }
        .e-main { max-width: 48rem; margin: 0 auto; padding: 40px 24px; }
        .e-back { color: #6b7280; display: inline-flex; }
        .e-back:hover { color: var(--o); }
        .e-title { font-size: 30px; line-height: 36px; font-weight: 700; color: #1f2937; }
        .e-card { background: #fff; border: 1px solid #e5e7eb; border-radius: 16px; padding: 32px; box-shadow: 0 1px 2px 0 rgb(0 0 0 / .05); }
        .e-label { display: block; font-size: 14px; line-height: 20px; font-weight: 600; color: #374151; margin-bottom: 8px; }
        .e-input {
            display: block; width: 100%; padding: 12px 16px; font-size: 16px; line-height: 24px; color: inherit;
            background: #fff; border: 1px solid #e5e7eb; border-radius: 8px; outline: none;
        }
        .e-input:focus { border-color: transparent; box-shadow: 0 0 0 2px var(--o); }
        .e-input:disabled { background: #f3f4f6; color: #6b7280; cursor: not-allowed; }
        textarea.e-input { resize: none; }
        .e-hint { font-size: 12px; line-height: 16px; color: #6b7280; margin: 8px 0 0; }
        .e-btn {
            --bs-btn-padding-x: 20px; --bs-btn-padding-y: 12px; --bs-btn-font-size: 16px;
            --bs-btn-font-weight: 600; --bs-btn-border-radius: 8px; --bs-btn-line-height: 24px;
            transition: background-color .15s, color .15s;
        }
        .e-cancel { --bs-btn-color: #374151; --bs-btn-border-color: #d1d5db; --bs-btn-bg: transparent;
                    --bs-btn-hover-color: #374151; --bs-btn-hover-bg: #f3f4f6; --bs-btn-hover-border-color: #d1d5db;
                    --bs-btn-active-color: #374151; --bs-btn-active-bg: #f3f4f6; --bs-btn-active-border-color: #d1d5db; }
        .e-save { --bs-btn-color: #fff; --bs-btn-bg: var(--o); --bs-btn-border-width: 0;
                  --bs-btn-hover-color: #fff; --bs-btn-hover-bg: #ac3509;
                  --bs-btn-active-color: #fff; --bs-btn-active-bg: #ac3509; }
    </style>
</head>


<body>

    <!-- ================= HEADER ================= -->
    <header class="e-header">
        <div class="e-wrap">
            <div class="d-flex align-items-center justify-content-between">

                <a href="${pageContext.request.contextPath}/CustomerProfileController" class="e-brand">
                    Light Ticket
                </a>

                <div class="d-flex align-items-center g-3px">
                    <div class="ico-box circle bg-o text-white" style="width:40px;height:40px">
                        <span class="material-symbols-outlined">person</span>
                    </div>
                    <div>
                        <p class="t-sm fw-semibold c-g800">${user.fullName}</p>
                        <p class="t-xs c-g500">Customer</p>
                    </div>
                </div>

            </div>
        </div>
    </header>


    <!-- ================= MAIN ================= -->
    <main class="e-main">

        <!-- Page title -->
        <div style="margin-bottom:32px">
            <div class="d-flex align-items-center g-3px" style="margin-bottom:8px">
                <a href="${pageContext.request.contextPath}/CustomerProfileController" class="e-back">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <h1 class="e-title">Chỉnh sửa hồ sơ</h1>
            </div>
            <p class="c-g500">Cập nhật thông tin cá nhân của bạn</p>
        </div>

        <!-- ================= FORM ================= -->
        <div class="e-card">
            <form action="${pageContext.request.contextPath}/UpdateCustomerProfileController" method="post">

                <div style="margin-bottom:24px">
                    <label for="fullName" class="e-label">Họ và tên</label>
                    <input type="text" id="fullName" name="fullName" value="${user.fullName}" required class="e-input">
                </div>

                <div style="margin-bottom:24px">
                    <label for="username" class="e-label">Tên đăng nhập</label>
                    <input type="text" id="username" value="${user.username}" disabled class="e-input">
                    <p class="e-hint">Tên đăng nhập không thể thay đổi.</p>
                </div>

                <div style="margin-bottom:24px">
                    <label for="email" class="e-label">Email</label>
                    <input type="email" id="email" name="email" value="${user.email}" required class="e-input">
                </div>

                <div style="margin-bottom:24px">
                    <label for="phone" class="e-label">Số điện thoại</label>
                    <input type="text" id="phone" name="phone" value="${user.phone}" class="e-input">
                </div>

                <div style="margin-bottom:32px">
                    <label for="address" class="e-label">Địa chỉ</label>
                    <textarea id="address" name="address" rows="3" class="e-input">${user.address}</textarea>
                </div>

                <!-- ================= BUTTONS ================= -->
                <div class="d-flex align-items-center justify-content-end g-3px">
                    <a href="${pageContext.request.contextPath}/CustomerProfileController" class="btn e-btn e-cancel">Hủy</a>
                    <button type="submit" class="btn e-btn e-save d-flex align-items-center g-2px">
                        <span class="material-symbols-outlined">save</span>
                        Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>

    </main>

</body>
</html>
