/*
 * Light Ticket — menu tài khoản dùng chung (WEB-INF/views/common/user-menu.jsp).
 * Tự mở/đóng, không cần Bootstrap JS. Đóng khi bấm ra ngoài hoặc nhấn Esc.
 */
(function () {
    'use strict';
    if (window.__ltUserMenu) return;
    window.__ltUserMenu = true;

    function setOpen(root, open) {
        var toggle = root.querySelector('[data-um-toggle]');
        var menu = root.querySelector('[data-um-menu]');
        if (!toggle || !menu) return;
        menu.hidden = !open;
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        root.classList.toggle('is-open', open);
    }

    function closeAll(except) {
        document.querySelectorAll('[data-user-menu].is-open').forEach(function (root) {
            if (root !== except) setOpen(root, false);
        });
    }

    document.addEventListener('click', function (e) {
        var toggle = e.target.closest('[data-um-toggle]');
        if (toggle) {
            var root = toggle.closest('[data-user-menu]');
            var willOpen = !root.classList.contains('is-open');
            closeAll(root);
            setOpen(root, willOpen);
            if (willOpen) {
                var first = root.querySelector('[data-um-menu] .um-item');
                if (first && e.detail === 0) first.focus();   // mở bằng bàn phím
            }
            return;
        }
        if (!e.target.closest('[data-um-menu]')) closeAll(null);
    });

    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        var open = document.querySelector('[data-user-menu].is-open');
        if (!open) return;
        setOpen(open, false);
        var t = open.querySelector('[data-um-toggle]');
        if (t) t.focus();
    });
})();
