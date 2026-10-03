<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Nếu server không có sẵn JSTL (Tomcat), thêm dependency jakarta.servlet.jsp.jstl --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tạo sự kiện - LTM</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/bootstrap.css">
</head>
<body class="bg-light">
<main class="container py-4" style="max-width: 800px;">
    <div class="card shadow-sm">
        <div class="card-body p-4">
            <h1 class="h4 mb-4">Tạo sự kiện mới</h1>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success"><c:out value="${successMessage}"/></div>
            </c:if>
            <c:if test="${not empty errors.general}">
                <div class="alert alert-danger"><c:out value="${errors.general}"/></div>
            </c:if>

            <form id="create-event-form" method="post" enctype="multipart/form-data" novalidate
                  action="${pageContext.request.contextPath}/organizer/event/create">

                <div class="mb-3">
                    <label for="eventName" class="form-label">Tên sự kiện <span class="text-danger">*</span></label>
                    <input type="text" id="eventName" name="eventName" maxlength="200"
                           class="form-control ${not empty errors.eventName ? 'is-invalid' : ''}"
                           value="<c:out value='${event.eventName}'/>">
                    <div class="invalid-feedback"><c:out value="${errors.eventName}"/></div>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Mô tả <span class="text-danger">*</span></label>
                    <textarea id="description" name="description" rows="6" maxlength="5000"
                              class="form-control ${not empty errors.description ? 'is-invalid' : ''}"><c:out value="${event.description}"/></textarea>
                    <div class="invalid-feedback"><c:out value="${errors.description}"/></div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="categoryId" class="form-label">Danh mục <span class="text-danger">*</span></label>
                        <select id="categoryId" name="categoryId"
                                class="form-select ${not empty errors.categoryId ? 'is-invalid' : ''}">
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach var="category" items="${categories}">
                                <option value="${category.key}" ${event.categoryId == category.key ? 'selected' : ''}>
                                    <c:out value="${category.value}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <div class="invalid-feedback"><c:out value="${errors.categoryId}"/></div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label for="venueId" class="form-label">Địa điểm <span class="text-danger">*</span></label>
                        <select id="venueId" name="venueId"
                                class="form-select ${not empty errors.venueId ? 'is-invalid' : ''}">
                            <option value="">-- Chọn địa điểm --</option>
                            <c:forEach var="venue" items="${venues}">
                                <option value="${venue.key}" ${event.venueId == venue.key ? 'selected' : ''}>
                                    <c:out value="${venue.value}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <div class="invalid-feedback"><c:out value="${errors.venueId}"/></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="startTime" class="form-label">Bắt đầu <span class="text-danger">*</span></label>
                        <input type="datetime-local" id="startTime" name="startTime"
                               class="form-control ${not empty errors.startTime ? 'is-invalid' : ''}"
                               value="${event.startTime}">
                        <div class="invalid-feedback"><c:out value="${errors.startTime}"/></div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="endTime" class="form-label">Kết thúc <span class="text-danger">*</span></label>
                        <input type="datetime-local" id="endTime" name="endTime"
                               class="form-control ${not empty errors.endTime ? 'is-invalid' : ''}"
                               value="${event.endTime}">
                        <div class="invalid-feedback"><c:out value="${errors.endTime}"/></div>
                    </div>
                </div>

                <div class="mb-4">
                    <label for="eventImage" class="form-label">Ảnh sự kiện (JPG, PNG, WEBP, tối đa 5MB)</label>
                    <input type="file" id="eventImage" name="eventImage" accept=".jpg,.jpeg,.png,.webp"
                           class="form-control ${not empty errors.eventImage ? 'is-invalid' : ''}">
                    <div class="invalid-feedback"><c:out value="${errors.eventImage}"/></div>
                </div>

                <button type="submit" class="btn btn-primary">Tạo sự kiện</button>
            </form>
        </div>
    </div>
</main>
<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/event.js"></script>
</body>
</html>
