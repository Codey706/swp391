<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Đăng ký</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/login.css">
</head>
<body>
  <div class="glow-shape-1"></div>
  <div class="glow-shape-2"></div>

  <div class="container d-flex justify-content-center">
    <div class="auth-card">
      <div class="d-flex align-items-center justify-content-between mb-4">
        <a class="pill-badge shadow-sm" href="${pageContext.request.contextPath}/home">
          <svg style="width: 20px; height: 20px;" viewBox="0 0 32 32">
            <rect fill="#ac3509" fill-opacity="0.95" height="22" rx="4" width="28" x="2" y="5"></rect>
            <circle cx="2" cy="16" fill="#f8f9ff" r="3.5"></circle>
            <circle cx="30" cy="16" fill="#f8f9ff" r="3.5"></circle>
            <line stroke="#f8f9ff" stroke-dasharray="2 3" stroke-width="2" x1="12" x2="12" y1="7" y2="25"></line>
            <circle cx="8" cy="16" fill="#f8f9ff" r="2"></circle>
          </svg>
          <span style="font-size: 0.875rem;">Light Ticket</span>
        </a>
        <button class="mode-toggle-btn shadow-sm" id="themeToggleBtn" type="button">
          <i class="bi bi-brightness-high text-warning-emphasis" id="modeIcon"></i>
          <span id="modeText">Chế độ sáng</span>
        </button>
      </div>

      <div class="text-center mb-4">
        <h1 class="auth-title">Đăng ký tài khoản</h1>
        <p class="auth-subtitle mb-0">Tạo tài khoản Customer để đặt vé sự kiện.</p>
      </div>

      <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger py-2 px-3 mb-3 small"><%= request.getAttribute("error") %></div>
      <% } %>

      <form method="post" action="${pageContext.request.contextPath}/Auth">
        <input type="hidden" name="action" value="register"/>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="fullName">Họ và tên</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-person"></i></span>
            <input class="form-control" id="fullName" name="fullName" required type="text" value="${fullName}"/>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="username">Username</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-at"></i></span>
            <input class="form-control" id="username" name="username" required type="text" value="${username}"/>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="email">Gmail</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-envelope"></i></span>
            <input class="form-control" id="email" name="email" required type="email" value="${email}"/>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="phone">Số điện thoại</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-phone"></i></span>
            <input class="form-control" id="phone" name="phone" required type="text" value="${phone}"/>
          </div>
        </div>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="password">Mật khẩu</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-lock"></i></span>
            <input class="form-control" id="password" minlength="8" name="password" required type="password"/>
            <button class="btn-eye" id="togglePassword" type="button"><i class="bi bi-eye" id="eyeIcon"></i></button>
          </div>
          <ul class="password-rules">
            <li>Tối thiểu 8 ký tự</li>
            <li>Có chữ hoa và chữ thường</li>
            <li>Có số và ký tự đặc biệt</li>
          </ul>
        </div>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="confirmPassword">Xác nhận mật khẩu</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-lock-fill"></i></span>
            <input class="form-control" id="confirmPassword" name="confirmPassword" required type="password"/>
          </div>
        </div>

        <div class="form-check mb-4">
          <input class="form-check-input" id="terms" name="terms" type="checkbox"/>
          <label class="form-check-label" for="terms">Tôi đồng ý Điều khoản và Chính sách bảo mật</label>
        </div>

        <button class="btn-submit-orange" type="submit">
          <span>Gửi mã OTP</span>
          <i class="bi bi-arrow-right"></i>
        </button>
      </form>

      <div class="text-center mt-4 pt-2">
        <span class="text-secondary small">Đã có tài khoản?</span>
        <a class="link-orange small fw-bold ms-1" href="${pageContext.request.contextPath}/Auth?action=login">Đăng nhập</a>
      </div>
    </div>
  </div>

  <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
</body>
</html>
