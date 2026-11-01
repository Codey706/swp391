package model;

import utils.Constants;

/**
 * Số liệu của một khu trên trang Staff - Seat Status.
 * Khu ngồi: đếm theo Event_Seats. Khu đứng: sức chứa lấy từ Event_Zones, số vé đã bán
 * và số người đã check-in lấy từ Tickets (null = không xác định riêng cho khu này).
 */
public class SeatZoneStat {

    public static final String STATUS_OPEN = "OPEN";
    public static final String STATUS_NEAR_FULL = "NEAR_FULL";
    public static final String STATUS_FULL = "FULL";
    public static final String STATUS_UNKNOWN = "UNKNOWN";
    public static final String STATUS_NO_CAPACITY = "NO_CAPACITY";

    private int zoneId;
    private String zoneName;
    private String zoneType;
    private int capacity;

    // Khu ngồi
    private int totalSeats;
    private int availableSeats;
    private int heldSeats;
    private int bookedSeats;   // Sold, chưa check-in
    private int usedSeats;     // Sold và đã check-in

    // Khu đứng (null = không tách được số liệu riêng từng khu)
    private Integer ticketsSold;
    private Integer ticketsCheckedIn;

    public boolean isStanding() {
        return EventZone.TYPE_STANDING.equals(zoneType);
    }

    /** Ghế đã đặt/đã sử dụng (không gồm ghế đang giữ chỗ). */
    public int getSoldSeats() {
        return bookedSeats + usedSeats;
    }

    /** Khu ngồi: % ghế đã đặt/sử dụng trên tổng ghế. */
    public int getSeatPercent() {
        return totalSeats <= 0 ? 0 : Math.min(100, getSoldSeats() * 100 / totalSeats);
    }

    /** Khu đứng: số chỗ còn lại để vào = sức chứa - số đã check-in, không âm; null nếu không xác định. */
    public Integer getRemaining() {
        if (ticketsCheckedIn == null) {
            return null;
        }
        return Math.max(0, capacity - ticketsCheckedIn);
    }

    /** Khu đứng: % sức chứa đã vào. */
    public int getStandingPercent() {
        if (ticketsCheckedIn == null || capacity <= 0) {
            return 0;
        }
        return Math.min(100, (int) Math.round(ticketsCheckedIn * 100.0 / capacity));
    }

    public String getStatusKey() {
        if (capacity <= 0) {
            return STATUS_NO_CAPACITY;
        }
        if (ticketsCheckedIn == null) {
            return STATUS_UNKNOWN;
        }
        if (ticketsCheckedIn >= capacity) {
            return STATUS_FULL;
        }
        if (ticketsCheckedIn >= capacity * Constants.STANDING_NEAR_FULL_RATIO) {
            return STATUS_NEAR_FULL;
        }
        return STATUS_OPEN;
    }

    public int getZoneId() {
        return zoneId;
    }

    public void setZoneId(int zoneId) {
        this.zoneId = zoneId;
    }

    public String getZoneName() {
        return zoneName;
    }

    public void setZoneName(String zoneName) {
        this.zoneName = zoneName;
    }

    public String getZoneType() {
        return zoneType;
    }

    public void setZoneType(String zoneType) {
        this.zoneType = zoneType;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public int getAvailableSeats() {
        return availableSeats;
    }

    public void setAvailableSeats(int availableSeats) {
        this.availableSeats = availableSeats;
    }

    public int getHeldSeats() {
        return heldSeats;
    }

    public void setHeldSeats(int heldSeats) {
        this.heldSeats = heldSeats;
    }

    public int getBookedSeats() {
        return bookedSeats;
    }

    public void setBookedSeats(int bookedSeats) {
        this.bookedSeats = bookedSeats;
    }

    public int getUsedSeats() {
        return usedSeats;
    }

    public void setUsedSeats(int usedSeats) {
        this.usedSeats = usedSeats;
    }

    public Integer getTicketsSold() {
        return ticketsSold;
    }

    public void setTicketsSold(Integer ticketsSold) {
        this.ticketsSold = ticketsSold;
    }

    public Integer getTicketsCheckedIn() {
        return ticketsCheckedIn;
    }

    public void setTicketsCheckedIn(Integer ticketsCheckedIn) {
        this.ticketsCheckedIn = ticketsCheckedIn;
    }
}
