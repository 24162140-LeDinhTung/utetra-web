-- V5: Part B demonstration data for the group development database (MySQL 8.4).
-- Demo accounts only, password: PartB@123456. Do not use on a production database.
-- Runs after V1-V4 and BEFORE DataInitializer. Does not depend on initializer IDs.
-- Existing rows/passwords are never updated. No DELETE, TRUNCATE or schema changes.
-- Stable demo email/slug/code keys resolve all relationships; IDs are auto-generated.
-- NOT EXISTS guards also allow recovery if a previous import was interrupted.
-- Images are bundled demo illustrations, not uploads or real customer reviews.


-- 1. Independent test users and role mappings (no change to A/C existing users).

INSERT INTO users (email, password, full_name, status, email_verified, loyalty_points, is_deleted, created_at, updated_at)
SELECT 'partb.customer@utetra.test', '$2a$10$ZpROd14VrXLQ184VV.wa8.51eZWSqI7dSnB8wma0Gk1/wQV0C1OQS', 'Khách thử phần B', 'ACTIVE', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'partb.customer@utetra.test');

INSERT INTO user_roles (user_id, role_id)
SELECT (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM roles WHERE name = 'ROLE_CUSTOMER')
WHERE NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND role_id = (SELECT id FROM roles WHERE name = 'ROLE_CUSTOMER'));

INSERT INTO users (email, password, full_name, status, email_verified, loyalty_points, is_deleted, created_at, updated_at)
SELECT 'partb.vendor1@utetra.test', '$2a$10$ZpROd14VrXLQ184VV.wa8.51eZWSqI7dSnB8wma0Gk1/wQV0C1OQS', 'Chủ shop mẫu B 1', 'ACTIVE', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'partb.vendor1@utetra.test');

INSERT INTO user_roles (user_id, role_id)
SELECT (SELECT id FROM users WHERE email = 'partb.vendor1@utetra.test'), (SELECT id FROM roles WHERE name = 'ROLE_VENDOR')
WHERE NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = (SELECT id FROM users WHERE email = 'partb.vendor1@utetra.test') AND role_id = (SELECT id FROM roles WHERE name = 'ROLE_VENDOR'));

INSERT INTO users (email, password, full_name, status, email_verified, loyalty_points, is_deleted, created_at, updated_at)
SELECT 'partb.vendor2@utetra.test', '$2a$10$ZpROd14VrXLQ184VV.wa8.51eZWSqI7dSnB8wma0Gk1/wQV0C1OQS', 'Chủ shop mẫu B 2', 'ACTIVE', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'partb.vendor2@utetra.test');

INSERT INTO user_roles (user_id, role_id)
SELECT (SELECT id FROM users WHERE email = 'partb.vendor2@utetra.test'), (SELECT id FROM roles WHERE name = 'ROLE_VENDOR')
WHERE NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = (SELECT id FROM users WHERE email = 'partb.vendor2@utetra.test') AND role_id = (SELECT id FROM roles WHERE name = 'ROLE_VENDOR'));

INSERT INTO users (email, password, full_name, status, email_verified, loyalty_points, is_deleted, created_at, updated_at)
SELECT 'partb.admin@utetra.test', '$2a$10$ZpROd14VrXLQ184VV.wa8.51eZWSqI7dSnB8wma0Gk1/wQV0C1OQS', 'Quản trị thử phần B', 'ACTIVE', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'partb.admin@utetra.test');

INSERT INTO user_roles (user_id, role_id)
SELECT (SELECT id FROM users WHERE email = 'partb.admin@utetra.test'), (SELECT id FROM roles WHERE name = 'ROLE_ADMIN')
WHERE NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = (SELECT id FROM users WHERE email = 'partb.admin@utetra.test') AND role_id = (SELECT id FROM roles WHERE name = 'ROLE_ADMIN'));


-- 2. Minimal ACTIVE shop fixtures for B; wallet logic remains owned by C.

INSERT INTO shops (owner_id, name, slug, status, address, email, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM users WHERE email = 'partb.vendor1@utetra.test'), 'UTETra mẫu B - Thủ Đức', 'part-b-demo-shop-1', 'ACTIVE', 'Địa chỉ thử nghiệm - Thủ Đức', 'shop1@utetra.test', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE slug = 'part-b-demo-shop-1');

INSERT INTO shops (owner_id, name, slug, status, address, email, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM users WHERE email = 'partb.vendor1@utetra.test'), 'UTETra mẫu B - Bình Thạnh', 'part-b-demo-shop-2', 'ACTIVE', 'Địa chỉ thử nghiệm - Bình Thạnh', 'shop2@utetra.test', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE slug = 'part-b-demo-shop-2');

