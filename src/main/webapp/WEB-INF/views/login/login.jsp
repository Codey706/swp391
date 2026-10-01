<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Login - Light Ticket</title>

    <!-- Bootstrap -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css"
        rel="stylesheet"
    >

    <style>
        body {
            min-height: 100vh;
            background: #f5f8f6;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            background: white;
            border-radius: 16px;
            padding: 35px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
        }

        .logo {
            text-align: center;
            margin-bottom: 25px;
        }

        .logo h2 {
            color: #198754;
            font-weight: 700;
        }

        .logo p {
            color: #777;
            margin-bottom: 0;
        }

        .form-label {
            font-weight: 600;
        }

        .btn-login {
            width: 100%;
            background: #198754;
            border: none;
            padding: 11px;
            font-weight: 600;
        }

        .btn-login:hover {
            background: #157347;
        }

        .login-footer {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
        }

        .login-footer a {
            color: #198754;
            text-decoration: none;
            font-weight: 600;
        }
    </style>
</head>

<body>

<div class="login-card">

    <!-- Logo / Title -->
    <div class="logo">
        <h2>Light Ticket</h2>
        <p>Welcome back!</p>
    </div>

    <!-- Error message -->
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">
            <%= request.getAttribute("error") %>
        </div>
    <% } %>

    <!-- Login Form -->
    <form action="${pageContext.request.contextPath}/login"
          method="post">

        <!-- Email -->
        <div class="mb-3">
            <label for="email" class="form-label">
                Email
            </label>

            <input
                type="email"
                class="form-control"
                id="email"
                name="email"
                placeholder="Enter your email"
                required
            >
        </div>

        <!-- Password -->
        <div class="mb-3">
            <label for="password" class="form-label">
                Password
            </label>

            <input
                type="password"
                class="form-control"
                id="password"
                name="password"
                placeholder="Enter your password"
                required
            >
        </div>

        <!-- Remember me -->
        <div class="d-flex justify-content-between align-items-center mb-4">

            <div class="form-check">
                <input
                    class="form-check-input"
                    type="checkbox"
                    id="remember"
                    name="remember"
                >

                <label class="form-check-label" for="remember">
                    Remember me
                </label>
            </div>

            <a href="${pageContext.request.contextPath}/forgot-password">
                Forgot password?
            </a>

        </div>

        <!-- Login button -->
        <button type="submit"
                class="btn btn-success btn-login">
            Login
        </button>

    </form>

    <!-- Register -->
    <div class="login-footer">
        Don't have an account?
        <a href="${pageContext.request.contextPath}/register">
            Register
        </a>
    </div>

</div>

</body>
</html>