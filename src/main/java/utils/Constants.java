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

    // Booking: Select Event
    public static final int BOOKING_EVENT_PAGE_SIZE = 9;
    public static final int MAX_TICKETS_PER_ORDER = 10;
    public static final String SESSION_BOOKING_SELECTION = "bookingSelection";
    public static final String BOOKING_CHECKOUT_URL = "/booking/checkout";

    // Manage My Organizer Profile (khớp Users: full_name NVARCHAR(100), email VARCHAR(255), address NVARCHAR(255))
    public static final String SESSION_ORGANIZER_PROFILE_CSRF = "organizerProfileCsrf";
    public static final String SESSION_ORGANIZER_PROFILE_SUCCESS = "organizerProfileSuccess";
    public static final int PROFILE_FULL_NAME_MIN_LENGTH = 2;
    public static final int PROFILE_FULL_NAME_MAX_LENGTH = 100;
    public static final int PROFILE_EMAIL_MAX_LENGTH = 255;
    public static final int PROFILE_ADDRESS_MAX_LENGTH = 255;

    // Seat map designer (Organizer)
    public static final String SESSION_SEATMAP_CSRF = "seatMapCsrf";
    public static final int SEATMAP_CANVAS_WIDTH = 1200;
    public static final int SEATMAP_CANVAS_HEIGHT = 800;
    public static final int SEATMAP_MAX_ZONES = 40;
    public static final int SEATMAP_MAX_ROWS = 26;            // A..Z
    public static final int SEATMAP_MAX_SEATS_PER_ROW = 40;
    public static final int SEATMAP_MIN_ZONE_SIZE = 40;
    public static final int SEATMAP_ZONE_NAME_MAX_LENGTH = 100;

    // Manage My Staff Profile (Users: full_name NVARCHAR(100), email VARCHAR(255), address NVARCHAR(255))
    public static final String ROLE_STAFF = "Staff";
    public static final String SESSION_STAFF_PROFILE_CSRF = "staffProfileCsrf";
    public static final String SESSION_STAFF_PROFILE_SUCCESS = "staffProfileSuccess";
    public static final String EVENT_STAFF_ACTIVE = "ACTIVE";
    public static final int STAFF_EVENT_PAGE_SIZE = 5;
    public static final String TICKET_CANCELLED = "Cancelled";
    public static final int STAFF_CUSTOMER_PAGE_SIZE = 8;
    public static final int STAFF_CUSTOMER_TICKET_LIMIT = 50;

    // Hồ sơ mở rộng của Organizer (khớp Organizer_Profiles)
    public static final int PROFILE_SUMMARY_MAX_LENGTH = 300;
    public static final int PROFILE_LEGAL_REP_MIN_LENGTH = 2;
    public static final int PROFILE_LEGAL_REP_MAX_LENGTH = 150;
    public static final int PROFILE_URL_MAX_LENGTH = 500;
    // Kích thước hiển thị (%) của ảnh bìa / logo trong khung; 100 = mặc định. Khớp data-min/data-max trong profile.jsp
    public static final int PROFILE_SCALE_DEFAULT = 100;
    public static final int PROFILE_COVER_SCALE_MIN = 100;
    public static final int PROFILE_COVER_SCALE_MAX = 200;
    public static final int PROFILE_LOGO_SCALE_MIN = 50;
    public static final int PROFILE_LOGO_SCALE_MAX = 200;
    public static final int PROFILE_BANK_NAME_MAX_LENGTH = 150;
    public static final int PROFILE_BANK_HOLDER_MAX_LENGTH = 150;
    public static final int PROFILE_DOC_NAME_MAX_LENGTH = 200;
    public static final long PROFILE_IMAGE_MAX_SIZE = 5L * 1024 * 1024;
    public static final long PROFILE_DOCUMENT_MAX_SIZE = 5L * 1024 * 1024;
    public static final String PROFILE_VERIFIED = "VERIFIED";
    public static final String DOC_PENDING = "PENDING";
    public static final String DOC_APPROVED = "APPROVED";
    // Tài liệu pháp lý lưu ngoài thư mục web (không public): ${user.home}/ltm-uploads/organizer-docs
    public static final String PRIVATE_DOC_DIR_NAME = "ltm-uploads/organizer-docs";

    // Book Tickets 
    public static final int BOOKING_MAX_TICKETS_PER_ORDER = 10;
    public static final int BOOKING_HOLD_SECONDS = 600;
    public static final int VOUCHER_CODE_MAX_LENGTH = 50;

    // Event_Seats.status
    public static final String SEAT_AVAILABLE = "Available";
    public static final String SEAT_HELD = "Held";
    public static final String SEAT_SOLD = "Sold";

    // Tickets.ticket_status
    public static final String TICKET_CHECKED_IN = "CheckedIn";

    // Organizer dashboard
    public static final int DASHBOARD_RECENT_EVENTS = 5;
    public static final int DASHBOARD_RECENT_ORDERS = 5;
    public static final int DASHBOARD_CHART_DAYS = 90;   // biểu đồ doanh thu: 7/30/90 ngày
    public static final int DASHBOARD_PERIOD_DAYS = 30;  // kỳ so sánh cho thẻ thống kê

    // Staff - Seat Status (chỉ xem)
    public static final String BUSINESS_ZONE_ID = "Asia/Ho_Chi_Minh";   // múi giờ nghiệp vụ để xác định "hôm nay"
    public static final int STAFF_SEAT_MAX_EVENTS = 20;                  // số sự kiện tối đa trong ô chọn sự kiện
    public static final double STANDING_NEAR_FULL_RATIO = 0.8;           // khu đứng "Gần đầy" khi số người đã vào >= 80% sức chứa

}
