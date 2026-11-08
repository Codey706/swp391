-- =========================================================
-- 005: Thêm 4 tài khoản Staff ACTIVE (staff02..staff05)
-- Organizer cần nhiều nhân viên để phân công soát vé.
-- Mật khẩu: sao chép đúng hash hiện tại của staff01 (đăng nhập bằng cùng mật khẩu với staff01).
-- Bỏ qua tài khoản đã tồn tại (theo username hoặc email) nên chạy lại vẫn an toàn.
-- =========================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DECLARE @pwd VARCHAR(255) = (SELECT password FROM Users WHERE username = 'staff01');

IF @pwd IS NULL
BEGIN
    RAISERROR(N'Không tìm thấy tài khoản staff01 để lấy mật khẩu; bỏ qua migration 005.', 16, 1);
    RETURN;
END

INSERT INTO Users (username, email, password, full_name, phone, address, role, status)
SELECT v.username, v.email, @pwd, v.full_name, v.phone, v.address, 'Staff', 'ACTIVE'
FROM (VALUES
    ('staff02', 'staff2@ltm.vn', N'Trần Thị Mai', '0561434568', N'Cần Thơ'),
    ('staff03', 'staff3@ltm.vn', N'Lê Minh Khoa', '0561434569', N'TP. Hồ Chí Minh'),
    ('staff04', 'staff4@ltm.vn', N'Phạm Thu Hà', '0561434570', N'Hà Nội'),
    ('staff05', 'staff5@ltm.vn', N'Võ Quốc Bảo', '0561434571', N'Đà Nẵng')
) AS v(username, email, full_name, phone, address)
WHERE NOT EXISTS (SELECT 1 FROM Users u WHERE u.username = v.username OR u.email = v.email);
GO
