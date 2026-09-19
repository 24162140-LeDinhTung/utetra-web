-- File này chạy tự động khi MySQL container khởi tạo lần đầu
-- Docker đã tự tạo database + user từ biến môi trường, nên file này chỉ cần set charset

ALTER DATABASE utetra_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;