INSERT INTO shops (owner_id, name, slug, status, address, email, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM users WHERE email = 'partb.vendor2@utetra.test'), 'UTETra mẫu B - Quận 7', 'part-b-demo-shop-3', 'ACTIVE', 'Địa chỉ thử nghiệm - Quận 7', 'shop3@utetra.test', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM shops WHERE slug = 'part-b-demo-shop-3');


-- 3. Three categories, 12 ACTIVE products per shop, Size M/L and local images.

INSERT INTO categories (name, slug, is_deleted, created_at, updated_at)
SELECT 'Trà sữa (mẫu B)', 'part-b-demo-milk-tea', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'part-b-demo-milk-tea');

INSERT INTO categories (name, slug, is_deleted, created_at, updated_at)
SELECT 'Trà trái cây (mẫu B)', 'part-b-demo-fruit-tea', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'part-b-demo-fruit-tea');

INSERT INTO categories (name, slug, is_deleted, created_at, updated_at)
SELECT 'Món đặc biệt (mẫu B)', 'part-b-demo-special', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'part-b-demo-special');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa truyền thống', 'part-b-demo-s1-p01', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 30000, 97, 3, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p01');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa ô long', 'part-b-demo-s1-p02', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 31000, 99, 1, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p02');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa matcha', 'part-b-demo-s1-p03', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 32000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p03');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p03') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa socola', 'part-b-demo-s1-p04', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 33000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p04');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p04') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà đào cam sả', 'part-b-demo-s1-p05', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 34000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p05');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p05') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà vải', 'part-b-demo-s1-p06', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 35000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p06');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p06') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà chanh dây', 'part-b-demo-s1-p07', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 36000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p07');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p07') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà dâu', 'part-b-demo-s1-p08', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 37000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p08');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p08') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Sữa tươi trân châu', 'part-b-demo-s1-p09', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 38000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p09');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p09') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Matcha latte', 'part-b-demo-s1-p10', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 39000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p10');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p10') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Cacao sữa', 'part-b-demo-s1-p11', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 40000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p11');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Trà kem cheese', 'part-b-demo-s1-p12', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 1', 41000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s1-p12');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa truyền thống', 'part-b-demo-s2-p01', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 30000, 98, 2, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p01');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa ô long', 'part-b-demo-s2-p02', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 31000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p02');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p02') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa matcha', 'part-b-demo-s2-p03', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 32000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p03');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p03') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa socola', 'part-b-demo-s2-p04', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 33000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p04');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p04') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà đào cam sả', 'part-b-demo-s2-p05', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 34000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p05');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p05') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà vải', 'part-b-demo-s2-p06', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 35000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p06');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p06') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà chanh dây', 'part-b-demo-s2-p07', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 36000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p07');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p07') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà dâu', 'part-b-demo-s2-p08', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 37000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p08');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p08') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Sữa tươi trân châu', 'part-b-demo-s2-p09', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 38000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p09');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p09') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Matcha latte', 'part-b-demo-s2-p10', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 39000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p10');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p10') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Cacao sữa', 'part-b-demo-s2-p11', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 40000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p11');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Trà kem cheese', 'part-b-demo-s2-p12', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 2', 41000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s2-p12');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa truyền thống', 'part-b-demo-s3-p01', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 30000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p01');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa ô long', 'part-b-demo-s3-p02', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 31000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p02');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p02') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa matcha', 'part-b-demo-s3-p03', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 32000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p03');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p03') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Trà sữa socola', 'part-b-demo-s3-p04', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 33000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p04');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p04') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà đào cam sả', 'part-b-demo-s3-p05', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 34000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p05');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p05') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà vải', 'part-b-demo-s3-p06', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 35000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p06');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p06') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà chanh dây', 'part-b-demo-s3-p07', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 36000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p07');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p07') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-fruit-tea'), 'Trà dâu', 'part-b-demo-s3-p08', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 37000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p08');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p08') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Sữa tươi trân châu', 'part-b-demo-s3-p09', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 38000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p09');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p09') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Matcha latte', 'part-b-demo-s3-p10', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 39000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p10');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p10') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Cacao sữa', 'part-b-demo-s3-p11', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 40000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p11');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11') AND name = 'Size') AND value = 'L');

