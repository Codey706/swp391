<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Trình thiết kế sơ đồ ghế (dùng chung cho trang /organizer/event/seatmap và bước 3 của form tạo sự kiện).
     Dữ liệu khởi tạo nằm trong <script id="smData"> của trang chứa; request attribute: readOnly, embedded. --%>
<div class="sm-workspace ${embedded ? 'sm-embedded' : ''}">

    <%-- ============ Cột trái: công cụ + hạng vé ============ --%>
    <aside class="sm-side">
        <section class="org-card sm-panel">
            <h2><i class="ph ph-ticket" aria-hidden="true"></i> Hạng vé &amp; giá</h2>
            <p class="sm-hint">Mỗi khu gán một hạng vé; màu của khu theo màu hạng vé. Số lượng vé tự đồng bộ theo tổng chỗ của các khu.</p>
            <div id="smTicketList" class="sm-ticket-list"></div>
            <c:if test="${not readOnly}">
                <button type="button" class="btn-soft sm-full" id="smAddTicketBtn">
                    <i class="ph ph-plus" aria-hidden="true"></i> Thêm hạng vé
                </button>
            </c:if>
        </section>

        <section class="org-card sm-panel">
            <h2><i class="ph ph-chart-line-up" aria-hidden="true"></i> Tổng quan</h2>
            <div class="sm-stats">
                <div><span id="statZones">0</span><small>Khu</small></div>
                <div><span id="statSeats">0</span><small>Tổng chỗ</small></div>
                <div><span id="statVenue">-</span><small>Sức chứa địa điểm</small></div>
            </div>
            <div class="sm-capbar"><div id="capBar"></div></div>
            <div id="issueBox" class="sm-issues" hidden>
                <b><i class="ph ph-warning" aria-hidden="true"></i> Cần chỉnh sửa (<span id="issueCount">0</span>)</b>
                <ul id="issueList"></ul>
            </div>
        </section>
    </aside>

    <%-- ============ Giữa: khung vẽ ============ --%>
    <section class="org-card sm-stage-card">
        <div class="sm-canvas-bar">
            <span class="sm-canvas-title">Khung sơ đồ</span>
            <div class="sm-zoom">
                <button type="button" class="sm-icon-btn" id="zoomOut" aria-label="Thu nhỏ"><i class="ph ph-minus" aria-hidden="true"></i></button>
                <span id="zoomLabel">100%</span>
                <button type="button" class="sm-icon-btn" id="zoomIn" aria-label="Phóng to"><i class="ph ph-plus" aria-hidden="true"></i></button>
                <button type="button" class="sm-icon-btn" id="zoomFit" aria-label="Về 100% (vừa khung)" title="Về 100% (vừa khung)"><i class="ph ph-frame-corners" aria-hidden="true"></i></button>
                <button type="button" class="sm-icon-btn sm-fs-btn" id="smFullscreen" aria-pressed="false" aria-label="Toàn màn hình" title="Toàn màn hình">
                    <i class="ph ph-corners-out" aria-hidden="true"></i><span class="sm-fs-text">Thoát toàn màn hình</span>
                </button>
            </div>
        </div>
        <%-- Thanh công cụ ngang ngay trên khung vẽ: thêm khu / áp mẫu sơ đồ --%>
        <c:if test="${not readOnly}">
            <div class="sm-toolbar" role="toolbar" aria-label="Thêm khu vào sơ đồ">
                <div class="sm-toolbar-group">
                    <span class="sm-toolbar-label"><i class="ph ph-plus-square" aria-hidden="true"></i> Thêm khu</span>
                    <button type="button" class="sm-tool" data-add="STAGE" id="addStage" title="Thêm sân khấu (mỗi sơ đồ tối đa 1)">
                        <i class="ph ph-mask-happy" aria-hidden="true"></i> Sân khấu
                    </button>
                    <button type="button" class="sm-tool" data-add="SEATED" title="Thêm khu ghế ngồi đánh số">
                        <i class="ph ph-armchair" aria-hidden="true"></i> Khu ngồi
                    </button>
                    <button type="button" class="sm-tool" data-add="STANDING" title="Thêm khu đứng tự do">
                        <i class="ph ph-users-three" aria-hidden="true"></i> Khu đứng
                    </button>
                </div>
                <div class="sm-toolbar-group">
                    <span class="sm-toolbar-label"><i class="ph ph-layout" aria-hidden="true"></i> Mẫu có sẵn</span>
                    <button type="button" class="sm-tool sm-tool-soft" data-preset="hall">Hội trường / Nhà hát</button>
                    <button type="button" class="sm-tool sm-tool-soft" data-preset="concert">Concert sân khấu</button>
                </div>
            </div>
        </c:if>
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
            <h2><i class="ph ph-sliders-horizontal" aria-hidden="true"></i> Thuộc tính khu</h2>
            <p class="sm-hint">Chọn một khu trên sơ đồ để xem hoặc chỉnh sửa.</p>
        </section>

        <section class="org-card sm-panel" id="propsPanel" hidden>
            <h2><i class="ph ph-sliders-horizontal" aria-hidden="true"></i> Thuộc tính khu <span class="sm-type-pill" id="pType"></span></h2>

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
                    <i class="ph ph-arrow-clockwise" aria-hidden="true"></i> Khôi phục tất cả ghế
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
                    <button type="button" class="btn-soft" id="pDuplicate"><i class="ph ph-copy" aria-hidden="true"></i> Nhân bản</button>
                    <button type="button" class="btn-soft sm-danger" id="pDelete"><i class="ph ph-trash" aria-hidden="true"></i> Xóa khu</button>
                </div>
            </c:if>
        </section>
    </aside>
</div>
