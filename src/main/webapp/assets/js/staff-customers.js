// Trang Thông tin khách hàng (Staff): điền dữ liệu vào modal "Xem vé" từ thuộc tính data-* của nút.
(function () {
    var modal = document.getElementById('ticketModal');
    if (!modal) {
        return;
    }
    var fields = ['code', 'type', 'seat', 'order', 'event', 'status', 'checkin'];
    modal.addEventListener('show.bs.modal', function (event) {
        var btn = event.relatedTarget;
        if (!btn) {
            return;
        }
        fields.forEach(function (name) {
            var el = modal.querySelector('[data-field="' + name + '"]');
            if (el) {
                el.textContent = btn.getAttribute('data-' + name) || '—';
            }
        });
    });
})();
