-- =========================================================
-- 003: Reviews - mỗi khách hàng chỉ 1 đánh giá cho mỗi sự kiện (UC-19)
-- Reviews.status: ACTIVE (hiển thị công khai) / HIDDEN (Admin ẩn, UC-33)
-- =========================================================
IF EXISTS (SELECT customer_id, event_id FROM Reviews GROUP BY customer_id, event_id HAVING COUNT(*) > 1)
BEGIN
    RAISERROR (N'Có khách hàng đã đánh giá một sự kiện nhiều lần. Hãy xóa/gộp các dòng trùng trong Reviews rồi chạy lại migration này.', 16, 1);
    RETURN;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Reviews_customer_event')
    CREATE UNIQUE INDEX UX_Reviews_customer_event ON Reviews(customer_id, event_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Reviews_status')
    ALTER TABLE Reviews ADD CONSTRAINT CK_Reviews_status CHECK (status IN ('ACTIVE', 'HIDDEN'));
GO
