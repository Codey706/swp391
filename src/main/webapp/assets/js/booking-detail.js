// Tương tác giao diện trang chi tiết đơn hàng 
(function () {
    'use strict';

    var modal = document.getElementById('ticket-info-modal');
    var openButton = document.getElementById('open-ticket-btn');
    var closeButton = document.getElementById('close-ticket-modal');
    var doneButton = document.getElementById('done-ticket-modal');

    function openModal() {
        if (!modal || !openButton || openButton.disabled) return;
        modal.hidden = false;
        if (closeButton) closeButton.focus();
    }

    function closeModal() {
        if (!modal) return;
        modal.hidden = true;
        if (openButton) openButton.focus();
    }

    if (openButton) openButton.addEventListener('click', openModal);
    if (closeButton) closeButton.addEventListener('click', closeModal);
    if (doneButton) doneButton.addEventListener('click', closeModal);

    if (modal) {
        modal.addEventListener('click', function (event) {
            if (event.target === modal) closeModal();
        });
    }

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && modal && !modal.hidden) closeModal();
    });
})();
