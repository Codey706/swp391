-- =========================================================
-- 006: Đồng bộ ghế của sự kiện "Chuyến Bay Hoàng Hôn" (event_id = 1)
--      và chặn một ghế có hai vé hiệu lực ở mức database.
--
-- Hiện trạng: sự kiện chỉ có 2 ghế không thuộc khu nào (VIP-A01, VIP-A02), trong khi VIP có 100 vé;
-- VIP-A01 đang gắn với 2 vé hiệu lực (vé thừa TCK-2026-8802 và một vé GA).
--
-- Việc làm:
--   1. Hủy vé thừa TCK-2026-8802.
--   2. Bỏ ghế khỏi các vé GA còn hiệu lực (GA là khu đứng) và xóa dòng Order_Seats tương ứng.
--      Vé GA vẫn Valid. Order_Seats của đơn đã hủy được giữ làm lịch sử.
--   3. Trả VIP-A01 về Available nếu không còn vé hiệu lực hay đơn Pending/Paid nào giữ ghế.
--   4. Tạo sơ đồ đúng định dạng SeatMapDAO/SeatMapSupport:
--        sân khấu, khu ngồi "VIP" 10 hàng x 10 ghế (mã khu VIP, ghế VIP-A01..VIP-J10), khu đứng "GA" 500 chỗ.
--        Kích thước khu ngồi theo seatedSize() của seatmap.js: 16 + 10*24 + 20 = 276; 24 + 10*24 + 20 = 284.
--      Giữ nguyên 2 ghế đã có (chỉ gắn khu), chỉ thêm ghế chưa tồn tại.
--   5. Ẩn (HIDDEN) mọi review gắn với vé không ở trạng thái CheckedIn.
--   6. Tạo unique index lọc trên Tickets(event_seat_id).
--
-- Chạy lại vẫn an toàn. Nếu sự kiện đã có sơ đồ khác thì giữ nguyên sơ đồ đó, không sinh ghế.
-- Điều kiện so khớp chỉ dùng ký tự ASCII để không phụ thuộc bảng mã khi chạy bằng sqlcmd.
-- =========================================================
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;

DECLARE @eventId INT = (SELECT event_id FROM Events WHERE event_id = 1 AND event_name LIKE N'%Live Concert 2026');
DECLARE @vipTicket INT = (SELECT event_ticket_id FROM Event_Tickets WHERE event_id = @eventId AND ticket_name LIKE N'%VIP Zone A');
DECLARE @gaTicket INT = (SELECT event_ticket_id FROM Event_Tickets WHERE event_id = @eventId AND ticket_name LIKE N'%GA Ph%');

IF @eventId IS NULL OR @vipTicket IS NULL OR @gaTicket IS NULL
BEGIN
    PRINT N'006: không tìm thấy sự kiện/hạng vé mẫu, bỏ qua phần dữ liệu.';
