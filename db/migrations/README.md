# Database migrations

Áp dụng cho database **đang dùng** (không chạy lại `db.sql`, vì `db.sql` DROP database).
Chạy theo thứ tự số trong SSMS hoặc `sqlcmd -S <server> -d LightTicketDB -i <file>`.
Mỗi file chỉ ALTER/CREATE/UPDATE và có kiểm tra tồn tại nên chạy lại vẫn an toàn.
`db.sql` luôn được cập nhật kèm, dùng cho lần cài mới.
