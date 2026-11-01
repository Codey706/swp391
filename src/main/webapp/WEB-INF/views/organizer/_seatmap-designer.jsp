<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Trình thiết kế sơ đồ ghế (dùng chung cho trang /organizer/event/seatmap và bước 3 của form tạo sự kiện).
     Dữ liệu khởi tạo nằm trong <script id="smData"> của trang chứa; request attribute: readOnly, embedded. --%>
<div class="sm-workspace ${embedded ? 'sm-embedded' : ''}">

    <%-- ============ Cột trái: công cụ + hạng vé ============ --%>
    <aside class="sm-side">
        <c:if test="${not readOnly}">
            <section class="org-card sm-panel">
                <h2><span class="material-symbols-outlined">add_box</span> Thêm khu</h2>
                <div class="sm-tools">
                    <button type="button" class="sm-tool" data-add="STAGE" id="addStage">
                        <span class="material-symbols-outlined">theater_comedy</span> Sân khấu
                    </button>
                    <button type="button" class="sm-tool" data-add="SEATED">
                        <span class="material-symbols-outlined">event_seat</span> Khu ngồi
                    </button>
                    <button type="button" class="sm-tool" data-add="STANDING">
                        <span class="material-symbols-outlined">groups</span> Khu đứng
                    </button>
                </div>
                <h3>Mẫu sơ đồ có sẵn</h3>
                <div class="sm-presets">
                    <button type="button" class="btn-soft" data-preset="hall">Hội trường / Nhà hát</button>
                    <button type="button" class="btn-soft" data-preset="concert">Concert sân khấu</button>
                </div>
            </section>
        </c:if>

        <section class="org-card sm-panel">
            <h2><span class="material-symbols-outlined">confirmation_number</span> Hạng vé &amp; giá</h2>
            <p class="sm-hint">Mỗi khu gán một hạng vé; màu của khu theo màu hạng vé. Số lượng vé tự đồng bộ theo tổng chỗ của các khu.</p>
            <div id="smTicketList" class="sm-ticket-list"></div>
            <c:if test="${not readOnly}">
                <button type="button" class="btn-soft sm-full" id="smAddTicketBtn">
                    <span class="material-symbols-outlined">add</span> Thêm hạng vé
                </button>
            </c:if>
        </section>

        <section class="org-card sm-panel">
            <h2><span class="material-symbols-outlined">monitoring</span> Tổng quan</h2>
            <div class="sm-stats">
                <div><span id="statZones">0</span><small>Khu</small></div>
                <div><span id="statSeats">0</span><small>Tổng chỗ</small></div>
                <div><span id="statVenue">-</span><small>Sức chứa địa điểm</small></div>
            </div>
            <div class="sm-capbar"><div id="capBar"></div></div>
            <div id="issueBox" class="sm-issues" hidden>
                <b><span class="material-symbols-outlined">warning</span> Cần chỉnh sửa (<span id="issueCount">0</span>)</b>
                <ul id="issueList"></ul>
            </div>
        </section>
    </aside>

    <%-- ============ Giữa: khung vẽ ============ --%>
    <section class="org-card sm-stage-card">
        <div class="sm-canvas-bar">
            <span class="sm-canvas-title">Khung sơ đồ</span>
            <div class="sm-zoom">
                <button type="button" class="sm-icon-btn" id="zoomOut" aria-label="Thu nhỏ"><span class="material-symbols-outlined">remove</span></button>
                <span id="zoomLabel">100%</span>
                <button type="button" class="sm-icon-btn" id="zoomIn" aria-label="Phóng to"><span class="material-symbols-outlined">add</span></button>
                <button type="button" class="sm-icon-btn" id="zoomFit" aria-label="Vừa khung"><span class="material-symbols-outlined">fit_screen</span></button>
            </div>
        </div>
        <div class="sm-canvas-wrap" id="canvasWrap">
            <svg id="smSvg" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Sơ đồ ghế của sự kiện"></svg>
        </div>
        <div class="sm-legend" id="smLegend"></div>
        <p class="sm-hint sm-canvas-hint">
            <c:choose>
                <c:when test="${readOnly}">Nhấp vào một khu để xem thông tin chi tiết.</c:when>
                <c:otherwise>Kéo để di chuyển khu, kéo góc dưới phải để đổi kích thước (khu đứng, sân khấu). Phím mũi tên để dịch chuyển, Delete để xóa khu.</c:otherwise>
            </c:choose>
        </p>
    </section>

    <%-- ============ Phải: thuộc tính khu ============ --%>
    <aside class="sm-side">
        <section class="org-card sm-panel" id="propsEmpty">
            <h2><span class="material-symbols-outlined">tune</span> Thuộc tính khu</h2>
            <p class="sm-hint">Chọn một khu trên sơ đồ để xem hoặc chỉnh sửa.</p>
        </section>

        <section class="org-card sm-panel" id="propsPanel" hidden>
            <h2><span class="material-symbols-outlined">tune</span> Thuộc tính khu <span class="sm-type-pill" id="pType"></span></h2>

            <div class="sm-field">
                <label for="pName">Tên khu <span class="req">*</span></label>
                <input type="text" id="pName" class="lt-input" maxlength="100">
            </div>

            <div class="sm-field" id="fTicket">
                <label for="pTicket">Hạng vé (giá) <span class="req">*</span></label>
                <select id="pTicket" class="lt-input"></select>
            </div>

            <div id="fSeated">
                <div class="sm-two">
                    <div class="sm-field">
                        <label for="pRows">Số hàng</label>
                        <input type="number" id="pRows" class="lt-input" min="1" step="1">
                    </div>
                    <div class="sm-field">
                        <label for="pCols">Ghế mỗi hàng</label>
                        <input type="number" id="pCols" class="lt-input" min="1" step="1">
                    </div>
                </div>
                <label class="sm-check">
                    <input type="checkbox" id="pBlockMode">
                    <span>Chế độ bỏ ghế / tạo lối đi (nhấp hoặc kéo qua các ghế)</span>
                </label>
                <button type="button" class="btn-soft sm-full" id="pResetSeats">
                    <span class="material-symbols-outlined">restart_alt</span> Khôi phục tất cả ghế
                </button>
            </div>

            <div id="fStanding">
                <div class="sm-field">
                    <label for="pCapacity">Sức chứa (số người)</label>
                    <input type="number" id="pCapacity" class="lt-input" min="1" step="1">
                </div>
            </div>

            <div class="sm-info" id="pInfo"></div>

            <c:if test="${not readOnly}">
                <div class="sm-actions">
                    <button type="button" class="btn-soft" id="pDuplicate"><span class="material-symbols-outlined">content_copy</span> Nhân bản</button>
                    <button type="button" class="btn-soft sm-danger" id="pDelete"><span class="material-symbols-outlined">delete</span> Xóa khu</button>
                </div>
            </c:if>
        </section>
    </aside>
</div>