END
ELSE
BEGIN
    BEGIN TRANSACTION;

    -- 1. Vé thừa của đơn mua 1 vé nhưng có 2 vé điện tử
    UPDATE Tickets
    SET ticket_status = 'Cancelled'
    WHERE ticket_code = 'TCK-2026-8802' AND event_id = @eventId AND ticket_status IN ('Valid', 'CheckedIn');

    -- 2. Vé GA (khu đứng) không giữ ghế
    DECLARE @gaSeats TABLE (ticket_id INT PRIMARY KEY, event_seat_id INT NOT NULL, order_id INT NOT NULL);

    INSERT INTO @gaSeats (ticket_id, event_seat_id, order_id)
    SELECT t.ticket_id, t.event_seat_id, od.order_id
    FROM Tickets t
    JOIN Order_Details od ON od.order_detail_id = t.order_detail_id
    WHERE od.event_ticket_id = @gaTicket
      AND t.event_seat_id IS NOT NULL
      AND t.ticket_status IN ('Valid', 'CheckedIn');

    UPDATE t SET t.event_seat_id = NULL
    FROM Tickets t JOIN @gaSeats g ON g.ticket_id = t.ticket_id;

    DELETE os
    FROM Order_Seats os
    JOIN @gaSeats g ON g.order_id = os.order_id AND g.event_seat_id = os.event_seat_id;

    -- 3. Trả VIP-A01 nếu không còn ai giữ ghế
    UPDATE es SET es.status = 'Available'
    FROM Event_Seats es
    WHERE es.event_id = @eventId
      AND es.seat_label = 'VIP-A01'
      AND es.status = 'Sold'
      AND NOT EXISTS (SELECT 1 FROM Tickets t
                      WHERE t.event_seat_id = es.event_seat_id AND t.ticket_status IN ('Valid', 'CheckedIn'))
      AND NOT EXISTS (SELECT 1 FROM Order_Seats os JOIN Orders o ON o.order_id = os.order_id
                      WHERE os.event_seat_id = es.event_seat_id AND o.status IN ('Pending', 'Paid'));

    -- 4. Sơ đồ (tên sân khấu ghép bằng NCHAR để không phụ thuộc bảng mã của sqlcmd)
    IF NOT EXISTS (SELECT 1 FROM Event_Zones WHERE event_id = @eventId)
    BEGIN
        INSERT INTO Event_Zones (event_id, event_ticket_id, zone_name, zone_type, color, pos_x, pos_y, width, height,
                                 row_count, seats_per_row, capacity, blocked_seats, sort_order)
        VALUES (@eventId, NULL, N'S' + NCHAR(226) + N'n kh' + NCHAR(7845) + N'u', 'STAGE', '#4B4B52', 400, 30, 400, 90, 0, 0, 0, NULL, 0),
               (@eventId, @vipTicket, N'VIP', 'SEATED', '#FF5B49', 460, 150, 276, 284, 10, 10, 100, NULL, 1),
               (@eventId, @gaTicket, N'GA', 'STANDING', '#141414', 300, 470, 600, 260, 0, 0, 500, NULL, 2);
    END

    DECLARE @vipZone INT = (SELECT zone_id FROM Event_Zones
                            WHERE event_id = @eventId AND event_ticket_id = @vipTicket AND zone_name = N'VIP'
                              AND zone_type = 'SEATED' AND row_count = 10 AND seats_per_row = 10);

    IF @vipZone IS NULL
    BEGIN
        PRINT N'006: sự kiện đã có sơ đồ khác, giữ nguyên và không sinh ghế.';
    END
    ELSE
    BEGIN
        -- Giữ nguyên 2 ghế đã có: chỉ gắn khu và đưa row_label về đúng định dạng {mã khu}-{chữ hàng}
        UPDATE Event_Seats
        SET zone_id = @vipZone, row_label = 'VIP-A'
        WHERE event_id = @eventId AND zone_id IS NULL AND seat_label IN ('VIP-A01', 'VIP-A02');

        -- 5. Chỉ thêm ghế chưa có
        INSERT INTO Event_Seats (event_id, source_seat_id, zone_id, row_label, seat_number, seat_label, seat_type, status)
        SELECT @eventId, NULL, @vipZone, g.row_label, g.seat_number,
               g.row_label + RIGHT('0' + CAST(g.seat_number AS VARCHAR(2)), 2), 'VIP', 'Available'
        FROM (
            SELECT 'VIP-' + r.letter AS row_label, c.seat_number
            FROM (VALUES ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J')) r(letter)
            CROSS JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)) c(seat_number)
        ) g
        WHERE NOT EXISTS (SELECT 1 FROM Event_Seats es
                          WHERE es.event_id = @eventId
                            AND es.seat_label = g.row_label + RIGHT('0' + CAST(g.seat_number AS VARCHAR(2)), 2));
    END

    COMMIT TRANSACTION;
END
GO

-- Review chỉ hợp lệ khi vé đã check-in
UPDATE r
SET r.status = 'HIDDEN', r.updated_at = GETDATE()
FROM Reviews r
JOIN Tickets t ON t.ticket_id = r.ticket_id
WHERE r.status <> 'HIDDEN' AND t.ticket_status <> 'CheckedIn';
GO

-- Một ghế chỉ có tối đa một vé hiệu lực. Vé đã hủy không tính, nên ghế có thể bán lại.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('Tickets') AND name = 'UX_Tickets_ActiveSeat')
BEGIN
    IF EXISTS (SELECT 1 FROM Tickets
               WHERE event_seat_id IS NOT NULL AND ticket_status IN ('Valid', 'CheckedIn')
               GROUP BY event_seat_id HAVING COUNT(*) > 1)
    BEGIN
        RAISERROR(N'006: vẫn có ghế gắn với nhiều vé hiệu lực, chưa thể tạo UX_Tickets_ActiveSeat.', 16, 1);
    END
    ELSE
    BEGIN
        CREATE UNIQUE NONCLUSTERED INDEX UX_Tickets_ActiveSeat
            ON Tickets (event_seat_id)
            WHERE event_seat_id IS NOT NULL AND ticket_status IN ('Valid', 'CheckedIn');
    END
END
GO
