<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Light Ticket - Nền tảng bán vé sự kiện trực tiếp hàng đầu</title>

        <!-- Google Fonts: Plus Jakarta Sans -->
        <link href="https://fonts.googleapis.com" rel="preconnect"/>
        <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>

        <!-- Material Symbols Outlined -->
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>

        <!-- Bootstrap 5.3 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>

        <!-- External CSS -->
        <link href="${pageContext.request.contextPath}/assets/css/home.css" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/stitch-custom.css" rel="stylesheet"/>
    </head>
    <body>
        <!-- 1. NAVBAR BOOTSTRAP 5 -->
        <nav class="custom-navbar navbar navbar-expand-xl px-3 px-lg-5">
            <div class="container-fluid px-0">
                <!-- Brand Logo -->
                <a class="navbar-brand d-flex items-center align-items-center gap-2 m-0 text-decoration-none" href="#">
                    <img alt="Light Ticket Logo" src="https://lh3.googleusercontent.com/aida/AEtjO1XCI4pNVR1LGpUueuP9_9k14rz3oGicBwB__UCCRlZ3mNWWsQwLyQcea6WY4e2S4NiF2kxi9pyZSAfD539GHPQ_33mPeRhZpIPhRtji29s4QEP6_l-3Chm3ggkHpxyI7y-uomu6uDLT-lmezb9aBB5pybNOB5jk9soXkdw9qoc89BAk7a5qlR2Pk-2gt4yjPpKuGtJB7DJGqYkGPujCmTiy8cOwTap_sH4FPUaxt6r6VaM_ztASYSlvHryI" style="height: 32px; width: auto; object-fit: contain;"/>
                    <span class="fs-4 fw-bold text-dark tracking-tight">Light Ticket</span>
                </a>
                <!-- Navbar Links (Desktop) -->
                <div class="d-none d-xl-flex align-items-center gap-2 ms-4">
                    <a class="nav-pill-active text-decoration-none" href="#">Sự kiện</a>
                    <a class="nav-pill-idle" href="#">Địa điểm</a>
                    <a class="nav-pill-idle" href="#">Tin tức</a>
                    <a class="nav-pill-idle text-decoration-none" href="${pageContext.request.contextPath}/customer/booking-history">Vé của tôi</a>
                </div>
                <!-- Search Input bar -->
                <div class="flex-grow-1 mx-4 d-none d-md-block" style="max-width: 440px;">
                    <div class="position-relative d-flex align-items-center">
                        <span class="material-symbols-outlined position-absolute ms-3 text-secondary" style="font-size: 20px; pointer-events: none;">search</span>
                        <input class="form-control nav-search-input w-100" placeholder="Tìm kiếm buổi hòa nhạc, lễ hội, rạp hát..." type="text"/>
                    </div>

                </div>
                <div class="d-flex align-items-center ms-auto">
               <c:choose>

    <c:when test="${empty sessionScope.user}">

        <a class="btn btn-outline-primary ms-2"
           href="${pageContext.request.contextPath}/Auth?action=login">
            Đăng nhập
        </a>
    </c:when>


  
    <c:otherwise>

        <div class="dropdown ms-1">

            <a href="#"
               class="d-flex align-items-center gap-2 text-decoration-none p-1 rounded-pill"
               id="userDropdown"
               data-bs-toggle="dropdown"
               aria-expanded="false">

                <img src="${pageContext.request.contextPath}/assets/icons/user_icon.png"
                     alt="User"
                     style="width: 36px;
                            height: 36px;
                            object-fit: cover;
                            border-radius: 50%;">
                <div class="d-none d-lg-flex flex-column text-start me-1" style="line-height:1.2;">
                    <span class="fw-bold small text-dark">${empty sessionScope.user.fullName ? sessionScope.user.username : sessionScope.user.fullName}</span>
                    <span class="text-secondary" style="font-size: 11px;">${empty sessionScope.user.role ? 'Khách hàng' : sessionScope.user.role}</span>
                </div>
                <span class="material-symbols-outlined text-secondary d-none d-lg-inline" style="font-size: 18px;">expand_more</span>
            </a>

            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0"
                aria-labelledby="userDropdown"
                style="border-radius: 12px; min-width: 220px;">

                <li class="px-3 py-2 bg-light rounded-top d-lg-none border-bottom mb-1">
                    <p class="fw-bold small text-dark mb-0">${empty sessionScope.user.fullName ? sessionScope.user.username : sessionScope.user.fullName}</p>
                    <span class="text-secondary" style="font-size: 11px;">${empty sessionScope.user.role ? 'Khách hàng' : sessionScope.user.role}</span>
                </li>

                <!-- Hồ sơ của tôi -->
                <li>
                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                       href="${pageContext.request.contextPath}/CustomerProfileController">
                        <span class="material-symbols-outlined text-secondary" style="font-size: 20px;">account_circle</span>
                        Hồ sơ của tôi
                    </a>
                </li>

                <!-- Vé của tôi -->
                <li>
                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                       href="${pageContext.request.contextPath}/customer/booking-history">
                        <span class="material-symbols-outlined text-secondary" style="font-size: 20px;">
                            confirmation_number
                        </span>
                        Vé của tôi
                    </a>
                </li>

                <!-- Sự kiện của tôi -->
                <li>
                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                       href="${pageContext.request.contextPath}/my-events">
                        <span class="material-symbols-outlined">
                            event
                        </span>
                        Sự kiện của tôi
                    </a>
                </li>

                <li>
                    <hr class="dropdown-divider">
                </li>

                <!-- Đăng xuất -->
                <li>
                    <form action="${pageContext.request.contextPath}/logout"
                          method="POST"
                          class="m-0">

                        <button type="submit"
                                class="dropdown-item d-flex align-items-center gap-2 py-2 text-danger border-0 bg-transparent w-100">
                            <span class="material-symbols-outlined">
                                logout
                            </span>
                            Đăng xuất
                        </button>

                    </form>
                </li>

            </ul>

        </div>

    </c:otherwise>

