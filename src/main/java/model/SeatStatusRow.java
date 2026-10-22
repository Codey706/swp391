package model;

/**
 * Một ghế của sự kiện (Event_Seats) kèm cờ "đã check-in" lấy từ Tickets. Chỉ
 * dùng để dựng trang Staff - Seat Status (chỉ xem).
 */
public class SeatStatusRow {

    private Integer zoneId;      // null: ghế chưa gắn khu (dữ liệu cũ)
    private String rowLabel;
    private int seatNumber;
    private String seatType;
    private String status;
    private boolean checkedIn;

    public Integer getZoneId() {
        return zoneId;
    }

    public void setZoneId(Integer zoneId) {
        this.zoneId = zoneId;
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

    public boolean isCheckedIn() {
        return checkedIn;
    }

    public void setCheckedIn(boolean checkedIn) {
        this.checkedIn = checkedIn;
    }
}
