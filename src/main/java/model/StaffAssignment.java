package model;

import java.time.LocalDateTime;

/**
 * Một sự kiện được phân công cho Staff (Event_Staff + Events + Categories +
 * Venues), kèm số liệu vé của sự kiện. timeStatus được tính theo thời gian thực
 * của sự kiện: UPCOMING, ONGOING, ENDED hoặc CANCELLED.
 */
public class StaffAssignment {

    private int eventId;
    private String eventName;
    private String eventImage;
    private String description;
    private String categoryName;
    private String venueName;
    private String venueAddress;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private String timeStatus;
    private LocalDateTime assignedAt;
    private int ticketTotal;
    private int ticketIssued;
    private int checkedIn;

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getEventImage() {
        return eventImage;
    }

    public void setEventImage(String eventImage) {
        this.eventImage = eventImage;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getVenueName() {
        return venueName;
    }

    public void setVenueName(String venueName) {
        this.venueName = venueName;
    }

    public String getVenueAddress() {
        return venueAddress;
    }

    public void setVenueAddress(String venueAddress) {
        this.venueAddress = venueAddress;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTimeStatus() {
        return timeStatus;
    }

    public void setTimeStatus(String timeStatus) {
        this.timeStatus = timeStatus;
    }

    public LocalDateTime getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(LocalDateTime assignedAt) {
        this.assignedAt = assignedAt;
    }

    public int getTicketTotal() {
        return ticketTotal;
    }

    public void setTicketTotal(int ticketTotal) {
        this.ticketTotal = ticketTotal;
    }

    public int getTicketIssued() {
        return ticketIssued;
    }

    public void setTicketIssued(int ticketIssued) {
        this.ticketIssued = ticketIssued;
    }

    public int getCheckedIn() {
        return checkedIn;
    }

    public void setCheckedIn(int checkedIn) {
        this.checkedIn = checkedIn;
    }
}
