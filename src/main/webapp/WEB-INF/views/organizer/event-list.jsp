<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách sự kiện - LTM</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.css">
</head>
<body class="bg-light">
<main class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="h4 mb-0">Sự kiện của tôi <span class="text-muted fs-6">(${totalEvents})</span></h1>
        <a href="${pageContext.request.contextPath}/organizer/event/create" class="btn btn-primary">+ Tạo sự kiện</a>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success"><c:out value="${successMessage}"/></div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
    </c:if>

    <form method="get" action="${pageContext.request.contextPath}/organizer/event/list" class="row g-2 mb-3">
        <div class="col-md-6">
            <input type="text" name="keyword" class="form-control" maxlength="200"
                   placeholder="Tìm theo tên sự kiện..." value="<c:out value='${keyword}'/>">
        </div>
        <div class="col-md-3">
            <select name="status" class="form-select">
                <option value="">Tất cả trạng thái</option>
                <c:forEach var="status" items="${statuses}">
                    <option value="${status}" ${selectedStatus == status ? 'selected' : ''}>${status}</option>
                </c:forEach>
            </select>
        </div>
        <div class="col-md-3 d-flex gap-2">
            <button type="submit" class="btn btn-outline-primary">Tìm kiếm</button>
            <a href="${pageContext.request.contextPath}/organizer/event/list" class="btn btn-outline-secondary">Xóa lọc</a>
        </div>
    </form>

    <div class="card shadow-sm">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th style="width: 90px;">Ảnh</th>
                    <th>Sự kiện</th>
                    <th>Danh mục</th>
                    <th>Địa điểm</th>
                    <th>Thời gian</th>
                    <th>Trạng thái</th>
                    <th class="text-end">Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="e" items="${events}">
                    <c:set var="modifiable" value="${e.status == 'DRAFT' || e.status == 'REJECTED'}"/>
                    <tr>
                        <td>
                            <c:if test="${not empty e.eventImage}">
                                <img src="${pageContext.request.contextPath}/<c:out value='${e.eventImage}'/>"
                                     alt="" class="rounded" style="width: 72px; height: 48px; object-fit: cover;">
                            </c:if>
                        </td>
                        <td class="fw-semibold"><c:out value="${e.eventName}"/></td>
                        <td><c:out value="${e.categoryName}"/></td>
                        <td><c:out value="${e.venueName}"/></td>
                        <td class="small">
                            ${fn:replace(fn:substring(e.startTime, 0, 16), 'T', ' ')}<br>
                            ${fn:replace(fn:substring(e.endTime, 0, 16), 'T', ' ')}
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${e.status == 'ACTIVE'}"><span class="badge bg-success">${e.status}</span></c:when>
                                <c:when test="${e.status == 'PENDING_APPROVAL'}"><span class="badge bg-warning text-dark">${e.status}</span></c:when>
                                <c:when test="${e.status == 'REJECTED' || e.status == 'CANCELLED'}"><span class="badge bg-danger">${e.status}</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${e.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end text-nowrap">
                            <c:if test="${modifiable}">
                                <a class="btn btn-sm btn-outline-primary"
                                   href="${pageContext.request.contextPath}/organizer/event/update?eventId=${e.eventId}">Sửa</a>
                                <form method="post" class="d-inline js-confirm-delete"
                                      action="${pageContext.request.contextPath}/organizer/event/delete"
                                      data-event-name="<c:out value='${e.eventName}'/>">
                                    <input type="hidden" name="eventId" value="${e.eventId}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">Xóa</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty events}">
                    <tr><td colspan="7" class="text-center text-muted py-4">Chưa có sự kiện nào.</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <c:if test="${totalPages > 1}">
        <c:url var="pageBase" value="/organizer/event/list">
            <c:if test="${not empty keyword}"><c:param name="keyword" value="${keyword}"/></c:if>
            <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
        </c:url>
        <c:set var="joiner" value="${fn:contains(pageBase, '?') ? '&' : '?'}"/>
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                    <a class="page-link" href="${pageBase}${joiner}page=${page - 1}">Trước</a>
                </li>
                <c:forEach var="i" begin="1" end="${totalPages}">
                    <li class="page-item ${i == page ? 'active' : ''}">
                        <a class="page-link" href="${pageBase}${joiner}page=${i}">${i}</a>
                    </li>
                </c:forEach>
                <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                    <a class="page-link" href="${pageBase}${joiner}page=${page + 1}">Sau</a>
                </li>
            </ul>
        </nav>
    </c:if>
</main>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/event.js"></script>
</body>
</html>
