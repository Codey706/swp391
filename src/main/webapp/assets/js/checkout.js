(function () {
    'use strict';

    const form = document.getElementById('ticketForm');
    const maxTickets = form ? (parseInt(form.dataset.maxTickets, 10) || 10) : 10;

    function formatMoney(value) {
        return new Intl.NumberFormat('vi-VN').format(value) + ' đ';
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
            const selectedSeats = form.querySelectorAll('input[name="seatIds"]:checked').length;
            if (total < 1 || total > maxTickets || (selectedSeats > 0 && selectedSeats !== total)) {
                event.preventDefault();
                window.alert('Vui lòng kiểm tra số vé và số ghế đã chọn.');
            }
        });
        updateTotals();
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
