/* Light Ticket - Organizer Portal: Hồ sơ Nhà tổ chức
   Validation phía client (backend vẫn validate lại), xem trước trực tiếp,
   hủy chỉnh sửa, mở/đóng modal, toast, đổi tài khoản ngân hàng. */
(function () {
    'use strict';

    // Khớp với Constants / ValidationUtils ở backend
    var LIMITS = {fullName: [2, 100], email: 255, address: 255, summary: 300, legalRepresentative: [2, 150],
        url: 500, bankName: 150, bankAccountHolder: 150};
    var EMAIL_PATTERN = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
    var PHONE_PATTERN = /^0\d{9,10}$/;
    var TAX_PATTERN = /^\d{10}(-?\d{3})?$/;
    var ACCOUNT_PATTERN = /^\d{6,20}$/;
    var MAX_FILE = 5 * 1024 * 1024;
    var IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
    var DOC_TYPES = ['application/pdf', 'image/jpeg', 'image/png'];
    var URL_FIELDS = {websiteUrl: 'Website', facebookUrl: 'Fanpage Facebook',
        youtubeUrl: 'Kênh YouTube / TikTok', spotifyUrl: 'Trang Spotify'};

    function byId(id) {
        return document.getElementById(id);
    }

    function initForm() {
        var form = byId('opProfileForm');
        if (!form) {
            return;
        }

        function field(name) {
            return byId(name);
        }

        function setError(name, message) {
            var input = field(name);
            var feedback = form.querySelector('[data-error-for="' + name + '"]');
            if (input && input.classList) {
                input.classList.toggle('is-invalid', !!message);
            }
            if (feedback) {
                feedback.textContent = message || '';
            }
        }

        function isHttpUrl(value) {
            try {
                var url = new URL(value);
                return (url.protocol === 'http:' || url.protocol === 'https:') && !/\s/.test(value);
            } catch (e) {
                return false;
            }
        }

        function validateFile(name, types, label, formats) {
            var input = field(name);
            var file = input && input.files && input.files[0];
            var message = '';
            if (file) {
                if (file.size > MAX_FILE) {
                    message = label + ' vượt quá dung lượng tối đa 5MB.';
                } else if (types.indexOf(file.type) === -1) {
                    message = label + ' chỉ chấp nhận định dạng ' + formats + '.';
                }
            }
            setError(name, message);
            return message === '';
        }

        function validateField(name) {
            var input = field(name);
            if (!input) {
                return true;
            }
            var value = input.value.trim();
            var message = '';

            if (name === 'fullName') {
                if (!value) {
                    message = 'Tên tổ chức không được để trống.';
                } else if (value.length < LIMITS.fullName[0] || value.length > LIMITS.fullName[1]) {
                    message = 'Tên tổ chức phải từ ' + LIMITS.fullName[0] + ' đến ' + LIMITS.fullName[1] + ' ký tự.';
                }
            } else if (name === 'email') {
                if (!value) {
                    message = 'Email không được để trống.';
                } else if (value.length > LIMITS.email) {
                    message = 'Email tối đa ' + LIMITS.email + ' ký tự.';
                } else if (!EMAIL_PATTERN.test(value)) {
                    message = 'Email không đúng định dạng.';
                }
            } else if (name === 'phone') {
                var digits = value.replace(/[\s.\-]/g, '');
                if (!digits) {
                    message = 'Số điện thoại không được để trống.';
                } else if (!PHONE_PATTERN.test(digits)) {
                    message = 'Số điện thoại không hợp lệ (bắt đầu bằng 0, gồm 10-11 chữ số).';
                }
            } else if (name === 'address') {
                if (!value) {
                    message = 'Địa chỉ trụ sở không được để trống.';
                } else if (value.length > LIMITS.address) {
                    message = 'Địa chỉ tối đa ' + LIMITS.address + ' ký tự.';
                }
            } else if (name === 'summary') {
                if (value.length > LIMITS.summary) {
                    message = 'Mô tả tối đa ' + LIMITS.summary + ' ký tự.';
                }
            } else if (name === 'legalRepresentative') {
                if (!value) {
                    message = 'Người đại diện pháp luật không được để trống.';
                } else if (value.length < LIMITS.legalRepresentative[0] || value.length > LIMITS.legalRepresentative[1]) {
                    message = 'Người đại diện phải từ ' + LIMITS.legalRepresentative[0] + ' đến ' + LIMITS.legalRepresentative[1] + ' ký tự.';
                }
            } else if (name === 'taxCode') {
                if (input.readOnly) {
                    return true;
                }
                var tax = value.replace(/\s/g, '');
                if (!tax) {
                    message = 'Mã số thuế không được để trống.';
                } else if (!TAX_PATTERN.test(tax)) {
                    message = 'Mã số thuế gồm 10 chữ số (hoặc 13 chữ số cho chi nhánh).';
                }
            } else if (URL_FIELDS[name]) {
                if (value && value.length > LIMITS.url) {
                    message = URL_FIELDS[name] + ' tối đa ' + LIMITS.url + ' ký tự.';
                } else if (value && !isHttpUrl(value)) {
                    message = URL_FIELDS[name] + ' phải là liên kết hợp lệ bắt đầu bằng http:// hoặc https://.';
                }
            }
            setError(name, message);
            return message === '';
        }

        // Ngân hàng: không bắt buộc, nhưng đã nhập thì phải đủ 3 trường
        function validateBank() {
            var name = field('bankName').value.trim();
            var number = field('bankAccountNumber').value.replace(/[\s.\-]/g, '');
            var holder = field('bankAccountHolder').value.trim();
            var any = !!(name || number || holder);
            var ok = true;
            var messages = {bankName: '', bankAccountNumber: '', bankAccountHolder: ''};
            if (any) {
                if (!name) {
                    messages.bankName = 'Vui lòng nhập tên ngân hàng.';
                } else if (name.length > LIMITS.bankName) {
                    messages.bankName = 'Tên ngân hàng tối đa ' + LIMITS.bankName + ' ký tự.';
                }
                if (!number) {
                    messages.bankAccountNumber = 'Vui lòng nhập số tài khoản.';
                } else if (!ACCOUNT_PATTERN.test(number)) {
                    messages.bankAccountNumber = 'Số tài khoản gồm 6-20 chữ số.';
                }
                if (!holder) {
                    messages.bankAccountHolder = 'Vui lòng nhập tên chủ tài khoản.';
                } else if (holder.length > LIMITS.bankAccountHolder) {
                    messages.bankAccountHolder = 'Tên chủ tài khoản tối đa ' + LIMITS.bankAccountHolder + ' ký tự.';
                }
            }
            Object.keys(messages).forEach(function (key) {
                setError(key, messages[key]);
                if (messages[key]) {
                    ok = false;
                }
            });
            if (!ok) {
                showBankFields();
            }
            return ok;
        }

        function validateCategories() {
            var checked = form.querySelectorAll('input[name="categoryIds"]:checked').length;
            var feedback = form.querySelector('[data-error-for="categories"]');
            var message = checked === 0 ? 'Vui lòng chọn ít nhất một thể loại sự kiện chuyên trách.' : '';
            if (feedback) {
                feedback.textContent = message;
            }
            return message === '';
        }

        var textFields = ['fullName', 'email', 'phone', 'address', 'summary', 'legalRepresentative', 'taxCode']
                .concat(Object.keys(URL_FIELDS));
        var bankFields = ['bankName', 'bankAccountNumber', 'bankAccountHolder'];

        var initialValues = {};
        textFields.concat(bankFields).forEach(function (name) {
            if (field(name)) {
                initialValues[name] = field(name).value;
            }
        });
        var initialChecked = checkedCategories();
        var formDirty = false;

        function checkedCategories() {
            return Array.prototype.map.call(form.querySelectorAll('input[name="categoryIds"]:checked'),
                    function (input) {
                        return input.value;
                    }).sort().join(',');
        }

        function isDirty() {
            if (formDirty || checkedCategories() !== initialChecked) {
                return true;
            }
            return Object.keys(initialValues).some(function (name) {
                return field(name).value !== initialValues[name];
            });
        }

        textFields.forEach(function (name) {
            var input = field(name);
            if (!input) {
                return;
            }
            input.addEventListener('blur', function () {
                validateField(name);
            });
            input.addEventListener('input', function () {
                if (input.classList.contains('is-invalid')) {
                    validateField(name);
                }
            });
        });
        bankFields.forEach(function (name) {
            field(name).addEventListener('blur', validateBank);
        });
        form.querySelectorAll('input[name="categoryIds"]').forEach(function (input) {
            input.addEventListener('change', validateCategories);
        });
        [['cover', IMAGE_TYPES, 'Ảnh bìa', 'JPG, PNG hoặc WEBP'], ['logo', IMAGE_TYPES, 'Logo', 'JPG, PNG hoặc WEBP'],
            ['document', DOC_TYPES, 'Tài liệu', 'PDF, JPG hoặc PNG']].forEach(function (cfg) {
            field(cfg[0]).addEventListener('change', function () {
                formDirty = formDirty || !!field(cfg[0]).files.length;
                validateFile(cfg[0], cfg[1], cfg[2], cfg[3]);
            });
        });

        form.addEventListener('submit', function (event) {
            var firstInvalid = null;
            textFields.forEach(function (name) {
                if (field(name) && !validateField(name) && firstInvalid === null) {
                    firstInvalid = field(name);
                }
            });
            if (!validateCategories() && firstInvalid === null) {
                firstInvalid = form.querySelector('input[name="categoryIds"]');
            }
            if (!validateBank() && firstInvalid === null) {
                firstInvalid = field('bankName');
            }
            [['cover', IMAGE_TYPES, 'Ảnh bìa', 'JPG, PNG hoặc WEBP'], ['logo', IMAGE_TYPES, 'Logo', 'JPG, PNG hoặc WEBP'],
                ['document', DOC_TYPES, 'Tài liệu', 'PDF, JPG hoặc PNG']].forEach(function (cfg) {
                if (!validateFile(cfg[0], cfg[1], cfg[2], cfg[3]) && firstInvalid === null) {
                    firstInvalid = field(cfg[0]);
                }
            });
            if (firstInvalid) {
                event.preventDefault();
                firstInvalid.scrollIntoView({behavior: 'smooth', block: 'center'});
                firstInvalid.focus({preventScroll: true});
                return;
            }
            // tránh bấm lưu hai lần
            document.querySelectorAll('button[form="opProfileForm"]').forEach(function (button) {
                button.disabled = true;
            });
        });

        // Hủy: không lưu gì, tải lại trang để lấy lại dữ liệu gốc từ database
        var cancelButton = byId('opCancel');
        if (cancelButton) {
            cancelButton.addEventListener('click', function () {
                if (isDirty() && !window.confirm('Bạn có chắc muốn hủy các thay đổi chưa lưu?')) {
                    return;
                }
                window.location.assign(form.getAttribute('data-cancel-url'));
            });
        }

        // Số ký tự mô tả
        var summary = field('summary');
        var summaryCount = byId('opSummaryCount');
        function updateSummaryCount() {
            if (summaryCount) {
                summaryCount.textContent = summary.value.length;
            }
        }
        summary.addEventListener('input', updateSummaryCount);
        updateSummaryCount();

        // Xem trước thẻ công khai theo nội dung đang nhập
        function setText(id, value) {
            var element = byId(id);
            if (element) {
                element.textContent = value || element.getAttribute('data-empty') || '';
            }
        }
        function updatePreview() {
            setText('opPvName', field('fullName').value.trim());
            setText('opPvAddress', field('address').value.trim());
            setText('opPvSummary', summary.value.trim());
        }
        ['fullName', 'address', 'summary'].forEach(function (name) {
            field(name).addEventListener('input', updatePreview);
        });

        // Xem trước ảnh vừa chọn (cover/logo) ngay trong form và thẻ xem trước
        function bindImagePreview(inputId, targets) {
            var input = field(inputId);
            var objectUrl = null;
            input.addEventListener('change', function () {
                var file = input.files && input.files[0];
                if (!file || IMAGE_TYPES.indexOf(file.type) === -1 || file.size > MAX_FILE) {
                    return;
                }
                if (objectUrl) {
                    URL.revokeObjectURL(objectUrl);
                }
                objectUrl = URL.createObjectURL(file);
                targets.forEach(function (target) {
                    var img = byId(target.img);
                    var empty = byId(target.empty);
                    img.src = objectUrl;
                    img.hidden = false;
                    if (empty) {
                        empty.hidden = true;
                    }
                });
            });
        }
        bindImagePreview('cover', [{img: 'opCoverImg', empty: 'opCoverEmpty'}, {img: 'opPvCover', empty: 'opPvCoverEmpty'}]);
        bindImagePreview('logo', [{img: 'opLogoImg', empty: 'opLogoEmpty'}, {img: 'opPvLogo', empty: 'opPvLogoEmpty'}]);

        // Đổi tài khoản ngân hàng: mở các ô nhập
        function showBankFields() {
            var fields = byId('opBankFields');
            var toggle = byId('opBankToggle');
            if (fields) {
                fields.hidden = false;
            }
            if (toggle) {
                toggle.hidden = true;
            }
        }
        var bankToggle = byId('opBankToggle');
        if (bankToggle) {
            bankToggle.addEventListener('click', function () {
                showBankFields();
                field('bankName').focus();
            });
        }

        // Nếu server trả lỗi, đưa người dùng tới ô lỗi đầu tiên
        var firstServerError = form.querySelector('.is-invalid, .op-error:not(:empty)');
        if (firstServerError) {
            var target = firstServerError.classList.contains('is-invalid') ? firstServerError
                    : (firstServerError.previousElementSibling || firstServerError);
            target.scrollIntoView({behavior: 'smooth', block: 'center'});
        }
    }

    function initModal() {
        var modal = byId('opPublicModal');
        if (!modal) {
            return;
        }
        function openModal() {
            modal.hidden = false;
        }
        function closeModal() {
            modal.hidden = true;
        }
        ['opOpenPublic', 'opOpenPublicCard'].forEach(function (id) {
            var button = byId(id);
            if (button) {
                button.addEventListener('click', openModal);
            }
        });
        modal.querySelectorAll('[data-close-modal]').forEach(function (element) {
            element.addEventListener('click', closeModal);
        });
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape' && !modal.hidden) {
                closeModal();
            }
        });
    }

    function initToast() {
        var toast = byId('opToast');
        if (!toast) {
            return;
        }
        function hide() {
            toast.classList.add('is-hiding');
        }
        var close = byId('opToastClose');
        if (close) {
            close.addEventListener('click', hide);
        }
        window.setTimeout(hide, 4000);
    }

    document.addEventListener('DOMContentLoaded', function () {
        initForm();
        initModal();
        initToast();
    });
})();
