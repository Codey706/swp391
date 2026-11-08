<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Xác thực OTP</title>
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
      <div class="text-center mb-4">
        <h1 class="auth-title">Nhập mã OTP</h1>
        <p class="auth-subtitle mb-0">Mã gồm 6 số, hiệu lực 3 phút. Kiểm tra hộp thư email của bạn.</p>
      </div>

      <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger py-2 px-3 mb-3 small"><%= request.getAttribute("error") %></div>
      <% } else if (session.getAttribute("otpNotice") != null) { %>
      <div class="alert alert-info py-2 px-3 mb-3 small"><%= session.getAttribute("otpNotice") %></div>
      <% } %>
      <%-- Chế độ dev: chưa cấu hình SMTP thì email không được gửi, hiện mã ngay tại đây để test được.
           Không hiện với OTP giả (quên mật khẩu bằng email không tồn tại) để không lộ email nào có thật. --%>
      <% if (!utils.EmailService.isConfigured() && session.getAttribute("otpCode") != null
             && !Boolean.TRUE.equals(session.getAttribute("otpFake"))) { %>
      <div class="alert alert-warning py-2 px-3 mb-3 small">
        <strong>Chế độ dev:</strong> chưa cấu hình SMTP nên email không được gửi.
        Mã OTP của bạn: <strong style="letter-spacing:2px"><%= session.getAttribute("otpCode") %></strong>
      </div>
      <% } %>


      <form method="post" action="${pageContext.request.contextPath}/Auth">
        <input type="hidden" name="action" value="otp"/>
        <div class="mb-4">
          <label class="form-label form-label-custom" for="otp">OTP</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="ph ph-lock-key"></i></span>
            <input class="form-control" id="otp" maxlength="6" name="otp" pattern="\d{6}" required type="text"/>
          </div>
        </div>
        <button class="btn-submit-orange" type="submit">Xác nhận OTP</button>
      </form>

      <div class="text-center mt-4">
        <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=resendOtp">Gửi lại OTP</a>
        <span class="text-secondary small mx-2">|</span>
        <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=login">Về đăng nhập</a>
      </div>
    </div>
  </div>
  <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
</body>
</html>
