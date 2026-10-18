<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <footer class="org-footer">
        <div class="org-container d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div class="d-flex align-items-center gap-2">
                <span class="material-symbols-outlined text-warning">confirmation_number</span>
                <span class="fw-bold">Light Ticket</span>
                <small class="text-muted">Staff Check-in Portal</small>
            </div>
            <small class="text-muted">© 2026 Light Ticket Platform. Hệ thống quản lý và kiểm soát vé sự kiện.</small>
        </div>
    </footer>
</div><!-- đóng org-shell từ _header.jsp -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const sb = document.getElementById('orgSidebar');
    const openBtn = document.getElementById('orgSidebarOpen');
    const closeBtn = document.getElementById('orgSidebarClose');
    const bd = document.getElementById('orgSidebarBackdrop');
    if (openBtn && sb) openBtn.onclick = () => { sb.classList.add('is-open'); bd.classList.add('is-open'); };
    if (closeBtn && sb) closeBtn.onclick = () => { sb.classList.remove('is-open'); bd.classList.remove('is-open'); };
    if (bd && sb) bd.onclick = () => { sb.classList.remove('is-open'); bd.classList.remove('is-open'); };
</script>