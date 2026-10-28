-- =========================================================
-- V6: Seed dữ liệu Ví và Yêu cầu rút tiền cho Phần C
-- Dựa trên các Shop mẫu đã được tạo ở V5
-- =========================================================

-- 1. TẠO VÍ CHO 3 SHOP MẪU CỦA V5
-- (Shop 1: Đã có đơn DELIVERED 69,900đ, phí ship 15,000đ => Doanh thu 54,900đ)
INSERT INTO wallets (shop_id, balance, is_deleted, created_at, updated_at)
SELECT id, 54900, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM shops WHERE slug = 'part-b-demo-shop-1'
AND NOT EXISTS (SELECT 1 FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'));

-- (Shop 2: Cấp sẵn 200,000đ để test)
INSERT INTO wallets (shop_id, balance, is_deleted, created_at, updated_at)
SELECT id, 200000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM shops WHERE slug = 'part-b-demo-shop-2'
AND NOT EXISTS (SELECT 1 FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'));

-- (Shop 3: Cấp sẵn 100,000đ để test)
INSERT INTO wallets (shop_id, balance, is_deleted, created_at, updated_at)
SELECT id, 100000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM shops WHERE slug = 'part-b-demo-shop-3'
AND NOT EXISTS (SELECT 1 FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'));


-- 2. TẠO LỊCH SỬ GIAO DỊCH (WALLET TRANSACTIONS)
-- Ghi nhận thu nhập từ đơn hàng B-DEMO-DELIVERED cho Shop 1 (54,900đ)
INSERT INTO wallet_transactions (wallet_id, type, amount, balance_after, note, is_deleted, created_at, updated_at)
SELECT
    (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1')),
    'ORDER_INCOME',
    54900,
    54900,
    'Thu nhập từ đơn hàng B-DEMO-DELIVERED',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM wallet_transactions WHERE wallet_id = (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'))
);

-- Ghi nhận thu nhập mô phỏng cho Shop 2
INSERT INTO wallet_transactions (wallet_id, type, amount, balance_after, note, is_deleted, created_at, updated_at)
SELECT
    (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2')),
    'ORDER_INCOME',
    200000,
    200000,
    'Thu nhập mô phỏng',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM wallet_transactions WHERE wallet_id = (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'))
);

-- Ghi nhận thu nhập mô phỏng cho Shop 3
INSERT INTO wallet_transactions (wallet_id, type, amount, balance_after, note, is_deleted, created_at, updated_at)
SELECT
    (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3')),
    'ORDER_INCOME',
    100000,
    100000,
    'Thu nhập mô phỏng',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM wallet_transactions WHERE wallet_id = (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'))
);


-- 3. TẠO CÁC YÊU CẦU RÚT TIỀN (WITHDRAW REQUESTS)
-- Yêu cầu 1: Đang chờ duyệt (PENDING) của Shop 1
INSERT INTO withdraw_requests (wallet_id, amount, bank_account, status, is_deleted, created_at, updated_at)
SELECT
    (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1')),
    50000,
    '123456789 - Vietcombank',
    'PENDING',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM withdraw_requests WHERE wallet_id = (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'))
);

-- Yêu cầu 2: Đã duyệt (APPROVED) của Shop 2
INSERT INTO withdraw_requests (wallet_id, amount, bank_account, status, is_deleted, created_at, updated_at)
SELECT
    (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2')),
    100000,
    '987654321 - Techcombank',
    'APPROVED',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM withdraw_requests WHERE wallet_id = (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'))
);

-- Yêu cầu 3: Bị từ chối (REJECTED) của Shop 3
INSERT INTO withdraw_requests (wallet_id, amount, bank_account, status, is_deleted, created_at, updated_at)
SELECT
    (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3')),
    50000,
    '111222333 - BIDV',
    'REJECTED',
    FALSE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM withdraw_requests WHERE wallet_id = (SELECT id FROM wallets WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'))
);
