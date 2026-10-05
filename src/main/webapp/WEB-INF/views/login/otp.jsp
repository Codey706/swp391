<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Xác thực OTP</title>
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
      <div class="text-center mb-4">
        <h1 class="auth-title">Nhập mã OTP</h1>
        <p class="auth-subtitle mb-0">Mã gồm 6 số, hiệu lực 3 phút. Kiểm tra hộp thư email của bạn.</p>
      </div>

      <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger py-2 px-3 mb-3 small"><%= request.getAttribute("error") %></div>
      <% } %>
      

      <form method="post" action="${pageContext.request.contextPath}/Auth">
        <input type="hidden" name="action" value="otp"/>
        <div class="mb-4">
          <label class="form-label form-label-custom" for="otp">OTP</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-shield-lock"></i></span>
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
