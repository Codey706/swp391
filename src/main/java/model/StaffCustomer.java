package model;

/**
 * Khách hàng có vé trong các sự kiện được phân công cho Staff. Số vé luôn tính
 * trong phạm vi sự kiện của Staff: activeTickets = vé còn hiệu lực (Valid +
 * CheckedIn), checkedIn = vé đã check-in, cancelled = vé đã hủy.
 */
public class StaffCustomer {

    public static final String CHECKED_IN = "CHECKED_IN";
    public static final String NOT_CHECKED_IN = "NOT_CHECKED_IN";
    public static final String PARTIAL = "PARTIAL";
    public static final String CANCELLED = "CANCELLED";

    private int userId;
    private String fullName;
    private String phone;
    private String email;
    private String address;
    private int activeTickets;
    private int checkedIn;
    private int cancelled;
    private int eventCount;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getActiveTickets() {
        return activeTickets;
    }

    public void setActiveTickets(int activeTickets) {
        this.activeTickets = activeTickets;
    }

    public int getCheckedIn() {
        return checkedIn;
    }

    public void setCheckedIn(int checkedIn) {
        this.checkedIn = checkedIn;
    }

    public int getCancelled() {
        return cancelled;
    }

    public void setCancelled(int cancelled) {
        this.cancelled = cancelled;
    }

    public int getEventCount() {
        return eventCount;
    }

    public void setEventCount(int eventCount) {
        this.eventCount = eventCount;
    }

    /**
     * Vé hiệu lực chưa check-in.
     */
    public int getNotCheckedIn() {
        return activeTickets - checkedIn;
    }

    /**
     * Trạng thái check-in của khách: không có vé hiệu lực -> CANCELLED;
     * check-in đủ -> CHECKED_IN; chưa check-in vé nào -> NOT_CHECKED_IN; còn
     * lại -> PARTIAL.
     */
    public String getStatusKey() {
        return statusOf(activeTickets, checkedIn);
    }

    public static String statusOf(int active, int checkedIn) {
        if (active <= 0) {
            return CANCELLED;
        }
        if (checkedIn >= active) {
            return CHECKED_IN;
        }
        return checkedIn == 0 ? NOT_CHECKED_IN : PARTIAL;
    }

    /**
     * Chữ cái đầu của hai từ đầu tiên trong họ tên (vd. "Nguyễn Thị Mai" ->
     * "NT").
     */
    public String getInitials() {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "?";
        }
        String[] parts = fullName.trim().split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.length && i < 2; i++) {
            sb.append(parts[i].substring(0, parts[i].offsetByCodePoints(0, 1)));
        }
        return sb.toString().toUpperCase();
    }
}
