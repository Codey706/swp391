// Staff - Trạng thái chỗ ngồi: CHỈ XEM. Không có sự kiện click/kéo/thả trên ghế,
// không gửi bất kỳ request nào lên server ngoài việc đổi sự kiện bằng GET (form).
(function () {
    'use strict';

    // ---- đổi sự kiện (GET /staff/seats?eventId=...; server kiểm tra lại quyền) ----
    var select = document.getElementById('ssEventSelect');
    if (select && select.form) {
        select.addEventListener('change', function () {
            select.form.submit();
        });
    }

    // ---- tab Khu ghế ngồi / Khu đứng (chỉ ẩn/hiện) ----
    var tabs = document.querySelectorAll('.ss-tab');
    tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
            tabs.forEach(function (t) {
                var active = t === tab;
                t.classList.toggle('is-active', active);
                t.setAttribute('aria-selected', active ? 'true' : 'false');
                var pane = document.getElementById(t.getAttribute('data-target'));
                if (pane) {
                    pane.hidden = !active;
                }
            });
        });
    });

    // ---- sơ đồ ghế ----
    var dataEl = document.getElementById('ssData');
    var svg = document.getElementById('ssSvg');
    if (!dataEl || !svg) {
        return;
    }

    var data;
    try {
        data = JSON.parse(dataEl.textContent);
    } catch (e) {
        return;
    }

    var SVG_NS = 'http://www.w3.org/2000/svg';
    var PITCH = data.pitch || 24, PAD = 10, HEAD = 24, LEFT = 16, SEAT_R = 8;
    var STATUS = ['Còn trống', 'Đang giữ chỗ', 'Đã đặt', 'Đã sử dụng (đã check-in)', 'Không khả dụng'];

    function el(name, attrs, parent) {
        var node = document.createElementNS(SVG_NS, name);
        Object.keys(attrs || {}).forEach(function (k) {
            node.setAttribute(k, attrs[k]);
        });
        if (parent) {
            parent.appendChild(node);
        }
        return node;
    }

    function truncate(text, max) {
        text = text || '';
        return text.length > max ? text.substring(0, Math.max(1, max - 1)) + '…' : text;
    }

    var zones = data.zones || [];
    if (!zones.length) {
        return;
    }

    // Vừa khung theo vùng thực sự có khu (sân khấu + khu ngồi)
    var minX = Infinity, minY = Infinity, maxX = 0, maxY = 0;
    zones.forEach(function (z) {
        minX = Math.min(minX, z.x);
        minY = Math.min(minY, z.y);
        maxX = Math.max(maxX, z.x + z.w);
        maxY = Math.max(maxY, z.y + z.h);
    });
    var MARGIN = 20;
    var vbX = Math.max(0, minX - MARGIN), vbY = Math.max(0, minY - MARGIN);
    var vbW = maxX - vbX + MARGIN, vbH = maxY - vbY + MARGIN;
    svg.setAttribute('viewBox', vbX + ' ' + vbY + ' ' + vbW + ' ' + vbH);

    zones.forEach(function (z) {
        var g = el('g', {transform: 'translate(' + z.x + ',' + z.y + ')'}, svg);

        if (z.type === 'STAGE') {
            el('rect', {width: z.w, height: z.h, rx: 10, fill: '#334155', stroke: '#0f172a'}, g);
            var st = el('text', {x: z.w / 2, y: z.h / 2 + 5, 'text-anchor': 'middle', fill: '#fff',
                'font-size': 15, 'font-weight': 800, 'letter-spacing': 1.5}, g);
            st.textContent = truncate((z.name || '').toUpperCase(), Math.max(4, Math.floor(z.w / 11)));
            return;
        }

        var color = /^#[0-9A-Fa-f]{6}$/.test(z.color || '') ? z.color : '#94A3B8';
        el('rect', {width: z.w, height: z.h, rx: 10, fill: color, 'fill-opacity': 0.1, stroke: color, 'stroke-width': 1.5}, g);

        var counts = [0, 0, 0, 0, 0];
        (z.seats || []).forEach(function (s) {
            counts[s[2]]++;
        });
        var total = (z.seats || []).length;

        var title = el('text', {x: 10, y: 17, fill: '#0f172a', 'font-size': 12, 'font-weight': 800}, g);
        title.textContent = truncate(z.name, Math.max(6, Math.floor((z.w - 100) / 7)));
        var cap = el('text', {x: z.w - 10, y: 17, 'text-anchor': 'end', fill: '#475569', 'font-size': 10.5, 'font-weight': 600}, g);
        cap.textContent = counts[0] + '/' + total + ' trống';

        for (var r = 0; r < z.rows; r++) {
            var letter = el('text', {x: PAD + 4, y: HEAD + PAD + r * PITCH + PITCH / 2 + 3, 'text-anchor': 'middle',
                fill: '#64748b', 'font-size': 9, 'font-weight': 700}, g);
            letter.textContent = String.fromCharCode(65 + r);
        }

        // Chỉ vẽ ghế có thật trong DB (vị trí bỏ trống/lối đi không có ghế nên không vẽ)
        (z.seats || []).forEach(function (s) {
            var row = s[0], col = s[1], status = s[2], vip = s[3] === 1;
            var circle = el('circle', {
                cx: LEFT + PAD + col * PITCH + PITCH / 2,
                cy: HEAD + PAD + row * PITCH + PITCH / 2,
                r: SEAT_R,
                'class': 'ss-seat st-' + status + (vip ? ' is-vip' : '')
            }, g);
            var tip = el('title', {}, circle);
            tip.textContent = (z.name || '') + ' · Hàng ' + String.fromCharCode(65 + row) + ' · Ghế ' + (col + 1)
                    + ' — ' + STATUS[status] + (vip ? ' · Ghế VIP' : '');
        });
    });

    // ---- thu phóng (chỉ đổi kích thước hiển thị) ----
    var zoom = 1;
    function applyZoom() {
        svg.style.width = (zoom * 100) + '%';
    }
    function bind(id, fn) {
        var b = document.getElementById(id);
        if (b) {
            b.addEventListener('click', fn);
        }
    }
    bind('ssZoomIn', function () {
        zoom = Math.min(3, zoom + 0.25);
        applyZoom();
    });
    bind('ssZoomOut', function () {
        zoom = Math.max(0.5, zoom - 0.25);
        applyZoom();
    });
    bind('ssZoomReset', function () {
        zoom = 1;
        applyZoom();
    });
})();
