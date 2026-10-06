// Booking History: modal chi tiết, đếm ngược giữ chỗ, ảnh dự phòng
(function () {
    'use strict';

    // Đổ dữ liệu từ data-* của nút "Xem chi tiết" vào modal
    var STATUS_TEXT = { Paid: 'Đã thanh toán', Pending: 'Chờ thanh toán', Cancelled: 'Đã hủy' };
    var fields = {
        detailCode: 'code', detailEvent: 'event', detailTime: 'time', detailVenue: 'venue',
        detailTicket: 'ticket', detailCreated: 'created', detailTotal: 'total',
        detailDiscount: 'discount', detailFinal: 'final'
    };

    document.querySelectorAll('.js-order-detail').forEach(function (button) {
        button.addEventListener('click', function () {
            Object.keys(fields).forEach(function (id) {
                document.getElementById(id).textContent = button.dataset[fields[id]] || '';
            });
            var status = button.dataset.status;
            document.getElementById('detailStatus').textContent = STATUS_TEXT[status] || status;
        });
    });

    // Ảnh sự kiện lỗi/không tồn tại -> hiện khung dự phòng
    document.querySelectorAll('.js-event-image').forEach(function (img) {
        img.addEventListener('error', function () {
            img.parentElement.classList.add('lt-thumb-empty');
            img.remove();
        });
    });
    document.querySelectorAll('.lt-thumb').forEach(function (thumb) {
        if (!thumb.querySelector('img')) {
            thumb.classList.add('lt-thumb-empty');
        }
    });

    // Đếm ngược thời gian giữ chỗ của đơn Pending (hold_expired_at)
    var countdowns = document.querySelectorAll('.js-countdown');

    function pad(n) { return n < 10 ? '0' + n : String(n); }

    function tick() {
        countdowns.forEach(function (el) {
            var remaining = new Date(el.dataset.expire).getTime() - Date.now();
            if (isNaN(remaining) || remaining <= 0) {
                el.textContent = 'Đã hết hạn giữ chỗ';
                return;
            }
            var totalSeconds = Math.floor(remaining / 1000);
            el.textContent = pad(Math.floor(totalSeconds / 60)) + ':' + pad(totalSeconds % 60);
        });
    }

    if (countdowns.length > 0) {
        tick();
        setInterval(tick, 1000);
    }
})();