INSERT INTO products (shop_id, category_id, name, slug, description, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), (SELECT id FROM categories WHERE slug = 'part-b-demo-special'), 'Trà kem cheese', 'part-b-demo-s3-p12', 'Sản phẩm mẫu phần B, menu riêng cửa hàng 3', 41000, 100, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-s3-p12');

INSERT INTO product_images (product_id, image_url, is_default, sort_order, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12'), '/images/part-b-demo.svg', TRUE, 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_images WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12') AND image_url = '/images/part-b-demo.svg');

INSERT INTO product_attributes (product_id, name, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12'), 'Size', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12') AND name = 'Size');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12') AND name = 'Size'), 'M', 0, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12') AND name = 'Size') AND value = 'M');

INSERT INTO product_attribute_values (product_id, attribute_id, value, extra_price, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12'), (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12') AND name = 'Size'), 'L', 5000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_attribute_values WHERE attribute_id = (SELECT id FROM product_attributes WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12') AND name = 'Size') AND value = 'L');


-- 4. One pending product and one out-of-stock product for negative scenarios.

INSERT INTO products (shop_id, category_id, name, slug, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Món thử pending', 'part-b-demo-pending', 35000, 100, 0, 'PENDING', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-pending');

INSERT INTO products (shop_id, category_id, name, slug, price, stock, sold_count, status, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), (SELECT id FROM categories WHERE slug = 'part-b-demo-milk-tea'), 'Món thử out-of-stock', 'part-b-demo-out-of-stock', 35000, 0, 0, 'ACTIVE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'part-b-demo-out-of-stock');


-- 5. Shop-specific vouchers and promotions. Dates are relative to installation.

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), 'BDEMO1SAVE10', 'PRODUCT', 'PERCENT', 10, 50000, 20000, 100, 1, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO1SAVE10');

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), 'BDEMO1SHIP', 'SHIPPING', 'FIXED', 15000, 50000, 15000, 100, 0, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO1SHIP');

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), 'BDEMO1EXPIRED', 'PRODUCT', 'FIXED', 5000, 0, 5000, 100, 0, TIMESTAMPADD(DAY, -30, CURRENT_TIMESTAMP), TIMESTAMPADD(DAY, -1, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO1EXPIRED');

INSERT INTO promotions (shop_id, name, promotion_type, discount_type, discount_value, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), 'B-DEMO-S1-PROMO10', 'PERCENT', 'PERCENT', 10, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND name = 'B-DEMO-S1-PROMO10');

INSERT INTO promotion_products (promotion_id, product_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND name = 'B-DEMO-S1-PROMO10'), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotion_products WHERE promotion_id = (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND name = 'B-DEMO-S1-PROMO10') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p11'));

INSERT INTO promotion_products (promotion_id, product_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND name = 'B-DEMO-S1-PROMO10'), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotion_products WHERE promotion_id = (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND name = 'B-DEMO-S1-PROMO10') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p12'));

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), 'BDEMO2SAVE10', 'PRODUCT', 'PERCENT', 10, 50000, 20000, 100, 0, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO2SAVE10');

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), 'BDEMO2SHIP', 'SHIPPING', 'FIXED', 15000, 50000, 15000, 100, 0, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO2SHIP');

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), 'BDEMO2EXPIRED', 'PRODUCT', 'FIXED', 5000, 0, 5000, 100, 0, TIMESTAMPADD(DAY, -30, CURRENT_TIMESTAMP), TIMESTAMPADD(DAY, -1, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO2EXPIRED');

INSERT INTO promotions (shop_id, name, promotion_type, discount_type, discount_value, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), 'B-DEMO-S2-PROMO10', 'PERCENT', 'PERCENT', 10, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND name = 'B-DEMO-S2-PROMO10');

INSERT INTO promotion_products (promotion_id, product_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND name = 'B-DEMO-S2-PROMO10'), (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotion_products WHERE promotion_id = (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND name = 'B-DEMO-S2-PROMO10') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p11'));

INSERT INTO promotion_products (promotion_id, product_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND name = 'B-DEMO-S2-PROMO10'), (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotion_products WHERE promotion_id = (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND name = 'B-DEMO-S2-PROMO10') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p12'));

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), 'BDEMO3SAVE10', 'PRODUCT', 'PERCENT', 10, 50000, 20000, 100, 0, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO3SAVE10');

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), 'BDEMO3SHIP', 'SHIPPING', 'FIXED', 15000, 50000, 15000, 100, 0, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO3SHIP');

