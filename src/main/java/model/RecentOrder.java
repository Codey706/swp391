package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Một dòng đơn hàng hiển thị ở trang tổng quan Organizer (gộp theo đơn + sự kiện).
 */
public class RecentOrder {

    private int orderId;
    private String orderCode;
    private String customerName;
    private String eventName;
    private int quantity;
    private BigDecimal amount = BigDecimal.ZERO;
    private String status;
    private LocalDateTime createdAt;

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getEventName() { return eventName; }
    public void setEventName(String eventName) { this.eventName = eventName; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
