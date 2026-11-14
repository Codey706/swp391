/* Simple SVG revenue chart. No CDN or dependency required. */
(function () {
    'use strict';
    const svg = document.getElementById('ltRevenueChart');
    const dataElement = document.getElementById('ltChartData');
    if (!svg || !dataElement)
        return;
    const data = Array.from(dataElement.querySelectorAll('[data-day]')).map(el => ({
            day: el.dataset.day,
            amount: Number(el.dataset.amount) || 0
        }));
    const empty = document.getElementById('ltChartEmpty');
    const NS = 'http://www.w3.org/2000/svg';
    const add = (name, attrs, parent = svg) => {
        const el = document.createElementNS(NS, name);
        Object.entries(attrs).forEach(([k, v]) => el.setAttribute(k, String(v)));
        parent.appendChild(el);
        return el;
    };
    if (!data.length || !data.some(d => d.amount > 0)) {
        empty.hidden = false;
        return;
    }
    const w = 740, h = 250, left = 76, right = 16, top = 14, bottom = 35;
    const plotW = w - left - right, plotH = h - top - bottom;
    const max = Math.max(...data.map(d => d.amount));
    const ceiling = max * 1.12;
    const fmt = n => n >= 1000000 ? (n / 1000000).toFixed(n % 1000000 ? 1 : 0) + 'm' : n >= 1000 ? Math.round(n / 1000) + 'k' : String(Math.round(n));
    for (let i = 0; i <= 4; i++) {
        const y = top + plotH * i / 4;
        add('line', {x1: left, y1: y, x2: w - right, y2: y, stroke: '#e8e8eb', 'stroke-width': 1});
        const label = add('text', {x: left - 12, y: y + 4, 'text-anchor': 'end', fill: '#77777e', 'font-size': 11});
        label.textContent = fmt(ceiling * (1 - i / 4));
    }
    const pts = data.map((d, i) => ({x: left + (data.length === 1 ? plotW / 2 : i * plotW / (data.length - 1)), y: top + plotH * (1 - d.amount / ceiling), ...d}));
    const points = pts.map(p => p.x + ',' + p.y).join(' ');
    add('polygon', {points: left + ',' + (top + plotH) + ' ' + points + ' ' + pts[pts.length - 1].x + ',' + (top + plotH), fill: '#ffe7e2', opacity: .9});
    add('polyline', {points, fill: 'none', stroke: '#d93a27', 'stroke-width': 3, 'stroke-linecap': 'round', 'stroke-linejoin': 'round'});
    pts.forEach((p, i) => {
        const mark = add('circle', {cx: p.x, cy: p.y, r: data.length > 35 ? 2 : 3.5, fill: '#d93a27'});
        const tooltip = add('title', {}, mark);
        tooltip.textContent = p.day + ': ' + new Intl.NumberFormat('vi-VN').format(p.amount) + ' ₫';
        if (i === 0 || i === pts.length - 1 || (i % Math.max(1, Math.ceil(pts.length / 6)) === 0)) {
            const label = add('text', {x: p.x, y: h - 8, 'text-anchor': 'middle', fill: '#77777e', 'font-size': 11});
            label.textContent = p.day.slice(5);
        }
    });
})();
