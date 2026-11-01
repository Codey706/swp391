<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="staffInitial" value="${fn:toUpperCase(fn:substring(staff.fullName, 0, 1))}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Hồ sơ nhân viên - Light Ticket</title>
    <jsp:include page="/WEB-INF/views/staff/_head.jsp"/>
    <style>
        .staff-badge-status {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 9999px; font-size: 13px; font-weight: 600;
            background: #ecfdf5; color: #059669;
        }
        .stat-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 20px; }
        .stat-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 16px 18px; }
        .stat-box .num { font-size: 26px; font-weight: 800; color: #0f172a; line-height: 1.1; }
        .stat-box .lbl { font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: .05em; margin-top: 4px; }
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }
        .form-grid .full { grid-column: 1 / -1; }
        .sf-label { font-size: 12px; font-weight: 600; color: #64748b; text-transform: uppercase; letter-spacing: .05em; margin-bottom: 6px; display: block; }
        .sf-label .req { color: #dc2626; }
        .sf-input {
            width: 100%; border: 1px solid #cbd5e1; border-radius: 10px; padding: 10px 14px;
            font-size: 15px; font-weight: 500; color: #1e293b; background: #fff; transition: border-color .2s, box-shadow .2s;
        }
        .sf-input:focus { outline: none; border-color: #ff7043; box-shadow: 0 0 0 3px rgba(255,112,67,.18); }
        .sf-input.is-invalid { border-color: #dc2626; }
        .sf-input[readonly] { background: #f8fafc; color: #64748b; cursor: not-allowed; }
        .sf-error { color: #dc2626; font-size: 13px; margin-top: 4px; min-height: 0; }
        .sf-error:empty { display: none; }
        .sf-hint { color: #94a3b8; font-size: 12px; margin-top: 4px; }
        .btn-staff-primary {
            background: #ff7043; color: #fff; border: 0; font-weight: 700; padding: 10px 22px; border-radius: 10px;
            display: inline-flex; align-items: center; gap: 8px; transition: background .2s;
        }
        .btn-staff-primary:hover { background: #f4511e; }
        .btn-staff-outline {
            background: #fff; color: #475569; border: 1px solid #cbd5e1;
            font-weight: 600; padding: 10px 18px; border-radius: 10px;
            display: inline-flex; align-items: center; gap: 8px; text-decoration: none; transition: all 0.2s;
        }
        .btn-staff-outline:hover { background: #f8fafc; color: #1e293b; border-color: #94a3b8; }
    </style>
</head>
<body class="org-body">
    <jsp:include page="/WEB-INF/views/staff/_header.jsp">
        <jsp:param name="active" value="profile"/>
        <jsp:param name="current" value="Hồ sơ nhân viên"/>
    </jsp:include>

    <main class="org-main">
        <div class="org-container" style="max-width: 1000px; margin: 0 auto; padding: 32px 20px;">
            <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 mb-4">
                <div>
                    <h1 class="h3 fw-bold mb-1" style="color: #0f172a;">Hồ sơ nhân viên</h1>
                </div>
                <div class="d-flex gap-2">
                    <a href="${ctx}/staff/change-password" class="btn-staff-outline">
                        <span class="material-symbols-outlined" style="font-size: 18px;">lock_reset</span>
                        <span>Đổi mật khẩu</span>
                    </a>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="lt-alert success" role="status">
                    <span class="material-symbols-outlined">check_circle</span>
                    <div><c:out value="${successMessage}"/></div>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="lt-alert error" role="alert">
                    <span class="material-symbols-outlined">error</span>
                    <div><c:out value="${errorMessage}"/></div>
                </div>
            </c:if>

            <%-- Số liệu công việc --%>
            <div class="stat-row">
                <div class="stat-box"><div class="num"><c:out value="${assignedEvents}"/></div><div class="lbl">Sự kiện được phân công</div></div>
                <div class="stat-box"><div class="num"><c:out value="${upcomingEvents}"/></div><div class="lbl">Sắp / đang diễn ra</div></div>
                <div class="stat-box"><div class="num"><c:out value="${checkedInTickets}"/></div><div class="lbl">Vé đã check-in</div></div>
            </div>

            <%-- Thẻ tóm tắt --%>
            <div class="staff-card">
                <div class="d-flex align-items-center gap-4">
                    <div class="d-flex align-items-center justify-content-center text-white fw-bold rounded-circle"
                         style="width: 72px; height: 72px; font-size: 28px; background: linear-gradient(135deg, #ff7043, #f4511e); box-shadow: 0 4px 12px rgba(255,112,67,.3);">
                        <c:out value="${staffInitial}"/>
                    </div>
                    <div>
                        <h2 class="h5 fw-bold mb-1 text-dark"><c:out value="${staff.fullName}"/></h2>
                        <div class="d-flex flex-wrap align-items-center gap-2">
                            <span class="text-muted small">@<c:out value="${staff.username}"/></span>
                            <span class="text-muted">•</span>
                            <span class="text-muted small"><c:out value="${staff.role}"/></span>
                            <span class="text-muted">•</span>
                            <span class="staff-badge-status">
                                <span class="material-symbols-outlined" style="font-size: 16px;">verified</span>
                                <c:out value="${staff.status}"/>
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Form chỉnh sửa --%>
            <form method="post" action="${ctx}/staff/profile" class="staff-card" novalidate>
                <input type="hidden" name="csrfToken" value="<c:out value='${csrfToken}'/>">

                <div class="d-flex align-items-center gap-2 mb-3 pb-3 border-bottom">
                    <span class="material-symbols-outlined" style="color:#ff7043;">edit_note</span>
                    <h3 class="h6 fw-bold mb-0 text-dark">Thông tin cá nhân</h3>
                </div>

                <div class="form-grid">
                    <div>
                        <label class="sf-label" for="fullName">Họ và tên <span class="req">*</span></label>
                        <input type="text" id="fullName" name="fullName" maxlength="100"
                               class="sf-input ${not empty errors.fullName ? 'is-invalid' : ''}"
                               value="<c:out value='${form.fullName}'/>" required>
                        <div class="sf-error"><c:out value="${errors.fullName}"/></div>
                    </div>

                    <div>
                        <label class="sf-label" for="username">Tên đăng nhập</label>
                        <input type="text" id="username" class="sf-input" value="<c:out value='${staff.username}'/>" readonly>
                        <div class="sf-hint">Không thể thay đổi tên đăng nhập.</div>
                    </div>

                    <div>
                        <label class="sf-label" for="email">Email <span class="req">*</span></label>
                        <input type="email" id="email" name="email" maxlength="255"
                               class="sf-input ${not empty errors.email ? 'is-invalid' : ''}"
                               value="<c:out value='${form.email}'/>" required>
                        <div class="sf-error"><c:out value="${errors.email}"/></div>
                    </div>

                    <div>
                        <label class="sf-label" for="phone">Số điện thoại <span class="req">*</span></label>
                        <input type="tel" id="phone" name="phone" maxlength="20"
                               class="sf-input ${not empty errors.phone ? 'is-invalid' : ''}"
                               value="<c:out value='${form.phone}'/>" required>
                        <div class="sf-error"><c:out value="${errors.phone}"/></div>
                    </div>

                    <div class="full">
                        <label class="sf-label" for="address">Địa chỉ</label>
                        <input type="text" id="address" name="address" maxlength="255"
                               class="sf-input ${not empty errors.address ? 'is-invalid' : ''}"
                               value="<c:out value='${form.address}'/>">
                        <div class="sf-error"><c:out value="${errors.address}"/></div>
                    </div>
                </div>

                <div class="d-flex flex-wrap justify-content-end gap-2 mt-4 pt-3 border-top">
                    <a href="${ctx}/staff/profile" class="btn-staff-outline">Hủy thay đổi</a>
                    <button type="submit" class="btn-staff-primary">
                        <span class="material-symbols-outlined" style="font-size: 18px;">save</span>
                        <span>Lưu thay đổi</span>
                    </button>
                </div>
            </form>

            <%-- Bảo mật --%>
            <div class="staff-card">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <div class="d-flex align-items-center gap-2">
                        <span class="material-symbols-outlined text-warning" style="font-size: 24px;">security</span>
                        <h3 class="h6 fw-bold mb-0 text-dark">Bảo mật tài khoản</h3>
                    </div>
                    <a href="${ctx}/staff/change-password" class="text-decoration-none fw-semibold small" style="color: #ff7043;">
                        Đổi mật khẩu ngay &rarr;
                    </a>
                </div>
                <p class="text-muted small mb-0">Nhân viên sự kiện chịu trách nhiệm bảo mật tài khoản để đảm bảo an toàn cho tiến trình quét vé và soát chỗ ngồi.</p>
            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/staff/_footer.jsp"/>
</body>
</html>
