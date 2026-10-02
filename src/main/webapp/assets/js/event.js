// Validate phía client chỉ để phản hồi nhanh; backend (EventController) vẫn là nơi quyết định.
(function () {
    var form = document.getElementById('create-event-form');
    if (!form) {
        return;
    }

    var ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'webp'];
    var MAX_IMAGE_SIZE = 5 * 1024 * 1024;

    function toDate(id) {
        var value = document.getElementById(id).value;
        return value ? new Date(value) : null;
    }

    function check(id, condition, message) {
        var input = document.getElementById(id);
        var feedback = input.parentElement.querySelector('.invalid-feedback');
        input.classList.toggle('is-invalid', !condition);
        if (feedback) {
            feedback.textContent = condition ? '' : message;
        }
        return condition;
    }

    form.addEventListener('submit', function (e) {
        var name = document.getElementById('eventName').value.trim();
        var description = document.getElementById('description').value.trim();
        var start = toDate('startTime');
        var end = toDate('endTime');
        var file = document.getElementById('eventImage').files[0];
        var extension = file ? file.name.split('.').pop().toLowerCase() : '';

        var results = [
            check('eventName', name.length >= 5 && name.length <= 200, 'Tên sự kiện phải từ 5 đến 200 ký tự.'),
            check('description', description.length >= 20 && description.length <= 5000, 'Mô tả phải từ 20 đến 5000 ký tự.'),
            check('categoryId', document.getElementById('categoryId').value !== '', 'Vui lòng chọn danh mục sự kiện.'),
            check('venueId', document.getElementById('venueId').value !== '', 'Vui lòng chọn địa điểm tổ chức.'),
            check('startTime', start !== null && start > new Date(), 'Thời gian bắt đầu phải sau thời điểm hiện tại.'),
            check('endTime', end !== null && start !== null && end > start, 'Thời gian kết thúc phải sau thời gian bắt đầu.'),
            check('eventImage', !file || (ALLOWED_EXTENSIONS.indexOf(extension) >= 0 && file.size <= MAX_IMAGE_SIZE),
                'Ảnh phải là JPG, PNG hoặc WEBP và không quá 5MB.')
        ];

        if (results.indexOf(false) >= 0) {
            e.preventDefault();
        }
    });
})();
