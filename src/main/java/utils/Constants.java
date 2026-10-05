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

    // View Event List
    public static final int EVENT_PAGE_SIZE = 10;
}
