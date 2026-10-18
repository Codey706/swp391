<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
    <link rel="stylesheet" href="${ctx}/assets/css/bootstrap.css">
    <link rel="stylesheet" href="${ctx}/assets/css/select-event.css">
    <title>Chọn sự kiện - Light Ticket</title>
</head>
<body class="bk-page d-flex flex-column min-vh-100">
<header class="bk-header sticky-top">
    <div class="container-xl bk-header-inner d-flex align-items-center justify-content-between gap-3">
        <div class="d-flex align-items-center gap-4">
            <a class="d-flex align-items-center gap-2" href="${ctx}/home">
                <div class="bk-logo-mark">LT</div>
                <div class="d-flex flex-column">
                    <span class="bk-logo-text">Light<span>Ticket</span></span>
                    <span class="bk-logo-sub">Live Event Platform</span>
                </div>
            </a>
            <nav class="d-none d-md-flex align-items-center gap-1">
                <a class="bk-nav active" href="${ctx}/booking/events">Sự kiện</a>
                <a class="bk-nav" href="${ctx}/customer/booking-history">Vé của tôi</a>
            </nav>
        </div>

        <c:choose>
            <c:when test="${not empty sessionScope.user}">
                <c:set var="displayName" value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : sessionScope.user.username}"/>
                <div class="d-flex align-items-center gap-2">
                    <div class="bk-avatar"><c:out value="${fn:toUpperCase(fn:substring(displayName, 0, 1))}"/></div>
                    <span class="d-none d-md-inline small fw-bold"><c:out value="${displayName}"/></span>
                </div>
            </c:when>
            <c:otherwise>
                <a class="btn btn-brand btn-sm px-3" href="${ctx}/Auth?action=login">Đăng nhập</a>
            </c:otherwise>
        </c:choose>
    </div>
</header>

