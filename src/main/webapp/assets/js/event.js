// Validate phía client chỉ để phản hồi nhanh; backend (EventController) vẫn là nơi quyết định.

// ---------------------------------------------------------------- Xác nhận trước khi xóa (trang danh sách + trang sửa)
(function () {
    document.querySelectorAll('.js-confirm-delete').forEach(function (deleteForm) {
        deleteForm.addEventListener('submit', function (e) {
            var name = deleteForm.getAttribute('data-event-name');
            if (!window.confirm('Xóa sự kiện "' + name + '"? Thao tác này không thể hoàn tác.')) {
                e.preventDefault();
            }
        });
    });
})();

// ---------------------------------------------------------------- Form tạo / sửa sự kiện
(function () {
    var form = document.getElementById('create-event-form') || document.getElementById('edit-event-form');
    if (!form) {
        return;
    }

    var isCreate = form.id === 'create-event-form';
    var ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'webp'];
    var MAX_IMAGE_SIZE = 5 * 1024 * 1024;

    var panes = Array.prototype.slice.call(form.querySelectorAll('[data-step-pane]'));
    var stepButtons = Array.prototype.slice.call(document.querySelectorAll('#stepper [data-step-target]'));
    var totalSteps = panes.length;
    var currentStep = 1;

    // ------------------------------------------------ chuyển bước / tab
    function showStep(step) {
        step = Math.min(Math.max(1, step), totalSteps);
        currentStep = step;

        panes.forEach(function (pane) {
            pane.classList.toggle('active', Number(pane.getAttribute('data-step-pane')) === step);
        });
        stepButtons.forEach(function (button) {
            var n = Number(button.getAttribute('data-step-target'));
            button.classList.toggle('active', n === step);
            if (isCreate) {
                button.classList.toggle('done', n < step);
            }
        });

        var prevBtn = document.querySelector('[data-step-nav="prev"]');
        var nextBtn = document.getElementById('nextBtn');
        var nextLabel = document.getElementById('nextLabel');
        if (prevBtn) {
            prevBtn.style.visibility = step === 1 ? 'hidden' : 'visible';
        }
        if (nextBtn && nextLabel) {
            var last = step === totalSteps;
            nextLabel.textContent = last ? 'Hoàn tất & tạo sự kiện' : 'Tiếp tục sang bước tiếp theo';
            nextBtn.setAttribute('data-step-nav', last ? 'submit' : 'next');
        }
        if (step === totalSteps) {
            updateSummary();
        }
        window.scrollTo({top: 0, behavior: 'smooth'});
    }

    stepButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            goTo(Number(button.getAttribute('data-step-target')));
        });
    });

    document.querySelectorAll('[data-step-nav]').forEach(function (button) {
        button.addEventListener('click', function () {
            var action = button.getAttribute('data-step-nav');
            if (action === 'prev') {
                showStep(currentStep - 1);
            } else if (action === 'next') {
                goTo(currentStep + 1);
            } else if (action === 'submit' || action === 'next-header') {
                submitForm();
            }
        });
    });

    function submitForm() {
        if (typeof form.requestSubmit === 'function') {
            form.requestSubmit();
        } else {
            var submit = document.createElement('button');
            submit.type = 'submit';
            submit.style.display = 'none';
            form.appendChild(submit);
            submit.click();
            form.removeChild(submit);
        }
    }

    // ------------------------------------------------ validate (theo từng bước)
    function toDate(id) {
        var value = document.getElementById(id).value;
        return value ? new Date(value) : null;
    }

    // Mỗi quy tắc thuộc về một bước; tính lại mỗi lần gọi để luôn dùng giá trị mới nhất
    function getRules() {
        var name = document.getElementById('eventName').value.trim();
        var description = document.getElementById('description').value.trim();
        var start = toDate('startTime');
        var end = toDate('endTime');
        var file = document.getElementById('eventImage').files[0];
        var extension = file ? file.name.split('.').pop().toLowerCase() : '';

        return [
            {id: 'eventName', step: 1, ok: name.length >= 5 && name.length <= 200,
                msg: 'Tên sự kiện phải từ 5 đến 200 ký tự.'},
            {id: 'categoryId', step: 1, ok: document.getElementById('categoryId').value !== '',
                msg: 'Vui lòng chọn danh mục sự kiện.'},
            {id: 'eventImage', step: 1,
                ok: !file || (ALLOWED_EXTENSIONS.indexOf(extension) >= 0 && file.size <= MAX_IMAGE_SIZE),
                msg: 'Ảnh phải là JPG, PNG hoặc WEBP và không quá 5MB.'},
            {id: 'description', step: 1, ok: description.length >= 20 && description.length <= 5000,
                msg: 'Mô tả phải từ 20 đến 5000 ký tự.'},
            {id: 'startTime', step: 2, ok: start !== null && start > new Date(),
                msg: 'Thời gian bắt đầu phải sau thời điểm hiện tại.'},
            {id: 'endTime', step: 2, ok: end !== null && start !== null && end > start,
                msg: 'Thời gian kết thúc phải sau thời gian bắt đầu.'},
            {id: 'venueId', step: 2, ok: document.getElementById('venueId').value !== '',
                msg: 'Vui lòng chọn địa điểm tổ chức.'}
        ];
    }

    function check(id, condition, message) {
        var input = document.getElementById(id);
        var wrapper = input.closest('.lt-field') || input.closest('.side-card') || input.parentElement;
        var feedback = wrapper.querySelector('.invalid-feedback');
        input.classList.toggle('is-invalid', !condition);
        if (feedback) {
            feedback.textContent = condition ? '' : message;
        }
        return condition;
    }

    // Kiểm tra các trường của một bước; trả về true nếu hợp lệ
    function validateStep(step) {
        var firstInvalid = null;
        getRules().forEach(function (rule) {
            if (rule.step === step && !check(rule.id, rule.ok, rule.msg) && firstInvalid === null) {
                firstInvalid = rule.id;
            }
        });
        if (firstInvalid !== null) {
            try {
                document.getElementById(firstInvalid).focus({preventScroll: true});
            } catch (err) { /* input file ẩn có thể không focus được */ }
        }
        // Bước 3 của trang tạo: hạng vé (module bên dưới)
        var ticketsOk = true;
        if (isCreate && step === 3 && window.ltTickets) {
            ticketsOk = window.ltTickets.validate();
        }
        return firstInvalid === null && ticketsOk;
    }

    // Đi lùi tự do; đi tới chỉ khi mọi bước phía trước (từ bước hiện tại) đều hợp lệ
    function goTo(target) {
        target = Math.min(Math.max(1, target), totalSteps);
        if (target <= currentStep) {
            showStep(target);
            return;
        }
        for (var step = currentStep; step < target; step++) {
            if (!validateStep(step)) {
                showStep(step);
                validateStep(step); // hiện lại thông báo lỗi và focus sau khi bước đã hiển thị
                return;
            }
        }
        showStep(target);
    }

    // Sửa xong trường đang báo lỗi thì xóa/cập nhật thông báo ngay
    function revalidateField(e) {
        var target = e.target;
        if (!target || !target.classList || !target.classList.contains('is-invalid')) {
            return;
        }
        getRules().forEach(function (rule) {
            if (rule.id === target.id) {
                check(rule.id, rule.ok, rule.msg);
            }
        });
        // endTime phụ thuộc startTime
        if (target.id === 'startTime' && document.getElementById('endTime').classList.contains('is-invalid')) {
            getRules().forEach(function (rule) {
                if (rule.id === 'endTime') {
                    check(rule.id, rule.ok, rule.msg);
                }
            });
        }
    }
    form.addEventListener('input', revalidateField);
    form.addEventListener('change', revalidateField);

    // Gửi form: kiểm tra toàn bộ các bước, nhảy tới bước đầu tiên có lỗi
    form.addEventListener('submit', function (e) {
        var firstInvalidStep = 0;
        for (var step = 1; step <= totalSteps; step++) {
            if (!validateStep(step) && firstInvalidStep === 0) {
                firstInvalidStep = step;
            }
        }
        if (firstInvalidStep > 0) {
            e.preventDefault();
            showStep(firstInvalidStep);
            validateStep(firstInvalidStep);
        }
    });

    // ------------------------------------------------ đếm ký tự mô tả
    var description = document.getElementById('description');
    var descCount = document.getElementById('descCount');
    if (description && descCount) {
        var updateCount = function () {
            descCount.textContent = description.value.length;
        };
        description.addEventListener('input', updateCount);
        updateCount();
    }

    // ------------------------------------------------ xem trước poster + kéo thả
    var fileInput = document.getElementById('eventImage');
    var dropZone = document.getElementById('dropZone');
    var preview = document.getElementById('posterPreview');
    if (fileInput && dropZone && preview) {
        fileInput.addEventListener('change', function () {
            var file = fileInput.files[0];
            if (file && file.type.indexOf('image/') === 0) {
                preview.src = URL.createObjectURL(file);
                dropZone.classList.add('has-image');
            } else if (!file && !preview.getAttribute('src')) {
                dropZone.classList.remove('has-image');
            }
            updateSummary();
        });
        ['dragenter', 'dragover'].forEach(function (type) {
            dropZone.addEventListener(type, function (e) {
                e.preventDefault();
                dropZone.classList.add('dragover');
            });
        });
        ['dragleave', 'drop'].forEach(function (type) {
            dropZone.addEventListener(type, function () {
                dropZone.classList.remove('dragover');
            });
        });
        dropZone.addEventListener('drop', function (e) {
            e.preventDefault();
            if (e.dataTransfer && e.dataTransfer.files.length > 0) {
                fileInput.files = e.dataTransfer.files;
                fileInput.dispatchEvent(new Event('change'));
            }
        });
    }

    // ------------------------------------------------ tóm tắt ở bước cuối (trang tạo)
    function formatDateTime(value) {
        if (!value) {
            return '—';
        }
        var d = new Date(value);
        if (isNaN(d.getTime())) {
            return '—';
        }
        function p(n) {
            return n < 10 ? '0' + n : '' + n;
        }
        return p(d.getDate()) + '/' + p(d.getMonth() + 1) + '/' + d.getFullYear() + ' ' + p(d.getHours()) + ':' + p(d.getMinutes());
    }

    function updateSummary() {
        var targets = document.querySelectorAll('[data-summary]');
        if (targets.length === 0) {
            return;
        }
        targets.forEach(function (target) {
            var key = target.getAttribute('data-summary');
            var el = document.getElementById(key);
            var text = '—';
            if (!el) {
                return;
            }
            if (key === 'eventImage') {
                text = el.files[0] ? el.files[0].name : 'Chưa chọn ảnh';
            } else if (el.tagName === 'SELECT') {
                text = el.value ? el.options[el.selectedIndex].text.trim() : '—';
            } else if (key === 'startTime' || key === 'endTime') {
                text = formatDateTime(el.value);
            } else {
                text = el.value.trim() || '—';
            }
            target.textContent = text;
        });
    }

    form.addEventListener('input', updateSummary);
    form.addEventListener('change', updateSummary);

    // Có lỗi từ server -> mở sẵn bước chứa lỗi đầu tiên
    var firstServerError = form.querySelector('.is-invalid');
    var startAt = 1;
    if (firstServerError) {
        var pane = firstServerError.closest('[data-step-pane]');
        if (pane) {
            startAt = Number(pane.getAttribute('data-step-pane'));
        }
    }
    updateSummary();
    showStep(startAt);
    window.scrollTo(0, 0);
})();

