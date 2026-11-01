package model;

import java.math.BigDecimal;
import utils.DateTimeUtils;

/**
 * Sự kiện hiển thị cho Customer khi chọn sự kiện để đặt vé: thêm giá thấp nhất
 * và số vé còn lại (chỉ dùng để hiển thị, không phải cột của bảng Events).
 */
public class BookableEvent extends Event {

    private BigDecimal minPrice;
    private int availableTickets;

    public BigDecimal getMinPrice() {
        return minPrice;
    }

    public void setMinPrice(BigDecimal minPrice) {
        this.minPrice = minPrice;
    }

    public int getAvailableTickets() {
        return availableTickets;
    }

    public void setAvailableTickets(int availableTickets) {
        this.availableTickets = availableTickets;
    }

    public boolean isSoldOut() {
        return availableTickets <= 0;
    }

    /** Thời gian bắt đầu đã định dạng dd/MM/yyyy HH:mm (JSP không format được LocalDateTime trực tiếp). */
    public String getStartTimeText() {
        return DateTimeUtils.formatDateTime(getStartTime());
    }

    public String getEndTimeText() {
        return DateTimeUtils.formatDateTime(getEndTime());
    }
}
