package utils;

public final class Constants {

    private Constants() {
    }

    // Session / Role (giá trị role khớp cột Users.role)
    public static final String SESSION_USER = "user";
    public static final String ROLE_ORGANIZER = "Organizer";
    public static final String ROLE_ADMIN = "Admin";

    // Status chung cho Categories / Venues
    public static final String STATUS_ACTIVE = "ACTIVE";

    // Events.status
    public static final String EVENT_DRAFT = "DRAFT";
    public static final String EVENT_PENDING_APPROVAL = "PENDING_APPROVAL";
    public static final String EVENT_ACTIVE = "ACTIVE";
    public static final String EVENT_REJECTED = "REJECTED";
    public static final String EVENT_CANCELLED = "CANCELLED";

    // Event validation limits (khớp độ dài cột trong DB: event_name NVARCHAR(200))
    public static final int EVENT_NAME_MIN_LENGTH = 5;
    public static final int EVENT_NAME_MAX_LENGTH = 200;
    public static final int EVENT_DESCRIPTION_MIN_LENGTH = 20;
    public static final int EVENT_DESCRIPTION_MAX_LENGTH = 5000;

    // Upload ảnh sự kiện
    public static final long EVENT_IMAGE_MAX_SIZE = 5L * 1024 * 1024;
    public static final String UPLOAD_DIR = "/assets/uploads";

    // Hạng vé (Event_Tickets) khi tạo sự kiện: ticket_name NVARCHAR(100), description NVARCHAR(500)
    public static final String TICKET_ACTIVE = "ACTIVE";
    public static final int TICKET_MAX_TYPES = 10;
    public static final int TICKET_NAME_MAX_LENGTH = 100;
    public static final int TICKET_DESCRIPTION_MAX_LENGTH = 500;
    public static final long TICKET_MAX_PRICE = 100_000_000L;
    public static final int TICKET_MAX_QUANTITY = 1_000_000;

    // View Event List
    public static final int EVENT_PAGE_SIZE = 10;

    // Role Customer (khớp Users.role)
    public static final String ROLE_CUSTOMER = "Customer";

    // Orders.status
    public static final String ORDER_PENDING = "Pending";
    public static final String ORDER_PAID = "Paid";
    public static final String ORDER_CANCELLED = "Cancelled";

    // View Booking History
    public static final int BOOKING_PAGE_SIZE = 10;
    public static final int BOOKING_KEYWORD_MAX_LENGTH = 50;
}