// ================================================================ Organizer shell (Stitch): sidebar / drawer mobile
// Khối độc lập, không đụng tới logic wizard/validate ở trên.
(function () {
    var sidebar = document.getElementById('orgSidebar');
    if (!sidebar) {
        return;
    }
    var backdrop = document.getElementById('orgSidebarBackdrop');
    var openBtn = document.getElementById('orgSidebarOpen');
    var closeBtn = document.getElementById('orgSidebarClose');
    var mobile = window.matchMedia('(max-width: 991.98px)');

    function setOpen(open) {
        sidebar.classList.toggle('is-open', open);
        if (backdrop) {
            backdrop.classList.toggle('is-open', open);
        }
        document.body.classList.toggle('org-sidebar-lock', open);
        if (openBtn) {
            openBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
        }
    }

    if (openBtn) {
        openBtn.addEventListener('click', function () {
            setOpen(true);
        });
    }
    if (closeBtn) {
        closeBtn.addEventListener('click', function () {
            setOpen(false);
        });
    }
    if (backdrop) {
        backdrop.addEventListener('click', function () {
            setOpen(false);
        });
    }
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && sidebar.classList.contains('is-open')) {
            setOpen(false);
        }
    });
    sidebar.querySelectorAll('a').forEach(function (link) {
        link.addEventListener('click', function () {
            if (mobile.matches) {
                setOpen(false);
            }
        });
    });
    window.addEventListener('resize', function () {
        if (!mobile.matches && sidebar.classList.contains('is-open')) {
            setOpen(false);
        }
    });

    // Mục menu chưa có trang: không nhảy lên đầu trang
    document.querySelectorAll('[data-soon]').forEach(function (link) {
        link.addEventListener('click', function (e) {
            e.preventDefault();
        });
    });
})();

