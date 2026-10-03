<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Đăng nhập</title>
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
          <svg class="text-danger" style="width: 20px; height: 20px;" viewBox="0 0 32 32">
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
        <h1 class="auth-title">Đăng nhập tài khoản</h1>
        <p class="auth-subtitle mb-0">Tiếp tục đặt vé xem show diễn &amp; sự kiện yêu thích của bạn.</p>
      </div>

      <div class="mb-3">
        <button class="btn btn-google" id="googleLoginBtn" type="button">
          <svg height="20" viewBox="0 0 24 24" width="20">
            <path d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.8-2.4 3.66v3.05h3.88c2.27-2.09 3.665-5.17 3.665-9.15z" fill="#4285F4"></path>
            <path d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.33 24 12 24z" fill="#34A853"></path>
            <path d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.99 0 12s.45 3.82 1.25 5.42l4.03-3.15z" fill="#FBBC05"></path>
            <path d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.33 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z" fill="#EA4335"></path>
          </svg>
          <span>Tiếp tục với Google</span>
        </button>
      </div>

      <div class="divider-wrap">
        <span class="divider-text">HOẶC VỚI TÀI KHOẢN LIGHT TICKET</span>
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
            <span class="input-icon-prefix"><i class="bi bi-at"></i></span>
            <input class="form-control" id="identifier" name="identifier" placeholder="name@example.com" required type="text" value="${identifier}"/>
          </div>
        </div>

        <div class="mb-3">
          <div class="d-flex align-items-center justify-content-between mb-1">
            <label class="form-label form-label-custom mb-0" for="password">Mật khẩu</label>
            <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=forgot">Quên mật khẩu?</a>
          </div>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-lock"></i></span>
            <input class="form-control" id="password" name="password" placeholder="Nhập mật khẩu" required type="password"/>
            <button aria-label="Hiển thị mật khẩu" class="btn-eye" id="togglePassword" type="button">
              <i class="bi bi-eye" id="eyeIcon"></i>
            </button>
          </div>
        </div>

        <div class="form-check mb-4">
          <input class="form-check-input" id="rememberMe" name="rememberMe" type="checkbox"/>
          <label class="form-check-label" for="rememberMe">Duy trì đăng nhập trên thiết bị này</label>
        </div>

        <button class="btn-submit-orange" type="submit">
          <span>Đăng nhập ngay</span>
          <i class="bi bi-arrow-right"></i>
        </button>
            </form>

      <div class="divider d-flex align-items-center my-4">
        <hr class="flex-grow-1">
        <span class="mx-3 text-secondary small">hoặc đăng nhập với</span>
        <hr class="flex-grow-1">
      </div>

      <div class="d-flex justify-content-center mb-4">
        <div id="g_id_onload"
             data-client_id="605419551555-3epj9er66p13sl614tn96ii9jhf8g720.apps.googleusercontent.com"
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
