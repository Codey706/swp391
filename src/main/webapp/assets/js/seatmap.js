// Seat map designer (Organizer). Validate phía client chỉ để phản hồi nhanh;
// backend (SeatMapController) vẫn là nơi quyết định.
(function () {
    'use strict';

    var dataEl = document.getElementById('smData');
    var svg = document.getElementById('smSvg');
    if (!dataEl || !svg) {
        return;
    }

    var data = JSON.parse(dataEl.textContent);
    // Nhúng trong form tạo sự kiện (bước 3) thì không có form riêng #seatmap-form
    var EMBEDDED = !document.getElementById('seatmap-form');
    var READ_ONLY = !!data.readOnly;
    var CANVAS = data.canvas;
    var LIMITS = data.limits;
    var SVG_NS = 'http://www.w3.org/2000/svg';

    // Hình học khu ngồi (khớp hằng số bên server: kích thước tối đa vẫn nằm trong khung)
    var PITCH = 24, PAD = 10, HEAD = 24, LEFT = 16, SEAT_R = 8, SNAP = 10;
    var PALETTE = ['#FF7043', '#2E86DE', '#27AE60', '#8E44AD', '#F1C40F', '#E84393', '#16A085', '#D35400', '#34495E', '#7F8C8D'];
    var STAGE_COLOR = '#334155';
    var NEUTRAL_COLOR = '#94A3B8';

    // ------------------------------------------------ trạng thái
    var uidSeq = 0;
    var tickets = (data.tickets || []).map(function (t) {
        return {id: t.id, name: t.name || '', price: t.price || 0};
    });
    var nextTempId = -1;
    tickets.forEach(function (t) {
        if (t.id <= nextTempId) {
            nextTempId = t.id - 1;
        }
    });

    var zones = (data.zones || []).map(function (z) {
        var blocked = new Set();
        (z.blockedSeats ? String(z.blockedSeats).split(',') : []).forEach(function (p) {
            if (p) {
                blocked.add(p);
            }
        });
        return {
            uid: ++uidSeq,
            type: z.zoneType,
            name: z.zoneName || '',
            ticketId: z.eventTicketId === undefined ? null : z.eventTicketId,
            x: z.posX, y: z.posY, w: z.width, h: z.height,
            rows: z.rowCount || 0, cols: z.seatsPerRow || 0,
            capacity: z.capacity || 0,
            blocked: blocked
        };
    });

    var selectedUid = null;
    var blockMode = false;
    var drag = null;
    var zoom = 1;
    var dirty = false;

    // ------------------------------------------------ tiện ích
    function $(id) {
        return document.getElementById(id);
    }

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

    function clamp(v, min, max) {
        return Math.min(Math.max(v, min), max);
    }

    function snap(v) {
        return Math.round(v / SNAP) * SNAP;
    }

    function formatNumber(n) {
        return Number(n).toLocaleString('vi-VN');
    }

    function byUid(uid) {
        for (var i = 0; i < zones.length; i++) {
            if (zones[i].uid === Number(uid)) {
                return zones[i];
            }
        }
        return null;
    }

    function ticketById(id) {
        for (var i = 0; i < tickets.length; i++) {
            if (tickets[i].id === id) {
                return tickets[i];
            }
        }
        return null;
    }

    function ticketColor(id) {
        for (var i = 0; i < tickets.length; i++) {
            if (tickets[i].id === id) {
                return PALETTE[i % PALETTE.length];
            }
        }
        return NEUTRAL_COLOR;
    }

    function colorOf(z) {
        return z.type === 'STAGE' ? STAGE_COLOR : ticketColor(z.ticketId);
    }

    function seatedSize(z) {
        return {w: LEFT + z.cols * PITCH + 2 * PAD, h: HEAD + z.rows * PITCH + 2 * PAD};
    }

    function blockedInGrid(z) {
        var list = [];
        z.blocked.forEach(function (p) {
            var parts = p.split(':');
            if (Number(parts[0]) < z.rows && Number(parts[1]) < z.cols) {
                list.push(p);
            }
        });
        return list;
    }

    function capacityOf(z) {
        if (z.type === 'SEATED') {
            return Math.max(0, z.rows * z.cols - blockedInGrid(z).length);
        }
        return z.type === 'STANDING' ? z.capacity : 0;
    }

    function overlaps(a, b) {
        return a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h;
    }

    function markDirty() {
        dirty = true;
    }

    // ------------------------------------------------ vẽ SVG
    var defs, gridRect, zonesLayer;

    function initCanvas() {
        svg.setAttribute('viewBox', '0 0 ' + CANVAS.width + ' ' + CANVAS.height);
        if (READ_ONLY) {
            svg.classList.add('sm-readonly');
        }
        defs = el('defs', {}, svg);
        var grid = el('pattern', {id: 'smGrid', width: 50, height: 50, patternUnits: 'userSpaceOnUse'}, defs);
        el('path', {d: 'M 50 0 L 0 0 0 50', fill: 'none', stroke: '#e8edf5', 'stroke-width': 1}, grid);
        var stripes = el('pattern', {id: 'smStripes', width: 10, height: 10, patternUnits: 'userSpaceOnUse', patternTransform: 'rotate(45)'}, defs);
        el('line', {x1: 0, y1: 0, x2: 0, y2: 10, stroke: '#94a3b8', 'stroke-width': 2, opacity: 0.25}, stripes);

        gridRect = el('rect', {x: 0, y: 0, width: CANVAS.width, height: CANVAS.height, fill: 'url(#smGrid)', stroke: '#cbd5e1'}, svg);
        zonesLayer = el('g', {}, svg);
    }

    function truncate(text, max) {
        return text.length > max ? text.substring(0, Math.max(1, max - 1)) + '…' : text;
    }

    function renderZone(z) {
        if (z.type === 'SEATED') {
            var size = seatedSize(z);
            z.w = size.w;
            z.h = size.h;
        }
        var color = colorOf(z);
        var old = zonesLayer.querySelector('g[data-uid="' + z.uid + '"]');
        var g = el('g', {'data-uid': z.uid, transform: 'translate(' + z.x + ',' + z.y + ')'});
        g.setAttribute('class', 'sm-zone' + (z.uid === selectedUid ? ' is-selected' : ''));

        if (z.type === 'STAGE') {
            el('rect', {'class': 'sm-bg', width: z.w, height: z.h, rx: 10, fill: STAGE_COLOR, stroke: '#0f172a'}, g);
            var st = el('text', {x: z.w / 2, y: z.h / 2 + 5, 'text-anchor': 'middle', fill: '#fff', 'font-size': 15, 'font-weight': 800, 'letter-spacing': 1.5}, g);
            st.textContent = truncate(z.name.toUpperCase(), Math.max(4, Math.floor(z.w / 11)));
        } else if (z.type === 'STANDING') {
            el('rect', {'class': 'sm-bg', width: z.w, height: z.h, rx: 10, fill: color, 'fill-opacity': 0.16, stroke: color, 'stroke-width': 2, 'stroke-dasharray': '8 5'}, g);
            el('rect', {width: z.w, height: z.h, rx: 10, fill: 'url(#smStripes)', 'pointer-events': 'none'}, g);
            var t1 = el('text', {x: z.w / 2, y: z.h / 2 - 2, 'text-anchor': 'middle', fill: '#0f172a', 'font-size': 14, 'font-weight': 800}, g);
            t1.textContent = truncate(z.name, Math.max(4, Math.floor(z.w / 9)));
            var t2 = el('text', {x: z.w / 2, y: z.h / 2 + 16, 'text-anchor': 'middle', fill: '#475569', 'font-size': 12, 'font-weight': 600}, g);
            t2.textContent = 'Đứng · ' + formatNumber(z.capacity) + ' người';
        } else {
            el('rect', {'class': 'sm-bg', width: z.w, height: z.h, rx: 10, fill: color, 'fill-opacity': 0.12, stroke: color, 'stroke-width': 2}, g);
            var title = el('text', {x: 10, y: 17, fill: '#0f172a', 'font-size': 12, 'font-weight': 800}, g);
            title.textContent = truncate(z.name, Math.max(6, Math.floor((z.w - 90) / 7)));
            var cap = el('text', {x: z.w - 10, y: 17, 'text-anchor': 'end', fill: '#475569', 'font-size': 11, 'font-weight': 600}, g);
            cap.textContent = formatNumber(capacityOf(z)) + ' ghế';

            for (var r = 0; r < z.rows; r++) {
                var letter = el('text', {x: PAD + 4, y: HEAD + PAD + r * PITCH + PITCH / 2 + 3, 'text-anchor': 'middle', fill: '#64748b', 'font-size': 9, 'font-weight': 700}, g);
                letter.textContent = String.fromCharCode(65 + r);
                for (var c = 0; c < z.cols; c++) {
                    var isBlocked = z.blocked.has(r + ':' + c);
                    var seat = el('circle', {
                        cx: LEFT + PAD + c * PITCH + PITCH / 2,
                        cy: HEAD + PAD + r * PITCH + PITCH / 2,
                        r: SEAT_R, fill: color, stroke: color, 'fill-opacity': 0.85,
                        'data-r': r, 'data-c': c
                    }, g);
                    seat.setAttribute('class', 'sm-seat' + (isBlocked ? ' is-blocked' : ''));
                }
            }
        }

        if (z.uid === selectedUid && !READ_ONLY && z.type !== 'SEATED') {
            el('rect', {'class': 'sm-resize', x: z.w - 7, y: z.h - 7, width: 14, height: 14, rx: 3}, g);
        }

        if (old) {
            zonesLayer.replaceChild(g, old);
        } else {
            zonesLayer.appendChild(g);
        }
        return g;
    }

    function renderAll() {
        while (zonesLayer.firstChild) {
            zonesLayer.removeChild(zonesLayer.firstChild);
        }
        zones.forEach(renderZone);
        refreshOverlapMarks();
        refreshSummary();
    }

    function refreshOverlapMarks() {
        var bad = {};
        for (var i = 0; i < zones.length; i++) {
            for (var j = i + 1; j < zones.length; j++) {
                if (overlaps(zones[i], zones[j])) {
                    bad[zones[i].uid] = true;
                    bad[zones[j].uid] = true;
                }
            }
        }
        zones.forEach(function (z) {
            var g = zonesLayer.querySelector('g[data-uid="' + z.uid + '"]');
            if (g) {
                g.classList.toggle('is-bad', !!bad[z.uid]);
            }
        });
    }

    // ------------------------------------------------ hạng vé
    function renderTickets() {
        var box = $('smTicketList');
        box.innerHTML = '';
        tickets.forEach(function (t, index) {
            var isNew = t.id <= 0;
            var item = document.createElement('div');
            item.className = 'sm-ticket';
            item.style.borderLeftColor = PALETTE[index % PALETTE.length];
            item.setAttribute('data-ticket', t.id);

            var row1 = document.createElement('div');
            row1.className = 'sm-ticket-row';
            var name = document.createElement('input');
            name.type = 'text';
            name.className = 'lt-input';
            name.maxLength = 100;
            name.placeholder = 'Tên hạng vé (VD: VIP)';
            name.value = t.name;
            name.disabled = READ_ONLY;
            name.addEventListener('input', function () {
                t.name = name.value;
                markDirty();
                renderTicketSelect();
                renderLegend();
                refreshSummary();
            });
            row1.appendChild(name);
            item.appendChild(row1);

            var row2 = document.createElement('div');
            row2.className = 'sm-ticket-row';
            var price = document.createElement('input');
            price.type = 'number';
            price.className = 'lt-input sm-price';
            price.min = 0;
            price.max = LIMITS.maxPrice;
            price.step = 1000;
            price.placeholder = 'Giá vé';
            price.value = t.price === 0 && isNew ? '' : t.price;
            price.disabled = READ_ONLY;
            price.addEventListener('input', function () {
                t.price = price.value === '' ? NaN : Number(price.value);
                markDirty();
                renderLegend();
                refreshSummary();
            });
            var unit = document.createElement('span');
            unit.className = 'sm-vnd';
            unit.textContent = 'VNĐ';
            row2.appendChild(price);
            row2.appendChild(unit);
            item.appendChild(row2);

            var meta = document.createElement('div');
            meta.className = 'sm-ticket-meta';
            var count = document.createElement('span');
            count.setAttribute('data-ticket-count', t.id);
            meta.appendChild(count);
            if (isNew && !READ_ONLY) {
                var del = document.createElement('button');
                del.type = 'button';
                del.className = 'sm-mini-del';
                del.title = 'Xóa hạng vé này';
                del.innerHTML = '<span class="material-symbols-outlined">delete</span>';
                del.addEventListener('click', function () {
                    removeTicket(t.id);
                });
                meta.appendChild(del);
            } else if (isNew) {
                meta.appendChild(document.createTextNode(''));
            }
            item.appendChild(meta);
            box.appendChild(item);
        });
        if (!tickets.length) {
            var empty = document.createElement('p');
            empty.className = 'sm-hint';
            empty.textContent = 'Chưa có hạng vé. Bấm "Thêm hạng vé" hoặc chọn một mẫu sơ đồ.';
            box.appendChild(empty);
        }
        var addBtn = $('smAddTicketBtn');
        if (addBtn) {
            addBtn.disabled = tickets.length >= LIMITS.maxTickets;
        }
        renderTicketSelect();
        renderLegend();
        refreshSummary();
    }

    function addTicket(name, price) {
        if (tickets.length >= LIMITS.maxTickets) {
            return null;
        }
        var t = {id: nextTempId--, name: name || '', price: price === undefined ? NaN : price};
        tickets.push(t);
        markDirty();
        return t;
    }

    function removeTicket(id) {
        zones.forEach(function (z) {
            if (z.ticketId === id) {
                z.ticketId = null;
            }
        });
        tickets = tickets.filter(function (t) {
            return t.id !== id;
        });
        markDirty();
        renderTickets();
        renderAll();
        updateProps();
    }

    function renderTicketSelect() {
        var select = $('pTicket');
        var z = byUid(selectedUid);
        var current = z ? z.ticketId : null;
        select.innerHTML = '';
        var blank = document.createElement('option');
        blank.value = '';
        blank.textContent = '— Chọn hạng vé —';
        select.appendChild(blank);
        tickets.forEach(function (t) {
            var o = document.createElement('option');
            o.value = t.id;
            o.textContent = (t.name.trim() || '(chưa đặt tên)') + (isFinite(t.price) ? ' · ' + formatNumber(t.price) + ' đ' : '');
            select.appendChild(o);
        });
        select.value = current === null || current === undefined ? '' : String(current);
        select.disabled = READ_ONLY;
    }

    function renderLegend() {
        var box = $('smLegend');
        box.innerHTML = '';
        tickets.forEach(function (t, i) {
            var item = document.createElement('span');
            var swatch = document.createElement('i');
            swatch.style.background = PALETTE[i % PALETTE.length];
            item.appendChild(swatch);
            item.appendChild(document.createTextNode((t.name.trim() || '(chưa đặt tên)') + (isFinite(t.price) ? ' · ' + formatNumber(t.price) + ' đ' : '')));
            box.appendChild(item);
        });
        var stage = zones.some(function (z) {
            return z.type === 'STAGE';
        });
        if (stage) {
            var s = document.createElement('span');
            var sw = document.createElement('i');
            sw.style.background = STAGE_COLOR;
            s.appendChild(sw);
            s.appendChild(document.createTextNode('Sân khấu'));
            box.appendChild(s);
        }
    }

    // ------------------------------------------------ kiểm tra + tổng quan
    function validate() {
        var issues = [];
        var sellable = zones.filter(function (z) {
            return z.type !== 'STAGE';
        });
        if (!zones.length) {
            issues.push('Sơ đồ chưa có khu nào.');
        } else if (!sellable.length) {
            issues.push('Cần ít nhất một khu ngồi hoặc khu đứng để bán vé.');
        }

        var seen = {};
        zones.forEach(function (z, i) {
            var label = z.name.trim() ? 'Khu "' + z.name.trim() + '"' : 'Khu #' + (i + 1);
            var key = z.name.trim().toLowerCase();
            if (!z.name.trim()) {
                issues.push(label + ': chưa đặt tên.');
            } else if (seen[key]) {
                issues.push(label + ': tên bị trùng.');
            }
            seen[key] = true;
            if (z.type !== 'STAGE' && !ticketById(z.ticketId)) {
                issues.push(label + ': chưa chọn hạng vé.');
            }
            if (z.type === 'SEATED' && capacityOf(z) < 1) {
                issues.push(label + ': chưa có ghế nào.');
            }
            if (z.type === 'STANDING' && !(z.capacity >= 1)) {
                issues.push(label + ': sức chứa phải lớn hơn 0.');
            }
        });
        if (zones.filter(function (z) {
            return z.type === 'STAGE';
        }).length > 1) {
            issues.push('Chỉ được có tối đa 1 sân khấu.');
        }
        for (var i = 0; i < zones.length; i++) {
            for (var j = i + 1; j < zones.length; j++) {
                if (overlaps(zones[i], zones[j])) {
                    issues.push('"' + zones[i].name + '" và "' + zones[j].name + '" đang chồng lên nhau.');
                }
            }
        }

        var total = totalCapacity();
        if (data.venueCapacity > 0 && total > data.venueCapacity) {
            issues.push('Tổng chỗ (' + formatNumber(total) + ') vượt sức chứa địa điểm (' + formatNumber(data.venueCapacity) + ').');
        }

        var tnames = {};
        tickets.forEach(function (t) {
            var label = 'Hạng vé "' + (t.name.trim() || '(chưa đặt tên)') + '"';
            var used = zones.some(function (z) {
                return z.type !== 'STAGE' && z.ticketId === t.id;
            });
            if (!t.name.trim()) {
                issues.push(label + ': chưa đặt tên.');
            } else if (tnames[t.name.trim().toLowerCase()]) {
                issues.push(label + ': tên bị trùng.');
            }
            tnames[t.name.trim().toLowerCase()] = true;
            if (!isFinite(t.price) || t.price < 0 || t.price > LIMITS.maxPrice || Math.floor(t.price) !== t.price) {
                issues.push(label + ': giá phải là số nguyên từ 0 đến ' + formatNumber(LIMITS.maxPrice) + '.');
            }
            if (t.id <= 0 && !used) {
                issues.push(label + ': chưa gán cho khu nào (hãy gán hoặc xóa).');
            }
        });
        return issues;
    }

    function totalCapacity() {
        return zones.reduce(function (sum, z) {
            return sum + capacityOf(z);
        }, 0);
    }

    function refreshSummary() {
        var total = totalCapacity();
        $('statZones').textContent = zones.length;
        $('statSeats').textContent = formatNumber(total);
        $('statVenue').textContent = data.venueCapacity > 0 ? formatNumber(data.venueCapacity) : '-';
        var bar = $('capBar');
        var pct = data.venueCapacity > 0 ? Math.min(100, Math.round(total * 100 / data.venueCapacity)) : 0;
        bar.style.width = pct + '%';
        bar.classList.toggle('is-over', data.venueCapacity > 0 && total > data.venueCapacity);

        tickets.forEach(function (t) {
            var node = document.querySelector('[data-ticket-count="' + t.id + '"]');
            if (node) {
                var sum = zones.reduce(function (s, z) {
                    return z.type !== 'STAGE' && z.ticketId === t.id ? s + capacityOf(z) : s;
                }, 0);
                node.innerHTML = '';
                node.appendChild(document.createTextNode(sum > 0 ? formatNumber(sum) + ' vé theo sơ đồ' : 'Chưa gán khu'));
                if (t.id <= 0) {
                    var badge = document.createElement('span');
                    badge.className = 'sm-new';
                    badge.textContent = ' · mới';
                    node.appendChild(badge);
                }
            }
        });

        var issues = validate();
        var box = $('issueBox');
        box.hidden = !issues.length;
        $('issueCount').textContent = issues.length;
        var list = $('issueList');
        list.innerHTML = '';
        issues.slice(0, 8).forEach(function (m) {
            var li = document.createElement('li');
            li.textContent = m;
            list.appendChild(li);
        });
        if (issues.length > 8) {
            var more = document.createElement('li');
            more.textContent = '… và ' + (issues.length - 8) + ' vấn đề khác.';
            list.appendChild(more);
        }
        if (EMBEDDED) {
            syncHostSummary();
        }
        return issues;
    }

    // ------------------------------------------------ chọn khu + bảng thuộc tính
    function select(z) {
        var previous = byUid(selectedUid);
        selectedUid = z ? z.uid : null;
        if (previous) {
            renderZone(previous);
        }
        if (z) {
            renderZone(z);
            // Đưa khu được chọn lên trên cùng
            var g = zonesLayer.querySelector('g[data-uid="' + z.uid + '"]');
            if (g) {
                zonesLayer.appendChild(g);
            }
        }
        refreshOverlapMarks();
        updateProps();
    }

    function updateProps() {
        var z = byUid(selectedUid);
        $('propsEmpty').hidden = !!z;
        $('propsPanel').hidden = !z;
        document.body.classList.toggle('sm-block-mode', blockMode && !!z && z.type === 'SEATED' && !READ_ONLY);
        if (!z) {
            return;
        }
        var names = {SEATED: 'Khu ngồi', STANDING: 'Khu đứng', STAGE: 'Sân khấu'};
        $('pType').textContent = names[z.type] || z.type;
        $('pName').value = z.name;
        $('pName').disabled = READ_ONLY;
        $('fTicket').hidden = z.type === 'STAGE';
        $('fSeated').hidden = z.type !== 'SEATED';
        $('fStanding').hidden = z.type !== 'STANDING';
        renderTicketSelect();

        if (z.type === 'SEATED') {
            $('pRows').value = z.rows;
            $('pCols').value = z.cols;
            $('pRows').max = LIMITS.maxRows;
            $('pCols').max = LIMITS.maxSeatsPerRow;
            $('pRows').disabled = $('pCols').disabled = READ_ONLY;
            $('pBlockMode').checked = blockMode;
            $('pBlockMode').disabled = READ_ONLY;
            $('pResetSeats').disabled = READ_ONLY;
        }
        if (z.type === 'STANDING') {
            $('pCapacity').value = z.capacity;
            $('pCapacity').max = LIMITS.maxQuantity;
            $('pCapacity').disabled = READ_ONLY;
        }
        refreshInfo(z);
    }

    function refreshInfo(z) {
        var parts = [];
        if (z.type === 'SEATED') {
            var blocked = blockedInGrid(z).length;
            parts.push('<b>' + formatNumber(capacityOf(z)) + '</b> ghế (' + z.rows + ' hàng × ' + z.cols + ' ghế' + (blocked ? ', bỏ ' + blocked + ' vị trí' : '') + ')');
            parts.push('Nhãn ghế: hàng A–' + String.fromCharCode(64 + Math.max(1, z.rows)));
        } else if (z.type === 'STANDING') {
            parts.push('Sức chứa <b>' + formatNumber(z.capacity) + '</b> người đứng');
        }
        parts.push('Kích thước ' + z.w + ' × ' + z.h + ' · Vị trí (' + z.x + ', ' + z.y + ')');
        $('pInfo').innerHTML = parts.join('<br>');
    }

    function onZoneChanged(z, rerender) {
        markDirty();
        if (rerender !== false) {
            renderZone(z);
        }
        refreshOverlapMarks();
        refreshSummary();
        refreshInfo(z);
        renderLegend();
    }

    // ------------------------------------------------ thêm / xóa / nhân bản khu
    function nameFor(type) {
        var existing = {};
        zones.forEach(function (z) {
            existing[z.name.toLowerCase()] = true;
        });
        if (type === 'STAGE') {
            return 'Sân khấu';
        }
        var base = type === 'STANDING' ? 'Khu đứng ' : 'Khu ';
        for (var i = 0; i < 99; i++) {
            var candidate = base + (type === 'STANDING' ? i + 1 : String.fromCharCode(65 + (i % 26)) + (i >= 26 ? Math.floor(i / 26) : ''));
            if (!existing[candidate.toLowerCase()]) {
                return candidate;
            }
        }
        return base + Date.now();
    }

    function findFreeSpot(w, h) {
        for (var y = 20; y + h <= CANVAS.height; y += 20) {
            for (var x = 20; x + w <= CANVAS.width; x += 20) {
                var probe = {x: x, y: y, w: w, h: h};
                var hit = zones.some(function (z) {
                    return overlaps(probe, z);
                });
                if (!hit) {
                    return {x: x, y: y};
                }
            }
        }
        return {x: 20, y: 20};
    }

    function makeZone(type, opts) {
        opts = opts || {};
        var z = {
            uid: ++uidSeq, type: type, name: opts.name || nameFor(type),
            ticketId: opts.ticketId === undefined ? (type === 'STAGE' || !tickets.length ? null : tickets[0].id) : opts.ticketId,
            x: 0, y: 0, w: opts.w || 0, h: opts.h || 0,
            rows: opts.rows || 0, cols: opts.cols || 0,
            capacity: opts.capacity || 0, blocked: new Set()
        };
        if (type === 'SEATED') {
            z.rows = z.rows || 5;
            z.cols = z.cols || 10;
            var size = seatedSize(z);
            z.w = size.w;
            z.h = size.h;
        } else if (type === 'STANDING') {
            z.w = z.w || 260;
            z.h = z.h || 140;
            z.capacity = z.capacity || 200;
        } else {
            z.w = z.w || 400;
            z.h = z.h || 60;
        }
        if (opts.x !== undefined) {
            z.x = opts.x;
            z.y = opts.y;
        } else {
            var spot = findFreeSpot(z.w, z.h);
            z.x = spot.x;
            z.y = spot.y;
        }
        return z;
    }

    function addZone(type) {
        if (zones.length >= LIMITS.maxZones) {
            window.alert('Mỗi sơ đồ tối đa ' + LIMITS.maxZones + ' khu.');
            return;
        }
        if (type === 'STAGE' && zones.some(function (z) {
            return z.type === 'STAGE';
        })) {
            return;
        }
        if (type !== 'STAGE' && !tickets.length) {
            // Chưa có hạng vé nào: tạo sẵn một hạng để khu có thể gán ngay (chỉ cần nhập giá)
            addTicket('Vé thường', NaN);
            renderTickets();
        }
        var z = makeZone(type);
        zones.push(z);
        markDirty();
        renderZone(z);
        select(z);
        refreshSummary();
        renderLegend();
        updateStageButton();
        $('canvasWrap').scrollIntoView({block: 'nearest'});
    }

    function deleteZone(z) {
        zones = zones.filter(function (item) {
            return item.uid !== z.uid;
        });
        markDirty();
        selectedUid = null;
        renderAll();
        renderLegend();
        updateProps();
        updateStageButton();
    }

    function duplicateZone(z) {
        if (zones.length >= LIMITS.maxZones) {
            window.alert('Mỗi sơ đồ tối đa ' + LIMITS.maxZones + ' khu.');
            return;
        }
        if (z.type === 'STAGE') {
            return;
        }
        var copy = makeZone(z.type, {
            name: nameFor(z.type), ticketId: z.ticketId, w: z.w, h: z.h,
            rows: z.rows, cols: z.cols, capacity: z.capacity
        });
        z.blocked.forEach(function (p) {
            copy.blocked.add(p);
        });
        zones.push(copy);
        markDirty();
        renderZone(copy);
        select(copy);
        refreshSummary();
    }

    function updateStageButton() {
        var btn = $('addStage');
        if (btn) {
            btn.disabled = zones.some(function (z) {
                return z.type === 'STAGE';
            });
        }
    }

    // ------------------------------------------------ mẫu sơ đồ
    function ensureTickets(defaults) {
        // Cần ít nhất defaults.length hạng vé; thiếu thì tạo mới với tên/giá mặc định
        for (var i = tickets.length; i < defaults.length && tickets.length < LIMITS.maxTickets; i++) {
            addTicket(defaults[i].name, defaults[i].price);
        }
    }

    function ticketAt(i) {
        return tickets.length ? tickets[i % tickets.length].id : null;
    }

    function applyPreset(kind) {
        if (zones.length && !window.confirm('Áp dụng mẫu sẽ thay thế toàn bộ sơ đồ đang vẽ. Tiếp tục?')) {
            return;
        }
        var list = [];
        if (kind === 'hall') {
            ensureTickets([{name: 'VIP', price: 1500000}, {name: 'Thường', price: 800000}, {name: 'Phổ thông', price: 500000}]);
            list = [
                makeZone('STAGE', {x: 400, y: 30, w: 400, h: 70}),
                makeZone('SEATED', {name: 'Khu VIP', ticketId: ticketAt(0), rows: 6, cols: 20, x: 342, y: 130}),
                makeZone('SEATED', {name: 'Khu A', ticketId: ticketAt(1), rows: 8, cols: 24, x: 290, y: 340}),
                makeZone('SEATED', {name: 'Khu B', ticketId: ticketAt(2), rows: 6, cols: 28, x: 250, y: 600})
            ];
        } else {
            ensureTickets([{name: 'VIP Standing', price: 2000000}, {name: 'GA Standing', price: 900000}, {name: 'Khán đài', price: 600000}]);
            list = [
                makeZone('STAGE', {x: 350, y: 30, w: 500, h: 80}),
                makeZone('STANDING', {name: 'Fanzone VIP', ticketId: ticketAt(0), capacity: 300, x: 400, y: 140, w: 400, h: 130}),
                makeZone('STANDING', {name: 'Khu GA', ticketId: ticketAt(1), capacity: 800, x: 300, y: 300, w: 600, h: 200}),
                makeZone('SEATED', {name: 'Khán đài', ticketId: ticketAt(2), rows: 6, cols: 30, x: 222, y: 540})
            ];
        }
        zones = list;
        selectedUid = null;
        markDirty();
        renderTickets();
        renderAll();
        renderLegend();
        updateProps();
        updateStageButton();
    }

    // ------------------------------------------------ kéo thả
    function toCanvas(evt) {
        var pt = svg.createSVGPoint();
        pt.x = evt.clientX;
        pt.y = evt.clientY;
        var p = pt.matrixTransform(svg.getScreenCTM().inverse());
        return {x: p.x, y: p.y};
    }

    function toggleSeat(z, r, c, value) {
        var key = r + ':' + c;
        var has = z.blocked.has(key);
        if (value === has) {
            return;
        }
        if (value) {
            z.blocked.add(key);
        } else {
            z.blocked.delete(key);
        }
        var circle = zonesLayer.querySelector('g[data-uid="' + z.uid + '"] circle[data-r="' + r + '"][data-c="' + c + '"]');
        if (circle) {
            circle.classList.toggle('is-blocked', value);
        }
    }

    svg.addEventListener('pointerdown', function (e) {
        var g = e.target.closest ? e.target.closest('.sm-zone') : null;
        if (!g) {
            if (selectedUid !== null) {
                select(null);
            }
            return;
        }
        var z = byUid(g.getAttribute('data-uid'));
        if (!z) {
            return;
        }
        var wasSelected = z.uid === selectedUid;
        if (!wasSelected) {
            select(z);
            g = zonesLayer.querySelector('g[data-uid="' + z.uid + '"]');
        }
        if (READ_ONLY) {
            return;
        }
        var p = toCanvas(e);
        if (e.target.classList.contains('sm-resize')) {
            drag = {mode: 'resize', z: z, startW: z.w, startH: z.h, px: p.x, py: p.y};
        } else if (blockMode && z.type === 'SEATED' && e.target.classList.contains('sm-seat')) {
            var r = Number(e.target.getAttribute('data-r'));
            var c = Number(e.target.getAttribute('data-c'));
            var value = !z.blocked.has(r + ':' + c);
            drag = {mode: 'paint', z: z, value: value};
            toggleSeat(z, r, c, value);
        } else {
            drag = {mode: 'move', z: z, ox: p.x - z.x, oy: p.y - z.y, moved: false};
        }
        try {
            svg.setPointerCapture(e.pointerId);
        } catch (err) { /* không bắt buộc */ }
        e.preventDefault();
    });

    svg.addEventListener('pointermove', function (e) {
        if (!drag) {
            return;
        }
        var z = drag.z;
        var p = toCanvas(e);
        if (drag.mode === 'move') {
            var nx = clamp(snap(p.x - drag.ox), 0, CANVAS.width - z.w);
            var ny = clamp(snap(p.y - drag.oy), 0, CANVAS.height - z.h);
            if (nx !== z.x || ny !== z.y) {
                z.x = nx;
                z.y = ny;
                drag.moved = true;
                var g = zonesLayer.querySelector('g[data-uid="' + z.uid + '"]');
                g.setAttribute('transform', 'translate(' + z.x + ',' + z.y + ')');
                refreshOverlapMarks();
            }
        } else if (drag.mode === 'resize') {
            var min = LIMITS.minZoneSize;
            var nw = clamp(snap(drag.startW + (p.x - drag.px)), min, CANVAS.width - z.x);
            var nh = clamp(snap(drag.startH + (p.y - drag.py)), min, CANVAS.height - z.y);
            if (nw !== z.w || nh !== z.h) {
                z.w = nw;
                z.h = nh;
                drag.moved = true;
                renderZone(z);
                refreshOverlapMarks();
            }
        } else if (drag.mode === 'paint') {
            var target = document.elementFromPoint(e.clientX, e.clientY);
            if (target && target.classList && target.classList.contains('sm-seat')) {
                var owner = target.closest('.sm-zone');
                if (owner && Number(owner.getAttribute('data-uid')) === z.uid) {
                    toggleSeat(z, Number(target.getAttribute('data-r')), Number(target.getAttribute('data-c')), drag.value);
                }
            }
        }
    });

    function endDrag(e) {
        if (!drag) {
            return;
        }
        var finished = drag;
        drag = null;
        try {
            svg.releasePointerCapture(e.pointerId);
        } catch (err) { /* không bắt buộc */ }
        if (finished.mode === 'paint' || finished.moved) {
            // Bỏ/khôi phục ghế đổi số ghế nên vẽ lại khu để cập nhật tiêu đề; di chuyển/đổi cỡ đã vẽ sẵn
            onZoneChanged(finished.z, finished.mode === 'paint');
        }
    }
    svg.addEventListener('pointerup', endDrag);
    svg.addEventListener('pointercancel', endDrag);

    document.addEventListener('keydown', function (e) {
        var tag = (e.target.tagName || '').toLowerCase();
        var typing = tag === 'select' || tag === 'textarea'
                || (tag === 'input' && e.target.type !== 'checkbox' && e.target.type !== 'button');
        if (typing || READ_ONLY) {
            return;
        }
        var z = byUid(selectedUid);
        if (!z) {
            return;
        }
        var step = e.shiftKey ? 1 : SNAP;
        var moved = false;
        if (e.key === 'Delete') {
            deleteZone(z);
            e.preventDefault();
            return;
        }
        if (e.key === 'Escape') {
            select(null);
            return;
        }
        if (e.key === 'ArrowLeft') { z.x = clamp(z.x - step, 0, CANVAS.width - z.w); moved = true; }
        if (e.key === 'ArrowRight') { z.x = clamp(z.x + step, 0, CANVAS.width - z.w); moved = true; }
        if (e.key === 'ArrowUp') { z.y = clamp(z.y - step, 0, CANVAS.height - z.h); moved = true; }
        if (e.key === 'ArrowDown') { z.y = clamp(z.y + step, 0, CANVAS.height - z.h); moved = true; }
        if (moved) {
            e.preventDefault();
            var g = zonesLayer.querySelector('g[data-uid="' + z.uid + '"]');
            g.setAttribute('transform', 'translate(' + z.x + ',' + z.y + ')');
            markDirty();
            refreshOverlapMarks();
            refreshSummary();
            refreshInfo(z);
        }
    });

    // ------------------------------------------------ bảng thuộc tính
    function bindProps() {
        $('pName').addEventListener('input', function () {
            var z = byUid(selectedUid);
            if (!z) { return; }
            z.name = $('pName').value;
            onZoneChanged(z);
        });
        $('pTicket').addEventListener('change', function () {
            var z = byUid(selectedUid);
            if (!z) { return; }
            z.ticketId = $('pTicket').value === '' ? null : Number($('pTicket').value);
            onZoneChanged(z);
        });
        $('pRows').addEventListener('input', function () {
            var z = byUid(selectedUid);
            if (!z) { return; }
            var v = Math.floor(Number($('pRows').value));
            if (v >= 1 && v <= LIMITS.maxRows) {
                z.rows = v;
                fitInsideCanvas(z);
                onZoneChanged(z);
            }
        });
        $('pCols').addEventListener('input', function () {
            var z = byUid(selectedUid);
            if (!z) { return; }
            var v = Math.floor(Number($('pCols').value));
            if (v >= 1 && v <= LIMITS.maxSeatsPerRow) {
                z.cols = v;
                fitInsideCanvas(z);
                onZoneChanged(z);
            }
        });
        $('pCapacity').addEventListener('input', function () {
            var z = byUid(selectedUid);
            if (!z) { return; }
            var v = Math.floor(Number($('pCapacity').value));
            z.capacity = v >= 1 ? Math.min(v, LIMITS.maxQuantity) : 0;
            onZoneChanged(z);
        });
        $('pBlockMode').addEventListener('change', function () {
            blockMode = $('pBlockMode').checked;
            document.body.classList.toggle('sm-block-mode', blockMode);
        });
        $('pResetSeats').addEventListener('click', function () {
            var z = byUid(selectedUid);
            if (!z) { return; }
            z.blocked.clear();
            onZoneChanged(z);
        });
        var dup = $('pDuplicate');
        if (dup) {
            dup.addEventListener('click', function () {
                var z = byUid(selectedUid);
                if (z) { duplicateZone(z); }
            });
        }
        var del = $('pDelete');
        if (del) {
            del.addEventListener('click', function () {
                var z = byUid(selectedUid);
                if (z && window.confirm('Xóa khu "' + z.name + '"?')) { deleteZone(z); }
            });
        }
    }

    // Khi đổi số hàng/ghế, kéo khu vào trong khung nếu bị tràn
    function fitInsideCanvas(z) {
        var size = seatedSize(z);
        z.x = clamp(z.x, 0, Math.max(0, CANVAS.width - size.w));
        z.y = clamp(z.y, 0, Math.max(0, CANVAS.height - size.h));
    }

    // ------------------------------------------------ zoom
    function applyZoom() {
        svg.style.width = (zoom * 100) + '%';
        $('zoomLabel').textContent = Math.round(zoom * 100) + '%';
    }

    function bindZoom() {
        $('zoomIn').addEventListener('click', function () { zoom = Math.min(2, zoom + 0.25); applyZoom(); });
        $('zoomOut').addEventListener('click', function () { zoom = Math.max(0.5, zoom - 0.25); applyZoom(); });
        $('zoomFit').addEventListener('click', function () { zoom = 1; applyZoom(); });
    }

    // ------------------------------------------------ lưu
    function buildPayload() {
        return {
            tickets: tickets.map(function (t) {
                return {id: t.id, name: t.name.trim(), price: Math.round(Number(t.price) || 0)};
            }),
            zones: zones.map(function (z) {
                var seated = z.type === 'SEATED';
                return {
                    eventTicketId: z.type === 'STAGE' ? null : z.ticketId,
                    zoneName: z.name.trim(),
                    zoneType: z.type,
                    color: colorOf(z),
                    posX: Math.round(z.x), posY: Math.round(z.y),
                    width: Math.round(z.w), height: Math.round(z.h),
                    rowCount: seated ? z.rows : 0,
                    seatsPerRow: seated ? z.cols : 0,
                    capacity: capacityOf(z),
                    blockedSeats: seated ? blockedInGrid(z).sort().join(',') : ''
                };
            })
        };
    }

    function bindSave() {
        if (EMBEDDED) {
            return;
        }
        var form = $('seatmap-form');
        form.addEventListener('submit', function (e) {
            if (READ_ONLY) {
                e.preventDefault();
                return;
            }
            var issues = refreshSummary();
            if (issues.length) {
                e.preventDefault();
                $('issueBox').scrollIntoView({behavior: 'smooth', block: 'center'});
                return;
            }
            $('layoutJson').value = JSON.stringify(buildPayload());
            dirty = false;
        });

        var clear = $('clear-form');
        if (clear) {
            clear.addEventListener('submit', function (e) {
                if (!window.confirm('Xóa toàn bộ sơ đồ ghế của sự kiện này? Các hạng vé vẫn được giữ lại.')) {
                    e.preventDefault();
                    return;
                }
                dirty = false;
            });
        }

        window.addEventListener('beforeunload', function (e) {
            if (dirty && !READ_ONLY) {
                e.preventDefault();
                e.returnValue = '';
            }
        });
    }

    function bindTools() {
        document.querySelectorAll('[data-add]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                addZone(btn.getAttribute('data-add'));
            });
        });
        document.querySelectorAll('[data-preset]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                applyPreset(btn.getAttribute('data-preset'));
            });
        });
        var addTicketBtn = $('smAddTicketBtn');
        if (addTicketBtn) {
            addTicketBtn.addEventListener('click', function () {
                var t = addTicket('', NaN);
                if (t) {
                    renderTickets();
                    var inputs = document.querySelectorAll('#smTicketList [data-ticket="' + t.id + '"] input');
                    if (inputs.length) {
                        inputs[0].focus();
                    }
                }
            });
        }
    }

    // ------------------------------------------------ nhúng vào form tạo sự kiện (bước 3)
    var hostForm = null;

    function seatModeActive() {
        var checked = document.querySelector('input[name="ticketMode"]:checked');
        return !!checked && checked.value === 'SEATED';
    }

    function sellableZones() {
        return zones.filter(function (z) {
            return z.type !== 'STAGE';
        });
    }

    // Đồng bộ các vùng của trang chứa (tóm tắt bước 4, giá ở live preview, checklist)
    function syncHostSummary() {
        if (!hostForm) {
            return;
        }
        var active = seatModeActive();
        var sum = document.getElementById('sumTickets');
        var priced = tickets.filter(function (t) {
            return isFinite(t.price) && t.price >= 0;
        });
        var minPrice = priced.length ? Math.min.apply(null, priced.map(function (t) {
            return t.price;
        })) : null;

        if (active) {
            if (sum) {
                sum.textContent = zones.length
                    ? 'Theo sơ đồ ghế: ' + sellableZones().length + ' khu bán vé · ' + formatNumber(totalCapacity()) + ' chỗ · ' + tickets.length + ' hạng vé'
                    : 'Theo sơ đồ ghế (chưa vẽ khu nào)';
            }
            var pvPrice = document.getElementById('pvPrice');
            var pvLabel = document.getElementById('pvPriceLabel');
            if (pvPrice && pvLabel) {
                pvLabel.textContent = minPrice === null ? 'Giá vé' : 'Giá vé từ';
                pvPrice.textContent = minPrice === null ? 'Chưa cấu hình' : (minPrice === 0 ? 'Miễn phí' : formatNumber(minPrice) + ' đ');
            }
            var ck = document.querySelector('[data-ck="tickets"]');
            if (ck) {
                var done = sellableZones().length > 0;
                ck.classList.toggle('is-done', done);
                ck.classList.toggle('is-info', !done);
                var icon = ck.querySelector('.ck-ico');
                var status = ck.querySelector('.ck-status');
                if (icon) {
                    icon.textContent = done ? 'check_circle' : 'pending';
                }
                if (status) {
                    status.textContent = done ? sellableZones().length + ' khu · ' + formatNumber(totalCapacity()) + ' chỗ' : 'Không bắt buộc';
                }
            }
        } else if (sum) {
            var general = document.getElementById('ticketSummary');
            sum.textContent = general ? general.textContent : '—';
        }
    }

    function applyMode() {
        var active = seatModeActive();
        var general = document.getElementById('modeGeneral');
        var seated = document.getElementById('modeSeated');
        if (general) {
            general.hidden = active;
            // input bị disabled sẽ không được gửi lên server
            general.querySelectorAll('input, select, textarea, button').forEach(function (n) {
                n.disabled = active;
            });
        }
        if (seated) {
            seated.hidden = !active;
        }
        document.querySelectorAll('[data-mode-card]').forEach(function (card) {
            card.classList.toggle('is-selected', card.querySelector('input').checked);
        });
        if (!active) {
            // trả quyền tính tổng/preview cho module hạng vé theo số lượng
            var list = document.getElementById('ticketList');
            if (list) {
                list.dispatchEvent(new Event('input', {bubbles: true}));
            }
            var add = document.getElementById('addTicketBtn');
            if (add) {
                var rowCount = list ? list.querySelectorAll('[data-ticket-row]').length : 0;
                add.disabled = rowCount >= LIMITS.maxTickets;
            }
        }
        syncHostSummary();
    }

    function syncVenue() {
        var select = document.getElementById('venueId');
        if (!select || !data.venueCapacities) {
            return;
        }
        var capacity = Number(data.venueCapacities[select.value]);
        data.venueCapacity = capacity > 0 ? capacity : -1;
        refreshSummary();
    }

    function bindEmbedded() {
        hostForm = document.getElementById('create-event-form');
        if (!hostForm) {
            return;
        }
        document.querySelectorAll('input[name="ticketMode"]').forEach(function (radio) {
            radio.addEventListener('change', applyMode);
        });
        var venue = document.getElementById('venueId');
        if (venue) {
            venue.addEventListener('change', syncVenue);
        }
        // Tóm tắt bước 4 theo dõi cả phần vé theo số lượng
        hostForm.addEventListener('input', syncHostSummary);
        hostForm.addEventListener('change', syncHostSummary);
        document.querySelectorAll('[data-step-nav], [data-step-target]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                window.setTimeout(syncHostSummary, 0);
            });
        });

        hostForm.addEventListener('submit', function () {
            $('layoutJson').value = seatModeActive() ? JSON.stringify(buildPayload()) : '';
        });

        // API cho wizard (event.js)
        window.ltSeatMode = {
            active: seatModeActive,
            count: function () {
                return sellableZones().length;
            },
            validate: function () {
                var issues = refreshSummary();
                var alertBox = document.getElementById('seatStepAlert');
                var alertText = document.getElementById('seatStepAlertText');
                if (alertBox) {
                    alertBox.hidden = issues.length === 0;
                }
                if (alertText) {
                    alertText.textContent = issues.length ? 'Sơ đồ ghế & hạng vé còn ' + issues.length + ' vấn đề cần chỉnh sửa (xem khung vàng bên dưới).' : '';
                }
                if (issues.length) {
                    var box = $('issueBox');
                    if (box && !box.hidden) {
                        box.scrollIntoView({behavior: 'smooth', block: 'center'});
                    }
                }
                return issues.length === 0;
            }
        };
        syncVenue();
        applyMode();
    }

    // ------------------------------------------------ khởi động
    initCanvas();
    bindProps();
    bindZoom();
    bindSave();
    if (!READ_ONLY) {
        bindTools();
    }
    if (EMBEDDED) {
        bindEmbedded();
    }
    renderTickets();
    renderAll();
    updateProps();
    updateStageButton();
    applyZoom();
    dirty = false;
})();
