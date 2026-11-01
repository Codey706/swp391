package model;

/**
 * Khớp bảng Event_Zones: một khu trên sơ đồ ghế của sự kiện.
 * Cũng là DTO để đọc/ghi JSON giữa trình thiết kế (seatmap.js) và server,
 * nên tên field phải trùng tên khóa JSON.
 */
public class EventZone {

    public static final String TYPE_SEATED = "SEATED";
    public static final String TYPE_STANDING = "STANDING";
    public static final String TYPE_STAGE = "STAGE";

    private int zoneId;
    private Integer eventTicketId;
    private String zoneName;
    private String zoneType;
    private String color;
    private int posX;
    private int posY;
    private int width;
    private int height;
    private int rowCount;
    private int seatsPerRow;
    private int capacity;
    private String blockedSeats; // "r:c,r:c" (chỉ số từ 0); rỗng nếu không có
    private int sortOrder;

    // Chỉ dùng khi lưu: mã ASCII ngắn của khu, dùng làm tiền tố nhãn ghế (VD: VIPA-A05)
    private transient String code;

    public boolean isSeated() {
        return TYPE_SEATED.equals(zoneType);
    }

    public boolean isStanding() {
        return TYPE_STANDING.equals(zoneType);
    }

    public boolean isStage() {
        return TYPE_STAGE.equals(zoneType);
    }

    public int getZoneId() {
        return zoneId;
    }

    public void setZoneId(int zoneId) {
        this.zoneId = zoneId;
    }

    public Integer getEventTicketId() {
        return eventTicketId;
    }

    public void setEventTicketId(Integer eventTicketId) {
        this.eventTicketId = eventTicketId;
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

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public int getPosX() {
        return posX;
    }

    public void setPosX(int posX) {
        this.posX = posX;
    }

    public int getPosY() {
        return posY;
    }

    public void setPosY(int posY) {
        this.posY = posY;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int width) {
        this.width = width;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public int getRowCount() {
        return rowCount;
    }

    public void setRowCount(int rowCount) {
        this.rowCount = rowCount;
    }

    public int getSeatsPerRow() {
        return seatsPerRow;
    }

    public void setSeatsPerRow(int seatsPerRow) {
        this.seatsPerRow = seatsPerRow;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getBlockedSeats() {
        return blockedSeats;
    }

    public void setBlockedSeats(String blockedSeats) {
        this.blockedSeats = blockedSeats;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    /** Tập ghế bị bỏ trống, mỗi phần tử dạng "r:c" (chỉ số hàng/cột từ 0). */
    public java.util.Set<String> blockedSet() {
        java.util.Set<String> set = new java.util.LinkedHashSet<>();
        if (blockedSeats != null) {
            for (String part : blockedSeats.split(",")) {
                if (!part.trim().isEmpty()) {
                    set.add(part.trim());
                }
            }
        }
        return set;
    }

    /** 0 -> A, 1 -> B, ... 25 -> Z (tối đa 26 hàng mỗi khu). */
    public static String rowLetter(int index) {
        return String.valueOf((char) ('A' + index));
    }
}
