<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Đổi mật khẩu</title>
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
        <h1 class="auth-title">Đổi mật khẩu</h1>
        <p class="auth-subtitle mb-0">Mật khẩu mới phải đủ độ mạnh theo quy định hệ thống.</p>
      </div>

      <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger py-2 px-3 mb-3 small"><%= request.getAttribute("error") %></div>
      <% } %>
      <% if (request.getAttribute("success") != null) { %>
      <div class="alert alert-success py-2 px-3 mb-3 small"><%= request.getAttribute("success") %></div>
      <% } %>

      <form method="post" action="${pageContext.request.contextPath}/Auth">
        <input type="hidden" name="action" value="changePassword"/>

        <% if (Boolean.TRUE.equals(request.getAttribute("requireOld"))) { %>
        <div class="mb-3">
          <label class="form-label form-label-custom" for="oldPassword">Mật khẩu hiện tại</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-lock"></i></span>
            <input class="form-control" id="oldPassword" name="oldPassword" required type="password"/>
          </div>
        </div>
        <% } %>

        <div class="mb-3">
          <label class="form-label form-label-custom" for="newPassword">Mật khẩu mới</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-lock-fill"></i></span>
            <input class="form-control" id="password" minlength="8" name="newPassword" required type="password"/>
            <button class="btn-eye" id="togglePassword" type="button"><i class="bi bi-eye" id="eyeIcon"></i></button>
          </div>
          <ul class="password-rules">
            <li>Tối thiểu 8 ký tự</li>
            <li>Có ít nhất một số</li>
            <li>Có chữ hoa và chữ thường</li>
            <li>Có ký tự đặc biệt</li>
          </ul>
        </div>

        <div class="mb-4">
          <label class="form-label form-label-custom" for="confirmPassword">Xác nhận mật khẩu mới</label>
          <div class="custom-input-group">
            <span class="input-icon-prefix"><i class="bi bi-shield-check"></i></span>
            <input class="form-control" id="confirmPassword" name="confirmPassword" required type="password"/>
          </div>
        </div>

        <button class="btn-submit-orange" type="submit">Cập nhật mật khẩu</button>
      </form>

      <div class="text-center mt-4">
        <% if (session.getAttribute("user") != null) { %>
        <a class="link-orange" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
        <% } else { %>
        <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=login">Quay lại đăng nhập</a>
        <% } %>
      </div>
    </div>
  </div>
  <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
</body>
</html>
