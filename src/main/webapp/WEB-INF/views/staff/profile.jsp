<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Hồ sơ nhân viên - Light Ticket</title>
    <jsp:include page="_head.jsp"/>
    <style>
        .staff-badge-status {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 9999px; font-size: 13px; font-weight: 600;
            background: #ecfdf5; color: #059669;
        }
        .info-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px;
        }
        .info-cell {
            background: #f8fafc; border: 1px solid #f1f5f9; border-radius: 12px; padding: 16px;
        }
        .info-cell .label {
            font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase;
            letter-spacing: 0.05em; margin-bottom: 4px; display: flex; align-items: center; gap: 6px;
        }
        .info-cell .val { font-size: 15px; font-weight: 600; color: #1e293b; }
        .btn-staff-outline {
            background: #fff; color: #475569; border: 1px solid #cbd5e1;
            font-weight: 600; padding: 10px 18px; border-radius: 10px;
            display: inline-flex; align-items: center; gap: 8px; text-decoration: none; transition: all 0.2s;
        }
        .btn-staff-outline:hover { background: #f8fafc; color: #1e293b; border-color: #94a3b8; }
    </style>
</head>
<body class="org-body">
    <jsp:include page="_header.jsp">
        <jsp:param name="active" value="profile"/>
        <jsp:param name="current" value="Hồ sơ nhân viên"/>
    </jsp:include>

    <main class="org-main">
        <div class="org-container" style="max-width: 1000px; margin: 0 auto; padding: 32px 20px;">
            <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
                <div>
                    <h1 class="h3 fw-bold mb-1" style="color: #0f172a;">Thông tin nhân viên</h1>
                    <p class="text-muted small mb-0">Hồ sơ cá nhân và phân quyền soát vé tại sự kiện</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/staff/change-password" class="btn-staff-outline">
                        <span class="material-symbols-outlined" style="font-size: 18px;">lock_reset</span>
                        <span>Đổi mật khẩu</span>
                    </a>
                </div>
            </div>

            <div class="staff-card">
                <div class="d-flex align-items-center gap-4 mb-4 pb-3 border-bottom">
                    <div class="d-flex align-items-center justify-content-center text-white fw-bold rounded-circle" 
                         style="width: 72px; height: 72px; font-size: 28px; background: linear-gradient(135deg, #ff7043, #f4511e); box-shadow: 0 4px 12px rgba(255, 112, 67, 0.3);">
                        ${fn:toUpperCase(fn:substring(sessionScope.user.fullName, 0, 1))}
                    </div>
                    <div>
                        <h2 class="h5 fw-bold mb-1 text-dark">${sessionScope.user.fullName}</h2>
                        <div class="d-flex align-items-center gap-2">
                            <span class="text-muted small">@${sessionScope.user.username}</span>
                            <span class="text-muted">•</span>
                            <span class="staff-badge-status">
                                <span class="material-symbols-outlined" style="font-size: 16px;">verified</span>
                                ${sessionScope.user.status}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="info-grid">
                    <div class="info-cell">
                        <div class="label">
                            <span class="material-symbols-outlined" style="font-size: 16px;">mail</span>
                            Email
                        </div>
                        <div class="val text-break">${sessionScope.user.email}</div>
                    </div>

                    <div class="info-cell">
                        <div class="label">
                            <span class="material-symbols-outlined" style="font-size: 16px;">phone</span>
                            Số điện thoại
                        </div>
                        <div class="val">${empty sessionScope.user.phone ? 'Chưa cập nhật' : sessionScope.user.phone}</div>
                    </div>

                    <div class="info-cell">
                        <div class="label">
                            <span class="material-symbols-outlined" style="font-size: 16px;">badge</span>
                            Họ và tên
                        </div>
                        <div class="val">${sessionScope.user.fullName}</div>
                    </div>

                    <div class="info-cell">
                        <div class="label">
                            <span class="material-symbols-outlined" style="font-size: 16px;">manage_accounts</span>
                            Vai trò
                        </div>
                        <div class="val">${sessionScope.user.role}</div>
                    </div>

                    <div class="info-cell" style="grid-column: 1 / -1;">
                        <div class="label">
                            <span class="material-symbols-outlined" style="font-size: 16px;">location_on</span>
                            Địa chỉ
                        </div>
                        <div class="val">${empty sessionScope.user.address ? 'Chưa cập nhật địa chỉ' : sessionScope.user.address}</div>
                    </div>
                </div>
            </div>

            <!-- Security info -->
            <div class="staff-card">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <div class="d-flex align-items-center gap-2">
                        <span class="material-symbols-outlined text-warning" style="font-size: 24px;">security</span>
                        <h3 class="h6 fw-bold mb-0 text-dark">Bảo mật tài khoản</h3>
                    </div>
                    <a href="${pageContext.request.contextPath}/staff/change-password" class="text-decoration-none fw-semibold small" style="color: #ff7043;">
                        Đổi mật khẩu ngay &rarr;
                    </a>
                </div>
                <p class="text-muted small mb-0">Nhân viên sự kiện chịu trách nhiệm bảo mật tài khoản để đảm bảo an toàn cho tiến trình quét vé và soát chỗ ngồi.</p>
            </div>
        </div>
    </main>

    <jsp:include page="_footer.jsp"/>
</body>
</html>
