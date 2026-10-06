<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                    <a class="nav-pill-idle" href="#">Vé của tôi</a>
                </div>
                <!-- Search Input bar -->
                <div class="flex-grow-1 mx-4 d-none d-md-block" style="max-width: 440px;">
                    <div class="position-relative d-flex align-items-center">
                        <span class="material-symbols-outlined position-absolute ms-3 text-secondary" style="font-size: 20px; pointer-events: none;">search</span>
                        <input class="form-control nav-search-input w-100" placeholder="Tìm kiếm buổi hòa nhạc, lễ hội, rạp hát..." type="text"/>
                    </div>
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
               class="d-flex align-items-center text-decoration-none"
               id="userDropdown"
               data-bs-toggle="dropdown"
               aria-expanded="false">

                <img src="${pageContext.request.contextPath}/assets/icons/user_icon.png"
                     alt="User"
                     style="width: 36px;
                            height: 36px;
                            object-fit: cover;
                            border-radius: 50%;">
            </a>

            <ul class="dropdown-menu dropdown-menu-end shadow-sm border-0"
                aria-labelledby="userDropdown"
                style="border-radius: 12px; min-width: 200px;">

                <!-- Tài khoản của tôi -->
                <li>
                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                       href="${pageContext.request.contextPath}/CustomerProfileController">
                        <span class="material-symbols-outlined">person</span>
                        Tài khoản của tôi
                    </a>
                </li>

                <!-- Vé của tôi -->
                <li>
                    <a class="dropdown-item d-flex align-items-center gap-2 py-2"
                       href="${pageContext.request.contextPath}/customer/booking-history">
                        <span class="material-symbols-outlined">
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
                    <!-- Floating Search Filter Bar -->
                    <div class="search-box-floating mb-4">
                        <form class="row g-2 align-items-center" onsubmit="event.preventDefault();">
                            <!-- Keyword -->
                            <div class="col-12 col-md-4">
                                <div class="filter-field">
                                    <span class="material-symbols-outlined text-muted" style="font-size: 22px;">search</span>
                                    <div class="d-flex flex-column w-100">
                                        <span class="text-uppercase text-muted fw-bold" style="font-size: 0.68rem; letter-spacing: 0.5px;">Từ khóa</span>
                                        <input placeholder="Tìm kiếm theo nghệ sĩ, tên sự kiện..." type="text"/>
                                    </div>
                                </div>
                            </div>
                            <!-- Location -->
                            <div class="col-12 col-md-3">
                                <div class="filter-field">
                                    <span class="material-symbols-outlined text-muted" style="font-size: 22px;">location_on</span>
                                    <div class="d-flex flex-column w-100">
                                        <span class="text-uppercase text-muted fw-bold" style="font-size: 0.68rem; letter-spacing: 0.5px;">Địa điểm</span>
                                        <select>
                                            <option value="">Tất cả địa điểm</option>
                                            <option value="hanoi">Hà Nội</option>
                                            <option value="hcm">TP. Hồ Chí Minh</option>
                                            <option value="danang">Đà Nẵng</option>
                                            <option value="dalat">Đà Lạt</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <!-- Date Time -->
                            <div class="col-12 col-md-3">
                                <div class="filter-field">
                                    <span class="material-symbols-outlined text-muted" style="font-size: 22px;">calendar_month</span>
                                    <div class="d-flex flex-column w-100">
                                        <span class="text-uppercase text-muted fw-bold" style="font-size: 0.68rem; letter-spacing: 0.5px;">Thời gian</span>
                                        <select>
                                            <option value="all">Tất cả thời gian</option>
                                            <option value="today">Hôm nay</option>
                                            <option value="weekend">Cuối tuần này</option>
                                            <option value="month">Tháng này</option>
                                            <option value="custom">Tùy chọn ngày</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <!-- Submit CTA -->
                            <div class="col-12 col-md-2">
                                <button class="btn btn-primary-custom w-100 py-3 rounded-3 d-flex align-items-center justify-content-center gap-2" type="submit">
                                    <span class="material-symbols-outlined" style="font-size: 20px;">manage_search</span>
                                    <span>Tìm vé ngay</span>
                                </button>
                            </div>
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

            <!-- 3. CATEGORY PILLS BAR -->
            <section class="category-pills-bar py-3">
                <div class="container px-3 px-lg-5">
                    <div class="d-flex align-items-center justify-content-between gap-3">
                        <!-- Scrollable buttons -->
                        <div class="d-flex align-items-center gap-2 overflow-x-auto no-scrollbar py-1" id="categoryGroup">
                            <button class="cat-btn active" data-cat="all">Tất cả (128)</button>
                            <button class="cat-btn" data-cat="trending">🔥 Thịnh hành</button>
                            <button class="cat-btn" data-cat="concert">Concert Âm nhạc</button>
                            <button class="cat-btn" data-cat="festival">Lễ hội ngoài trời</button>
                            <button class="cat-btn" data-cat="theater">Sân khấu &amp; Kịch</button>
                            <button class="cat-btn" data-cat="workshop">Hội thảo &amp; Workshop</button>
                            <button class="cat-btn" data-cat="sport">Thể thao &amp; Esport</button>
                            <button class="cat-btn" data-cat="expo">Triển lãm Nghệ thuật</button>
                        </div>
                        <!-- Dynamic count badge -->
                        <div class="d-none d-lg-flex align-items-center gap-2 text-secondary small fw-medium text-nowrap">
                            <span class="badge bg-success rounded-circle p-1" style="width: 8px; height: 8px;"></span>
                            <span>18 sự kiện mới tuần này</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 4. FEATURED EVENT SHOWCASE -->
            <section class="py-5">
                <div class="container px-3 px-lg-5">
                    <!-- Section Header with Controls -->
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="d-flex align-items-center gap-2">
                            <span class="material-symbols-outlined text-primary-custom" style="font-size: 26px;">stars</span>
                            <h2 class="fs-3 fw-bold mb-0">Sự kiện tiêu điểm tuần này</h2>
                            <span class="badge bg-warning-subtle text-dark fw-bold px-3 py-2 rounded-pill ms-2 d-none d-sm-inline-block">
                                Độc quyền phân phối
                            </span>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <button aria-label="Sự kiện trước" class="carousel-nav-btn" data-bs-slide="prev" data-bs-target="#featuredEventsCarousel" type="button">
                                <span class="material-symbols-outlined" style="font-size: 22px;">arrow_back</span>
                            </button>
                            <button aria-label="Sự kiện tiếp theo" class="carousel-nav-btn" data-bs-slide="next" data-bs-target="#featuredEventsCarousel" type="button">
                                <span class="material-symbols-outlined" style="font-size: 22px;">arrow_forward</span>
                            </button>
                        </div>
                    </div>

                    <!-- Bootstrap 5 Carousel -->
                    <div class="carousel slide carousel-fade featured-carousel" data-bs-interval="5000" data-bs-pause="hover" data-bs-ride="carousel" id="featuredEventsCarousel">
                        <div class="carousel-inner">
                            <!-- SLIDE 1: Chuyến Bay Hoàng Hôn -->
                            <div class="carousel-item active">
                                <div class="featured-card featured-card-slider">
                                    <div class="row g-0">
                                        <div class="col-lg-7 featured-img-container position-relative">
                                            <img alt="Live Concert Chuyến Bay Hoàng Hôn" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBG0BksVD1pjfG2Ygq20Ju57v3PwtdcRHsSBbdREk5xB_1giZVaQ1FHF0fcoKyT6SDzA7DHl1rL-5y5Tlpltefi1qvZ_BAcb07qjylCvQS-Z4NjefKt7M5LjTNmrEhiqcqwKlT7BwEbV9Y2hM-V7NMwJE5bw-Rwi-0--GylozUmPa9rNpV9la0e86E-cHdimA9XP16sbwmhvxGNP9WDhE1gyKeu29GMOzv_hpBMPI2gNooa-PnhdOCtkA"/>
                                            <div class="position-absolute top-0 start-0 w-100 h-100" style="background: linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.85) 100%);"></div>
                                            <div class="position-absolute top-0 start-0 p-3 d-flex flex-wrap gap-2">
                                                <span class="badge bg-primary-custom text-white fw-bold px-3 py-2 text-uppercase rounded-3 shadow">
                                                    🔥 Siêu Nhạc Hội 2025
                                                </span>
                                                <span class="badge bg-white text-dark fw-semibold px-3 py-2 rounded-3 shadow-sm">
                                                    Chỉ còn 15% lượng vé
                                                </span>
                                            </div>
                                            <div class="position-absolute bottom-0 start-0 p-4 text-white">
                                                <span class="text-uppercase fw-semibold tracking-wider text-warning" style="font-size: 0.8rem;">Lineup nghệ sĩ chính</span>
                                                <h4 class="fw-bold mb-0 text-white mt-1">
                                                    Vũ. • Chillies • Đen Vâu • Hoàng Dũng • Trang
                                                </h4>
                                            </div>
                                        </div>
                                        <div class="d-none d-lg-flex ticket-stub-divider">
                                            <div class="ticket-notch-top"></div>
                                            <div class="ticket-dashed-line"></div>
                                            <div class="ticket-notch-bottom"></div>
                                        </div>
                                        <div class="col-lg p-4 p-xl-5 d-flex flex-column justify-content-between bg-white">
                                            <div>
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-uppercase small fw-bold text-muted" style="letter-spacing: 0.5px;">Tour Lưu Diễn Toàn Quốc</span>
                                                    <button class="btn btn-link text-muted p-1 text-decoration-none like-btn-stub" title="Lưu vào danh sách thích">
                                                        <span class="material-symbols-outlined" style="font-size: 24px;">favorite</span>
                                                    </button>
                                                </div>
                                                <h3 class="fw-extrabold text-dark mb-3">
                                                    Chuyến Bay Hoàng Hôn: Live Concert Hà Nội
                                                </h3>
                                                <div class="d-flex flex-column gap-2 mb-3">
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">calendar_today</span>
                                                        <strong class="text-dark">15 Tháng 05, 2025 • 19:30</strong>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">stadium</span>
                                                        <span>Sân vận động Quốc gia Mỹ Đình, Hà Nội</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">confirmation_number</span>
                                                        <span>Khu vực: CAT 1, CAT 2, Standing GA, VIP Lounge</span>
                                                    </div>
                                                </div>
                                                <div class="p-3 rounded-3 d-flex align-items-center justify-content-between mb-3" style="background-color: #eff4ff;">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">alarm</span>
                                                        <span class="small fw-semibold text-secondary">Đóng cổng bán sau:</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-1 fw-bold fs-5 text-primary-custom">
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm cd-hours" id="cd-hours">04</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm cd-minutes" id="cd-minutes">18</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm cd-seconds" id="cd-seconds">35</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pt-3 border-top d-flex align-items-center justify-content-between gap-3">
                                                <div>
                                                    <span class="small text-muted d-block">Giá vé từ</span>
                                                    <span class="fs-4 fw-bold text-primary-custom">650.000₫</span>
                                                </div>
                                                <button class="btn btn-primary-custom px-4 py-3 rounded-3 d-flex align-items-center gap-2">
                                                    <span>Mua vé ngay</span>
                                                    <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- SLIDE 2: Symphony of Lights -->
                            <div class="carousel-item">
                                <div class="featured-card featured-card-slider">
                                    <div class="row g-0">
                                        <div class="col-lg-7 featured-img-container position-relative">
                                            <img alt="Symphony of Lights Đêm Hòa Nhạc" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBHl6jIakVdo_0lAbJNd9BvxycHE1l_R7kEFo-j1pPwtLVT5oU150-22xZpFG0gqKEE8hVbritG9QTzzsrjlUA7BzePzc0FqPivgfIpizlfkZdOfBc9CpSWyJ5YV7ls2b2kl2Ut1rbhs9wFpaZJNaZ-9WVBAsnxBP_ne8sWxiDUMQGLJQjshJ5gM4imBReYRJBtwgKeofLesczGck2_KxR270IY7BEMBdp4eeKM0Wi9w-tMh97z6D9cng"/>
                                            <div class="position-absolute top-0 start-0 w-100 h-100" style="background: linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.85) 100%);"></div>
                                            <div class="position-absolute top-0 start-0 p-3 d-flex flex-wrap gap-2">
                                                <span class="badge bg-secondary text-white fw-bold px-3 py-2 text-uppercase rounded-3 shadow">
                                                    🎻 Giao Hưởng Đỉnh Cao
                                                </span>
                                                <span class="badge bg-white text-dark fw-semibold px-3 py-2 rounded-3 shadow-sm">
                                                    Độc Quyền Phân Phối
                                                </span>
                                            </div>
                                            <div class="position-absolute bottom-0 start-0 p-4 text-white">
                                                <span class="text-uppercase fw-semibold tracking-wider text-warning" style="font-size: 0.8rem;">Chỉ huy &amp; Trình tấu</span>
                                                <h4 class="fw-bold mb-0 text-white mt-1">
                                                    Dàn nhạc Giao hưởng Sài Gòn &amp; Khách mời Quốc tế
                                                </h4>
                                            </div>
                                        </div>
                                        <div class="d-none d-lg-flex ticket-stub-divider">
                                            <div class="ticket-notch-top"></div>
                                            <div class="ticket-dashed-line"></div>
                                            <div class="ticket-notch-bottom"></div>
                                        </div>
                                        <div class="col-lg p-4 p-xl-5 d-flex flex-column justify-content-between bg-white">
                                            <div>
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-uppercase small fw-bold text-muted" style="letter-spacing: 0.5px;">Nghệ thuật Thính phòng 2025</span>
                                                    <button class="btn btn-link text-muted p-1 text-decoration-none like-btn-stub" title="Lưu vào danh sách thích">
                                                        <span class="material-symbols-outlined" style="font-size: 24px;">favorite</span>
                                                    </button>
                                                </div>
                                                <h3 class="fw-extrabold text-dark mb-3">
                                                    Symphony of Lights: Đêm Beethoven &amp; Tchaikovsky
                                                </h3>
                                                <div class="d-flex flex-column gap-2 mb-3">
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">calendar_today</span>
                                                        <strong class="text-dark">28 Tháng 05, 2025 • 20:00</strong>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">theater_comedy</span>
                                                        <span>Nhà Hát Lớn TP. Hồ Chí Minh, Quận 1</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">confirmation_number</span>
                                                        <span>Khu vực: Hạng Diamond, Hạng Vàng, Ban công A/B</span>
                                                    </div>
                                                </div>
                                                <div class="p-3 rounded-3 d-flex align-items-center justify-content-between mb-3" style="background-color: #eff4ff;">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">alarm</span>
                                                        <span class="small fw-semibold text-secondary">Đóng cổng bán sau:</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-1 fw-bold fs-5 text-primary-custom">
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">17</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">45</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">12</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pt-3 border-top d-flex align-items-center justify-content-between gap-3">
                                                <div>
                                                    <span class="small text-muted d-block">Giá vé từ</span>
                                                    <span class="fs-4 fw-bold text-primary-custom">800.000₫</span>
                                                </div>
                                                <button class="btn btn-primary-custom px-4 py-3 rounded-3 d-flex align-items-center gap-2">
                                                    <span>Mua vé ngay</span>
                                                    <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- SLIDE 3: Saigon Electronic Music Fest -->
                            <div class="carousel-item">
                                <div class="featured-card featured-card-slider">
                                    <div class="row g-0">
                                        <div class="col-lg-7 featured-img-container position-relative">
                                            <img alt="Saigon Electronic Music Fest 2025" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCzX3LKkhEzRzvBVQPI0yMT0r_wnqk-GbmK7ILzxy7UMIW6Zu8XyQI-mmdd3u3UDbwp15S_TxfKWk_NzN_mbNpHf4GVCogiDzf9BbGK_3Q9gt1l-Fn3HcvhLv_926dMlOBYLC4fDGj6TLw_Sa2uogsfm4-M_a2wpYeeeq_3Nsk__rHCN8od5RQFtnBM57WjAhNVo7N28h_n3hoIA9lXiv_fkU1xzGNwVex41JvsAUZjxB1vkK7WKdwcYA"/>
                                            <div class="position-absolute top-0 start-0 w-100 h-100" style="background: linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.85) 100%);"></div>
                                            <div class="position-absolute top-0 start-0 p-3 d-flex flex-wrap gap-2">
                                                <span class="badge bg-danger text-white fw-bold px-3 py-2 text-uppercase rounded-3 shadow">
                                                    ⚡ Sắp Cháy Vé
                                                </span>
                                                <span class="badge bg-white text-dark fw-semibold px-3 py-2 rounded-3 shadow-sm">
                                                    Top 100 DJ Thế Giới
                                                </span>
                                            </div>
                                            <div class="position-absolute bottom-0 start-0 p-4 text-white">
                                                <span class="text-uppercase fw-semibold tracking-wider text-warning" style="font-size: 0.8rem;">Main Stage Headliners</span>
                                                <h4 class="fw-bold mb-0 text-white mt-1">
                                                    Top 100 DJ Mag &amp; Dàn Nghệ Sĩ EDM Hàng Đầu
                                                </h4>
                                            </div>
                                        </div>
                                        <div class="d-none d-lg-flex ticket-stub-divider">
                                            <div class="ticket-notch-top"></div>
                                            <div class="ticket-dashed-line"></div>
                                            <div class="ticket-notch-bottom"></div>
                                        </div>
                                        <div class="col-lg p-4 p-xl-5 d-flex flex-column justify-content-between bg-white">
                                            <div>
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-uppercase small fw-bold text-muted" style="letter-spacing: 0.5px;">Mega Rave Festival 2025</span>
                                                    <button class="btn btn-link text-muted p-1 text-decoration-none like-btn-stub" title="Lưu vào danh sách thích">
                                                        <span class="material-symbols-outlined" style="font-size: 24px;">favorite</span>
                                                    </button>
                                                </div>
                                                <h3 class="fw-extrabold text-dark mb-3">
                                                    Saigon Electronic Music Fest: Electric Horizons
                                                </h3>
                                                <div class="d-flex flex-column gap-2 mb-3">
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">calendar_today</span>
                                                        <strong class="text-dark">12 Tháng 06, 2025 • 16:00 - 23:30</strong>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">apartment</span>
                                                        <span>Trung tâm Hội chợ và Triển lãm SECC, Quận 7, TP.HCM</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">confirmation_number</span>
                                                        <span>Khu vực: General Admission, Early Bird GA, VVIP Table</span>
                                                    </div>
                                                </div>
                                                <div class="p-3 rounded-3 d-flex align-items-center justify-content-between mb-3" style="background-color: #eff4ff;">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">alarm</span>
                                                        <span class="small fw-semibold text-secondary">Đóng cổng bán sau:</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-1 fw-bold fs-5 text-primary-custom">
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">31</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">12</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">08</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pt-3 border-top d-flex align-items-center justify-content-between gap-3">
                                                <div>
                                                    <span class="small text-muted d-block">Giá vé từ</span>
                                                    <span class="fs-4 fw-bold text-primary-custom">790.000₫</span>
                                                </div>
                                                <button class="btn btn-primary-custom px-4 py-3 rounded-3 d-flex align-items-center gap-2">
                                                    <span>Mua vé ngay</span>
                                                    <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- SLIDE 4: Sunset Acoustic Chill -->
                            <div class="carousel-item">
                                <div class="featured-card featured-card-slider">
                                    <div class="row g-0">
                                        <div class="col-lg-7 featured-img-container position-relative">
                                            <img alt="Sunset Acoustic Chill Đà Lạt" src="https://lh3.googleusercontent.com/aida-public/AB6AXuAAUKho7TpYzZ5K1jxkHIy1wviA0Mw_HOjlxLHDNhSgr7SIVKNvszFq3T6YjKyFsSQtK8PI_uR8EuM7eSe00v0kB-fk-KFHJUYDYIpRnuVDK_BxsYxB3V71RvV1uGeeGpqVa6MkJBkhdIijNnnjPuwQIXTc6YOO2bxddXK5rYgtv5-CC1-WQWwFE89wYHlW4ffL_0cuFB8WWl3pW2NqtvVKb8M0b7jxLA2l6BctChD_ozDw8CwS-iPycg"/>
                                            <div class="position-absolute top-0 start-0 w-100 h-100" style="background: linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.85) 100%);"></div>
                                            <div class="position-absolute top-0 start-0 p-3 d-flex flex-wrap gap-2">
                                                <span class="badge bg-primary-custom text-white fw-bold px-3 py-2 text-uppercase rounded-3 shadow">
                                                    🌲 Acoustic Lãng Mạn
                                                </span>
                                                <span class="badge bg-white text-dark fw-semibold px-3 py-2 rounded-3 shadow-sm">
                                                    Bán Chạy Nhất
                                                </span>
                                            </div>
                                            <div class="position-absolute bottom-0 start-0 p-4 text-white">
                                                <span class="text-uppercase fw-semibold tracking-wider text-warning" style="font-size: 0.8rem;">Ca sĩ khách mời</span>
                                                <h4 class="fw-bold mb-0 text-white mt-1">
                                                    Hà Anh Tuấn • Nguyên Hà • Lân Nhã
                                                </h4>
                                            </div>
                                        </div>
                                        <div class="d-none d-lg-flex ticket-stub-divider">
                                            <div class="ticket-notch-top"></div>
                                            <div class="ticket-dashed-line"></div>
                                            <div class="ticket-notch-bottom"></div>
                                        </div>
                                        <div class="col-lg p-4 p-xl-5 d-flex flex-column justify-content-between bg-white">
                                            <div>
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-uppercase small fw-bold text-muted" style="letter-spacing: 0.5px;">Mây Lang Thang Concert</span>
                                                    <button class="btn btn-link text-muted p-1 text-decoration-none like-btn-stub" title="Lưu vào danh sách thích">
                                                        <span class="material-symbols-outlined" style="font-size: 24px;">favorite</span>
                                                    </button>
                                                </div>
                                                <h3 class="fw-extrabold text-dark mb-3">
                                                    Sunset Acoustic Chill: Mây &amp; Bản Tình Ca
                                                </h3>
                                                <div class="d-flex flex-column gap-2 mb-3">
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">calendar_today</span>
                                                        <strong class="text-dark">02 Tháng 06, 2025 • 17:00</strong>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">nature_people</span>
                                                        <span>Thung Lũng Mây Đà Lạt, TP. Đà Lạt</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">confirmation_number</span>
                                                        <span>Khu vực: Khán Đài Đồi Thông, Khu Cận Sân Khấu</span>
                                                    </div>
                                                </div>
                                                <div class="p-3 rounded-3 d-flex align-items-center justify-content-between mb-3" style="background-color: #eff4ff;">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">alarm</span>
                                                        <span class="small fw-semibold text-secondary">Đóng cổng bán sau:</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-1 fw-bold fs-5 text-primary-custom">
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">21</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">04</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">19</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pt-3 border-top d-flex align-items-center justify-content-between gap-3">
                                                <div>
                                                    <span class="small text-muted d-block">Giá vé từ</span>
                                                    <span class="fs-4 fw-bold text-primary-custom">350.000₫</span>
                                                </div>
                                                <button class="btn btn-primary-custom px-4 py-3 rounded-3 d-flex align-items-center gap-2">
                                                    <span>Mua vé ngay</span>
                                                    <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- SLIDE 5: Vở Kịch Kinh Điển -->
                            <div class="carousel-item">
                                <div class="featured-card featured-card-slider">
                                    <div class="row g-0">
                                        <div class="col-lg-7 featured-img-container position-relative">
                                            <img alt="Vở Kịch Kinh Điển Sân Khấu Idecaf" src="https://lh3.googleusercontent.com/aida-public/AB6AXuAfptPe1WjMskI6mUm3Ev7iGeBrVhPZSXkZN-FW00x72pwd9l2b861EWl9cWVSsnxZcd94XZZrGPliWhaPldxWP-vZtn7cHF6izJF2ANzn-y42Ty3WdHQSadQ0o1Zs2pU2cs2A5XyrU_CSFrpWNWfmMhHw5MJw8E5T-ba0gHyhBS3Z1_Uk01cWABol4eu3oJzusnYVMA4MHbmo475D639SLO9PRfCO0GUo46g9DXkOk-jeJGfL5CqX-vQ"/>
                                            <div class="position-absolute top-0 start-0 w-100 h-100" style="background: linear-gradient(180deg, rgba(0,0,0,0.15) 0%, rgba(0,0,0,0.85) 100%);"></div>
                                            <div class="position-absolute top-0 start-0 p-3 d-flex flex-wrap gap-2">
                                                <span class="badge bg-secondary text-white fw-bold px-3 py-2 text-uppercase rounded-3 shadow">
                                                    🎭 Kịch Nghệ Tinh Hoa
                                                </span>
                                                <span class="badge bg-white text-dark fw-semibold px-3 py-2 rounded-3 shadow-sm">
                                                    Đạo Diễn NSƯT Thành Lộc
                                                </span>
                                            </div>
                                            <div class="position-absolute bottom-0 start-0 p-4 text-white">
                                                <span class="text-uppercase fw-semibold tracking-wider text-warning" style="font-size: 0.8rem;">Đoàn kịch nghệ sĩ</span>
                                                <h4 class="fw-bold mb-0 text-white mt-1">
                                                    Sân Khấu Kịch Idecaf &amp; Diễn Viên Tinh Anh
                                                </h4>
                                            </div>
                                        </div>
                                        <div class="d-none d-lg-flex ticket-stub-divider">
                                            <div class="ticket-notch-top"></div>
                                            <div class="ticket-dashed-line"></div>
                                            <div class="ticket-notch-bottom"></div>
                                        </div>
                                        <div class="col-lg p-4 p-xl-5 d-flex flex-column justify-content-between bg-white">
                                            <div>
                                                <div class="d-flex align-items-center justify-content-between mb-2">
                                                    <span class="text-uppercase small fw-bold text-muted" style="letter-spacing: 0.5px;">Sân Khấu Kịch Idecaf</span>
                                                    <button class="btn btn-link text-muted p-1 text-decoration-none like-btn-stub" title="Lưu vào danh sách thích">
                                                        <span class="material-symbols-outlined" style="font-size: 24px;">favorite</span>
                                                    </button>
                                                </div>
                                                <h3 class="fw-extrabold text-dark mb-3">
                                                    Vở Kịch Kinh Điển: Người Tình Mùa Thu
                                                </h3>
                                                <div class="d-flex flex-column gap-2 mb-3">
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">calendar_today</span>
                                                        <strong class="text-dark">18 Tháng 06, 2025 • 20:00</strong>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">masks</span>
                                                        <span>Sân khấu kịch Idecaf, Quận 1, TP.HCM</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-2 text-secondary small">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">confirmation_number</span>
                                                        <span>Khu vực: Hàng A-C Chính Diện, Hàng D-G Tầng Trệt</span>
                                                    </div>
                                                </div>
                                                <div class="p-3 rounded-3 d-flex align-items-center justify-content-between mb-3" style="background-color: #eff4ff;">
                                                    <div class="d-flex align-items-center gap-2">
                                                        <span class="material-symbols-outlined text-primary-custom" style="font-size: 20px;">alarm</span>
                                                        <span class="small fw-semibold text-secondary">Đóng cổng bán sau:</span>
                                                    </div>
                                                    <div class="d-flex align-items-center gap-1 fw-bold fs-5 text-primary-custom">
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">08</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">52</span>
                                                        <span>:</span>
                                                        <span class="bg-white px-2 py-1 rounded shadow-sm">40</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pt-3 border-top d-flex align-items-center justify-content-between gap-3">
                                                <div>
                                                    <span class="small text-muted d-block">Giá vé từ</span>
                                                    <span class="fs-4 fw-bold text-primary-custom">250.000₫</span>
                                                </div>
                                                <button class="btn btn-primary-custom px-4 py-3 rounded-3 d-flex align-items-center gap-2">
                                                    <span>Mua vé ngay</span>
                                                    <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Carousel Indicators: 5 items -->
                        <div class="carousel-indicators">
                            <button aria-current="true" aria-label="Slide 1" class="active" data-bs-slide-to="0" data-bs-target="#featuredEventsCarousel" type="button"></button>
                            <button aria-label="Slide 2" data-bs-slide-to="1" data-bs-target="#featuredEventsCarousel" type="button"></button>
                            <button aria-label="Slide 3" data-bs-slide-to="2" data-bs-target="#featuredEventsCarousel" type="button"></button>
                            <button aria-label="Slide 4" data-bs-slide-to="3" data-bs-target="#featuredEventsCarousel" type="button"></button>
                            <button aria-label="Slide 5" data-bs-slide-to="4" data-bs-target="#featuredEventsCarousel" type="button"></button>
                        </div>
                    </div>
                </div>
            </section>

            <!-- 5. 128 EVENTS GRID -->
            <section class="py-4">
                <div class="container px-3 px-lg-5">
                    <!-- Toolbar Sorters -->
                    <div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-between pb-3 mb-4 border-bottom gap-3">
                        <div class="d-flex align-items-center gap-2">
                            <h2 class="fs-4 fw-bold mb-0">128 Sự kiện sắp diễn ra</h2>
                            <span class="badge bg-secondary-subtle text-dark rounded-pill px-3 py-1">Toàn quốc</span>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <div class="d-flex align-items-center gap-2">
                                <span class="small text-muted text-nowrap d-none d-md-inline">Sắp xếp:</span>
                                <select class="form-select form-select-sm bg-white border-0 shadow-sm rounded-3 fw-semibold py-2">
                                    <option value="popular">Phổ biến nhất</option>
                                    <option value="newest">Mới cập nhật</option>
                                    <option value="price-asc">Giá: Thấp đến Cao</option>
                                    <option value="price-desc">Giá: Cao đến Thấp</option>
                                    <option value="nearest">Ngày gần nhất</option>
                                </select>
                            </div>
                            <!-- View Mode Switcher -->
                            <div class="btn-group p-1 rounded-3" role="group" style="background-color: #e9eefa;">
                                <button class="btn btn-sm btn-white bg-white text-primary-custom shadow-xs" title="Xem dạng lưới" type="button">
                                    <span class="material-symbols-outlined d-block" style="font-size: 18px;">grid_view</span>
                                </button>
                                <button class="btn btn-sm btn-link text-secondary text-decoration-none" title="Xem dạng danh sách" type="button">
                                    <span class="material-symbols-outlined d-block" style="font-size: 18px;">view_list</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- 6 Event Cards Grid -->
                    <div class="row g-4" id="eventCardList">
                        <!-- CARD 1 -->
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="event-card">
                                <div class="event-card-media">
                                    <img alt="Những Thành Phố Mơ Màng 2025" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCvP7SQSxAcJ0UEQeLDd86WUGDdp1pzjmeQJJvHCc0DYUdCdfhaf-Pvq6MLsf_xQlv_TI-aiM5e12EJd5M9Jf-NcMA37Yheknp-V3Oajq9mmx02VVLazNv_DM3B62IWDz57ETnT0vtWCWIGtp5FRbeTFyPG_zwWWOKnqjCrWk-gdMOYawNwwLHcl_M8Yu4nBljk_nouZu2x3zV0tO2G1l2GpiByb6SL0cizyxb2erAQ2tOU_xoL4glm1A"/>
                                    <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                        <span class="badge bg-primary-custom text-white fw-bold px-2 py-1 rounded">Trending</span>
                                        <span class="badge bg-white text-dark fw-semibold px-2 py-1 rounded">Indie / Pop</span>
                                    </div>
                                    <button class="like-btn" title="Thêm vào yêu thích">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">favorite</span>
                                    </button>
                                    <div class="date-badge">
                                        <span class="fs-4 fw-bold text-primary-custom lh-1">20</span>
                                        <div class="d-flex flex-column lh-1">
                                            <span class="fw-bold small text-dark text-uppercase">Tháng 05</span>
                                            <span class="text-muted" style="font-size: 0.72rem;">Thứ Bảy</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                                    <div>
                                        <span class="small text-muted d-block mb-1">Ban Tổ Chức: Mơ Màng Entertainment</span>
                                        <h3 class="fs-5 fw-bold text-dark mb-2 text-truncate" title="Indie Rock Night: Những Thành Phố Mơ Màng 2025">
                                            Indie Rock Night: Những Thành Phố Mơ Màng 2025
                                        </h3>
                                        <div class="d-flex align-items-center gap-1 text-muted small mb-3">
                                            <span class="material-symbols-outlined" style="font-size: 18px;">location_on</span>
                                            <span class="text-truncate">Công viên Yên Sở, Hoàng Mai, Hà Nội</span>
                                        </div>
                                    </div>
                                    <div>
                                        <hr class="border-secondary-subtle my-2 border-dashed"/>
                                        <div class="d-flex align-items-center justify-content-between pt-1">
                                            <div>
                                                <span class="small text-muted d-block" style="font-size: 0.75rem;">Chỉ từ</span>
                                                <span class="fs-5 fw-bold text-primary-custom">450.000₫</span>
                                            </div>
                                            <button class="btn btn-sm px-3 py-2 rounded-3 d-flex align-items-center gap-1 text-dark" style="background-color: #eff4ff;">
                                                <span class="fw-semibold">Chọn vé</span>
                                                <span class="material-symbols-outlined" style="font-size: 16px;">chevron_right</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </div>

                        <!-- CARD 2 -->
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="event-card">
                                <div class="event-card-media">
                                    <img alt="Symphony of Lights" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBHl6jIakVdo_0lAbJNd9BvxycHE1l_R7kEFo-j1pPwtLVT5oU150-22xZpFG0gqKEE8hVbritG9QTzzsrjlUA7BzePzc0FqPivgfIpizlfkZdOfBc9CpSWyJ5YV7ls2b2kl2Ut1rbhs9wFpaZJNaZ-9WVBAsnxBP_ne8sWxiDUMQGLJQjshJ5gM4imBReYRJBtwgKeofLesczGck2_KxR270IY7BEMBdp4eeKM0Wi9w-tMh97z6D9cng"/>
                                    <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                        <span class="badge bg-secondary text-white fw-bold px-2 py-1 rounded">Bán chạy</span>
                                        <span class="badge bg-white text-dark fw-semibold px-2 py-1 rounded">Hòa nhạc Cổ điển</span>
                                    </div>
                                    <button class="like-btn" title="Thêm vào yêu thích">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">favorite</span>
                                    </button>
                                    <div class="date-badge">
                                        <span class="fs-4 fw-bold text-primary-custom lh-1">28</span>
                                        <div class="d-flex flex-column lh-1">
                                            <span class="fw-bold small text-dark text-uppercase">Tháng 05</span>
                                            <span class="text-muted" style="font-size: 0.72rem;">Chủ Nhật</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                                    <div>
                                        <span class="small text-muted d-block mb-1">Dàn nhạc Giao hưởng Sài Gòn</span>
                                        <h3 class="fs-5 fw-bold text-dark mb-2 text-truncate" title="Symphony of Lights: Đêm Hòa Nhạc Beethoven &amp; Tchaikovsky">
                                            Symphony of Lights: Đêm Hòa Nhạc Beethoven &amp; Tchaikovsky
                                        </h3>
                                        <div class="d-flex align-items-center gap-1 text-muted small mb-3">
                                            <span class="material-symbols-outlined" style="font-size: 18px;">theater_comedy</span>
                                            <span class="text-truncate">Nhà Hát Lớn TP. Hồ Chí Minh, Quận 1</span>
                                        </div>
                                    </div>
                                    <div>
                                        <hr class="border-secondary-subtle my-2 border-dashed"/>
                                        <div class="d-flex align-items-center justify-content-between pt-1">
                                            <div>
                                                <span class="small text-muted d-block" style="font-size: 0.75rem;">Chỉ từ</span>
                                                <span class="fs-5 fw-bold text-primary-custom">800.000₫</span>
                                            </div>
                                            <button class="btn btn-sm px-3 py-2 rounded-3 d-flex align-items-center gap-1 text-dark" style="background-color: #eff4ff;">
                                                <span class="fw-semibold">Chọn vé</span>
                                                <span class="material-symbols-outlined" style="font-size: 16px;">chevron_right</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </div>

                        <!-- CARD 3 -->
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="event-card">
                                <div class="event-card-media">
                                    <img alt="Sunset Acoustic Chill Đà Lạt" src="https://lh3.googleusercontent.com/aida-public/AB6AXuAAUKho7TpYzZ5K1jxkHIy1wviA0Mw_HOjlxLHDNhSgr7SIVKNvszFq3T6YjKyFsSQtK8PI_uR8EuM7eSe00v0kB-fk-KFHJUYDYIpRnuVDK_BxsYxB3V71RvV1uGeeGpqVa6MkJBkhdIijNnnjPuwQIXTc6YOO2bxddXK5rYgtv5-CC1-WQWwFE89wYHlW4ffL_0cuFB8WWl3pW2NqtvVKb8M0b7jxLA2l6BctChD_ozDw8CwS-iPycg"/>
                                    <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                        <span class="badge bg-primary-custom text-white fw-bold px-2 py-1 rounded">Hot</span>
                                        <span class="badge bg-white text-dark fw-semibold px-2 py-1 rounded">Acoustic Chill</span>
                                    </div>
                                    <button class="like-btn" title="Thêm vào yêu thích">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">favorite</span>
                                    </button>
                                    <div class="date-badge">
                                        <span class="fs-4 fw-bold text-primary-custom lh-1">02</span>
                                        <div class="d-flex flex-column lh-1">
                                            <span class="fw-bold small text-dark text-uppercase">Tháng 06</span>
                                            <span class="text-muted" style="font-size: 0.72rem;">Thứ Sáu</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                                    <div>
                                        <span class="small text-muted d-block mb-1">Mây Lang Thang Production</span>
                                        <h3 class="fs-5 fw-bold text-dark mb-2 text-truncate" title="Sunset Acoustic Chill: Mây Lang Thang &amp; Những Bản Tình Ca">
                                            Sunset Acoustic Chill: Mây Lang Thang &amp; Những Bản Tình Ca
                                        </h3>
                                        <div class="d-flex align-items-center gap-1 text-muted small mb-3">
                                            <span class="material-symbols-outlined" style="font-size: 18px;">nature_people</span>
                                            <span class="text-truncate">Thung Lũng Mơ Màng, TP. Đà Lạt</span>
                                        </div>
                                    </div>
                                    <div>
                                        <hr class="border-secondary-subtle my-2 border-dashed"/>
                                        <div class="d-flex align-items-center justify-content-between pt-1">
                                            <div>
                                                <span class="small text-muted d-block" style="font-size: 0.75rem;">Chỉ từ</span>
                                                <span class="fs-5 fw-bold text-primary-custom">350.000₫</span>
                                            </div>
                                            <button class="btn btn-sm px-3 py-2 rounded-3 d-flex align-items-center gap-1 text-dark" style="background-color: #eff4ff;">
                                                <span class="fw-semibold">Chọn vé</span>
                                                <span class="material-symbols-outlined" style="font-size: 16px;">chevron_right</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </div>

                        <!-- CARD 4 -->
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="event-card">
                                <div class="event-card-media">
                                    <img alt="EDM Festival TP.HCM" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCzX3LKkhEzRzvBVQPI0yMT0r_wnqk-GbmK7ILzxy7UMIW6Zu8XyQI-mmdd3u3UDbwp15S_TxfKWk_NzN_mbNpHf4GVCogiDzf9BbGK_3Q9gt1l-Fn3HcvhLv_926dMlOBYLC4fDGj6TLw_Sa2uogsfm4-M_a2wpYeeeq_3Nsk__rHCN8od5RQFtnBM57WjAhNVo7N28h_n3hoIA9lXiv_fkU1xzGNwVex41JvsAUZjxB1vkK7WKdwcYA"/>
                                    <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                        <span class="badge bg-danger text-white fw-bold px-2 py-1 rounded">Sắp hết vé</span>
                                        <span class="badge bg-white text-dark fw-semibold px-2 py-1 rounded">EDM / Festival</span>
                                    </div>
                                    <button class="like-btn" title="Thêm vào yêu thích">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">favorite</span>
                                    </button>
                                    <div class="date-badge">
                                        <span class="fs-4 fw-bold text-primary-custom lh-1">12</span>
                                        <div class="d-flex flex-column lh-1">
                                            <span class="fw-bold small text-dark text-uppercase">Tháng 06</span>
                                            <span class="text-muted" style="font-size: 0.72rem;">Thứ Bảy</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                                    <div>
                                        <span class="small text-muted d-block mb-1">Saigon Rave United</span>
                                        <h3 class="fs-5 fw-bold text-dark mb-2 text-truncate" title="Saigon Electronic Music Fest 2025: Electric Horizons">
                                            Saigon Electronic Music Fest 2025: Electric Horizons
                                        </h3>
                                        <div class="d-flex align-items-center gap-1 text-muted small mb-3">
                                            <span class="material-symbols-outlined" style="font-size: 18px;">apartment</span>
                                            <span class="text-truncate">Trung tâm Hội chợ SECC, Quận 7, TP.HCM</span>
                                        </div>
                                    </div>
                                    <div>
                                        <hr class="border-secondary-subtle my-2 border-dashed"/>
                                        <div class="d-flex align-items-center justify-content-between pt-1">
                                            <div>
                                                <span class="small text-muted d-block" style="font-size: 0.75rem;">Chỉ từ</span>
                                                <span class="fs-5 fw-bold text-primary-custom">790.000₫</span>
                                            </div>
                                            <button class="btn btn-sm px-3 py-2 rounded-3 d-flex align-items-center gap-1 text-dark" style="background-color: #eff4ff;">
                                                <span class="fw-semibold">Chọn vé</span>
                                                <span class="material-symbols-outlined" style="font-size: 16px;">chevron_right</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </div>

                        <!-- CARD 5 -->
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="event-card">
                                <div class="event-card-media">
                                    <img alt="Sân khấu kịch" src="https://lh3.googleusercontent.com/aida-public/AB6AXuAfptPe1WjMskI6mUm3Ev7iGeBrVhPZSXkZN-FW00x72pwd9l2b861EWl9cWVSsnxZcd94XZZrGPliWhaPldxWP-vZtn7cHF6izJF2ANzn-y42Ty3WdHQSadQ0o1Zs2pU2cs2A5XyrU_CSFrpWNWfmMhHw5MJw8E5T-ba0gHyhBS3Z1_Uk01cWABol4eu3oJzusnYVMA4MHbmo475D639SLO9PRfCO0GUo46g9DXkOk-jeJGfL5CqX-vQ"/>
                                    <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                        <span class="badge bg-light text-dark fw-bold px-2 py-1 rounded">Kịch Nói Tinh Hoa</span>
                                    </div>
                                    <button class="like-btn" title="Thêm vào yêu thích">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">favorite</span>
                                    </button>
                                    <div class="date-badge">
                                        <span class="fs-4 fw-bold text-primary-custom lh-1">18</span>
                                        <div class="d-flex flex-column lh-1">
                                            <span class="fw-bold small text-dark text-uppercase">Tháng 06</span>
                                            <span class="text-muted" style="font-size: 0.72rem;">Thứ Năm</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                                    <div>
                                        <span class="small text-muted d-block mb-1">Sân Khấu Kịch Idecaf</span>
                                        <h3 class="fs-5 fw-bold text-dark mb-2 text-truncate" title="Vở Kịch Kinh Điển: Người Tình Mùa Thu (Đạo diễn NSƯT Thành Lộc)">
                                            Vở Kịch Kinh Điển: Người Tình Mùa Thu (Đạo diễn NSƯT Thành Lộc)
                                        </h3>
                                        <div class="d-flex align-items-center gap-1 text-muted small mb-3">
                                            <span class="material-symbols-outlined" style="font-size: 18px;">masks</span>
                                            <span class="text-truncate">Sân khấu kịch Idecaf, Quận 1, TP.HCM</span>
                                        </div>
                                    </div>
                                    <div>
                                        <hr class="border-secondary-subtle my-2 border-dashed"/>
                                        <div class="d-flex align-items-center justify-content-between pt-1">
                                            <div>
                                                <span class="small text-muted d-block" style="font-size: 0.75rem;">Chỉ từ</span>
                                                <span class="fs-5 fw-bold text-primary-custom">250.000₫</span>
                                            </div>
                                            <button class="btn btn-sm px-3 py-2 rounded-3 d-flex align-items-center gap-1 text-dark" style="background-color: #eff4ff;">
                                                <span class="fw-semibold">Chọn vé</span>
                                                <span class="material-symbols-outlined" style="font-size: 16px;">chevron_right</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </div>

                        <!-- CARD 6 -->
                        <div class="col-12 col-md-6 col-lg-4">
                            <article class="event-card">
                                <div class="event-card-media">
                                    <img alt="Triển lãm TechWave 2025" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBobBX0X37K1Vc4aFv5Jbabug41V6-CLQ1DMcAACfe6z1hpTPu1Z2YilK64d9JrO0K77sDfgQU9AMT7Mot_mOXYNzoMiympU_fHV5HH6QXx8jTPjQp5geRuuhqBZU5n1UNb7xA7WCrRs98lqQCUfMpw15JEJYJ58f1hcAvhDiGA2WBG2CnZ0R967CcxX9YBrkQS0aLjtZ-0RITnsSqqtQHmCv1sg1izbJoBhkZ9qCbj45xTG7uzBRPC4g"/>
                                    <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                        <span class="badge bg-success text-white fw-bold px-2 py-1 rounded">Miễn phí vào cửa</span>
                                        <span class="badge bg-white text-dark fw-semibold px-2 py-1 rounded">Triển lãm Công nghệ</span>
                                    </div>
                                    <button class="like-btn" title="Thêm vào yêu thích">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">favorite</span>
                                    </button>
                                    <div class="date-badge">
                                        <span class="fs-4 fw-bold text-primary-custom lh-1">22</span>
                                        <div class="d-flex flex-column lh-1">
                                            <span class="fw-bold small text-dark text-uppercase">Tháng 06</span>
                                            <span class="text-muted" style="font-size: 0.72rem;">Chủ Nhật</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="p-3 d-flex flex-column justify-content-between flex-grow-1">
                                    <div>
                                        <span class="small text-muted d-block mb-1">Hiệp Hội Đổi Mới Sáng Tạo Quốc Gia</span>
                                        <h3 class="fs-5 fw-bold text-dark mb-2 text-truncate" title="Triển Lãm Công Nghệ Tương Lai &amp; Sáng Tạo Số TechWave 2025">
                                            Triển Lãm Công Nghệ Tương Lai &amp; Sáng Tạo Số TechWave 2025
                                        </h3>
                                        <div class="d-flex align-items-center gap-1 text-muted small mb-3">
                                            <span class="material-symbols-outlined" style="font-size: 18px;">hub</span>
                                            <span class="text-truncate">Cung Triển lãm Kiến trúc Quy hoạch, Hà Nội</span>
                                        </div>
                                    </div>
                                    <div>
                                        <hr class="border-secondary-subtle my-2 border-dashed"/>
                                        <div class="d-flex align-items-center justify-content-between pt-1">
                                            <div>
                                                <span class="small text-muted d-block" style="font-size: 0.75rem;">Giá vé</span>
                                                <span class="fs-5 fw-bold text-success">0₫ (Đăng ký)</span>
                                            </div>
                                            <button class="btn btn-sm px-3 py-2 rounded-3 d-flex align-items-center gap-1 text-dark" style="background-color: #eff4ff;">
                                                <span class="fw-semibold">Đăng ký</span>
                                                <span class="material-symbols-outlined" style="font-size: 16px;">how_to_reg</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </article>
                        </div>
                    </div>

                    <!-- 6. BOOTSTRAP PAGINATION -->
                    <div class="d-flex flex-column flex-sm-row align-items-center justify-content-between pt-5 pb-3 gap-3">
                        <span class="small text-muted order-2 order-sm-1">
                            Hiển thị <strong class="text-dark">1 - 6</strong> trong số <strong class="text-dark">128</strong> sự kiện
                        </span>
                        <nav aria-label="Phân trang sự kiện" class="order-1 order-sm-2">
                            <ul class="pagination mb-0 align-items-center">
                                <li class="page-item">
                                    <a aria-label="Previous" class="page-link-custom" href="#">
                                        <span class="material-symbols-outlined" style="font-size: 18px;">chevron_left</span>
                                    </a>
                                </li>
                                <li class="page-item"><a class="page-link-custom active" href="#">1</a></li>
                                <li class="page-item"><a class="page-link-custom" href="#">2</a></li>
                                <li class="page-item"><a class="page-link-custom" href="#">3</a></li>
                                <li class="page-item disabled"><span class="px-2 text-muted fw-bold">•••</span></li>
                                <li class="page-item"><a class="page-link-custom" href="#">12</a></li>
                                <li class="page-item">
                                    <a aria-label="Next" class="page-link-custom px-3 w-auto d-flex align-items-center gap-1" href="#">
                                        <span>Tiếp theo</span>
                                        <span class="material-symbols-outlined" style="font-size: 16px;">chevron_right</span>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </section>

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
                                <form class="bg-white p-2 rounded-4 shadow-lg d-flex flex-column flex-sm-row gap-2" onsubmit="event.preventDefault(); alert('Cảm ơn bạn đã đăng ký nhận thông báo!');">
                                    <div class="d-flex align-items-center px-3 py-2 flex-grow-1">
                                        <span class="material-symbols-outlined text-muted me-2" style="font-size: 20px;">mail</span>
                                        <input class="form-control border-0 p-0 text-dark" placeholder="Nhập địa chỉ email của bạn..." required="" type="email"/>
                                    </div>
                                    <button class="btn text-white fw-bold px-4 py-2 rounded-3 text-nowrap" style="background-color: #702400;" type="submit">
                                        Nhận thông báo
                                    </button>
                                </form>
                                <small class="text-white-50 d-block mt-2 text-center text-lg-start">
                                    Cam kết không spam • Hủy đăng ký bất cứ lúc nào chỉ với 1 cú nhấp chuột.
                                </small>
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
                            <li><a class="footer-link" href="#">Vé của tôi</a></li>
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

                                // 2. Category Pill Filter Active Toggle
                                const catButtons = document.querySelectorAll('#categoryGroup .cat-btn');
                                catButtons.forEach(btn => {
                                    btn.addEventListener('click', () => {
                                        catButtons.forEach(b => b.classList.remove('active'));
                                        btn.classList.add('active');
                                    });
                                });

                                // 3. Simple Dynamic Countdown Clock for Featured Event
                                let hours = 4;
                                let minutes = 18;
                                let seconds = 42;

                                const elHours = document.getElementById('cd-hours');
                                const elMinutes = document.getElementById('cd-minutes');
                                const elSeconds = document.getElementById('cd-seconds');

                                setInterval(() => {
                                    if (seconds > 0) {
                                        seconds--;
                                    } else {
                                        seconds = 59;
                                        if (minutes > 0) {
                                            minutes--;
                                        } else {
                                            minutes = 59;
                                            if (hours > 0)
                                                hours--;
                                        }
                                    }
                                    if (elHours)
                                        elHours.textContent = hours.toString().padStart(2, '0');
                                    if (elMinutes)
                                        elMinutes.textContent = minutes.toString().padStart(2, '0');
                                    if (elSeconds)
                                        elSeconds.textContent = seconds.toString().padStart(2, '0');
                                }, 1000);

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