// ================================================================ Trang tạo sự kiện: đếm ký tự tên, live preview, checklist
// Chỉ hiển thị (read-only): không đổi dữ liệu form, không gửi gì thêm lên server.
(function () {
    var form = document.getElementById('create-event-form');
    if (!form) {
        return;
    }

    function $(id) {
        return document.getElementById(id);
    }
    var nameInput = $('eventName');
    var categorySel = $('categoryId');
    var descInput = $('description');
    var startInput = $('startTime');
    var endInput = $('endTime');
    var venueSel = $('venueId');
    var fileInput = $('eventImage');

    var WEEKDAYS = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];

    function pad(n) {
        return n < 10 ? '0' + n : '' + n;
    }
    function selectedText(sel) {
        return sel && sel.value ? sel.options[sel.selectedIndex].text.trim() : '';
    }
    function formatBytes(bytes) {
        if (bytes >= 1048576) {
            return (bytes / 1048576).toFixed(1) + ' MB';
        }
        return Math.max(1, Math.round(bytes / 1024)) + ' KB';
    }

    // ---- đếm ký tự tên sự kiện
    function updateNameCount() {
        var count = $('nameCount');
        var wrap = $('nameCounter');
        if (!count || !nameInput) {
            return;
        }
        count.textContent = nameInput.value.length;
        if (wrap) {
            wrap.classList.toggle('is-over', nameInput.value.length > 200);
        }
    }

    // ---- live preview
    function updatePreview() {
        var title = $('pvTitle');
        var chip = $('pvCategory');
        var dateEl = $('pvDate');
        var venueEl = $('pvVenue');

        if (title) {
            var name = nameInput.value.trim();
            title.textContent = name || 'Tên sự kiện của bạn sẽ hiển thị tại đây';
            title.classList.toggle('is-empty', !name);
        }
        if (chip) {
            var cat = selectedText(categorySel);
            chip.textContent = cat;
            chip.classList.toggle('is-empty', !cat);
        }
        if (dateEl) {
            var d = startInput.value ? new Date(startInput.value) : null;
            if (d && !isNaN(d.getTime())) {
                dateEl.textContent = pad(d.getHours()) + ':' + pad(d.getMinutes()) + ' • ' + WEEKDAYS[d.getDay()] + ', '
                        + pad(d.getDate()) + '/' + pad(d.getMonth() + 1) + '/' + d.getFullYear();
                dateEl.classList.remove('is-empty');
            } else {
                dateEl.textContent = 'Chưa chọn thời gian';
                dateEl.classList.add('is-empty');
            }
        }
        if (venueEl) {
            venueEl.textContent = selectedText(venueSel) || 'Chưa chọn địa điểm';
        }
    }

    // ---- ảnh poster: preview + thông tin file
    function updatePoster() {
        var media = $('pvMedia');
        var img = $('pvImg');
        var meta = $('posterMeta');
        var file = fileInput && fileInput.files[0];
        var ok = file && file.type.indexOf('image/') === 0;

        if (meta) {
            meta.textContent = ok ? file.name + ' • ' + formatBytes(file.size) : '';
            meta.classList.toggle('has-text', !!ok);
        }
        if (media && img) {
            if (ok) {
                if (img.getAttribute('data-url')) {
                    URL.revokeObjectURL(img.getAttribute('data-url'));
                }
                var url = URL.createObjectURL(file);
                img.setAttribute('data-url', url);
                img.src = url;
                media.classList.add('has-image');
            } else {
                img.removeAttribute('src');
                media.classList.remove('has-image');
            }
        }
    }

    // ---- checklist độ sẵn sàng (chỉ phản ánh các quy tắc bắt buộc, không hiện lỗi)
    function setItem(key, done, text) {
        var el = document.querySelector('[data-ck="' + key + '"]');
        if (!el) {
            return;
        }
        el.classList.toggle('is-done', done);
        var icon = el.querySelector('.ck-ico');
        var status = el.querySelector('.ck-status');
        if (icon) {
            icon.textContent = done ? 'check_circle' : 'radio_button_unchecked';
        }
        if (status) {
            status.textContent = text || (done ? 'Hoàn tất' : 'Chưa hoàn tất');
        }
    }

    function updateChecklist() {
        var name = nameInput.value.trim();
        var desc = descInput.value.trim();
        var start = startInput.value ? new Date(startInput.value) : null;
        var end = endInput.value ? new Date(endInput.value) : null;

        var results = {
            name: name.length >= 5 && name.length <= 200,
            category: categorySel.value !== '',
            description: desc.length >= 20 && desc.length <= 5000,
            time: !!(start && end && !isNaN(start.getTime()) && !isNaN(end.getTime()) && start > new Date() && end > start),
            venue: venueSel.value !== ''
        };
        var keys = Object.keys(results);
        var done = 0;
        keys.forEach(function (k) {
            setItem(k, results[k]);
            if (results[k]) {
                done++;
            }
        });

        var pct = Math.round(done * 100 / keys.length);
        var bar = $('ckBar');
        var label = $('ckPct');
        if (bar) {
            bar.style.width = pct + '%';
        }
        if (label) {
            label.textContent = pct + '%';
        }

        var hasFile = fileInput && fileInput.files[0];
        var imageItem = document.querySelector('[data-ck="image"]');
        if (imageItem) {
            imageItem.classList.toggle('is-done', !!hasFile);
            var status = imageItem.querySelector('.ck-status');
            var icon = imageItem.querySelector('.ck-ico');
            if (status) {
                status.textContent = hasFile ? 'Đã chọn ảnh' : 'Không bắt buộc';
            }
            if (icon) {
                icon.textContent = hasFile ? 'check_circle' : 'image';
            }
        }
    }

    function refreshAll() {
        updateNameCount();
        updatePreview();
        updateChecklist();
    }

    form.addEventListener('input', refreshAll);
    form.addEventListener('change', refreshAll);
    if (fileInput) {
        // drag-drop phát sự kiện change không nổi bọt => nghe trực tiếp trên input
        fileInput.addEventListener('change', function () {
            updatePoster();
            updateChecklist();
        });
    }

    // Nút "Xem trước" (chỉ hiện trên màn hình nhỏ, khi preview nằm dưới form)
    var previewBtn = $('scrollPreviewBtn');
    var previewPanel = $('livePreview');
    if (previewBtn && previewPanel) {
        previewBtn.addEventListener('click', function () {
            previewPanel.scrollIntoView({behavior: 'smooth', block: 'start'});
        });
    }

    refreshAll();
    updatePoster();
})();

