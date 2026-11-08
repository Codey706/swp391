<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Đăng nhập</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/login.css">
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
  <div class="glow-shape-1"></div>
  <div class="glow-shape-2"></div>

  <div class="container d-flex justify-content-center">
    <div class="auth-card">
      <div class="d-flex align-items-center justify-content-between mb-4">
        <a class="pill-badge shadow-sm" href="${pageContext.request.contextPath}/home">
          <svg class="text-danger" style="width: 20px; height: 20px;" viewBox="0 0 32 32">
            <rect fill="#8a2315" fill-opacity="0.95" height="22" rx="4" width="28" x="2" y="5"></rect>
            <circle cx="2" cy="16" fill="#f5f5f6" r="3.5"></circle>
            <circle cx="30" cy="16" fill="#f5f5f6" r="3.5"></circle>
            <line stroke="#f5f5f6" stroke-dasharray="2 3" stroke-width="2" x1="12" x2="12" y1="7" y2="25"></line>
            <circle cx="8" cy="16" fill="#f5f5f6" r="2"></circle>
          </svg>
          <span style="font-size: 0.875rem;">Light Ticket</span>
        </a>
        <button class="mode-toggle-btn shadow-sm" id="themeToggleBtn" type="button">
          <i class="ph ph-sun text-warning-emphasis" id="modeIcon"></i>
          <span id="modeText">Chế độ sáng</span>
        </button>
      </div>

      <div class="text-center mb-4">
        <h1 class="auth-title">Đăng nhập tài khoản</h1>
        <p class="auth-subtitle mb-0">Tiếp tục đặt vé xem show diễn &amp; sự kiện yêu thích của bạn.</p>
      </div>
      <div class="divider-wrap">
        <span class="divider-text">ĐĂNG NHẬP VỚI TÀI KHOẢN LIGHT TICKET</span>
      </div>

      <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger py-2 px-3 mb-3 small"><%= request.getAttribute("error") %></div>
      <% } else if (request.getAttribute("success") != null) { %>
      <div class="alert alert-success py-2 px-3 mb-3 small"><%= request.getAttribute("success") %></div>
      <% } %>
      <div class="d-none alert py-2 px-3 mb-3 small" id="alertContainer" role="alert">
        <span id="alertMessage"></span>
      </div>

      <form id="loginForm" method="post" action="${pageContext.request.contextPath}/Auth">
        <input type="hidden" name="action" value="login"/>
        <div class="mb-3">
          <label class="form-label form-label-custom" for="identifier">Username hoặc Gmail</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="ph ph-at"></i></span>
            <input class="form-control" id="identifier" name="identifier" placeholder="name@example.com" required type="text" value="${fn:escapeXml(identifier)}"/>
          </div>
        </div>

        <div class="mb-3">
          <div class="d-flex align-items-center justify-content-between mb-1">
            <label class="form-label form-label-custom mb-0" for="password">Mật khẩu</label>
            <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=forgot">Quên mật khẩu?</a>
          </div>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="ph ph-lock"></i></span>
            <input class="form-control" id="password" name="password" placeholder="Nhập mật khẩu" required type="password"/>
            <button aria-label="Hiển thị mật khẩu" class="btn-eye" id="togglePassword" type="button">
              <i class="ph ph-eye" id="eyeIcon"></i>
            </button>
          </div>
        </div>

        <div class="form-check mb-4">
          <input class="form-check-input" id="rememberMe" name="rememberMe" type="checkbox"/>
          <label class="form-check-label" for="rememberMe">Duy trì đăng nhập trên thiết bị này</label>
        </div>

        <button class="btn-submit-orange" type="submit">
          <span>Đăng nhập ngay</span>
          <i class="ph ph-arrow-right"></i>
        </button>
            </form>

      <div class="divider d-flex align-items-center my-4">
        <hr class="flex-grow-1">
        <span class="mx-3 text-secondary small">hoặc đăng nhập với</span>
        <hr class="flex-grow-1">
      </div>

      <div class="d-flex justify-content-center mb-4">
        <div id="g_id_onload"
             data-client_id="<%= utils.GoogleUtils.GOOGLE_CLIENT_ID %>"
             data-callback="handleCredentialResponse"
             data-auto_prompt="false">
        </div>
        <div class="g_id_signin"
             data-type="standard"
             data-size="large"
             data-theme="outline"
             data-text="sign_in_with"
             data-shape="rectangular"
             data-logo_alignment="center">
        </div>
      </div>

      <form id="googleForm" action="${pageContext.request.contextPath}/Auth" method="POST" style="display:none;">
          <input type="hidden" name="action" value="googleLogin">
          <input type="hidden" name="credential" id="credential">
      </form>

      <script src="https://accounts.google.com/gsi/client" async defer></script>
      <script>
        function handleCredentialResponse(response) {
            document.getElementById('credential').value = response.credential;
            document.getElementById('googleForm').submit();
        }
      </script>

      <div class="text-center mt-4 pt-2">
        <span class="text-secondary small">Chưa có tài khoản Light Ticket?</span>
        <a class="link-orange small fw-bold ms-1" href="${pageContext.request.contextPath}/Auth?action=register">Đăng ký ngay</a>
      </div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
</body>
</html>
