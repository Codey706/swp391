/*
  Dữ liệu demo để test đặt vé / thanh toán trên giao diện.
  - Thêm 3 sự kiện ACTIVE (organizer01, staff01 được phân công) có hạng vé + sơ đồ ghế,
  - Bổ sung hạng vé + sơ đồ ghế cho "Người Tình Mùa Thu" (sự kiện mẫu chưa có hạng vé).
  Ghế được sinh giống hệt trình thiết kế sơ đồ của Organizer (SeatMapDAO):
  row_label = {mã khu}-{chữ hàng}, seat_label = row_label + số ghế 2 chữ số, mỗi khu gắn đúng hạng vé.
  Chạy lại nhiều lần an toàn: sự kiện đã có hạng vé thì bỏ qua.
  Chạy sau db.sql:  sqlcmd -S localhost -U sa -P 123 -C -d LightTicketDB -f 65001 -i db\seed_demo_events.sql
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
-- sqlcmd mặc định tắt QUOTED_IDENTIFIER, nhưng bảng có filtered index yêu cầu bật khi ghi dữ liệu
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @organizerId INT = (SELECT user_id FROM Users WHERE username = 'organizer01');
DECLARE @staffId INT = (SELECT user_id FROM Users WHERE username = 'staff01');
DECLARE @catMusic INT = (SELECT TOP 1 category_id FROM Categories WHERE category_name = N'Concert Âm Nhạc');
DECLARE @catStage INT = (SELECT TOP 1 category_id FROM Categories WHERE category_name = N'Sân Khấu & Kịch');
DECLARE @venueMyDinh INT = (SELECT TOP 1 venue_id FROM Venues WHERE venue_name = N'Sân vận động Mỹ Đình');
DECLARE @venueOpera INT = (SELECT TOP 1 venue_id FROM Venues WHERE venue_name = N'Nhà Hát Lớn Hà Nội');

IF @organizerId IS NULL OR @catMusic IS NULL OR @catStage IS NULL OR @venueMyDinh IS NULL OR @venueOpera IS NULL
BEGIN
    RAISERROR(N'Thiếu dữ liệu nền (organizer01 / danh mục / địa điểm). Hãy chạy db.sql trước.', 16, 1);
    RETURN;
END

-- ---------------------------------------------------------------- Sự kiện
DECLARE @E TABLE (k INT PRIMARY KEY, event_name NVARCHAR(200), category_id INT, venue_id INT,
                  description NVARCHAR(MAX), start_time DATETIME2, end_time DATETIME2);
INSERT INTO @E VALUES
(1, N'Đêm Nhạc Acoustic: Gió Mùa Về', @catMusic, @venueOpera,
    N'Đêm nhạc acoustic mộc mạc với guitar, piano và những bản tình ca mùa đông. Không gian nhà hát ấm cúng, ghế ngồi đánh số.',
    '2026-12-12 20:00', '2026-12-12 22:30'),
(2, N'Lễ Hội Âm Nhạc Mùa Đông 2026', @catMusic, @venueMyDinh,
    N'Lễ hội âm nhạc ngoài trời với nhiều nghệ sĩ khách mời. Khu VIP có ghế ngồi đánh số, khu GA đứng tự do trước sân khấu.',
    '2026-12-20 18:00', '2026-12-20 23:00'),
(3, N'Kịch: Hồn Trương Ba Da Hàng Thịt', @catStage, @venueOpera,
    N'Vở kịch kinh điển được dàn dựng mới. Ghế ngồi đánh số, chia hai hạng theo khoảng cách tới sân khấu.',
    '2026-12-05 19:30', '2026-12-05 21:45'),
(4, N'Vở Kịch Kinh Điển: Người Tình Mùa Thu', @catStage, @venueOpera, NULL, NULL, NULL);  -- đã có trong db.sql, chỉ bổ sung vé + sơ đồ

-- ---------------------------------------------------------------- Hạng vé
DECLARE @T TABLE (ek INT, ticket_name NVARCHAR(100), description NVARCHAR(500), price DECIMAL(18,2));
INSERT INTO @T VALUES
(1, N'Vé VIP', N'Hai hàng đầu, gần sân khấu', 1200000),
(1, N'Vé Thường', N'Khu ghế phía sau', 450000),
(2, N'Vé VIP Ghế Ngồi', N'Ghế ngồi đánh số, lối vào riêng', 1500000),
(2, N'Vé GA Đứng', N'Khu đứng tự do trước sân khấu', 500000),
(3, N'Hạng A', N'Các hàng đầu', 600000),
(3, N'Hạng B', N'Các hàng sau', 350000),
(4, N'Hạng A', N'Các hàng đầu', 500000),
(4, N'Hạng B', N'Các hàng sau', 300000);

-- ---------------------------------------------------------------- Khu (khung vẽ 1200 x 800)
-- code = mã khu như trình thiết kế sinh ra (chữ không dấu, viết hoa, tối đa 6 ký tự)
DECLARE @Z TABLE (ek INT, zone_name NVARCHAR(100), code VARCHAR(10), zone_type VARCHAR(20), color VARCHAR(7),
                  pos_x INT, pos_y INT, width INT, height INT, row_count INT, seats_per_row INT,
                  standing_capacity INT, ticket_name NVARCHAR(100), sort_order INT);
INSERT INTO @Z VALUES
(1, N'Sân khấu', 'SANKHA', 'STAGE',   '#424242', 400,  30, 400,  90, 0,  0,   0, NULL,               0),
(1, N'VIP',      'VIP',    'SEATED',  '#C8442B', 300, 170, 600, 120, 2, 10,   0, N'Vé VIP',          1),
(1, N'Thường',   'THUONG', 'SEATED',  '#1E88E5', 250, 330, 700, 250, 5, 12,   0, N'Vé Thường',       2),
(2, N'Sân khấu', 'SANKHA', 'STAGE',   '#424242', 350,  30, 500, 100, 0,  0,   0, NULL,               0),
(2, N'GA',       'GA',     'STANDING','#43A047', 300, 160, 600, 250, 0,  0, 300, N'Vé GA Đứng',      1),
(2, N'VIP',      'VIP',    'SEATED',  '#C8442B', 250, 450, 700, 250, 4, 10,   0, N'Vé VIP Ghế Ngồi', 2),
(3, N'Sân khấu', 'SANKHA', 'STAGE',   '#424242', 400,  30, 400,  90, 0,  0,   0, NULL,               0),
(3, N'Khu A',    'KHUA',   'SEATED',  '#8E24AA', 250, 160, 700, 200, 4, 12,   0, N'Hạng A',          1),
(3, N'Khu B',    'KHUB',   'SEATED',  '#FB8C00', 250, 400, 700, 300, 6, 12,   0, N'Hạng B',          2),
(4, N'Sân khấu', 'SANKHA', 'STAGE',   '#424242', 400,  30, 400,  90, 0,  0,   0, NULL,               0),
(4, N'Khu A',    'KHUA',   'SEATED',  '#8E24AA', 300, 160, 600, 200, 4, 10,   0, N'Hạng A',          1),
(4, N'Khu B',    'KHUB',   'SEATED',  '#FB8C00', 250, 400, 700, 300, 5, 12,   0, N'Hạng B',          2);

-- Bảng số 0..39 để sinh hàng / cột ghế
DECLARE @N TABLE (n INT PRIMARY KEY);
INSERT INTO @N SELECT TOP 40 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 FROM sys.all_objects;

BEGIN TRANSACTION;

DECLARE @k INT = 1, @eventId INT, @name NVARCHAR(200);
WHILE @k <= 4
BEGIN
    SELECT @name = event_name FROM @E WHERE k = @k;
    SET @eventId = (SELECT TOP 1 event_id FROM Events WHERE event_name = @name ORDER BY event_id);

    IF @eventId IS NULL
    BEGIN
        INSERT INTO Events (organizer_id, category_id, venue_id, event_name, description, event_image, start_time, end_time, status)
        SELECT @organizerId, category_id, venue_id, event_name, description, NULL, start_time, end_time, 'ACTIVE'
        FROM @E WHERE k = @k AND start_time IS NOT NULL;
        SET @eventId = SCOPE_IDENTITY();
    END

    IF @eventId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Event_Tickets WHERE event_id = @eventId)
    BEGIN
        -- Hạng vé: số lượng = tổng sức chứa các khu gắn với hạng vé đó
        INSERT INTO Event_Tickets (event_id, ticket_name, description, price, quantity, available_quantity, status)
        SELECT @eventId, t.ticket_name, t.description, t.price, cap.qty, cap.qty, 'ACTIVE'
        FROM @T t
        CROSS APPLY (SELECT SUM(CASE WHEN z.zone_type = 'SEATED' THEN z.row_count * z.seats_per_row
                                     ELSE z.standing_capacity END) AS qty
                     FROM @Z z WHERE z.ek = @k AND z.ticket_name = t.ticket_name) cap
        WHERE t.ek = @k;

        -- Khu
        DELETE FROM Event_Seats WHERE event_id = @eventId;
        DELETE FROM Event_Zones WHERE event_id = @eventId;
        INSERT INTO Event_Zones (event_id, event_ticket_id, zone_name, zone_type, color, pos_x, pos_y, width, height,
                                 row_count, seats_per_row, capacity, blocked_seats, sort_order)
        SELECT @eventId, et.event_ticket_id, z.zone_name, z.zone_type, z.color, z.pos_x, z.pos_y, z.width, z.height,
               z.row_count, z.seats_per_row,
               CASE z.zone_type WHEN 'SEATED' THEN z.row_count * z.seats_per_row
                                WHEN 'STANDING' THEN z.standing_capacity ELSE 0 END,
               NULL, z.sort_order
        FROM @Z z
        LEFT JOIN Event_Tickets et ON et.event_id = @eventId AND et.ticket_name = z.ticket_name
        WHERE z.ek = @k;

        -- Ghế cho khu ngồi
        INSERT INTO Event_Seats (event_id, source_seat_id, zone_id, row_label, seat_number, seat_label, seat_type, status)
        SELECT @eventId, NULL, ez.zone_id,
               z.code + '-' + CHAR(65 + r.n),
               c.n + 1,
               z.code + '-' + CHAR(65 + r.n) + RIGHT('0' + CAST(c.n + 1 AS VARCHAR(2)), 2),
               CASE WHEN LOWER(z.zone_name) LIKE '%vip%' THEN 'VIP' ELSE 'Standard' END,
               'Available'
        FROM @Z z
        JOIN Event_Zones ez ON ez.event_id = @eventId AND ez.zone_name = z.zone_name
        JOIN @N r ON r.n < z.row_count
        JOIN @N c ON c.n < z.seats_per_row
        WHERE z.ek = @k AND z.zone_type = 'SEATED'
        ORDER BY ez.sort_order, r.n, c.n;

        -- Phân công staff01 để test check-in
        IF @staffId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Event_Staff WHERE event_id = @eventId AND staff_id = @staffId)
            INSERT INTO Event_Staff (event_id, staff_id, status) VALUES (@eventId, @staffId, 'ACTIVE');

        PRINT N'Đã tạo vé + sơ đồ cho: ' + @name;
    END
    ELSE
        PRINT N'Bỏ qua (đã có hạng vé): ' + @name;

    SET @k += 1;
END

COMMIT TRANSACTION;
GO

-- ---------------------------------------------------------------- Ảnh poster / logo / ảnh bìa demo
-- File nằm trong src/main/webapp/assets/images/events. Chỉ ghi khi chưa có ảnh hoặc ảnh cũ trỏ tới file
-- không tồn tại; ảnh Organizer tự upload (assets/uploads/...) được giữ nguyên.
UPDATE e SET event_image = v.img, updated_at = GETDATE()
FROM Events e
JOIN (VALUES
    (N'Chuyến Bay Hoàng Hôn: Live Concert 2026', 'assets/images/events/chuyen-bay-hoang-hon.svg'),
    (N'Vở Kịch Kinh Điển: Người Tình Mùa Thu',  'assets/images/events/nguoi-tinh-mua-thu.svg'),
    (N'Đêm Nhạc Acoustic: Gió Mùa Về',          'assets/images/events/gio-mua-ve.svg'),
    (N'Lễ Hội Âm Nhạc Mùa Đông 2026',           'assets/images/events/le-hoi-mua-dong.svg'),
    (N'Kịch: Hồn Trương Ba Da Hàng Thịt',       'assets/images/events/hon-truong-ba.svg')
) AS v(event_name, img) ON v.event_name = e.event_name
WHERE e.event_image IS NULL OR e.event_image NOT LIKE 'assets/uploads/%';

UPDATE op SET logo_url = COALESCE(op.logo_url, 'assets/images/events/may-lang-thang-logo.svg'),
              cover_url = COALESCE(op.cover_url, 'assets/images/events/may-lang-thang-cover.svg')
FROM Organizer_Profiles op JOIN Users u ON u.user_id = op.user_id
WHERE u.username = 'organizer01';

PRINT N'Đã gán ảnh poster demo.';
GO
