<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Light Ticket - Đăng xuất</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/login.css">
</head>
<body>
  <div class="auth-card text-center">
    <h1 class="auth-title">Đăng xuất</h1>
    <p class="auth-subtitle">Phiên đăng nhập được xử lý tại /Auth?action=logout</p>
    <a class="link-orange" href="${pageContext.request.contextPath}/Auth?action=logout">Đăng xuất ngay</a>
  </div>
</body>
</html>
