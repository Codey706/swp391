<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Light Ticket - Nền tảng bán vé sự kiện trực tiếp hàng đầu</title>

        <!-- Google Fonts: Plus Jakarta Sans -->
        <link href="https://fonts.googleapis.com" rel="preconnect"/>
        <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>

        <!-- Material Symbols Outlined -->

        <!-- Bootstrap 5.3 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>

        <!-- External CSS -->
        <link href="${pageContext.request.contextPath}/assets/css/home.css?v=20261108" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/stitch-custom.css" rel="stylesheet"/>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/phosphor/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/phosphor/fill.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ui.css">
        <script src="${pageContext.request.contextPath}/assets/js/ui.js" defer></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css?v=20261109">
        <script src="${pageContext.request.contextPath}/assets/js/motion.js?v=20261109" defer></script>

        <style>
            .event-card-media {
                position: relative;
            }

            .wishlist-card-form,
            .wishlist-heart {
                position: absolute;
                top: 12px;
                right: 12px;
                z-index: 5;
            }

            .wishlist-heart {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: white;
                border: none;
                display: flex;
                align-items: center;
                justify-content: center;
                color: #ef4444;
                font-size: 22px;
                cursor: pointer;
                text-decoration: none;
                box-shadow: 0 2px 8px rgba(0,0,0,.12);
            }

            .wishlist-card-form .wishlist-heart {
                position: static;
            }

            .wishlist-heart:hover {
                background: #fff1f2;
                transform: scale(1.08);
            }
        </style>
    </head>
    <body class="sg-home">
        <jsp:include page="/WEB-INF/views/common/site-header.jsp">
            <jsp:param name="active" value="events"/>
        </jsp:include>

        <!-- MAIN CONTENT AREA -->
        <main class="w-100">
            <!-- 2. HERO: sự kiện tiêu điểm, ảnh tràn viền (kiểu SeatGeek) -->
            <section class="sg-hero" aria-label="Sự kiện tiêu điểm">
                <c:choose><c:when test="${empty featuredEvents}">
                        <div class="sg-hero-slide sg-hero-empty"><div class="container px-3 px-lg-5 sg-hero-content">
                                <span class="sg-hero-tag">Light Ticket</span>
                                <p class="sg-hero-title">Concert, kịch, workshop - tất cả ở một nơi</p>
                                <p class="sg-hero-meta">Chưa có sự kiện đang mở bán.</p>
                            </div></div>
                        </c:when>
                        <c:otherwise><div class="carousel slide featured-carousel" id="featuredEventsCarousel" data-bs-ride="carousel">
                            <div class="carousel-indicators">
                                <c:forEach var="e" items="${featuredEvents}" varStatus="loop">
                                    <button type="button" data-bs-target="#featuredEventsCarousel" data-bs-slide-to="${loop.index}" class="${loop.first ? 'active' : ''}" ${loop.first ? 'aria-current="true"' : ''} aria-label="Sự kiện ${loop.count}"></button>
                                </c:forEach>
                            </div>
                            <div class="carousel-inner">
                                <c:forEach var="e" items="${featuredEvents}" varStatus="loop">
                                    <div class="carousel-item ${loop.first ? 'active' : ''}">
                                        <div class="sg-hero-slide">
                                            <c:if test="${not empty e.eventImage}"><img class="sg-hero-img" alt="" src="${fn:startsWith(e.eventImage, 'http') ? '' : pageContext.request.contextPath.concat('/')}<c:out value='${e.eventImage}'/>"/></c:if>
                                                <div class="sg-hero-shade" aria-hidden="true"></div>
                                                <div class="container px-3 px-lg-5 sg-hero-content">
                                                    <span class="sg-hero-tag"><c:out value="${e.categoryName}"/></span>
                                                <h2 class="sg-hero-title"><c:out value="${e.eventName}"/></h2>
                                                <p class="sg-hero-meta">
                                                    <span><i class="ph ph-calendar-blank" aria-hidden="true"></i> ${e.startLabel}</span>
                                                    <span><i class="ph ph-map-pin" aria-hidden="true"></i> <c:out value="${e.venueName}"/> - <c:out value="${e.address}"/></span>
                                                </p>
                                                <div class="sg-hero-cta">
                                                    <a class="sg-hero-btn" href="${pageContext.request.contextPath}/event/detail?id=${e.eventId}">Xem vé <i class="ph ph-arrow-right" aria-hidden="true"></i></a>
                                                    <span class="sg-hero-price"><c:choose><c:when test="${not empty e.minPrice}">Từ <strong><fmt:formatNumber value="${e.minPrice}" type="number" maxFractionDigits="0"/> ₫</strong></c:when><c:otherwise>Chưa mở vé</c:otherwise></c:choose><span class="sg-hero-dot" aria-hidden="true">·</span>Còn ${e.remainingTickets} vé</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                </c:forEach>
                            </div>
                            <button class="carousel-control-prev" type="button" data-bs-target="#featuredEventsCarousel" data-bs-slide="prev" aria-label="Sự kiện trước"><i class="ph ph-caret-left" aria-hidden="true"></i></button>
                            <button class="carousel-control-next" type="button" data-bs-target="#featuredEventsCarousel" data-bs-slide="next" aria-label="Sự kiện sau"><i class="ph ph-caret-right" aria-hidden="true"></i></button>
                        </div></c:otherwise></c:choose>
                    </section>

                    <!-- 3. Tìm kiếm & lọc (dữ liệu từ DB) -->
                    <section class="sg-search-section">
                        <div class="container px-3 px-lg-5">
                            <h1 class="sg-section-title">Tìm sự kiện, đặt vé trong vài phút</h1>
                            <p class="sg-section-lead">Concert, kịch, workshop - lọc theo ngày, địa điểm hoặc mức giá. Vé điện tử được gửi qua email ngay sau khi thanh toán.</p>
                            <div class="search-box-floating mb-4">
                                <form class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/home">
                            <div class="col-12 col-md-5"><div class="filter-field"><i class="ph ph-magnifying-glass" aria-hidden="true"></i>
                                    <input class="form-control" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tên sự kiện..."/></div></div>
                            <div class="col-12 col-md-4"><div class="filter-field"><i class="ph ph-map-pin" aria-hidden="true"></i>
                                    <select class="form-select" name="venueId"><option value="">Tất cả địa điểm</option>
                                        <c:forEach var="v" items="${venues}"><option value="${v.id}" ${venueId == v.id ? 'selected="selected"' : ''}><c:out value="${v.name}"/></option></c:forEach>
                                        </select></div></div>
                                <input type="hidden" name="categoryId" value="${categoryId}"/>
                            <div class="col-12 col-md-3"><button type="submit" class="btn btn-primary-custom w-100 py-3">Tìm sự kiện</button></div>
                            <%-- UC-10: lọc theo khoảng ngày diễn ra và khoảng giá vé --%>
                            <div class="col-6 col-md-3"><label class="small text-secondary" for="dateFrom">Từ ngày</label>
                                <input class="form-control" type="date" id="dateFrom" name="dateFrom" value="${fn:escapeXml(dateFrom)}"/></div>
                            <div class="col-6 col-md-3"><label class="small text-secondary" for="dateTo">Đến ngày</label>
                                <input class="form-control" type="date" id="dateTo" name="dateTo" value="${fn:escapeXml(dateTo)}"/></div>
                                <%-- Mức giá gợi ý theo giá vé thực tế của các sự kiện đang mở bán --%>
                            <div class="col-12 col-md-6"><label class="small text-secondary" for="priceRange">Mức giá</label>
                                <select class="form-select" id="priceRange" name="price">
                                    <option value="">Tất cả mức giá</option>
                                    <c:set var="priceMatched" value="${priceRange == '-'}"/>
                                    <c:forEach var="r" items="${priceRanges}">
                                        <c:if test="${r.value == priceRange}"><c:set var="priceMatched" value="true"/></c:if>
                                        <option value="${r.value}" ${r.value == priceRange ? 'selected="selected"' : ''}><c:out value="${r.label}"/> (${r.count} sự kiện)</option>
                                    </c:forEach>
                                    <c:if test="${not priceMatched}">
                                        <option value="${fn:escapeXml(priceRange)}" selected="selected">Khoảng giá đang lọc: ${empty priceMin ? '0' : priceMin} – ${empty priceMax ? '…' : priceMax} ₫</option>
                                    </c:if>
                                </select></div>
                        </form>
                    </div>
                </div>
            </section>

            <!-- 4. Danh mục -->
            <section class="category-pills-bar"><div class="container px-3 px-lg-5">
                    <div class="d-flex align-items-center gap-2 overflow-x-auto no-scrollbar py-1" id="categoryGroup">
                        <c:url var="allCategoryUrl" value="/home"><c:param name="keyword" value="${keyword}"/><c:param name="venueId" value="${venueId}"/><c:param name="dateFrom" value="${dateFrom}"/><c:param name="dateTo" value="${dateTo}"/><c:param name="priceMin" value="${priceMin}"/><c:param name="priceMax" value="${priceMax}"/></c:url>
                        <a class="cat-btn text-decoration-none ${empty categoryId ? 'active' : ''}" href="${allCategoryUrl}">Tất cả (${totalEvents})</a>
                        <c:forEach var="cat" items="${categories}">
                            <c:url var="catUrl" value="/home"><c:param name="keyword" value="${keyword}"/><c:param name="venueId" value="${venueId}"/><c:param name="categoryId" value="${cat.id}"/><c:param name="dateFrom" value="${dateFrom}"/><c:param name="dateTo" value="${dateTo}"/><c:param name="priceMin" value="${priceMin}"/><c:param name="priceMax" value="${priceMax}"/></c:url>
                            <a class="cat-btn text-decoration-none ${categoryId == cat.id ? 'active' : ''}" href="${catUrl}"><c:out value="${cat.name}"/> (${cat.total})</a>
                        </c:forEach>
                    </div>
                </div></section>

            <!-- 5. Lưới sự kiện (dữ liệu từ DB) -->
            <section class="sg-events" id="events"><div class="container px-3 px-lg-5">
                    <div class="sg-events-head">
                        <h2 class="sg-section-title mb-0">${totalEvents} sự kiện sắp diễn ra</h2>
                        <form action="${pageContext.request.contextPath}/home" method="get">
                            <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}"/>
                            <input type="hidden" name="categoryId" value="${categoryId}"/>
                            <input type="hidden" name="venueId" value="${venueId}"/>
                            <input type="hidden" name="dateFrom" value="${fn:escapeXml(dateFrom)}"/>
                            <input type="hidden" name="dateTo" value="${fn:escapeXml(dateTo)}"/>
                            <input type="hidden" name="priceMin" value="${fn:escapeXml(priceMin)}"/>
                            <input type="hidden" name="priceMax" value="${fn:escapeXml(priceMax)}"/>
                            <select name="sort" class="form-select sg-sort" aria-label="Sắp xếp" onchange="this.form.submit()">
                                <option value="nearest" ${sort == 'nearest' ? 'selected' : ''}>Ngày gần nhất</option>
                                <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Mới cập nhật</option>
                                <option value="price-asc" ${sort == 'price-asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                                <option value="price-desc" ${sort == 'price-desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                            </select>
                        </form>
                    </div>
                    <c:choose>
                        <c:when test="${empty events}">
                            <div class="alert alert-info">Không có sự kiện phù hợp.</div>
                        </c:when>
                        <c:otherwise>
                            <div class="row g-4" id="eventCardList">
                                <c:forEach var="e" items="${events}">
                                    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
                                        <article class="event-card h-100">
                                            <div class="event-card-media">

                                                <c:choose>
                                                    <c:when test="${sessionScope.user.role eq 'Customer'}">
                                                        <form method="post"
                                                              action="${pageContext.request.contextPath}/customer/wishlist"
                                                              class="wishlist-card-form">

                                                            <input type="hidden" name="csrfToken"
                                                                   value="${csrfToken}">

                                                            <input type="hidden" name="eventId"
                                                                   value="${e.eventId}">

                                                            <input type="hidden" name="redirect"
                                                                   value="home">

                                                            <input type="hidden" name="action"
                                                                   value="${favoriteIds.contains(e.eventId) ? 'remove' : 'add'}">

                                                            <button type="submit"
                                                                    class="wishlist-heart"
                                                                    title="${favoriteIds.contains(e.eventId) ? 'Bỏ yêu thích' : 'Thêm vào yêu thích'}"
                                                                    aria-label="${favoriteIds.contains(e.eventId) ? 'Bỏ yêu thích' : 'Thêm vào yêu thích'}">

                                                                <i class="${favoriteIds.contains(e.eventId) ? 'ph-fill' : 'ph'} ph-heart"></i>
                                                            </button>
                                                        </form>
                                                    </c:when>

                                                    <c:when test="${empty sessionScope.user}">
                                                        <a href="${pageContext.request.contextPath}/Auth?action=login"
                                                           class="wishlist-heart"
                                                           title="Đăng nhập để yêu thích">
                                                            <i class="ph ph-heart"></i>
                                                        </a>
                                                    </c:when>
                                                </c:choose>

                                                <c:choose>
                                                    <c:when test="${not empty e.eventImage}">
                                                        <img alt="" loading="lazy" src="${fn:startsWith(e.eventImage, 'http') ? '' : pageContext.request.contextPath.concat('/')}<c:out value='${e.eventImage}'/>"/></c:when>
                                                    <c:otherwise>
                                                        <div class="event-card-placeholder">
                                                            <i class="ph ph-calendar-blank" aria-hidden="true"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <span class="event-card-tag">
                                                    <c:out value="${e.categoryName}"/>
                                                </span>
                                            </div>
                                            <div class="event-card-body">
                                                <small class="event-card-date">${e.startLabel}</small>
                                                <h3 class="event-card-title"><a class="stretched-link" href="${pageContext.request.contextPath}/event/detail?id=${e.eventId}">
                                                        <c:out value="${e.eventName}"/></a></h3>
                                                <p class="event-card-venue">
                                                    <i class="ph ph-map-pin" aria-hidden="true">

                                                    </i> 
                                                    <c:out value="${e.venueName}"/>
                                                </p>
                                                <div class="event-card-foot">
                                                    <span class="event-card-price"><c:choose><c:when test="${not empty e.minPrice}">Từ <strong><fmt:formatNumber value="${e.minPrice}" type="number" maxFractionDigits="0"/> ₫</strong></c:when><c:otherwise><strong>Chưa mở vé</strong></c:otherwise></c:choose></span>
                                                    <span class="event-card-left">Còn ${e.remainingTickets} vé</span>
                                                </div>
                                            </div>
                                        </article></div>
                                    </c:forEach>
                            </div></c:otherwise></c:choose>
                    <c:if test="${totalPages > 1}"><nav class="mt-4" aria-label="Phân trang"><ul class="pagination justify-content-center">
                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <c:url var="pageUrl" value="/home"><c:param name="page" value="${i}"/><c:param name="keyword" value="${keyword}"/><c:param name="categoryId" value="${categoryId}"/><c:param name="venueId" value="${venueId}"/><c:param name="sort" value="${sort}"/><c:param name="dateFrom" value="${dateFrom}"/><c:param name="dateTo" value="${dateTo}"/><c:param name="priceMin" value="${priceMin}"/><c:param name="priceMax" value="${priceMax}"/></c:url>
                                    <li class="page-item ${i == page ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${i}</a></li>
                                    </c:forEach>
                            </ul></nav></c:if>
                    </div></section>

                <!-- Past Events -->
            <c:if test="${not empty pastEvents}">
                <section class="sg-events py-5" id="past-events">

                    <div class="container px-3 px-lg-5">

                        <div class="sg-events-head mb-4">
                            <div>
                                <h2 class="sg-section-title mb-2">
                                    Sự kiện đã diễn ra
                                </h2>
                                <p class="text-secondary">
                                    Khám phá những sự kiện trước đây
                                    và đánh giá từ khán giả.
                                </p>
                            </div>
                        </div>

                        <div class="row g-4">

                            <c:forEach var="e" items="${pastEvents}">

                                <div class="col-12 col-sm-6 col-xl-3">

                                    <article class="event-card h-100">

                                        <div class="event-card-media">

                                            <%-- Wishlist button for past event cards --%>
                                            <c:choose>
                                                <c:when test="${sessionScope.user.role eq 'Customer'}">
                                                    <form method="post"
                                                          action="${pageContext.request.contextPath}/customer/wishlist"
                                                          class="wishlist-card-form">
                                                        <input type="hidden" name="csrfToken" value="${csrfToken}"/>
                                                        <input type="hidden" name="eventId" value="${e.eventId}"/>
                                                        <input type="hidden" name="redirect" value="home"/>
                                                        <input type="hidden" name="action" value="${favoriteIds.contains(e.eventId) ? 'remove' : 'add'}"/>
                                                        <button type="submit" class="wishlist-heart"
                                                                title="${favoriteIds.contains(e.eventId) ? 'Bỏ yêu thích' : 'Thêm vào yêu thích'}"
                                                                aria-label="${favoriteIds.contains(e.eventId) ? 'Bỏ yêu thích' : 'Thêm vào yêu thích'}">
                                                            <i class="${favoriteIds.contains(e.eventId) ? 'ph-fill' : 'ph'} ph-heart"></i>
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${empty sessionScope.user}">
                                                    <a href="${pageContext.request.contextPath}/Auth?action=login"
                                                       class="wishlist-heart" title="Đăng nhập để yêu thích"
                                                       aria-label="Đăng nhập để yêu thích">
                                                        <i class="ph ph-heart"></i>
                                                    </a>
                                                </c:when>
                                            </c:choose>

                                            <c:choose>
                                                <c:when test="${not empty e.eventImage}">
                                                    <img
                                                        src="${fn:startsWith(e.eventImage, 'http') ? '' : pageContext.request.contextPath.concat('/')}<c:out value='${e.eventImage}'/>"
                                                        alt=""
                                                        loading="lazy"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="event-card-placeholder">
                                                        <i class="ph ph-calendar-blank"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>

                                            <span class="event-card-tag">
                                                Đã kết thúc
                                            </span>
                                        </div>

                                        <div class="event-card-body">

                                            <small class="event-card-date">
                                                ${e.startLabel}
                                            </small>

                                            <h3 class="event-card-title">
                                                <a class="stretched-link"
                                                   href="${pageContext.request.contextPath}/event/detail?id=${e.eventId}#reviews">
                                                    <c:out value="${e.eventName}"/>
                                                </a>
                                            </h3>

                                            <p class="event-card-venue">
                                                <i class="ph ph-map-pin"></i>
                                                <c:out value="${e.venueName}"/>
                                            </p>

                                            <div class="event-card-foot">
                                                <span class="fw-semibold">
                                                    Xem đánh giá
                                                </span>
                                                <span class="text-secondary">
                                                    Đã diễn ra
                                                </span>
                                            </div>
                                        </div>

                                    </article>

                                </div>

                            </c:forEach>

                        </div>
                    </div>
                </section>
            </c:if>
        </main>

        <jsp:include page="/WEB-INF/views/common/site-footer.jsp"/>

        <!-- Bootstrap 5.3 JS Bundle CDN -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                document.addEventListener('DOMContentLoaded', function () {
                                    ['dateFrom', 'dateTo'].forEach(function (id) {
                                        const input = document.getElementById(id);
                                        if (!input)
                                            return;

                                        input.addEventListener('click', function () {
                                            input.focus();

                                            if (typeof input.showPicker === 'function') {
                                                try {
                                                    input.showPicker();
                                                } catch (e) {
                                                    // Trình duyệt không hỗ trợ showPicker
                                                }
                                            }
                                        });
                                    });
                                });
        </script>
    </body>
</html>