</c:choose>
                </div>
            </div>
        </nav>

        <!-- MAIN CONTENT AREA -->
        <main class="w-100">
            <!-- 2. HERO SEARCH & BANNER -->
            <section class="hero-section">
                <div class="hero-glow-1"></div>
                <div class="hero-glow-2"></div>
                <div class="container px-3 px-lg-5 position-relative" style="z-index: 2;">
                    <!-- Pre-title Breadcrumb badge -->
                    <div class="d-flex align-items-center gap-2 mb-3">
                        <span class="badge rounded-pill bg-white text-primary-custom px-3 py-2 d-inline-flex align-items-center gap-1 shadow-sm fs-7 fw-semibold">
                            <span class="material-symbols-outlined" style="font-size: 16px;">local_activity</span>
                            Vé chính hãng • Xác thực tức thì
                        </span>
                        <span class="text-muted d-none d-sm-inline">/</span>
                        <span class="text-muted small d-none d-sm-inline">Sự kiện trên toàn quốc</span>
                    </div>
                    <!-- Headline & Subtitle -->
                    <div class="col-lg-10 col-xl-9 mb-4">
                        <h1 class="display-5 fw-extrabold text-dark tracking-tight mb-3">
                            Khám phá sự kiện nổi bật &amp; <span class="text-primary-custom">Đặt vé ngay hôm nay</span>
                        </h1>
                        <p class="lead text-secondary" style="font-size: 1.1rem; max-width: 680px;">
                            Hàng trăm concert âm nhạc đỉnh cao, lễ hội bùng nổ, kịch nghệ tinh hoa và workshop truyền cảm hứng đang chờ đón bạn trải nghiệm.
                        </p>
                    </div>
                    <!-- Database-powered search -->
                    <div class="search-box-floating mb-4">
                      <form class="row g-2 align-items-center" method="get" action="${pageContext.request.contextPath}/home">
                        <div class="col-12 col-md-5"><div class="filter-field"><span class="material-symbols-outlined">search</span>
                          <input class="form-control" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tên sự kiện..."/></div></div>
                        <div class="col-12 col-md-4"><div class="filter-field"><span class="material-symbols-outlined">location_on</span>
                          <select class="form-select" name="venueId"><option value="">Tất cả địa điểm</option>
                          <c:forEach var="v" items="${venues}"><option value="${v.id}" ${venueId == v.id ? 'selected="selected"' : ''}><c:out value="${v.name}"/></option></c:forEach>
                          </select></div></div>
                        <input type="hidden" name="categoryId" value="${categoryId}"/>
                        <div class="col-12 col-md-3"><button type="submit" class="btn btn-primary-custom w-100 py-3">Tìm sự kiện</button></div>
                      </form>
                    </div>
                    <!-- Quick Metrics Ribbon -->
                    <div class="d-flex flex-wrap align-items-center gap-4 text-muted small fw-medium">
                        <div class="d-flex align-items-center gap-1">
                            <span class="material-symbols-outlined text-primary-custom" style="font-size: 18px;">verified</span>
                            <span>100% Hoàn tiền nếu hủy show</span>
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="material-symbols-outlined text-primary-custom" style="font-size: 18px;">bolt</span>
                            <span>Gửi vé điện tử trong 30 giây</span>
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <span class="material-symbols-outlined text-primary-custom" style="font-size: 18px;">support_agent</span>
                            <span>Hỗ trợ check-in sự kiện 24/7</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 3. Categories from database -->
            <section class="category-pills-bar py-3"><div class="container px-3 px-lg-5">
              <div class="d-flex align-items-center gap-2 overflow-x-auto no-scrollbar py-1" id="categoryGroup">
                <c:url var="allCategoryUrl" value="/home"><c:param name="keyword" value="${keyword}"/><c:param name="venueId" value="${venueId}"/></c:url>
                <a class="cat-btn text-decoration-none ${empty categoryId ? 'active' : ''}" href="${allCategoryUrl}">Tất cả (${totalEvents})</a>
                <c:forEach var="cat" items="${categories}">
                  <c:url var="catUrl" value="/home"><c:param name="keyword" value="${keyword}"/><c:param name="venueId" value="${venueId}"/><c:param name="categoryId" value="${cat.id}"/></c:url>
                  <a class="cat-btn text-decoration-none ${categoryId == cat.id ? 'active' : ''}" href="${catUrl}"><c:out value="${cat.name}"/> (${cat.total})</a>
                </c:forEach>
              </div>
            </div></section>

            <!-- 4. Featured events from database -->
            <section class="py-5"><div class="container px-3 px-lg-5">
              <h2 class="fs-3 fw-bold mb-3">Sự kiện tiêu điểm sắp diễn ra</h2>
              <c:choose><c:when test="${empty featuredEvents}"><p class="text-muted">Chưa có sự kiện đang mở bán.</p></c:when>
              <c:otherwise><div class="carousel slide featured-carousel" id="featuredEventsCarousel" data-bs-ride="carousel">
                <div class="carousel-inner">
                  <c:forEach var="e" items="${featuredEvents}" varStatus="loop">
                    <div class="carousel-item ${loop.first ? 'active' : ''}">
                      <div class="featured-card featured-card-slider"><div class="row g-0">
                        <div class="col-lg-7 featured-img-container position-relative">
                          <c:choose><c:when test="${not empty e.eventImage}"><img alt="${fn:escapeXml(e.eventName)}" src="${fn:startsWith(e.eventImage, 'http') ? '' : pageContext.request.contextPath.concat('/')}<c:out value='${e.eventImage}'/>"/></c:when>
                          <c:otherwise><div class="bg-light d-flex align-items-center justify-content-center h-100 p-5"><span class="material-symbols-outlined" style="font-size:96px">event</span></div></c:otherwise></c:choose>
                        </div>
                        <div class="col-lg p-4 p-xl-5 d-flex flex-column justify-content-between bg-white">
                          <div><span class="small text-muted"><c:out value="${e.categoryName}"/></span>
                            <h3 class="fw-bold my-3"><c:out value="${e.eventName}"/></h3>
                            <p><span class="material-symbols-outlined align-middle">calendar_month</span> ${e.startTime}</p>
                            <p><span class="material-symbols-outlined align-middle">location_on</span> <c:out value="${e.venueName}"/> — <c:out value="${e.address}"/></p>
                            <p class="text-muted">Còn ${e.remainingTickets} vé</p>
                          </div>
                          <div class="pt-3 border-top d-flex align-items-center justify-content-between">
                            <strong class="fs-4 text-primary-custom"><c:choose><c:when test="${not empty e.minPrice}">${e.minPrice} ₫</c:when><c:otherwise>Chưa mở vé</c:otherwise></c:choose></strong>
                            <a class="btn btn-primary-custom" href="${pageContext.request.contextPath}/event/detail?id=${e.eventId}">Chi tiết sự kiện</a>
                          </div>
                        </div>
                      </div></div>
                    </div>
                  </c:forEach>
                </div>
                <button class="carousel-control-prev" type="button" data-bs-target="#featuredEventsCarousel" data-bs-slide="prev"><span class="carousel-control-prev-icon"></span></button>
                <button class="carousel-control-next" type="button" data-bs-target="#featuredEventsCarousel" data-bs-slide="next"><span class="carousel-control-next-icon"></span></button>
              </div></c:otherwise></c:choose>
            </div></section>

            <!-- 5. Event grid from database -->
            <section class="py-4"><div class="container px-3 px-lg-5">
              <div class="d-flex flex-wrap align-items-center justify-content-between gap-3 pb-3 mb-4 border-bottom">
                <h2 class="fs-4 fw-bold mb-0">${totalEvents} sự kiện sắp diễn ra</h2>
                <form action="${pageContext.request.contextPath}/home" method="get">
                  <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}"/>
                  <input type="hidden" name="categoryId" value="${categoryId}"/>
                  <input type="hidden" name="venueId" value="${venueId}"/>
                  <select name="sort" class="form-select" onchange="this.form.submit()">
                    <option value="nearest" ${sort == 'nearest' ? 'selected' : ''}>Ngày gần nhất</option>
                    <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Mới cập nhật</option>
                    <option value="price-asc" ${sort == 'price-asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                    <option value="price-desc" ${sort == 'price-desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                  </select>
                </form>
              </div>
              <c:choose><c:when test="${empty events}"><div class="alert alert-info">Không có sự kiện phù hợp.</div></c:when>
              <c:otherwise><div class="row g-4" id="eventCardList">
                <c:forEach var="e" items="${events}">
                  <div class="col-12 col-md-6 col-lg-4"><article class="event-card h-100">
                    <div class="event-card-media">
                      <c:choose><c:when test="${not empty e.eventImage}"><img alt="${fn:escapeXml(e.eventName)}" src="${fn:startsWith(e.eventImage, 'http') ? '' : pageContext.request.contextPath.concat('/')}<c:out value='${e.eventImage}'/>"/></c:when>
                      <c:otherwise><div class="bg-light d-flex align-items-center justify-content-center h-100"><span class="material-symbols-outlined" style="font-size:72px">event</span></div></c:otherwise></c:choose>
                      <span class="badge bg-primary-custom position-absolute top-0 start-0 m-3"><c:out value="${e.categoryName}"/></span>
                    </div>
                    <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                      <div><small class="text-muted">${e.startTime}</small>
                        <h3 class="fs-5 fw-bold text-dark my-2"><c:out value="${e.eventName}"/></h3>
                        <p class="text-muted small"><span class="material-symbols-outlined align-middle">location_on</span> <c:out value="${e.venueName}"/></p>
                      </div>
                      <div><hr/><div class="d-flex align-items-center justify-content-between">
                        <div><small class="text-muted d-block">Giá từ</small><strong class="text-primary-custom"><c:choose><c:when test="${not empty e.minPrice}">${e.minPrice} ₫</c:when><c:otherwise>Chưa mở vé</c:otherwise></c:choose></strong></div>
                        <a class="btn btn-primary-custom" href="${pageContext.request.contextPath}/event/detail?id=${e.eventId}">Chi tiết</a>
                      </div><small class="text-muted">Còn ${e.remainingTickets} vé</small></div>
                    </div>
                  </article></div>
                </c:forEach>
              </div></c:otherwise></c:choose>
              <c:if test="${totalPages > 1}"><nav class="mt-4" aria-label="Phân trang"><ul class="pagination justify-content-center">
                <c:forEach begin="1" end="${totalPages}" var="i">
                  <c:url var="pageUrl" value="/home"><c:param name="page" value="${i}"/><c:param name="keyword" value="${keyword}"/><c:param name="categoryId" value="${categoryId}"/><c:param name="venueId" value="${venueId}"/><c:param name="sort" value="${sort}"/></c:url>
                  <li class="page-item ${i == page ? 'active' : ''}"><a class="page-link" href="${pageUrl}">${i}</a></li>
                </c:forEach>
              </ul></nav></c:if>
            </div></section>

            <!-- 7. NEWSLETTER / NOTIFICATION CTA BANNER -->
            <section class="py-4">
                <div class="container px-3 px-lg-5">
                    <div class="newsletter-card">
                        <div class="row align-items-center g-4 position-relative" style="z-index: 2;">
                            <div class="col-lg-7">
                                <span class="badge rounded-pill bg-white text-dark px-3 py-2 mb-3 d-inline-flex align-items-center gap-1 fw-semibold">
                                    <span class="material-symbols-outlined text-primary-custom" style="font-size: 16px;">campaign</span>
                                    Không bao giờ bỏ lỡ sự kiện yêu thích
                                </span>
                                <h2 class="display-6 fw-bold text-white mb-2">
                                    Đăng ký nhận thông báo vé sớm &amp; Ưu đãi độc quyền
                                </h2>
                                <p class="text-white-50 mb-0" style="font-size: 1.05rem;">
                                    Nhận mã giảm giá 10% cho đơn hàng đầu tiên cùng danh sách nghệ sĩ bạn hâm mộ sắp mở bán vé tại khu vực của bạn.
                                </p>
                            </div>
                            <div class="col-lg-5">
                                <p class="text-white">Thông tin sự kiện được cập nhật trực tiếp từ hệ thống.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <!-- 8. FOOTER BOOTSTRAP 5 -->
        <footer class="pt-5 pb-3">
            <div class="container px-3 px-lg-5">
                <div class="row g-4 pb-5">
                    <!-- Brand Summary -->
                    <div class="col-lg-4 col-md-6">
                        <div class="d-flex align-items-center gap-2 mb-3">
                            <img alt="Light Ticket" src="https://lh3.googleusercontent.com/aida/AEtjO1XCI4pNVR1LGpUueuP9_9k14rz3oGicBwB__UCCRlZ3mNWWsQwLyQcea6WY4e2S4NiF2kxi9pyZSAfD539GHPQ_33mPeRhZpIPhRtji29s4QEP6_l-3Chm3ggkHpxyI7y-uomu6uDLT-lmezb9aBB5pybNOB5jk9soXkdw9qoc89BAk7a5qlR2Pk-2gt4yjPpKuGtJB7DJGqYkGPujCmTiy8cOwTap_sH4FPUaxt6r6VaM_ztASYSlvHryI" style="height: 28px; width: auto;"/>
                            <span class="fs-4 fw-bold text-dark">Light Ticket</span>
                        </div>
                        <p class="text-secondary small mb-3" style="max-width: 320px; line-height: 1.6;">
                            Nền tảng mua vé sự kiện trực tiếp hàng đầu: hòa nhạc đỉnh cao, lễ hội âm nhạc, kịch sân khấu và workshop truyền cảm hứng.
                        </p>
                        <span class="badge bg-white text-secondary border px-3 py-2 fw-semibold">
                            AN TOÀN • LIỀN MẠCH • NHANH CHÓNG
                        </span>
                    </div>
                    <!-- Links Column: Khám phá -->
                    <div class="col-lg-2 col-6">
                        <h4 class="text-uppercase fw-bold text-dark mb-3" style="font-size: 0.85rem; letter-spacing: 0.5px;">Khám phá</h4>
                        <ul class="list-unstyled d-flex flex-column gap-2 mb-0">
                            <li><a class="footer-link" href="#">Tất cả sự kiện</a></li>
                            <li><a class="footer-link" href="#">Địa điểm &amp; Sân khấu</a></li>
                            <li><a class="footer-link" href="#">Cẩm nang giải trí</a></li>
                            <li><a class="footer-link" href="${pageContext.request.contextPath}/customer/booking-history">Vé của tôi</a></li>
                        </ul>
                    </div>
                    <!-- Links Column: Hỗ trợ -->
                    <div class="col-lg-2 col-6">
                        <h4 class="text-uppercase fw-bold text-dark mb-3" style="font-size: 0.85rem; letter-spacing: 0.5px;">Hỗ trợ</h4>
                        <ul class="list-unstyled d-flex flex-column gap-2 mb-0">
                            <li><a class="footer-link" href="#">Trung tâm trợ giúp</a></li>
                            <li><a class="footer-link" href="#">Chính sách hoàn vé</a></li>
                            <li><a class="footer-link" href="#">Dành cho Ban tổ chức</a></li>
                            <li><a class="footer-link" href="#">Quy chế bảo mật</a></li>
                        </ul>
                    </div>
                    <!-- Links Column: Newsletter -->
                    <div class="col-lg-4 col-md-6">
                        <h4 class="text-uppercase fw-bold text-dark mb-3" style="font-size: 0.85rem; letter-spacing: 0.5px;">Đăng ký nhận tin</h4>
                        <p class="text-secondary small mb-3">Nhận ưu đãi vé sớm và thông báo sự kiện nổi bật mỗi tuần.</p>
                        <form class="d-flex gap-2" onsubmit="event.preventDefault(); alert('Đã gửi email!');">
                            <input class="form-control form-control-sm bg-white rounded-3 py-2 px-3" placeholder="Email của bạn" type="email"/>
                            <button class="btn btn-primary-custom rounded-3 px-3 py-2 small" type="submit">Gửi</button>
                        </form>
                    </div>
                </div>
                <!-- Copyright Bar -->
                <div class="pt-4 border-top d-flex flex-column flex-md-row align-items-center justify-content-between gap-3 text-secondary small">
                    <p class="mb-0">© 2025 Light Ticket Joint Stock Co. Bảo lưu mọi quyền.</p>
                    <div class="d-flex align-items-center gap-3">
                        <a class="footer-link" href="#">Điều khoản sử dụng</a>
                        <a class="footer-link" href="#">Chính sách dữ liệu</a>
                        <a class="footer-link" href="#">Liên hệ hợp tác</a>
                    </div>
                </div>
            </div>
        </footer>

        <!-- Bootstrap 5.3 JS Bundle CDN -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Interactive JavaScript -->
        <script>
                            document.addEventListener('DOMContentLoaded', () => {
                                // 1. Wishlist Heart Toggle Micro-interaction
                                const heartButtons = document.querySelectorAll('.like-btn, .like-btn-stub');
                                heartButtons.forEach(btn => {
                                    btn.addEventListener('click', (e) => {
                                        e.preventDefault();
                                        btn.classList.toggle('favorited');
                                        const icon = btn.querySelector('.material-symbols-outlined');
                                        if (icon) {
                                            if (btn.classList.contains('favorited')) {
                                                icon.style.fontVariationSettings = "'FILL' 1";
                                                btn.style.color = '#ff7043';
                                            } else {
                                                icon.style.fontVariationSettings = "'FILL' 0";
                                                btn.style.color = '';
                                            }
                                        }
                                    });
                                });

                                // 4. Dark/Light Mode micro-switch icon feedback
                                const themeBtn = document.getElementById('themeToggleBtn');
                                if (themeBtn) {
                                    themeBtn.addEventListener('click', () => {
                                        const icon = themeBtn.querySelector('.material-symbols-outlined');
                                        if (icon.textContent === 'light_mode') {
                                            icon.textContent = 'dark_mode';
                                        } else {
                                            icon.textContent = 'light_mode';
                                        }
                                    });
                                }
                            });
        </script>
    </body>
</html>