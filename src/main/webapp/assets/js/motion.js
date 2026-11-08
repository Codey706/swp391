/* ==========================================================================
   Light Ticket — motion.js (nạp ở mọi trang, defer)
   · Hiệu ứng xuất hiện: các khối nội dung lần lượt trượt lên khi vào trang,
     khối bên dưới màn hình hiện ra khi cuộn tới.
   · Header công khai đổ bóng khi cuộn.
   · Số liệu thống kê chạy đếm từ 0.
   An toàn: chỉ JS này mới ẩn phần tử (thêm .mo-reveal), nên nếu script lỗi hay bị
   tắt, nội dung vẫn hiện đủ. Tôn trọng prefers-reduced-motion. Không đổi logic trang.
   ========================================================================== */
(function () {
    'use strict';
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var doc = document.documentElement;

    /* ---- Header công khai: đổ bóng khi cuộn ---------------------------- */
    var header = document.querySelector('.sh-header');
    if (header) {
        var onScroll = function () { header.classList.toggle('is-scrolled', window.scrollY > 4); };
        window.addEventListener('scroll', onScroll, { passive: true });
        onScroll();
    }
    if (reduce || !('IntersectionObserver' in window)) { return; }

    /* ---- Chọn khối để làm hiệu ứng xuất hiện --------------------------- */
    // Thẻ / panel: mỗi cái xuất hiện riêng, so le nhau
    var CARD = [
        '.event-card', '.ck-event-hero', '.ck-panel', '.lt-card', '.card', '.stat-card', '.dash-stat',
        '.dashboard-card', '.org-card', '.op-section', '.sg-footer-grid > *', '.search-box-floating',
        '.sg-section-title', '.sg-section-lead', '.sg-events-head', '.page-heading', '.ticket'
    ].join(',');
    // Gốc nội dung: con trực tiếp không chứa thẻ nào cũng được làm hiệu ứng
    var ROOTS = 'main, .admin-content > .content, .org-container, .ck-wrap';
    // Không bao giờ làm hiệu ứng cho các phần cố định/điều hướng/hộp thoại
    var SKIP = '.sh-header, .org-sidebar, .admin-sidebar, .org-topbar, .admin-topbar, .modal, .dropdown-menu,'
        + ' .category-pills-bar, .sg-hero, [data-um-menu], .event-modal, .ck-mobile-cta, script, style, link, template';

    function usable(el) {
        if (el.closest(SKIP)) { return false; }
        var cs = getComputedStyle(el);
        if (cs.display === 'none' || cs.visibility === 'hidden' || cs.position === 'fixed') { return false; }
        return el.getClientRects().length > 0;
    }

    var picked = [];
    var cards = Array.prototype.filter.call(document.querySelectorAll(CARD), usable);
    // chỉ lấy thẻ ngoài cùng (tránh thẻ lồng thẻ trượt 2 lần)
    cards.forEach(function (el) {
        var p = el.parentElement;
        while (p) { if (cards.indexOf(p) !== -1) { return; } p = p.parentElement; }
        picked.push(el);
    });
    Array.prototype.forEach.call(document.querySelectorAll(ROOTS), function (root) {
        Array.prototype.forEach.call(root.children, function (el) {
            if (picked.indexOf(el) !== -1 || !usable(el)) { return; }
            if (el.querySelector(CARD) || el.closest(CARD)) { return; }
            var inside = false;
            picked.forEach(function (c) { if (c.contains(el)) { inside = true; } });
            if (!inside) { picked.push(el); }
        });
    });
    // Hàng bảng: chỉ mờ dần (không trượt) để bảng không bị giật
    var rows = [];
    Array.prototype.forEach.call(document.querySelectorAll('table tbody'), function (tb) {
        if (tb.closest(SKIP) || tb.rows.length > 60) { return; }
        Array.prototype.forEach.call(tb.rows, function (tr) { rows.push(tr); });
    });

    // thứ tự theo vị trí trên trang
    picked.sort(function (a, b) {
        var ra = a.getBoundingClientRect(), rb = b.getBoundingClientRect();
        return (ra.top - rb.top) || (ra.left - rb.left);
    });

    function finish(el) {
        el.classList.remove('mo-reveal', 'mo-fade', 'mo-in');
        el.style.removeProperty('--mo-delay');
    }
    function show(el, delay) {
        el.style.setProperty('--mo-delay', delay + 'ms');
        el.classList.add('mo-in');
        var done = function (e) { if (e.target === el) { el.removeEventListener('transitionend', done); finish(el); } };
        el.addEventListener('transitionend', done);
        setTimeout(function () { finish(el); }, delay + 1200);   // phòng khi transitionend không chạy
    }

    picked.forEach(function (el) { el.classList.add('mo-reveal'); });
    rows.forEach(function (el) { el.classList.add('mo-fade'); });

    var io = new IntersectionObserver(function (entries) {
        var batch = 0;
        entries.forEach(function (en) {
            if (!en.isIntersecting) { return; }
            io.unobserve(en.target);
            var step = en.target.tagName === 'TR' ? 35 : 70;
            show(en.target, Math.min(batch * step, 560));
            batch++;
        });
    }, { rootMargin: '0px 0px -6% 0px', threshold: 0.01 });

    // đợi 1 frame để trạng thái ẩn được vẽ rồi mới bắt đầu
    requestAnimationFrame(function () {
        requestAnimationFrame(function () {
            picked.concat(rows).forEach(function (el) { io.observe(el); });
            doc.classList.add('mo-ready');
        });
    });
    // lưới an toàn: sau 4s mọi thứ chắc chắn hiện
    setTimeout(function () {
        Array.prototype.forEach.call(document.querySelectorAll('.mo-reveal:not(.mo-in), .mo-fade:not(.mo-in)'), function (el) { show(el, 0); });
    }, 4000);
    // in trang (vd. e-tickets ?print=1): hiện hết ngay
    window.addEventListener('beforeprint', function () {
        Array.prototype.forEach.call(document.querySelectorAll('.mo-reveal, .mo-fade'), finish);
    });

    /* ---- Số liệu thống kê chạy đếm --------------------------------------- */
    var NUM = '.stat-card h2, .dash-stat-value';
    Array.prototype.forEach.call(document.querySelectorAll(NUM), function (el) {
        if (el.children.length) { return; }
        var text = el.textContent.trim();
        var m = text.match(/^([\d.,]+)(\s*\D*)$/);
        if (!m) { return; }
        var sep = m[1].indexOf(',') !== -1 ? ',' : (m[1].indexOf('.') !== -1 && /\.\d{3}(?!\d)/.test(m[1]) ? '.' : '');
        var target = parseInt(m[1].replace(/[.,]/g, ''), 10);
        if (!isFinite(target) || target === 0) { return; }
        var fmt = function (n) { var s = String(n); return sep ? s.replace(/\B(?=(\d{3})+(?!\d))/g, sep) : s; };
        var ob = new IntersectionObserver(function (en) {
            if (!en[0].isIntersecting) { return; }
            ob.disconnect();
            var t0 = null, dur = 900;
            var tick = function (ts) {
                if (t0 === null) { t0 = ts; }
                var k = Math.min(1, (ts - t0) / dur), e = 1 - Math.pow(1 - k, 3);
                el.textContent = fmt(Math.round(target * e)) + m[2];
                if (k < 1) { requestAnimationFrame(tick); } else { el.textContent = text; }
            };
            requestAnimationFrame(tick);
        });
        ob.observe(el);
    });
})();
