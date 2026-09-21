-- =========================================================
-- V2__seed_roles_and_levels.sql
-- Data mẫu: roles + user levels
-- =========================================================

-- Roles
INSERT INTO roles (name, created_at, updated_at) VALUES
    ('ROLE_GUEST',    NOW(), NOW()),
    ('ROLE_CUSTOMER', NOW(), NOW()),
    ('ROLE_VENDOR',   NOW(), NOW()),
    ('ROLE_ADMIN',    NOW(), NOW());

-- User levels
INSERT INTO user_levels (name, min_spent, discount_percent, description, created_at, updated_at) VALUES
    ('Đồng',       0,        0,  'Cấp độ mặc định',           NOW(), NOW()),
    ('Bạc',        500000,   3,  'Chiết khấu 3%',              NOW(), NOW()),
    ('Vàng',       2000000,  5,  'Chiết khấu 5%',              NOW(), NOW()),
    ('Kim cương',  5000000,  10, 'Chiết khấu 10%',             NOW(), NOW());