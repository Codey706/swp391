-- =========================================================
-- 001: Chuẩn hóa Users.role về dạng Customer / Staff / Organizer / Admin
-- Dữ liệu cũ có thể bị lưu viết hoa (ORGANIZER, STAFF...) bởi chức năng sửa user của Admin
-- trước commit 93e554e. Chạy lại nhiều lần vẫn an toàn.
-- =========================================================
-- Chọn database khi chạy: sqlcmd -d LightTicketDB (hoặc LTM_TEST)

UPDATE Users SET role = 'Customer'  WHERE UPPER(role) = 'CUSTOMER'  AND role <> 'Customer'  COLLATE Latin1_General_CS_AS;
UPDATE Users SET role = 'Staff'     WHERE UPPER(role) = 'STAFF'     AND role <> 'Staff'     COLLATE Latin1_General_CS_AS;
UPDATE Users SET role = 'Organizer' WHERE UPPER(role) = 'ORGANIZER' AND role <> 'Organizer' COLLATE Latin1_General_CS_AS;
UPDATE Users SET role = 'Admin'     WHERE UPPER(role) = 'ADMIN'     AND role <> 'Admin'     COLLATE Latin1_General_CS_AS;
GO

-- Kiểm tra: các giá trị role còn lại
SELECT role, COUNT(*) AS total FROM Users GROUP BY role;
GO
