-- =========================================================
-- SYSTEM: Light Ticket Management (LTM)
-- SCRIPT: CREATE DATABASE & INSERT DEMO DATA (16 TABLES)
-- =========================================================

USE master;
GO

-- Xóa database cũ nếu đã tồn tại
IF DB_ID('LightTicketDB') IS NOT NULL
BEGIN
    ALTER DATABASE LightTicketDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LightTicketDB;
END
GO

-- Tạo database mới
CREATE DATABASE LightTicketDB;
GO

-- Sử dụng database mới
USE LightTicketDB;
GO

-- 1. USERS TABLE
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address NVARCHAR(255),
    role VARCHAR(20) NOT NULL, -- Customer, Staff, Organizer, Admin
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 2. CATEGORIES TABLE
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 3. VENUES TABLE
CREATE TABLE Venues (
    venue_id INT IDENTITY(1,1) PRIMARY KEY,
    venue_name NVARCHAR(200) NOT NULL,
    address NVARCHAR(500) NOT NULL,
    description NVARCHAR(1000),
    capacity INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 4. SEAT MAPS TABLE
CREATE TABLE Seat_Maps (
    seat_map_id INT IDENTITY(1,1) PRIMARY KEY,
    venue_id INT NOT NULL FOREIGN KEY REFERENCES Venues(venue_id),
    map_name NVARCHAR(150) NOT NULL,
    description NVARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 5. SEATS TABLE
CREATE TABLE Seats (
    seat_id INT IDENTITY(1,1) PRIMARY KEY,
    seat_map_id INT NOT NULL FOREIGN KEY REFERENCES Seat_Maps(seat_map_id),
    row_label VARCHAR(20) NOT NULL,
    seat_number INT NOT NULL,
    seat_label VARCHAR(50) NOT NULL,
    seat_type VARCHAR(30) NOT NULL, -- VIP, Standard
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

-- 6. EVENTS TABLE
CREATE TABLE Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    organizer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    category_id INT NOT NULL FOREIGN KEY REFERENCES Categories(category_id),
    venue_id INT NOT NULL FOREIGN KEY REFERENCES Venues(venue_id),
    event_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    event_image VARCHAR(500),
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2 NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    cancellation_reason NVARCHAR(1000),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 7. EVENT SEATS TABLE
CREATE TABLE Event_Seats (
    event_seat_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    source_seat_id INT NOT NULL FOREIGN KEY REFERENCES Seats(seat_id),
    row_label VARCHAR(20) NOT NULL,
    seat_number INT NOT NULL,
    seat_label VARCHAR(50) NOT NULL,
    seat_type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Available' -- Available, Held, Sold
);

-- 8. EVENT TICKETS TABLE
CREATE TABLE Event_Tickets (
    event_ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    ticket_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500),
    price DECIMAL(18,2) NOT NULL,
    quantity INT NOT NULL,
    available_quantity INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 9. EVENT STAFF TABLE
CREATE TABLE Event_Staff (
    event_staff_id INT IDENTITY(1,1) PRIMARY KEY,
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    staff_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    assigned_at DATETIME2 DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

-- 10. VOUCHERS TABLE
CREATE TABLE Vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    voucher_code VARCHAR(50) NOT NULL UNIQUE,
    voucher_name NVARCHAR(150) NOT NULL,
    discount_type VARCHAR(20) NOT NULL, -- Percentage, Fixed
    discount_value DECIMAL(18,2) NOT NULL,
    min_order_amount DECIMAL(18,2) DEFAULT 0,
    max_discount_amount DECIMAL(18,2),
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2 NOT NULL,
    usage_limit INT NOT NULL,
    used_count INT DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 11. ORDERS TABLE
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    voucher_id INT NULL FOREIGN KEY REFERENCES Vouchers(voucher_id),
    order_code VARCHAR(50) NOT NULL UNIQUE,
    total_amount DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) DEFAULT 0,
    final_amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending', -- Pending, Paid, Cancelled
    hold_started_at DATETIME2,
    hold_expired_at DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 12. ORDER DETAILS TABLE
CREATE TABLE Order_Details (
    order_detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
    event_ticket_id INT NOT NULL FOREIGN KEY REFERENCES Event_Tickets(event_ticket_id),
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL
);

-- 13. ORDER SEATS TABLE
CREATE TABLE Order_Seats (
    order_seat_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
    event_seat_id INT NOT NULL FOREIGN KEY REFERENCES Event_Seats(event_seat_id),
    created_at DATETIME2 DEFAULT GETDATE()
);

-- 14. PAYMENTS TABLE
CREATE TABLE Payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES Orders(order_id),
    payment_method VARCHAR(30) NOT NULL, -- VNPAY
    transaction_code VARCHAR(100),
    amount DECIMAL(18,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Success',
    paid_at DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- 15. TICKETS TABLE
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    order_detail_id INT NOT NULL FOREIGN KEY REFERENCES Order_Details(order_detail_id),
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    event_seat_id INT NULL FOREIGN KEY REFERENCES Event_Seats(event_seat_id),
    ticket_code VARCHAR(100) NOT NULL UNIQUE,
    qr_code VARCHAR(500) NOT NULL,
    ticket_status VARCHAR(30) NOT NULL DEFAULT 'Valid', -- Valid, CheckedIn, Cancelled
    check_in_time DATETIME2 NULL,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- 16. REVIEWS TABLE
CREATE TABLE Reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    ticket_id INT NOT NULL FOREIGN KEY REFERENCES Tickets(ticket_id),
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(1000),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INT DEFAULT 0,
    locked_until DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);
GO

-- =========================================================
-- INSERT DEMO DATA (2 RECORDS PER TABLE)
-- =========================================================

-- 1. Users
INSERT INTO Users (username, email, password, full_name, phone, address, role, status)
VALUES 
('organizer01', 'organizer1@ltm.vn', '$2a$12$bASvB9btHled4bxAPKOOp.AKEseDaK0qZ0zb2dWuywMednVxhQDjm', N'Mây Lang Thang Production', '0901234567', N'Đà Lạt, Lâm Đồng', 'Organizer', 'ACTIVE'),
('admin01', 'admin1@ltm.vn', '$2a$12$bASvB9btHled4bxAPKOOp.AKEseDaK0qZ0zb2dWuywMednVxhQDjm', N'Nguyễn Văn C', '0903434567', N'Cần Thơ', 'Admin', 'ACTIVE'),
('staff01', 'staff1@ltm.vn', '$2a$12$bASvB9btHled4bxAPKOOp.AKEseDaK0qZ0zb2dWuywMednVxhQDjm', N'Nguyễn Văn B', '0561434567', N'Cần Thơ', 'Staff', 'ACTIVE'),
('customer01', 'customer1@gmail.com', '$2a$12$bASvB9btHled4bxAPKOOp.AKEseDaK0qZ0zb2dWuywMednVxhQDjm', N'Nguyễn Văn A', '0912345678', N'Cần Thơ', 'Customer', 'ACTIVE');

-- 2. Categories
INSERT INTO Categories (category_name, description, status)
VALUES 
(N'Concert Âm Nhạc', N'Sự kiện biểu diễn âm nhạc, liveshow', 'ACTIVE'),
(N'Sân Khấu & Kịch', N'Vở kịch, biểu diễn nghệ thuật sân khấu', 'ACTIVE');

-- 3. Venues
INSERT INTO Venues (venue_name, address, description, capacity, status)
VALUES 
(N'Sân vận động Mỹ Đình', N'Đường Lê Đức Thọ, Nam Từ Liêm, Hà Nội', N'Sân vận động quốc gia', 40000, 'ACTIVE'),
(N'Nhà Hát Lớn Hà Nội', N'Số 1 Tràng Tiền, Hoàn Kiếm, Hà Nội', N'Nhà hát cổ điển', 600, 'ACTIVE');

-- 4. Seat_Maps
INSERT INTO Seat_Maps (venue_id, map_name, description, status)
VALUES 
(1, N'Sơ đồ Concert 2026 Mỹ Đình', N'Sơ đồ cho sự kiện lớn', 'ACTIVE'),
(2, N'Sơ đồ Khán phòng Nhà Hát Lớn', N'Sơ đồ tiêu chuẩn nhà hát', 'ACTIVE');

-- 5. Seats
INSERT INTO Seats (seat_map_id, row_label, seat_number, seat_label, seat_type, status)
VALUES 
(1, 'A', 1, 'VIP-A01', 'VIP', 'ACTIVE'),
(1, 'A', 2, 'VIP-A02', 'VIP', 'ACTIVE');

-- 6. Events
INSERT INTO Events (organizer_id, category_id, venue_id, event_name, description, event_image, start_time, end_time, status)
VALUES 
(1, 1, 1, N'Chuyến Bay Hoàng Hôn: Live Concert 2026', N'Concert âm nhạc đỉnh cao', 'sunset_concert.jpg', '2026-11-15 19:30:00', '2026-11-15 22:30:00', 'ACTIVE'),
(1, 2, 2, N'Vở Kịch Kinh Điển: Người Tình Mùa Thu', N'Vở kịch sân khấu tâm lý', 'nguoi_tinh_mua_thu.jpg', '2026-12-01 20:00:00', '2026-12-01 22:00:00', 'ACTIVE');

-- 7. Event_Seats
INSERT INTO Event_Seats (event_id, source_seat_id, row_label, seat_number, seat_label, seat_type, status)
VALUES 
(1, 1, 'A', 1, 'VIP-A01', 'VIP', 'Available'),
(1, 2, 'A', 2, 'VIP-A02', 'VIP', 'Sold');

-- 8. Event_Tickets
INSERT INTO Event_Tickets (event_id, ticket_name, description, price, quantity, available_quantity, status)
VALUES 
(1, N'Vé VIP Zone A', N'Bao gồm quà tặng & lối đi riêng', 2800000.00, 100, 99, 'ACTIVE'),
(1, N'Vé GA Phổ Thông', N'Khu đứng tự do', 650000.00, 500, 500, 'ACTIVE');

-- 9. Event_Staff
INSERT INTO Event_Staff (event_id, staff_id, status)
VALUES 
(1, 1, 'ACTIVE'),
(2, 1, 'ACTIVE');

-- 10. Vouchers
INSERT INTO Vouchers (voucher_code, voucher_name, discount_type, discount_value, min_order_amount, max_discount_amount, start_time, end_time, usage_limit, used_count, status)
VALUES 
('EARLYBIRD10', N'Giảm 10% vé sớm', 'Percentage', 10.00, 500000.00, 200000.00, '2026-10-01 00:00:00', '2026-10-31 23:59:59', 100, 1, 'ACTIVE'),
('LTMVIP50K', N'Giảm trực tiếp 50k', 'Fixed', 50000.00, 300000.00, 50000.00, '2026-10-01 00:00:00', '2026-12-31 23:59:59', 200, 0, 'ACTIVE');

-- 11. Orders
INSERT INTO Orders (customer_id, voucher_id, order_code, total_amount, discount_amount, final_amount, status, hold_started_at, hold_expired_at)
VALUES 
(2, 1, 'ORD2026100101', 2800000.00, 200000.00, 2600000.00, 'Paid', '2026-10-01 10:00:00', '2026-10-01 10:15:00'),
(2, NULL, 'ORD2026100102', 650000.00, 0.00, 650000.00, 'Pending', '2026-10-01 11:00:00', '2026-10-01 11:15:00');

-- 12. Order_Details
INSERT INTO Order_Details (order_id, event_ticket_id, quantity, unit_price, subtotal)
VALUES 
(1, 1, 1, 2800000.00, 2800000.00),
(2, 2, 1, 650000.00, 650000.00);

-- 13. Order_Seats
INSERT INTO Order_Seats (order_id, event_seat_id)
VALUES 
(1, 2),
(2, 1);

-- 14. Payments
INSERT INTO Payments (order_id, payment_method, transaction_code, amount, payment_status, paid_at)
VALUES 
(1, 'VNPAY', 'VNP14589230', 2600000.00, 'Success', '2026-10-01 10:05:22'),
(2, 'VNPAY', 'VNP14589231', 650000.00, 'Failed', '2026-10-01 11:02:10');

-- 15. Tickets
INSERT INTO Tickets (order_detail_id, event_id, event_seat_id, ticket_code, qr_code, ticket_status, check_in_time)
VALUES 
(1, 1, 2, 'TCK-2026-8801', 'QR_DATA_BASE64_SAMPLE_1', 'Valid', NULL),
(1, 1, 1, 'TCK-2026-8802', 'QR_DATA_BASE64_SAMPLE_2', 'CheckedIn', '2026-11-15 18:45:00');

-- 16. Reviews
INSERT INTO Reviews (customer_id, event_id, ticket_id, rating, comment, status)
VALUES 
(2, 1, 2, 5, N'Sự kiện rất tuyệt vời, âm thanh đỉnh cao!', 'ACTIVE'),
(2, 2, 1, 4, N'Sân khấu đẹp nhưng ghế ngồi hơi chật.', 'ACTIVE');
GO

-- =========================================================
-- 17-19. ORGANIZER PROFILE (UC-20): bảng hồ sơ mở rộng + quy tắc giấy phép kinh doanh + dữ liệu demo
-- (cùng nội dung với db-organizer-profile.sql dành cho DB đã tồn tại)
-- =========================================================
-- 17. ORGANIZER PROFILES: thông tin mở rộng, quan hệ 1-1 với Users
IF OBJECT_ID('Organizer_Profiles', 'U') IS NULL
CREATE TABLE Organizer_Profiles (
    user_id INT NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES Users(user_id),
    summary NVARCHAR(300) NULL,                 -- mô tả ngắn giới thiệu đơn vị
    logo_url VARCHAR(500) NULL,                 -- logo 1:1
    cover_url VARCHAR(500) NULL,                -- ảnh bìa 16:9
    tax_code VARCHAR(20) NULL,                  -- mã số thuế doanh nghiệp
    legal_representative NVARCHAR(150) NULL,    -- người đại diện pháp luật & chức vụ
    website_url VARCHAR(500) NULL,
    facebook_url VARCHAR(500) NULL,
    youtube_url VARCHAR(500) NULL,              -- YouTube / TikTok
    spotify_url VARCHAR(500) NULL,
    bank_name NVARCHAR(150) NULL,               -- ngân hàng - chi nhánh
    bank_account_number VARCHAR(30) NULL,
    bank_account_holder NVARCHAR(150) NULL,
    -- Các cột do Admin quản lý, Organizer chỉ xem (không có trong form chỉnh sửa)
    kyc_level TINYINT NOT NULL DEFAULT 0 CHECK (kyc_level BETWEEN 0 AND 2),
    verification_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    partner_tier NVARCHAR(50) NULL,             -- ví dụ: Đối tác Bạch Kim
    withdrawal_limit DECIMAL(18,2) NULL,        -- NULL = không giới hạn
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);
GO

-- Mã số thuế không được trùng giữa các tổ chức (bỏ qua NULL)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Organizer_Profiles_tax_code')
CREATE UNIQUE INDEX UX_Organizer_Profiles_tax_code
    ON Organizer_Profiles(tax_code) WHERE tax_code IS NOT NULL;
GO

-- 18. ORGANIZER CATEGORIES: thể loại sự kiện chuyên trách (dùng lại bảng Categories)
IF OBJECT_ID('Organizer_Categories', 'U') IS NULL
CREATE TABLE Organizer_Categories (
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    category_id INT NOT NULL FOREIGN KEY REFERENCES Categories(category_id),
    PRIMARY KEY (user_id, category_id)
);
GO

-- 19. ORGANIZER DOCUMENTS: tài liệu pháp lý (Admin duyệt)
IF OBJECT_ID('Organizer_Documents', 'U') IS NULL
CREATE TABLE Organizer_Documents (
    document_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES Users(user_id),
    doc_type VARCHAR(30) NOT NULL
        CHECK (doc_type IN ('BUSINESS_LICENSE', 'PERFORMANCE_PERMIT', 'COPYRIGHT_CONTRACT', 'OTHER')),
    doc_name NVARCHAR(200) NOT NULL,            -- tên file người dùng tải lên
    file_name VARCHAR(200) NOT NULL,            -- tên file đã lưu trên server (không phải đường dẫn)
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    uploaded_at DATETIME2 DEFAULT GETDATE(),
    reviewed_at DATETIME2 NULL
);
GO

-- QUY TẮC NGHIỆP VỤ: tổ chức chỉ được xác minh (VERIFIED) khi có Giấy phép kinh doanh đã được duyệt.
-- Trigger chỉ kiểm tra khi verification_status chuyển sang VERIFIED, nên không chặn
-- Organizer cập nhật hồ sơ (các lệnh cập nhật hồ sơ không đụng tới cột này).
CREATE OR ALTER TRIGGER TR_Organizer_Profiles_RequireBusinessLicense
ON Organizer_Profiles
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN deleted d ON d.user_id = i.user_id
        WHERE i.verification_status = 'VERIFIED'
          AND (d.user_id IS NULL OR d.verification_status <> 'VERIFIED')
          AND NOT EXISTS (
                SELECT 1 FROM Organizer_Documents od
                WHERE od.user_id = i.user_id
                  AND od.doc_type = 'BUSINESS_LICENSE'
                  AND od.status = 'APPROVED')
    )
    BEGIN
        RAISERROR (N'Phải có Giấy phép kinh doanh đã được duyệt mới được xác minh tổ chức.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Dữ liệu demo cho organizer01 (bỏ qua nếu đã có). Giấy phép KD phải được duyệt trước khi VERIFIED.
IF NOT EXISTS (SELECT 1 FROM Organizer_Documents WHERE doc_type = 'BUSINESS_LICENSE'
               AND user_id = (SELECT user_id FROM Users WHERE username = 'organizer01'))
INSERT INTO Organizer_Documents (user_id, doc_type, doc_name, file_name, status, reviewed_at)
SELECT user_id, 'BUSINESS_LICENSE', N'Giấy ĐKKD.pdf', 'demo-business-license.pdf', 'APPROVED', GETDATE()
FROM Users WHERE username = 'organizer01';
GO

-- Hồ sơ demo cho organizer01
IF NOT EXISTS (SELECT 1 FROM Organizer_Profiles WHERE user_id = (SELECT user_id FROM Users WHERE username = 'organizer01'))
INSERT INTO Organizer_Profiles (user_id, summary, tax_code, legal_representative, website_url,
                                bank_name, bank_account_number, bank_account_holder,
                                kyc_level, verification_status)
SELECT user_id, N'Đơn vị tổ chức các đêm nhạc acoustic và workshop sáng tạo tại Đà Lạt.',
       '0315894120', N'Nguyễn Minh Anh - Tổng Giám Đốc', 'https://example.com',
       N'Vietcombank - CN Đà Lạt', '0071000882688', N'CONG TY TNHH MAY LANG THANG PRODUCTION',
       2, 'VERIFIED'
FROM Users WHERE username = 'organizer01';
GO
