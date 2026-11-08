// Chỉnh khung ảnh trước khi tải lên, khoá đúng tỉ lệ (mặc định 16:9).
// Chặn sự kiện change của file gốc, mở cửa sổ chỉnh khung, rồi đưa ảnh đã cắt vào đúng input đó
// nên server vẫn nhận một file ảnh bình thường (validate JPG/PNG/WEBP, tối đa 5MB như cũ).
// Phải được nạp TRƯỚC script khác nghe change của input (event.js, organizer-profile.js).
//
// Dùng lại: window.LTImageCropper.attach({input, dropZone, preview, ratioW, ratioH, outMaxW, title, fileSuffix})
//   - input:    <input type="file"> nhận ảnh
//   - dropZone: phần tử mà thanh nút "Chỉnh khung ảnh / Bỏ ảnh đã chọn" được chèn ngay sau
//   - preview:  <img> xem trước (tùy chọn)
// Trang tạo/sửa sự kiện tự gắn vào #eventImage (16:9) như trước.
(function () {
    'use strict';

    var MAX_BYTES = 5 * 1024 * 1024;
    var MAX_ZOOM = 5; // tối đa gấp 5 lần mức vừa khung
    var TYPES = ['image/jpeg', 'image/png', 'image/webp'];

    function attach(opts) {
        var input = opts && opts.input;
        var dropZone = opts && opts.dropZone;
        var preview = opts && opts.preview;
        if (!input || !dropZone || !window.File || !window.DataTransfer) {
            return null;
        }

        var RATIO_W = opts.ratioW || 16, RATIO_H = opts.ratioH || 9;
        var OUT_MAX_W = opts.outMaxW || 1920;
        var TITLE = opts.title || 'Chỉnh khung ảnh poster';
        var SUFFIX = opts.fileSuffix || (RATIO_W + 'x' + RATIO_H);
        var DEFAULT_NAME = opts.defaultName || 'poster';

        var originalFile = null;                          // ảnh gốc người dùng đã chọn (để chỉnh lại khung)
        var initialSrc = preview ? preview.getAttribute('src') : null; // ảnh đang lưu trên server (trang sửa)
        var passThrough = false;                          // đang tự phát change với ảnh đã cắt
        var objectUrls = [];

        // ------------------------------------------------ nút phụ dưới ô tải ảnh
        var bar = document.createElement('div');
        bar.className = 'ic-actions';
        bar.innerHTML = '<button type="button" class="btn-soft ic-adjust"><i class="ph ph-crop" aria-hidden="true"></i> Chỉnh khung ảnh</button>'
                + '<button type="button" class="btn-soft ic-remove"><i class="ph ph-x" aria-hidden="true"></i> Bỏ ảnh đã chọn</button>';
        dropZone.parentNode.insertBefore(bar, dropZone.nextSibling);
        var adjustBtn = bar.querySelector('.ic-adjust');
        var removeBtn = bar.querySelector('.ic-remove');

        function currentSrc() {
            if (originalFile) {
                return urlFor(originalFile);
            }
            return preview && preview.getAttribute('src') ? preview.getAttribute('src') : null;
        }

        function refreshBar() {
            adjustBtn.hidden = !currentSrc();
            removeBtn.hidden = !originalFile;
        }

        function urlFor(blob) {
            var url = URL.createObjectURL(blob);
            objectUrls.push(url);
            return url;
        }

        // ------------------------------------------------ gán file vào input
        function setInputFile(file) {
            var dt = new DataTransfer();
            if (file) {
                dt.items.add(file);
            }
            input.files = dt.files;
        }

        function emitChange() {
            passThrough = true;
            try {
                input.dispatchEvent(new Event('change', {bubbles: true}));
            } finally {
                passThrough = false;
            }
        }

        // ------------------------------------------------ chặn file gốc
        input.addEventListener('change', function (e) {
            if (passThrough) {
                return;
            }
            var file = input.files && input.files[0];
            if (!file) {
                return; // bỏ chọn: để event.js xử lý như cũ
            }
            if (TYPES.indexOf(file.type) < 0) {
                return; // sai định dạng: để bước validate báo lỗi như cũ
            }
            e.stopImmediatePropagation(); // event.js chỉ nhìn thấy ảnh đã cắt
            var previous = lastCropped;
            openCropper(urlFor(file), file.name, function (cropped) {
                originalFile = file;
                lastCropped = cropped;
                setInputFile(cropped);
                emitChange();
                refreshBar();
            }, function () {
                // Hủy: trả input về ảnh đã chọn trước đó (nếu có)
                setInputFile(previous);
            });
        }, false);

        var lastCropped = null;

        adjustBtn.addEventListener('click', function () {
            var src = currentSrc();
            if (!src) {
                return;
            }
            var name = originalFile ? originalFile.name : DEFAULT_NAME + '.jpg';
            openCropper(src, name, function (cropped) {
                lastCropped = cropped;
                setInputFile(cropped);
                emitChange();
                refreshBar();
            }, function () { /* giữ nguyên */ });
        });

        removeBtn.addEventListener('click', function () {
            originalFile = null;
            lastCropped = null;
            setInputFile(null);
            // khôi phục ảnh trên server (trang sửa) hoặc về ô trống (trang tạo)
            if (preview) {
                if (initialSrc) {
                    preview.setAttribute('src', initialSrc);
                    dropZone.classList.add('has-image');
                } else {
                    preview.removeAttribute('src');
                    dropZone.classList.remove('has-image');
                }
            }
            emitChange();
            refreshBar();
        });

        // ------------------------------------------------ cửa sổ chỉnh khung
        var overlay = null;
        var els = {};

        function buildOverlay() {
            overlay = document.createElement('div');
            overlay.className = 'ic-overlay';
            overlay.hidden = true;
            overlay.setAttribute('role', 'dialog');
            overlay.setAttribute('aria-modal', 'true');
            overlay.setAttribute('aria-label', TITLE);
            overlay.innerHTML = ''
                + '<div class="ic-modal">'
                + '  <div class="ic-head">'
                + '    <div><strong>' + TITLE + '</strong>'
                + '    <span>Tỷ lệ ' + RATIO_W + ':' + RATIO_H + ' · kéo để di chuyển, cuộn chuột hoặc kéo thanh để phóng to</span></div>'
                + '    <button type="button" class="ic-close" aria-label="Đóng"><i class="ph ph-x" aria-hidden="true"></i></button>'
                + '  </div>'
                + '  <div class="ic-stage">'
                + '    <div class="ic-viewport" tabindex="0"><img class="ic-img" alt="" draggable="false"><div class="ic-grid"></div></div>'
                + '  </div>'
                + '  <div class="ic-zoom">'
                + '    <button type="button" class="ic-zbtn ic-zout" aria-label="Thu nhỏ"><i class="ph ph-minus" aria-hidden="true"></i></button>'
                + '    <input type="range" class="ic-range" min="0" max="100" step="1" value="0" aria-label="Phóng to">'
                + '    <button type="button" class="ic-zbtn ic-zin" aria-label="Phóng to"><i class="ph ph-plus" aria-hidden="true"></i></button>'
                + '  </div>'
                + '  <div class="ic-meta"></div>'
                + '  <div class="ic-foot">'
                + '    <button type="button" class="btn-soft ic-reset"><i class="ph ph-arrow-clockwise" aria-hidden="true"></i> Đặt lại</button>'
                + '    <span class="ic-spacer"></span>'
                + '    <button type="button" class="btn-soft ic-cancel">Hủy</button>'
                + '    <button type="button" class="btn-cta ic-ok"><i class="ph ph-check" aria-hidden="true"></i> Dùng khung này</button>'
                + '  </div>'
                + '</div>';
            document.body.appendChild(overlay);
            els = {
                viewport: overlay.querySelector('.ic-viewport'),
                img: overlay.querySelector('.ic-img'),
                range: overlay.querySelector('.ic-range'),
                meta: overlay.querySelector('.ic-meta'),
                ok: overlay.querySelector('.ic-ok'),
                cancel: overlay.querySelector('.ic-cancel'),
                close: overlay.querySelector('.ic-close'),
                reset: overlay.querySelector('.ic-reset'),
                zin: overlay.querySelector('.ic-zin'),
                zout: overlay.querySelector('.ic-zout')
            };
            // Khung cắt khoá đúng tỉ lệ của ảnh cần tải lên
            els.viewport.style.aspectRatio = RATIO_W + ' / ' + RATIO_H;
            if (RATIO_W / RATIO_H < 1.4) {
                els.viewport.classList.add('is-compact');
            }
            bindOverlay();
        }

        // trạng thái đang chỉnh
        var st = null;

        function clampOffset() {
            var w = st.nw * st.scale;
            var h = st.nh * st.scale;
            st.ox = Math.min(0, Math.max(st.ox, st.vw - w));
            st.oy = Math.min(0, Math.max(st.oy, st.vh - h));
        }

        function apply() {
            clampOffset();
            els.img.style.width = (st.nw * st.scale) + 'px';
            els.img.style.height = (st.nh * st.scale) + 'px';
            els.img.style.transform = 'translate(' + st.ox + 'px,' + st.oy + 'px)';
            var cropW = st.vw / st.scale;
            var outW = Math.max(1, Math.min(OUT_MAX_W, Math.round(cropW)));
            var outH = Math.round(outW * RATIO_H / RATIO_W);
            els.meta.textContent = 'Ảnh gốc ' + st.nw + '×' + st.nh + ' px · Kết quả ' + outW + '×' + outH + ' px';
            els.range.value = String(Math.round(Math.log(st.scale / st.minScale) / Math.log(MAX_ZOOM) * 100));
        }

        // Phóng/thu quanh một điểm trong khung (giữ nguyên điểm đó dưới con trỏ)
        function zoomTo(newScale, cx, cy) {
            newScale = Math.min(st.minScale * MAX_ZOOM, Math.max(st.minScale, newScale));
            var ratio = newScale / st.scale;
            st.ox = cx - (cx - st.ox) * ratio;
            st.oy = cy - (cy - st.oy) * ratio;
            st.scale = newScale;
            apply();
        }

        function resetFrame() {
            st.scale = st.minScale;
            st.ox = (st.vw - st.nw * st.scale) / 2;
            st.oy = (st.vh - st.nh * st.scale) / 2;
            apply();
        }

        function bindOverlay() {
            var drag = null;
            els.viewport.addEventListener('pointerdown', function (e) {
                drag = {x: e.clientX, y: e.clientY, ox: st.ox, oy: st.oy};
                els.viewport.classList.add('is-dragging');
                try {
                    els.viewport.setPointerCapture(e.pointerId);
                } catch (err) { /* không bắt buộc */ }
                e.preventDefault();
            });
            els.viewport.addEventListener('pointermove', function (e) {
                if (!drag) {
                    return;
                }
                st.ox = drag.ox + (e.clientX - drag.x);
                st.oy = drag.oy + (e.clientY - drag.y);
                apply();
            });
            function endDrag() {
                drag = null;
                els.viewport.classList.remove('is-dragging');
            }
            els.viewport.addEventListener('pointerup', endDrag);
            els.viewport.addEventListener('pointercancel', endDrag);

            els.viewport.addEventListener('wheel', function (e) {
                e.preventDefault();
                var rect = els.viewport.getBoundingClientRect();
                var factor = e.deltaY < 0 ? 1.1 : 1 / 1.1;
                zoomTo(st.scale * factor, e.clientX - rect.left, e.clientY - rect.top);
            }, {passive: false});

            els.range.addEventListener('input', function () {
                var t = Number(els.range.value) / 100;
                zoomTo(st.minScale * Math.pow(MAX_ZOOM, t), st.vw / 2, st.vh / 2);
            });
            els.zin.addEventListener('click', function () {
                zoomTo(st.scale * 1.15, st.vw / 2, st.vh / 2);
            });
            els.zout.addEventListener('click', function () {
                zoomTo(st.scale / 1.15, st.vw / 2, st.vh / 2);
            });
            els.reset.addEventListener('click', resetFrame);

            els.viewport.addEventListener('keydown', function (e) {
                var step = e.shiftKey ? 2 : 12;
                var handled = true;
                if (e.key === 'ArrowLeft') { st.ox += step; }
                else if (e.key === 'ArrowRight') { st.ox -= step; }
                else if (e.key === 'ArrowUp') { st.oy += step; }
                else if (e.key === 'ArrowDown') { st.oy -= step; }
                else if (e.key === '+' || e.key === '=') { zoomTo(st.scale * 1.1, st.vw / 2, st.vh / 2); return; }
                else if (e.key === '-') { zoomTo(st.scale / 1.1, st.vw / 2, st.vh / 2); return; }
                else { handled = false; }
                if (handled) {
                    e.preventDefault();
                    apply();
                }
            });
        }

        // ------------------------------------------------ mở / đóng
        var session = null;

        function closeOverlay() {
            overlay.hidden = true;
            document.body.classList.remove('ic-open');
            document.removeEventListener('keydown', onDocKey, true);
            session = null;
        }

        function onDocKey(e) {
            if (e.key === 'Escape') {
                e.stopPropagation();
                discard();
            } else if (e.key === 'Enter' && e.target && e.target.tagName !== 'BUTTON') {
                e.preventDefault();
                commit();
            }
        }

        function discard() {
            var done = session && session.onCancel;
            closeOverlay();
            if (done) {
                done();
            }
        }

        function commit() {
            if (!session || els.ok.disabled) {
                return;
            }
            els.ok.disabled = true;
            var s = session;
            renderCropped(s.baseName, function (file) {
                els.ok.disabled = false;
                if (!file) {
                    window.alert('Không thể xử lý ảnh này. Vui lòng chọn ảnh khác.');
                    return;
                }
                closeOverlay();
                s.onDone(file);
            });
        }

        function openCropper(src, fileName, onDone, onCancel) {
            if (!overlay) {
                buildOverlay();
                els.ok.addEventListener('click', commit);
                els.cancel.addEventListener('click', discard);
                els.close.addEventListener('click', discard);
            }
            session = {baseName: fileName.replace(/\.[^.]+$/, ''), onDone: onDone, onCancel: onCancel};
            els.ok.disabled = true;
            els.img.removeAttribute('src');
            overlay.hidden = false;
            document.body.classList.add('ic-open');
            document.addEventListener('keydown', onDocKey, true);

            els.img.onload = function () {
                var vw = els.viewport.clientWidth;
                var vh = els.viewport.clientHeight;
                var nw = els.img.naturalWidth;
                var nh = els.img.naturalHeight;
                st = {nw: nw, nh: nh, vw: vw, vh: vh, minScale: Math.max(vw / nw, vh / nh), scale: 1, ox: 0, oy: 0};
                resetFrame();
                els.ok.disabled = false;
                els.viewport.focus({preventScroll: true});
            };
            els.img.onerror = function () {
                closeOverlay();
                window.alert('Không đọc được ảnh này. Vui lòng chọn ảnh JPG, PNG hoặc WEBP khác.');
                if (onCancel) {
                    onCancel();
                }
            };
            els.img.src = src;
        }

        // ------------------------------------------------ xuất ảnh đã cắt
        function renderCropped(baseName, callback) {
            var sx = -st.ox / st.scale;
            var sy = -st.oy / st.scale;
            var sw = st.vw / st.scale;
            var sh = st.vh / st.scale;
            var outW = Math.max(1, Math.min(OUT_MAX_W, Math.round(sw)));
            var attempt = 0;
            var qualities = [0.92, 0.85, 0.75, 0.65];

            function once() {
                var w = outW;
                var h = Math.round(w * RATIO_H / RATIO_W);
                var canvas = document.createElement('canvas');
                canvas.width = w;
                canvas.height = h;
                var ctx = canvas.getContext('2d');
                ctx.fillStyle = '#ffffff'; // ảnh PNG trong suốt -> nền trắng khi lưu JPEG
                ctx.fillRect(0, 0, w, h);
                ctx.imageSmoothingQuality = 'high';
                ctx.drawImage(els.img, sx, sy, sw, sh, 0, 0, w, h);
                canvas.toBlob(function (blob) {
                    if (!blob) {
                        callback(null);
                        return;
                    }
                    if (blob.size > MAX_BYTES && attempt < qualities.length + 3) {
                        attempt++;
                        if (attempt >= qualities.length) {
                            outW = Math.max(320, Math.round(outW * 0.8)); // hết mức chất lượng thì thu nhỏ kích thước
                        }
                        once();
                        return;
                    }
                    var safe = baseName.replace(/[^\w.-]+/g, '-').replace(/^-+|-+$/g, '') || DEFAULT_NAME;
                    callback(new File([blob], safe + '-' + SUFFIX + '.jpg', {type: 'image/jpeg', lastModified: Date.now()}));
                }, 'image/jpeg', qualities[Math.min(attempt, qualities.length - 1)]);
            }
            once();
        }

        window.addEventListener('beforeunload', function () {
            objectUrls.forEach(function (url) {
                URL.revokeObjectURL(url);
            });
        });

        refreshBar();
        return {refresh: refreshBar};
    }

    window.LTImageCropper = {attach: attach};

    // Trang tạo / sửa sự kiện: poster 16:9
    attach({
        input: document.getElementById('eventImage'),
        dropZone: document.getElementById('dropZone'),
        preview: document.getElementById('posterPreview')
    });
})();
