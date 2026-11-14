
package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Ticket {

    private int ticketId;
    private int orderId;
    private String ticketCode;
    private String qrCode;
    private String ticketStatus;
    private String eventName;
    private String venueName;
    private String ticketName;
    private String seatLabel;
    private LocalDateTime eventStartTime;
    private LocalDateTime eventEndTime;

    public Ticket() {
    }

    public Ticket(int ticketId, int orderId, String ticketCode,
            String qrCode, String ticketStatus, String eventName,
            String venueName, String ticketName, String seatLabel,
            LocalDateTime eventStartTime) {

        this.ticketId = ticketId;
        this.orderId = orderId;
        this.ticketCode = ticketCode;
        this.qrCode = qrCode;
        this.ticketStatus = ticketStatus;
        this.eventName = eventName;
        this.venueName = venueName;
        this.ticketName = ticketName;
        this.seatLabel = seatLabel;
        this.eventStartTime = eventStartTime;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getTicketCode() {
        return ticketCode;
    }

    public void setTicketCode(String ticketCode) {
        this.ticketCode = ticketCode;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public String getTicketStatus() {
        return ticketStatus;
    }

    public void setTicketStatus(String ticketStatus) {
        this.ticketStatus = ticketStatus;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getVenueName() {
        return venueName;
    }

    public void setVenueName(String venueName) {
        this.venueName = venueName;
    }

    public String getTicketName() {
        return ticketName;
    }

    public void setTicketName(String ticketName) {
        this.ticketName = ticketName;
    }

    public String getSeatLabel() {
        return seatLabel;
    }

    public void setSeatLabel(String seatLabel) {
        this.seatLabel = seatLabel;
    }

    public LocalDateTime getEventStartTime() {
        return eventStartTime;
    }

    public void setEventStartTime(LocalDateTime eventStartTime) {
        this.eventStartTime = eventStartTime;
    }

    /**
     * Hiển thị thời gian bắt đầu sự kiện.
     */
    public String getEventStartLabel() {
        return eventStartTime == null ? ""
                : eventStartTime.format(
                        DateTimeFormatter.ofPattern("HH:mm '·' dd/MM/yyyy"));
    }

    public LocalDateTime getEventEndTime() {
        return eventEndTime;
    }

    public void setEventEndTime(LocalDateTime eventEndTime) {
        this.eventEndTime = eventEndTime;
    }

    public boolean isExpired() {
        return eventEndTime != null
                && !LocalDateTime.now().isBefore(eventEndTime);
    }
}
