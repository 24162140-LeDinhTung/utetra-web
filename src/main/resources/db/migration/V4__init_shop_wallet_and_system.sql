-- =========================================================
-- V4: Tạo các bảng cho module Shop, Wallet, System (Thành viên C)
-- Lưu ý: Bảng shops đã được tạo ở V3, ở đây ta chỉ ALTER để thêm cột
-- =========================================================

-- 1. Bổ sung các cột còn thiếu vào bảng shops (do B tạo ở V3)
ALTER TABLE shops ADD COLUMN slug VARCHAR(255) UNIQUE;
ALTER TABLE shops ADD COLUMN avatar_url VARCHAR(500);
ALTER TABLE shops ADD COLUMN cover_url VARCHAR(500);
ALTER TABLE shops ADD COLUMN phone VARCHAR(20);
ALTER TABLE shops ADD COLUMN email VARCHAR(255);
ALTER TABLE shops ADD COLUMN address VARCHAR(500);
ALTER TABLE shops ADD COLUMN status VARCHAR(50) NOT NULL DEFAULT 'PENDING';
ALTER TABLE shops ADD COLUMN shop_level_id BIGINT;
ALTER TABLE shops ADD COLUMN rating_avg DECIMAL(3,2) DEFAULT 0;
ALTER TABLE shops ADD COLUMN follower_count INT DEFAULT 0;

-- 2. Tạo bảng Ví điện tử (Wallets)
CREATE TABLE IF NOT EXISTS wallets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id BIGINT NOT NULL UNIQUE,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    pending_balance DECIMAL(15,2) DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 3. Tạo bảng Lịch sử giao dịch ví (Wallet Transactions)
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wallet_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    note VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 4. Tạo bảng Yêu cầu rút tiền (Withdraw Requests)
CREATE TABLE IF NOT EXISTS withdraw_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wallet_id BIGINT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    bank_account VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 5. Tạo bảng Nhà vận chuyển (Shipping Providers)
CREATE TABLE IF NOT EXISTS shipping_providers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE,
    phone VARCHAR(20),
    base_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 6. Tạo bảng Cấp độ cửa hàng (Shop Levels)
CREATE TABLE IF NOT EXISTS shop_levels (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    commission_percent DECIMAL(5,2) DEFAULT 0,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    min_revenue DECIMAL(15,2) DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 7. Tạo bảng Chính sách hoa hồng (Commission Policies)
CREATE TABLE IF NOT EXISTS commission_policies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_level_id BIGINT,
    category_id BIGINT,
    percent DECIMAL(5,2) NOT NULL,
    effective_from DATETIME,
    effective_to DATETIME,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 8. Tạo bảng Nhân viên cửa hàng (Shop Staffs)
CREATE TABLE IF NOT EXISTS shop_staffs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(50) NOT NULL,
    joined_at DATETIME,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);

-- 9. Tạo bảng Ảnh cửa hàng (Shop Images)
CREATE TABLE IF NOT EXISTS shop_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id BIGINT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME(6),
    updated_at DATETIME(6)
);