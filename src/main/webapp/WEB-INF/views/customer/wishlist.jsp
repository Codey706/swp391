
<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport"
              content="width=device-width, initial-scale=1">

        <title>My Wishlist | Light Ticket</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <link rel="stylesheet"
              href="${ctx}/assets/vendor/phosphor/style.css">

        <link rel="stylesheet"
              href="${ctx}/assets/css/ui.css">

        <link rel="stylesheet"
              href="${ctx}/assets/css/theme.css">

        <style>
            body {
                background: #f8f9fc;
            }

            .wishlist-container {
                max-width: 1200px;
                margin: 45px auto;
                padding: 0 20px;
            }

            .wishlist-title {
                font-size: 30px;
                font-weight: 800;
                margin-bottom: 8px;
            }

            .wishlist-subtitle {
                color: #777;
                margin-bottom: 30px;
            }

            .wishlist-card {
                background: white;
                border-radius: 16px;
                overflow: hidden;
                border: 1px solid #eee;
                height: 100%;
                box-shadow: 0 4px 12px rgba(0,0,0,.04);
            }

            .wishlist-image {
                width: 100%;
                height: 200px;
                object-fit: cover;
                background: #eee;
            }

            .wishlist-content {
                padding: 20px;
            }

            .wishlist-event-name {
                font-size: 19px;
                font-weight: 700;
            }

            .wishlist-info {
                color: #666;
                font-size: 14px;
                margin-top: 8px;
            }

            .wishlist-actions {
                display: flex;
                gap: 10px;
                margin-top: 20px;
            }

            .wishlist-actions form {
                flex: 1;
            }

            .wishlist-actions .btn {
                width: 100%;
            }

            .empty-wishlist {
                text-align: center;
                background: white;
                border-radius: 16px;
                padding: 65px 20px;
            }

            .empty-wishlist i {
                font-size: 55px;
                color: #ef4444;
            }
        </style>
    </head>

    <body>

        <jsp:include page="/WEB-INF/views/common/site-header.jsp">
            <jsp:param name="active" value="wishlist"/>
        </jsp:include>

        <main class="wishlist-container">

            <h1 class="wishlist-title">
                <i class="ph ph-heart" style="color:#ef4444"></i>
                My Wishlist
            </h1>

            <p class="wishlist-subtitle">
                Những sự kiện bạn đã lưu để theo dõi và đặt vé sau.
            </p>

            <c:choose>

                <c:when test="${empty wishlist}">

                    <div class="empty-wishlist">

                        <i class="ph ph-heart"></i>

                        <h3>Danh sách yêu thích đang trống</h3>

                        <p>Bạn chưa lưu sự kiện nào.</p>

                        <a href="${ctx}/home"
                           class="btn btn-primary">
                            Khám phá sự kiện
                        </a>

                    </div>

                </c:when>

                <c:otherwise>

                    <div class="row g-4">

                        <c:forEach var="e" items="${wishlist}">

                            <div class="col-md-6 col-lg-4">

                                <div class="wishlist-card">

                                    <c:choose>
                                        <c:when test="${not empty e.eventImage and not fn:startsWith(e.eventImage, 'http')}">
                                            <img class="wishlist-image"
                                                 src="${ctx}/${fn:escapeXml(e.eventImage)}"
                                                 alt="Ảnh sự kiện">
                                        </c:when>

                                        <c:otherwise>
                                            <div class="wishlist-image d-flex align-items-center justify-content-center">
                                                <i class="ph ph-calendar"
                                                   style="font-size:45px"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="wishlist-content">

                                        <span class="badge text-bg-light">
                                            <c:out value="${e.categoryName}"/>
                                        </span>

                                        <h3 class="wishlist-event-name mt-3">
                                            <c:out value="${e.eventName}"/>
                                        </h3>

                                        <p class="wishlist-info">
                                            <i class="ph ph-map-pin"></i>
                                        <c:out value="${e.venueName}"/>
                                        </p>

                                        <p class="wishlist-info">
                                            <i class="ph ph-calendar"></i>
                                        <c:out value="${e.startTime}"/>
                                        </p>

                                        <c:if test="${not empty e.minPrice}">
                                            <p class="fw-bold text-danger">
                                                Từ
                                            <fmt:formatNumber
                                                value="${e.minPrice}"
                                                pattern="#,##0"/> đ
                                            </p>
                                        </c:if>

                                        <div class="wishlist-actions">

                                            <a href="${ctx}/event/detail?id=${e.eventId}"
                                               class="btn btn-primary">
                                                Xem chi tiết
                                            </a>

                                            <form method="post"
                                                  action="${ctx}/customer/wishlist">

                                                <input type="hidden"
                                                       name="csrfToken"
                                                       value="${csrfToken}">

                                                <input type="hidden"
                                                       name="eventId"
                                                       value="${e.eventId}">

                                                <input type="hidden"
                                                       name="action"
                                                       value="remove">

                                                <button type="submit"
                                                        class="btn btn-outline-danger">
                                                    <i class="ph ph-trash"></i>
                                                    Xóa
                                                </button>

                                            </form>

                                        </div>
                                    </div>
                                </div>
                            </div>

                        </c:forEach>

                    </div>

                </c:otherwise>
            </c:choose>

        </main>

        <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>

    </body>
</html>
