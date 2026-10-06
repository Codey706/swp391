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
        return firstInvalid === null;
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
