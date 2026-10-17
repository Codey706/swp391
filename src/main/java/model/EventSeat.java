package model;

/** Khớp bảng Event_Seats: ghế của một sự kiện. */
public class EventSeat {

    private int eventSeatId;
    private int eventId;
    private String rowLabel;
    private int seatNumber;
    private String seatLabel;
    private String seatType;
    private String status;

    public int getEventSeatId() {
        return eventSeatId;
    }

    public void setEventSeatId(int eventSeatId) {
        this.eventSeatId = eventSeatId;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getRowLabel() {
        return rowLabel;
    }

    public void setRowLabel(String rowLabel) {
        this.rowLabel = rowLabel;
    }

    public int getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(int seatNumber) {
        this.seatNumber = seatNumber;
    }

    public String getSeatLabel() {
        return seatLabel;
    }

    public void setSeatLabel(String seatLabel) {
        this.seatLabel = seatLabel;
    }

    public String getSeatType() {
        return seatType;
    }

    public void setSeatType(String seatType) {
        this.seatType = seatType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

  
}