INSERT INTO vouchers (shop_id, code, voucher_type, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, used_count, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), 'BDEMO3EXPIRED', 'PRODUCT', 'FIXED', 5000, 0, 5000, 100, 0, TIMESTAMPADD(DAY, -30, CURRENT_TIMESTAMP), TIMESTAMPADD(DAY, -1, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM vouchers WHERE code = 'BDEMO3EXPIRED');

INSERT INTO promotions (shop_id, name, promotion_type, discount_type, discount_value, start_date, end_date, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), 'B-DEMO-S3-PROMO10', 'PERCENT', 'PERCENT', 10, CURRENT_DATE, TIMESTAMPADD(DAY, 365, CURRENT_TIMESTAMP), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3') AND name = 'B-DEMO-S3-PROMO10');

INSERT INTO promotion_products (promotion_id, product_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3') AND name = 'B-DEMO-S3-PROMO10'), (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotion_products WHERE promotion_id = (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3') AND name = 'B-DEMO-S3-PROMO10') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p11'));

INSERT INTO promotion_products (promotion_id, product_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3') AND name = 'B-DEMO-S3-PROMO10'), (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM promotion_products WHERE promotion_id = (SELECT id FROM promotions WHERE shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3') AND name = 'B-DEMO-S3-PROMO10') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p12'));


-- 6. Customer carts in two shops; two variants of the same product.

INSERT INTO carts (user_id, shop_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'));

INSERT INTO cart_items (cart_id, product_id, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND is_deleted = FALSE LIMIT 1), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), 1, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM cart_items WHERE cart_id = (SELECT id FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND is_deleted = FALSE LIMIT 1) AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND selected_attributes = '{"Size":"M"}');

INSERT INTO cart_items (cart_id, product_id, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND is_deleted = FALSE LIMIT 1), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), 1, '{"Size":"L"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM cart_items WHERE cart_id = (SELECT id FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1') AND is_deleted = FALSE LIMIT 1) AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND selected_attributes = '{"Size":"L"}');

INSERT INTO carts (user_id, shop_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'));

INSERT INTO cart_items (cart_id, product_id, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND is_deleted = FALSE LIMIT 1), (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'), 1, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM cart_items WHERE cart_id = (SELECT id FROM carts WHERE user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test') AND shop_id = (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2') AND is_deleted = FALSE LIMIT 1) AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01') AND selected_attributes = '{"Size":"M"}');


-- 7. Four simulated COD orders. No online gateway or wallet transaction is created.

INSERT INTO orders (order_code, user_id, shop_id, subtotal, discount_amount, shipping_fee, total_amount, status, payment_method, payment_status, shipping_address, is_deleted, created_at, updated_at)
SELECT 'B-DEMO-CONFIRMED', (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), 60000, 0, 15000, 75000, 'CONFIRMED', 'COD', 'PENDING', 'Khách thử phần B - địa chỉ mô phỏng, không giao hàng thật', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE order_code = 'B-DEMO-CONFIRMED');

INSERT INTO order_items (order_id, product_id, product_name, product_image, unit_price, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED'), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), 'Trà sữa truyền thống', '/images/part-b-demo.svg', 30000, 2, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'));

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED'), 'NEW', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED') AND status = 'NEW');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED'), 'CONFIRMED', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED') AND status = 'CONFIRMED');

INSERT INTO payment_transactions (order_id, reference, provider, status, amount, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CONFIRMED'), 'B-DEMO-PAY-CONFIRMED', 'COD', 'PENDING', 75000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM payment_transactions WHERE reference = 'B-DEMO-PAY-CONFIRMED');

INSERT INTO orders (order_code, user_id, shop_id, subtotal, discount_amount, shipping_fee, total_amount, status, payment_method, payment_status, shipping_address, is_deleted, created_at, updated_at)
SELECT 'B-DEMO-SHIPPING', (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-2'), 60000, 0, 15000, 75000, 'SHIPPING', 'COD', 'PENDING', 'Khách thử phần B - địa chỉ mô phỏng, không giao hàng thật', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE order_code = 'B-DEMO-SHIPPING');

INSERT INTO order_items (order_id, product_id, product_name, product_image, unit_price, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING'), (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'), 'Trà sữa truyền thống', '/images/part-b-demo.svg', 30000, 2, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s2-p01'));

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING'), 'NEW', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING') AND status = 'NEW');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING'), 'CONFIRMED', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING') AND status = 'CONFIRMED');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING'), 'PICKED_UP', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING') AND status = 'PICKED_UP');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING'), 'SHIPPING', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING') AND status = 'SHIPPING');

