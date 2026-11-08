-- =========================================================
-- 004: Users.password_set
-- Tài khoản đăng ký bằng Google được gán mật khẩu ngẫu nhiên mà người dùng không biết,
-- nên lần đầu họ phải "Thiết lập mật khẩu" (không hỏi mật khẩu hiện tại).
-- password_set = 0: chưa từng tự đặt mật khẩu; = 1: đã có mật khẩu do người dùng đặt.
-- =========================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('Users', 'password_set') IS NULL
BEGIN
    ALTER TABLE Users ADD password_set BIT NOT NULL
        CONSTRAINT DF_Users_password_set DEFAULT 1;

    -- Tài khoản Google tạo trước migration này: đăng ký thường bắt buộc nhập số điện thoại,
    -- còn tài khoản tạo qua Google thì phone để trống, nên dùng dấu hiệu đó để đánh dấu.
    EXEC(N'UPDATE Users SET password_set = 0
           WHERE role = ''Customer'' AND (phone IS NULL OR LTRIM(RTRIM(phone)) = '''')');
END
GO