// ================================================================ Trang tạo sự kiện: cấu hình hạng vé & giá
// Thêm/xóa dòng hạng vé, validate phía client (backend vẫn kiểm tra lại), tổng hợp số vé/doanh thu,
// cập nhật live preview + checklist. Dữ liệu gửi lên qua các input ticketName/ticketDescription/ticketPrice/ticketQuantity.
(function () {
    var form = document.getElementById('create-event-form');
    var list = document.getElementById('ticketList');
    var template = document.getElementById('ticketRowTemplate');
    if (!form || !list || !template) {
        return;
    }

    var MAX_TYPES = Number(document.getElementById('ticketBlock').getAttribute('data-max-types')) || 10;
    var MAX_PRICE = 100000000;
    var MAX_QTY = 1000000;
    var addBtn = document.getElementById('addTicketBtn');
    var emptyNote = document.getElementById('ticketEmpty');

    function rows() {
        return Array.prototype.slice.call(list.querySelectorAll('[data-ticket-row]'));
    }
    function field(row, name) {
        return row.querySelector('[name="' + name + '"]');
    }
    function formatVnd(n) {
        return Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ' đ';
    }
    function isBlankRow(row) {
        return ['ticketName', 'ticketDescription', 'ticketPrice', 'ticketQuantity'].every(function (n) {
            return field(row, n).value.trim() === '';
        });
    }
    // Dòng hợp lệ cơ bản (dùng để tính tổng, không hiện lỗi)
    function readRow(row) {
        var price = field(row, 'ticketPrice').value.trim();
        var qty = field(row, 'ticketQuantity').value.trim();
        var priceNum = price === '' ? NaN : Number(price);
        var qtyNum = qty === '' ? NaN : Number(qty);
        return {
            name: field(row, 'ticketName').value.trim(),
            price: priceNum,
            qty: qtyNum,
            valid: !isNaN(priceNum) && priceNum >= 0 && !isNaN(qtyNum) && qtyNum > 0 && Math.floor(qtyNum) === qtyNum
        };
    }

    // ---- đánh số lại + trạng thái rỗng + nút thêm
    function refreshRows() {
        var all = rows();
        all.forEach(function (row, i) {
            row.querySelector('[data-ticket-badge]').textContent = 'Hạng vé ' + (i + 1);
        });
        emptyNote.style.display = all.length === 0 ? '' : 'none';
        addBtn.disabled = all.length >= MAX_TYPES;
    }

    // ---- tổng hợp + preview + checklist
    function refreshSummary() {
        var totalQty = 0, totalRevenue = 0, minPrice = null, count = 0;
        rows().forEach(function (row) {
            if (isBlankRow(row)) {
                return;
            }
            count++;
            var r = readRow(row);
            if (r.valid) {
                totalQty += r.qty;
                totalRevenue += r.qty * r.price;
                minPrice = minPrice === null ? r.price : Math.min(minPrice, r.price);
            }
        });

        document.getElementById('tkTotalQty').textContent = totalQty.toLocaleString('vi-VN');
        document.getElementById('tkTotalRevenue').textContent = formatVnd(totalRevenue);

        var summary = document.getElementById('ticketSummary');
        if (summary) {
            summary.textContent = count === 0 ? 'Chưa cấu hình (có thể thêm sau)'
                    : count + ' hạng vé · ' + totalQty.toLocaleString('vi-VN') + ' vé · doanh thu kỳ vọng ' + formatVnd(totalRevenue);
        }

        var pvPrice = document.getElementById('pvPrice');
        var pvLabel = document.getElementById('pvPriceLabel');
        if (pvPrice && pvLabel) {
            if (minPrice === null) {
                pvLabel.textContent = 'Giá vé';
                pvPrice.textContent = 'Chưa cấu hình';
            } else {
                pvLabel.textContent = 'Giá vé từ';
                pvPrice.textContent = minPrice === 0 ? 'Miễn phí' : formatVnd(minPrice);
            }
        }

        var ck = document.querySelector('[data-ck="tickets"]');
        if (ck) {
            var done = count > 0;
            ck.classList.toggle('is-done', done);
            ck.classList.toggle('is-info', !done);
            var icon = ck.querySelector('.ck-ico');
            var status = ck.querySelector('.ck-status');
            if (icon) {
                icon.textContent = done ? 'check_circle' : 'pending';
            }
            if (status) {
                status.textContent = done ? count + ' hạng vé' : 'Không bắt buộc';
            }
        }
    }

    function addRow() {
        if (rows().length >= MAX_TYPES) {
            return null;
        }
        list.appendChild(document.importNode(template.content, true));
        refreshRows();
        refreshSummary();
        var row = rows()[rows().length - 1];
        field(row, 'ticketName').focus();
        return row;
    }

    // ---- validate (khớp quy tắc ở EventValidator.validateTickets, trừ kiểm tra sức chứa địa điểm do server làm)
    function setRowError(row, message) {
        row.querySelector('[data-ticket-error]').textContent = message || '';
        ['ticketName', 'ticketPrice', 'ticketQuantity'].forEach(function (n) {
            field(row, n).classList.toggle('is-invalid', !!message);
        });
    }
    function rowMessage(row, seenNames) {
        var name = field(row, 'ticketName').value.trim();
        var description = field(row, 'ticketDescription').value.trim();
        var priceRaw = field(row, 'ticketPrice').value.trim();
        var qtyRaw = field(row, 'ticketQuantity').value.trim();
        var price = Number(priceRaw);
        var qty = Number(qtyRaw);

        if (name === '') {
            return 'Vui lòng nhập tên hạng vé.';
        }
        if (name.length > 100) {
            return 'Tên hạng vé tối đa 100 ký tự.';
        }
        if (description.length > 500) {
            return 'Mô tả hạng vé tối đa 500 ký tự.';
        }
        if (priceRaw === '' || isNaN(price)) {
            return 'Vui lòng nhập giá vé hợp lệ (nhập 0 nếu miễn phí).';
        }
        if (price < 0) {
            return 'Giá vé không được âm.';
        }
        if (Math.floor(price) !== price) {
            return 'Giá vé phải là số nguyên (đơn vị VNĐ).';
        }
        if (price > MAX_PRICE) {
            return 'Giá vé tối đa 100.000.000 VNĐ.';
        }
        if (qtyRaw === '' || isNaN(qty) || qty <= 0 || Math.floor(qty) !== qty) {
            return 'Số lượng vé phải là số nguyên lớn hơn 0.';
        }
        if (qty > MAX_QTY) {
            return 'Số lượng mỗi hạng vé tối đa 1.000.000 vé.';
        }
        var key = name.toLowerCase();
        if (seenNames[key]) {
            return 'Tên hạng vé bị trùng với hạng vé khác trong sự kiện.';
        }
        seenNames[key] = true;
        return '';
    }
    function showAlert(message) {
        var alertBox = document.getElementById('ticketAlert');
        document.getElementById('ticketAlertText').textContent = message || '';
        alertBox.style.display = message ? '' : 'none';
    }

    function validate() {
        var seen = {};
        var ok = true;
        var firstBad = null;
        var filled = rows().filter(function (row) {
            return !isBlankRow(row);
        });
        // dòng trống hoàn toàn: bỏ qua (server cũng bỏ qua)
        rows().forEach(function (row) {
            if (isBlankRow(row)) {
                setRowError(row, '');
            }
        });
        showAlert(filled.length > MAX_TYPES ? 'Mỗi sự kiện tối đa ' + MAX_TYPES + ' hạng vé.' : '');
        if (filled.length > MAX_TYPES) {
            ok = false;
        }
        filled.forEach(function (row) {
            var message = rowMessage(row, seen);
            setRowError(row, message);
            if (message) {
                ok = false;
                if (firstBad === null) {
                    firstBad = row;
                }
            }
        });
        if (firstBad !== null) {
            field(firstBad, 'ticketName').focus({preventScroll: true});
        }
        return ok;
    }

    // ---- sự kiện
    addBtn.addEventListener('click', addRow);
    list.addEventListener('click', function (e) {
        var btn = e.target.closest('[data-ticket-remove]');
        if (!btn) {
            return;
        }
        var row = btn.closest('[data-ticket-row]');
        row.parentNode.removeChild(row);
        refreshRows();
        refreshSummary();
    });
    list.addEventListener('input', function (e) {
        // sửa xong thì gỡ thông báo lỗi của dòng đó
        var row = e.target.closest('[data-ticket-row]');
        if (row && row.querySelector('.is-invalid')) {
            setRowError(row, '');
        }
        refreshSummary();
    });

    window.ltTickets = {validate: validate};
    refreshRows();
    refreshSummary();
})();