INSERT INTO payment_transactions (order_id, reference, provider, status, amount, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-SHIPPING'), 'B-DEMO-PAY-SHIPPING', 'COD', 'PENDING', 75000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM payment_transactions WHERE reference = 'B-DEMO-PAY-SHIPPING');

INSERT INTO orders (order_code, user_id, shop_id, subtotal, discount_amount, shipping_fee, total_amount, status, payment_method, payment_status, shipping_address, is_deleted, created_at, updated_at)
SELECT 'B-DEMO-DELIVERED', (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-1'), 61000, 6100, 15000, 69900, 'DELIVERED', 'COD', 'SUCCESS', 'Khách thử phần B - địa chỉ mô phỏng, không giao hàng thật', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE order_code = 'B-DEMO-DELIVERED');

INSERT INTO order_items (order_id, product_id, product_name, product_image, unit_price, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), 'Trà sữa truyền thống', '/images/part-b-demo.svg', 30000, 1, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'));

INSERT INTO order_items (order_id, product_id, product_name, product_image, unit_price, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02'), 'Trà sữa ô long', '/images/part-b-demo.svg', 31000, 1, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p02'));

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), 'NEW', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND status = 'NEW');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), 'CONFIRMED', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND status = 'CONFIRMED');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), 'PICKED_UP', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND status = 'PICKED_UP');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), 'SHIPPING', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND status = 'SHIPPING');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), 'DELIVERED', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND status = 'DELIVERED');

INSERT INTO payment_transactions (order_id, reference, provider, status, amount, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), 'B-DEMO-PAY-DELIVERED', 'COD', 'SUCCESS', 69900, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM payment_transactions WHERE reference = 'B-DEMO-PAY-DELIVERED');

INSERT INTO voucher_usages (voucher_id, user_id, order_id, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM vouchers WHERE code = 'BDEMO1SAVE10'), (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED'), FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM voucher_usages WHERE voucher_id = (SELECT id FROM vouchers WHERE code = 'BDEMO1SAVE10') AND order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-DELIVERED') AND user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'));

INSERT INTO orders (order_code, user_id, shop_id, subtotal, discount_amount, shipping_fee, total_amount, status, payment_method, payment_status, shipping_address, is_deleted, created_at, updated_at)
SELECT 'B-DEMO-CANCELLED', (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), (SELECT id FROM shops WHERE slug = 'part-b-demo-shop-3'), 60000, 0, 15000, 75000, 'CANCELLED', 'COD', 'FAILED', 'Khách thử phần B - địa chỉ mô phỏng, không giao hàng thật', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM orders WHERE order_code = 'B-DEMO-CANCELLED');

INSERT INTO order_items (order_id, product_id, product_name, product_image, unit_price, quantity, selected_attributes, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED'), (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01'), 'Trà sữa truyền thống', '/images/part-b-demo.svg', 30000, 2, '{"Size":"M"}', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED') AND product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s3-p01'));

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED'), 'NEW', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED') AND status = 'NEW');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED'), 'CONFIRMED', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED') AND status = 'CONFIRMED');

INSERT INTO order_status_history (order_id, status, note, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED'), 'CANCELLED', 'B-DEMO: trạng thái mô phỏng để kiểm thử', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_id = (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED') AND status = 'CANCELLED');

INSERT INTO payment_transactions (order_id, reference, provider, status, amount, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM orders WHERE order_code = 'B-DEMO-CANCELLED'), 'B-DEMO-PAY-CANCELLED', 'COD', 'FAILED', 75000, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM payment_transactions WHERE reference = 'B-DEMO-PAY-CANCELLED');


-- 8. A demo review for delivered product 1; product 2 remains available to review.

INSERT INTO product_reviews (product_id, user_id, rating, comment, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01'), (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'), 5, 'Đánh giá mô phỏng phần B: trà thơm, vị ngọt vừa phải, đóng gói cẩn thận và giao hàng đúng hẹn.', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM product_reviews WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test'));

INSERT INTO review_media (review_id, media_url, media_type, is_deleted, created_at, updated_at)
SELECT (SELECT id FROM product_reviews WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test')), '/images/part-b-demo.svg', 'IMAGE', FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM review_media WHERE review_id = (SELECT id FROM product_reviews WHERE product_id = (SELECT id FROM products WHERE slug = 'part-b-demo-s1-p01') AND user_id = (SELECT id FROM users WHERE email = 'partb.customer@utetra.test')) AND media_url = '/images/part-b-demo.svg');
