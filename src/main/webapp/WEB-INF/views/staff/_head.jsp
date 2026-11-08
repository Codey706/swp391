<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/organizer.css">
<style>
    :root {
        --staff-accent: #d93a27;
        --staff-accent-hover: #b42e1d;
        --staff-bg: #f5f5f6;
    }
    body { font-family: 'Inter', sans-serif; background-color: var(--staff-bg); }
    .staff-card {
        background: #fff;
        border: 1px solid #e4e4e7;
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        padding: 24px;
        margin-bottom: 20px;
    }
</style>