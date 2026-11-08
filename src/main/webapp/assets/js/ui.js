/*
 * Light Ticket — shared UI behaviour (loaded on every page, deferred).
 *  1. Press ripple on buttons.
 *  2. Loading spinner on the button that submitted a form, which also blocks
 *     double submits. The button is not disabled, so its name/value is still sent.
 */
(function () {
    'use strict';

    var BUTTON = 'button, [type="submit"], [type="button"], [role="button"], .btn, a[class*="btn"], a[class*="button"]';
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function isDisabled(el) {
        return el.disabled || el.classList.contains('disabled') || el.getAttribute('aria-disabled') === 'true';
    }

    /* ---- 1. Ripple ------------------------------------------------------ */
    document.addEventListener('pointerdown', function (e) {
        if (reduceMotion || e.button !== 0) return;
        var btn = e.target.closest(BUTTON);
        if (!btn || isDisabled(btn) || btn.tagName === 'INPUT' || btn.classList.contains('btn-close')) return;

        var rect = btn.getBoundingClientRect();
        if (rect.width < 24 || rect.height < 18) return;

        if (getComputedStyle(btn).position === 'static') btn.style.position = 'relative';

        var host = document.createElement('span');
        host.className = 'ui-ripple-host';
        var dot = document.createElement('span');
        dot.className = 'ui-ripple';
        var size = Math.max(rect.width, rect.height) * 2.2;
        dot.style.width = dot.style.height = size + 'px';
        dot.style.left = (e.clientX - rect.left - size / 2) + 'px';
        dot.style.top = (e.clientY - rect.top - size / 2) + 'px';
        host.appendChild(dot);
        btn.appendChild(host);
        setTimeout(function () { host.remove(); }, 600);
    }, { passive: true });

    /* ---- 2. Loading state on submit ------------------------------------ */
    var lastClicked = null;
    document.addEventListener('click', function (e) {
        var b = e.target.closest('button, input[type="submit"]');
        if (b && b.form) lastClicked = b;
    }, true);

    function clearLoading() {
        document.querySelectorAll('.ui-loading').forEach(function (b) {
            b.classList.remove('ui-loading');
            b.removeAttribute('aria-busy');
        });
    }

    // Runs after the form's own handlers (inline onsubmit, validation, confirm()).
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (e.defaultPrevented || !(form instanceof HTMLFormElement)) return;
        if (form.target && form.target !== '_self') return;     // new tab: page stays
        if (form.hasAttribute('data-no-loading')) return;

        var btn = e.submitter || (lastClicked && lastClicked.form === form ? lastClicked : null)
            || form.querySelector('button[type="submit"], button:not([type]), input[type="submit"]');
        if (!btn || btn.tagName === 'INPUT' || btn.classList.contains('ui-loading')) return;

        btn.style.setProperty('--ui-spin', getComputedStyle(btn).color);
        btn.classList.add('ui-loading');
        btn.setAttribute('aria-busy', 'true');
        // File downloads and AJAX-ish forms never unload the page.
        setTimeout(clearLoading, 8000);
    });

    // Coming back with the browser Back button restores the page from cache.
    window.addEventListener('pageshow', clearLoading);
})();
