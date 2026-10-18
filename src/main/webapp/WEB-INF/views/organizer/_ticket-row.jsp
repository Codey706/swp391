<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Một dòng hạng vé của form tạo sự kiện. Dùng cho cả dòng đã có dữ liệu (requestScope.row) và <template> dòng mới (row rỗng). --%>
<div class="tk-row is-editing" data-ticket-row>
    <div class="tk-row-head">
        <span class="tk-badge" data-ticket-badge>Hạng vé</span>
        <button type="button" class="tk-remove" data-ticket-remove aria-label="Xóa hạng vé">
            <span class="material-symbols-outlined">delete</span>
        </button>
    </div>
    <div class="tk-fields">
        <div class="tk-f">
            <label>Tên hạng vé <span class="req">*</span></label>
            <input type="text" name="ticketName" maxlength="100"
                   class="lt-input ${not empty row.error ? 'is-invalid' : ''}"
                   placeholder="Ví dụ: VIP - Fanzone đứng"
                   value="<c:out value='${row.ticketName}'/>">
        </div>
        <div class="tk-f">
            <label>Giá vé <span class="req">*</span></label>
            <div class="tk-unit">
                <input type="number" name="ticketPrice" min="0" max="100000000" step="1000"
                       class="lt-input ${not empty row.error ? 'is-invalid' : ''}"
                       placeholder="0"
                       value="${row.price != null ? row.price.toPlainString() : ''}">
                <span>VNĐ</span>
            </div>
        </div>
        <div class="tk-f">
            <label>Số lượng <span class="req">*</span></label>
            <div class="tk-unit">
                <input type="number" name="ticketQuantity" min="1" max="1000000" step="1"
                       class="lt-input ${not empty row.error ? 'is-invalid' : ''}"
                       placeholder="100"
                       value="${row.quantity > 0 ? row.quantity : ''}">
                <span>vé</span>
            </div>
        </div>
        <div class="tk-f tk-desc">
            <label>Mô tả quyền lợi (không bắt buộc)</label>
            <input type="text" name="ticketDescription" maxlength="500" class="lt-input"
                   placeholder="Ví dụ: Ghế ngồi sát sân khấu, kèm quà tặng"
                   value="<c:out value='${row.description}'/>">
        </div>
    </div>
    <div class="tk-error" data-ticket-error><c:out value="${row.error}"/></div>
</div>
