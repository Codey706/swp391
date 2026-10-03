<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Auth" %>
<%
    Auth user = (Auth) session.getAttribute("user");
%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Light Ticket - Trang chủ</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/login.css">
</head>
<body>
  <div class="container d-flex justify-content-center">
    <div class="auth-card">
      <h1 class="auth-title">Light Ticket</h1>
      <% if (user == null) { %>
      <p class="auth-subtitle">Bạn đang xem với tư cách khách. Đăng nhập để đặt vé.</p>
      <a class="btn-submit-orange mb-2" href="${pageContext.request.contextPath}/Auth?action=login">Đăng nhập</a>
      <div class="text-center mt-3">
        <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=register">Đăng ký tài khoản</a>
      </div>
      <% } else { %>
      <p class="auth-subtitle mb-1">Xin chào, <strong><%= user.getFullName() %></strong></p>
      <p class="auth-subtitle">Vai trò: <%= user.getRole() %></p>
      <a class="btn-submit-orange mb-3" href="${pageContext.request.contextPath}/Auth?action=changePassword">Đổi mật khẩu</a>
      <div class="text-center">
        <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=logout">Đăng xuất</a>
      </div>
      <% } %>
    </div>
  </div>
</body>
</html>