<main class="flex-grow-1">
    <!-- Banner tiêu đề + tìm kiếm -->
    <section class="bk-band py-4">
        <div class="container-xl">
            <nav class="bk-crumb d-flex align-items-center gap-2 mb-3" aria-label="Breadcrumb">
                <a class="d-flex align-items-center gap-1" href="${ctx}/home"><span class="material-symbols-outlined" style="font-size:15px">home</span> Trang chủ</a>
                <span class="sep">/</span>
                <span class="current">Sự kiện</span>
            </nav>
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-end gap-3">
                <div>
                    <h1 class="h3 fw-bold mb-1">Chọn sự kiện</h1>
                    <p class="text-muted-lt mb-0">Chọn sự kiện bạn muốn tham gia để tiếp tục đặt vé.</p>
                </div>
                <form class="bk-search position-relative" method="get" action="${ctx}/booking/events">
                    <div class="d-flex gap-2">
                        <div class="position-relative flex-grow-1">
                            <span class="material-symbols-outlined bi-icon">search</span>
                            <input type="text" class="form-control" name="keyword" maxlength="50"
                                   placeholder="Tìm theo tên sự kiện..." value="<c:out value='${keyword}'/>">
                        </div>
                        <button type="submit" class="btn btn-brand px-4">Tìm</button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <div class="container-xl py-4">
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger d-flex align-items-center gap-2" role="alert">
                <span class="material-symbols-outlined">error</span>
                <span><c:out value="${errorMessage}"/></span>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty events}">
                <div class="bk-card text-center py-5 px-3">
                    <span class="material-symbols-outlined text-outline-lt" style="font-size:3rem">event_busy</span>
                    <h2 class="h5 fw-bold mt-2">Không có sự kiện nào phù hợp</h2>
                    <p class="text-muted-lt mb-3">
                        <c:choose>
                            <c:when test="${not empty keyword}">Không tìm thấy sự kiện nào với từ khóa "<c:out value="${keyword}"/>".</c:when>
                            <c:otherwise>Hiện chưa có sự kiện nào đang mở bán vé.</c:otherwise>
                        </c:choose>
                    </p>
                    <c:if test="${not empty keyword}">
                        <div><a class="btn btn-outline-secondary" href="${ctx}/booking/events">Xem tất cả sự kiện</a></div>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <p class="small text-muted-lt mb-3"><strong>${totalEvents}</strong> sự kiện</p>
                <div class="row g-4">
                    <c:forEach var="e" items="${events}">
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="bk-card bk-event h-100 d-flex flex-column">
                                <div class="bk-thumb">
                                    <c:if test="${not empty e.eventImage}">
                                        <img class="js-event-image" src="${ctx}/<c:out value='${e.eventImage}'/>" alt="<c:out value='${e.eventName}'/>">
                                    </c:if>
                                    <span class="bk-badge"><c:out value="${e.categoryName}"/></span>
                                    <c:if test="${e.soldOut}"><div class="bk-soldout-mask">Hết vé</div></c:if>
                                </div>
                                <div class="p-3 d-flex flex-column flex-grow-1">
                                    <h2 class="h6 fw-bold bk-event-title mb-3"><c:out value="${e.eventName}"/></h2>
                                    <div class="bk-meta mb-1"><span class="material-symbols-outlined">calendar_month</span><c:out value="${e.startTimeText}"/></div>
                                    <div class="bk-meta mb-3"><span class="material-symbols-outlined">location_on</span><c:out value="${e.venueName}"/></div>
                                    <div class="mt-auto d-flex justify-content-between align-items-center pt-3 border-top">
                                        <div>
                                            <c:choose>
                                                <c:when test="${e.soldOut}"><span class="fw-bold text-danger">Hết vé</span></c:when>
                                                <c:otherwise>
                                                    <div class="lt-xs text-outline-lt">Từ</div>
                                                    <div class="fw-bold fs-5 text-brand"><fmt:formatNumber value="${e.minPrice}" pattern="#,##0"/> ₫</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <c:choose>
                                            <c:when test="${e.soldOut}">
                                                <button class="btn btn-secondary" type="button" disabled>Đặt vé</button>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="btn btn-brand px-4" href="${ctx}/booking/select-ticket?eventId=${e.eventId}">Đặt vé</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </article>
                        </div>
                    </c:forEach>
                </div>

                <c:if test="${totalPages > 1}">
                    <nav class="mt-5" aria-label="Phân trang">
                        <ul class="pagination justify-content-center">
                            <c:forEach var="p" begin="1" end="${totalPages}">
                                <c:url var="pageUrl" value="/booking/events">
                                    <c:param name="keyword" value="${keyword}"/>
                                    <c:param name="page" value="${p}"/>
                                </c:url>
                                <li class="page-item ${p == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageUrl}">${p}</a>
                                </li>
                            </c:forEach>
                        </ul>
                    </nav>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<footer class="bk-footer mt-5">
    <div class="container-xl py-5">
        <div class="row g-4">
            <div class="col-lg-6">
                <div class="d-flex align-items-center gap-2 mb-3">
                    <div class="bk-logo-mark" style="width:36px;height:36px;font-size:1.1rem;">LT</div>
                    <span class="bk-logo-text" style="font-size:1.25rem;">Light<span>Ticket</span></span>
                </div>
                <p class="small text-muted-lt mb-0" style="max-width:26rem;">Nền tảng mua vé sự kiện trực tiếp: hòa nhạc, lễ hội âm nhạc, kịch sân khấu và workshop.</p>
            </div>
            <div class="col-6 col-lg-3">
                <h3 class="bk-footer-title mb-3">Khám phá</h3>
                <nav class="d-flex flex-column gap-2">
                    <a href="${ctx}/booking/events">Tất cả sự kiện</a>
                    <a href="${ctx}/customer/booking-history">Vé của tôi</a>
                </nav>
            </div>
            <div class="col-6 col-lg-3">
                <h3 class="bk-footer-title mb-3">Hỗ trợ</h3>
                <nav class="d-flex flex-column gap-2">
                    <a href="#">Trung tâm trợ giúp</a>
                    <a href="#">Chính sách hoàn vé</a>
                </nav>
            </div>
        </div>
    </div>
    <div class="bk-footer-bottom py-3">
        <div class="container-xl">© 2025 Light Ticket Joint Stock Co. Bảo lưu mọi quyền.</div>
    </div>
</footer>
<script src="${ctx}/assets/js/select-event.js"></script>
</body>
</html>
