(function () {
    'use strict';

    const form = document.getElementById('ticketForm');
    const maxTickets = form ? (parseInt(form.dataset.maxTickets, 10) || 10) : 10;

    function formatMoney(value) {
        return new Intl.NumberFormat('vi-VN').format(value) + ' đ';
    }

    // UC-13: chỉ hiện ghế của hạng vé đang chọn. Hạng có ghế (khu ngồi) phải chọn đúng số ghế bằng số vé,
    // hạng không có ghế (khu đứng) thì không cần. Server vẫn kiểm tra lại khi tạo đơn.
    const seatLabels = form ? Array.from(form.querySelectorAll('.ck-seat[data-ticket-id]')) : [];
    const seatSection = document.getElementById('seatSection');
    const seatStatus = document.getElementById('seatStatus');
    const seatSummaryNote = document.getElementById('seatSummaryNote');
    // Thứ tự khách bấm chọn: giảm số vé thì bỏ các ghế chọn sau cùng trước
    const seatOrder = seatLabels.map(function (label) { return label.querySelector('input[name="seatIds"]'); })
        .filter(function (box) { return box && box.checked; });
    let seatNotice = '';

    function ticketIdOf(input) {
        return input.name.replace('quantity_', '');
    }

    function ticketNameOf(input) {
        const title = input.closest('.ck-ticket').querySelector('h3');
        return title ? title.textContent.trim() : '';
    }

    function seatBoxesOf(ticketId) {
        return seatLabels.filter(function (label) { return label.dataset.ticketId === ticketId; })
            .map(function (label) { return label.querySelector('input[name="seatIds"]'); });
    }

    function uncheckSeat(box) {
        box.checked = false;
        const index = seatOrder.indexOf(box);
        if (index !== -1) seatOrder.splice(index, 1);
    }

    /** Mô tả số ghế còn thiếu của từng hạng khu ngồi đang chọn; mảng rỗng nghĩa là đã đủ. */
    function missingSeatMessages(inputs) {
        const messages = [];
        inputs.forEach(function (input) {
            const qty = Math.max(0, parseInt(input.value, 10) || 0);
            const boxes = seatBoxesOf(ticketIdOf(input));
            if (qty < 1 || boxes.length === 0) return;
            const chosen = boxes.filter(function (box) { return box.checked; }).length;
            if (chosen < qty) {
                messages.push('Hạng "' + ticketNameOf(input) + '" còn thiếu ' + (qty - chosen) + ' ghế');
            }
        });
        return messages;
    }

    function renderLines(node, lines) {
        if (!node) return;
        node.replaceChildren.apply(node, lines.map(function (text) {
            const line = document.createElement('span');
            line.textContent = text;
            return line;
        }));
        node.hidden = lines.length === 0;
    }

    function renderSeatStatus(inputs, isError) {
        const missing = missingSeatMessages(inputs);
        const anySeatVisible = seatLabels.some(function (label) { return !label.hidden; });
        const lines = missing.slice();
        if (seatNotice) lines.unshift(seatNotice);
        if (lines.length === 0 && anySeatVisible) lines.push('Đã chọn đủ ghế.');
        renderLines(seatStatus, lines);
        if (seatStatus) {
            seatStatus.classList.toggle('is-done', missing.length === 0 && !seatNotice);
            seatStatus.classList.toggle('is-error', !!isError);
        }
        renderLines(seatSummaryNote, missing);
        if (seatSection) seatSection.hidden = !anySeatVisible;
    }

    function syncSeats(inputs) {
        const quantities = new Map();
        inputs.forEach(function (input) {
            quantities.set(ticketIdOf(input), Math.max(0, parseInt(input.value, 10) || 0));
        });
        seatLabels.forEach(function (label) {
            const visible = (quantities.get(label.dataset.ticketId) || 0) > 0;
            label.hidden = !visible;
            const box = label.querySelector('input[name="seatIds"]');
            if (!visible && box && box.checked) uncheckSeat(box);
        });
        // Giảm số vé: giữ các ghế chọn trước, bỏ các ghế chọn sau cùng
        quantities.forEach(function (qty, ticketId) {
            const chosen = seatOrder.filter(function (box) { return seatBoxesOf(ticketId).indexOf(box) !== -1; });
            chosen.slice(qty).forEach(uncheckSeat);
        });
        seatNotice = '';
        renderSeatStatus(inputs, false);
    }

    function updateTotals() {
        if (!form) return;
        const inputs = Array.from(form.querySelectorAll('[data-qty]'));
        let quantity = 0;
        let amount = 0;
        inputs.forEach(function (input) {
            const qty = Math.max(0, parseInt(input.value, 10) || 0);
            const price = Number(input.dataset.price) || 0;
            quantity += qty;
            amount += qty * price;
        });
        const qtyNode = document.getElementById('totalQty');
        const priceNode = document.getElementById('totalPrice');
        const grandNode = document.getElementById('grandTotal');
        if (qtyNode) qtyNode.textContent = quantity + ' vé';
        if (priceNode) priceNode.textContent = formatMoney(amount);
        // Đổi số vé thì kết quả xem trước voucher không còn đúng
        const discountRow = document.getElementById('discountRow');
        if (discountRow) discountRow.hidden = true;
        syncSeats(inputs);
        if (grandNode) grandNode.textContent = formatMoney(amount);
        const mobileGrandNode = document.getElementById('mobileGrandTotal');
        if (mobileGrandNode) mobileGrandNode.textContent = formatMoney(amount);
        document.querySelectorAll('#ticketForm button[type="submit"], button[type="submit"][form="ticketForm"]')
            .forEach(function (submit) { submit.disabled = quantity < 1 || quantity > maxTickets; });
    }

    if (form) {
        form.addEventListener('click', function (event) {
            const button = event.target.closest('[data-change]');
            if (!button) return;
            const input = button.parentElement.querySelector('[data-qty]');
            if (!input) return;
            const inputs = Array.from(form.querySelectorAll('[data-qty]'));
            const total = inputs.reduce(function (sum, item) { return sum + (parseInt(item.value, 10) || 0); }, 0);
            const next = Math.max(0, (parseInt(input.value, 10) || 0) + Number(button.dataset.change));
            if (button.dataset.change === '1' && total >= maxTickets) return;
            const limit = input.max === '' ? maxTickets : Number(input.max);
            input.value = Math.min(next, limit);
            updateTotals();
        });
        form.addEventListener('input', function (event) {
            if (!event.target.matches('[data-qty]')) return;
            const inputs = Array.from(form.querySelectorAll('[data-qty]'));
            let total = 0;
            inputs.forEach(function (input) {
                input.value = Math.max(0, parseInt(input.value, 10) || 0);
                total += Number(input.value);
            });
            if (total > maxTickets) {
                event.target.value = Math.max(0, Number(event.target.value) - (total - maxTickets));
            }
            updateTotals();
        });
        form.addEventListener('submit', function (event) {
            const total = Array.from(form.querySelectorAll('[data-qty]')).reduce(function (sum, input) {
                return sum + (parseInt(input.value, 10) || 0);
            }, 0);
            if (total < 1 || total > maxTickets) {
                event.preventDefault();
                window.alert('Vui lòng kiểm tra số vé đã chọn.');
                return;
            }
            const inputs = Array.from(form.querySelectorAll('[data-qty]'));
            if (missingSeatMessages(inputs).length > 0) {
                event.preventDefault();
                seatNotice = '';
                renderSeatStatus(inputs, true);
                if (seatSection) seatSection.scrollIntoView({behavior: 'smooth', block: 'center'});
            }
        });
        form.addEventListener('change', function (event) {
            if (!event.target.matches('input[name="seatIds"]')) return;
            const box = event.target;
            const inputs = Array.from(form.querySelectorAll('[data-qty]'));
            const label = box.closest('.ck-seat');
            const input = inputs.find(function (item) { return ticketIdOf(item) === label.dataset.ticketId; });
            seatNotice = '';
            if (box.checked) {
                const qty = input ? Math.max(0, parseInt(input.value, 10) || 0) : 0;
                const chosen = seatBoxesOf(label.dataset.ticketId).filter(function (item) { return item.checked; }).length;
                if (chosen > qty) {
                    box.checked = false;
                    seatNotice = 'Hạng "' + (input ? ticketNameOf(input) : '') + '" chỉ cần ' + qty
                        + ' ghế. Bỏ chọn một ghế trước khi chọn ghế khác.';
                } else {
                    seatOrder.push(box);
                }
            } else {
                uncheckSeat(box);
            }
            renderSeatStatus(inputs, false);
        });
        updateTotals();

        // UC-14: xem trước mức giảm của voucher (không giữ vé, không tăng lượt dùng)
        const applyButton = document.getElementById('voucherApply');
        const voucherMessage = document.getElementById('voucherMessage');
        if (applyButton) {
            applyButton.addEventListener('click', function () {
                const body = new URLSearchParams(new FormData(form));
                applyButton.disabled = true;
                fetch(applyButton.dataset.url, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: body
                }).then(function (res) {
                    if (!res.ok) throw new Error('HTTP ' + res.status);
                    return res.json();
                }).then(function (data) {
                    voucherMessage.textContent = data.message;
                    voucherMessage.style.color = data.ok ? '#13804b' : '#b42e1d';
                    const discountRow = document.getElementById('discountRow');
                    if (data.ok) {
                        document.getElementById('discountAmount').textContent = '-' + formatMoney(data.discount);
                        discountRow.hidden = false;
                        ['grandTotal', 'mobileGrandTotal'].forEach(function (id) {
                            const node = document.getElementById(id);
                            if (node) node.textContent = formatMoney(data.finalAmount);
                        });
                    } else {
                        discountRow.hidden = true;
                    }
                }).catch(function () {
                    voucherMessage.textContent = 'Không kiểm tra được mã giảm giá. Vui lòng thử lại.';
                    voucherMessage.style.color = '#b42e1d';
                }).finally(function () {
                    applyButton.disabled = false;
                });
            });
        }
    }

    document.querySelectorAll('[data-expire]').forEach(function (container) {
        const expireValue = container.dataset.expire;
        const output = container.querySelector('[data-countdown]');
        if (!expireValue || !output) return;
        // LocalDateTime từ server có dạng yyyy-MM-ddTHH:mm:ss; coi là giờ local của trình duyệt.
        let normalized = expireValue.replace(/(\.\d{3})\d+/, '$1');
        if (/T\d{2}:\d{2}$/.test(normalized)) normalized += ':00';
        const expiresAt = new Date(normalized).getTime();
        if (isNaN(expiresAt)) { output.textContent = '--:--'; return; }
        function tick() {
            const remaining = Math.max(0, Math.floor((expiresAt - Date.now()) / 1000));
            const minutes = Math.floor(remaining / 60);
            const seconds = remaining % 60;
            output.textContent = String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
            if (remaining <= 0) {
                container.classList.add('expired');
                output.textContent = '00:00';
                const note = document.createElement('div');
                note.className = 'ck-alert';
                note.textContent = 'Thời gian giữ vé đã hết. Đơn hàng có thể đã bị hủy; vui lòng chọn vé lại.';
                if (!container.dataset.warned) {
                    container.dataset.warned = 'true';
                    container.insertAdjacentElement('afterend', note);
                }
            } else {
                window.setTimeout(tick, 250);
            }
        }
        tick();
    });
})();
