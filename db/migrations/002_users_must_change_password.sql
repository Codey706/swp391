-- =========================================================
-- 002: Users.must_change_password
-- Tài khoản Organizer/Staff do Admin tạo với mật khẩu tạm phải đổi mật khẩu ở lần đăng nhập đầu.
-- =========================================================
IF COL_LENGTH('Users', 'must_change_password') IS NULL
    ALTER TABLE Users ADD must_change_password BIT NOT NULL
        CONSTRAINT DF_Users_must_change_password DEFAULT 0;
GO
