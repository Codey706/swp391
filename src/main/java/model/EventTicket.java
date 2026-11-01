package model;

import java.math.BigDecimal;

/**
 * Khớp bảng Event_Tickets (hạng vé của một sự kiện).
 */
public class EventTicket {

    private int eventTicketId;
    private int eventId;
    private String ticketName;
    private String description;
    private BigDecimal price;
    private int quantity;
    private int availableQuantity;
    private String status;

    // Chỉ dùng để hiển thị lại form khi validate lỗi, không phải cột của bảng
    private String error;

    public EventTicket() {
    }

    public int getEventTicketId() {
        return eventTicketId;
    }

    public void setEventTicketId(int eventTicketId) {
        this.eventTicketId = eventTicketId;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getTicketName() {
        return ticketName;
    }

    public void setTicketName(String ticketName) {
        this.ticketName = ticketName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getAvailableQuantity() {
        return availableQuantity;
    }

    public void setAvailableQuantity(int availableQuantity) {
        this.availableQuantity = availableQuantity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
}
