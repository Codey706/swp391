/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/ClientSide/javascript.js to edit this template
 */


// Booking - Select Event: ảnh dự phòng cho thẻ sự kiện
(function () {
    'use strict';

    // Ảnh lỗi/không tồn tại -> giữ khung nền gradient
    document.querySelectorAll('.js-event-image').forEach(function (img) {
        img.addEventListener('error', function () { img.remove(); });
    });
})();
