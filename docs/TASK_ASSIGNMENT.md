> Cập nhật theo yêu cầu người dùng 29/10/2026: khuyến mãi sản phẩm phải được khách chọn tại checkout rồi bấm Tính lại tổng tiền; không tự áp dụng. Voucher nhập riêng. Chi tiết: MANUAL_PROMOTIONS_2026-10-29.md. Các mô tả cũ khác với quy tắc này là yêu cầu lịch sử.

> Điều chỉnh được người dùng yêu cầu ngày 29/10/2026: đánh giá vẫn cần sản phẩm đã mua trong đơn đã giao, nhưng bỏ tối thiểu 50 ký tự và bắt buộc ảnh/video. Cho phép chỉ chấm sao; nội dung phân công gốc bên dưới được giữ để tham khảo lịch sử.

# 📋 PHÂN CÔNG NHIỆM VỤ — DỰ ÁN UTETRA

> **Đồ án cuối kỳ môn Lập trình Web**
> Website chuỗi bán trà sữa UTETra
> Spring Boot 4.1.1 + JSP + JSTL + Sitemesh + Bootstrap + JPA + MySQL + JWT + WebSocket + Cloudinary

---

## 🎯 TỔNG QUAN

- **Số thành viên:** 3
- **Thời gian:** 6 tuần
- **Công nghệ:** Java 21, Spring Boot 4.1.1, MySQL 8.4, Docker
- **Actor:** Guest, Customer, Vendor, Admin
- **Tổng số bảng:** 37
- **Template:** 01 template Bootstrap dùng chung

---

## 🎭 CÁC ACTOR TRONG HỆ THỐNG

| # | Actor | Mô tả |
|---|---|---|
| 1 | **Guest** | Khách chưa đăng nhập — xem sản phẩm, shop, user |
| 2 | **Customer** | Khách hàng đã đăng nhập — mua hàng, quản lý tài khoản |
| 3 | **Vendor** | Người bán — quản lý shop, sản phẩm, đơn hàng |
| 4 | **Admin** | Quản trị viên — quản lý toàn hệ thống |

---

## 👤 THÀNH VIÊN A — GUEST + CUSTOMER + AUTH

### 📦 Module sở hữu (11 bảng)

**Nhóm User & Auth:**
- `users`, `roles`, `user_roles`, `user_levels`, `addresses`
- `otp_tokens`, `refresh_tokens`

**Nhóm Tương tác:**
- `product_favorites`, `shop_follows`, `product_view_logs`
- `notifications`

### 🎯 Chức năng chi tiết

#### 1. Chức năng chung — Auth (dùng cho mọi actor)
| STT | Chức năng | Mô tả | API |
|---|---|---|---|
| 1 | Đăng ký + OTP | Đăng ký tài khoản, gửi OTP qua email | `POST /api/auth/register` |
| 2 | Xác thực OTP | Nhập OTP kích hoạt tài khoản | `POST /api/auth/verify-otp` |
| 3 | Đăng nhập | Đăng nhập, trả về JWT | `POST /api/auth/login` |
| 4 | Đăng xuất | Revoke refresh token | `POST /api/auth/logout` |
| 5 | Quên mật khẩu | Gửi OTP qua email | `POST /api/auth/forgot-password` |
| 6 | Đặt lại mật khẩu | Nhập OTP + mật khẩu mới | `POST /api/auth/reset-password` |
| 7 | Mã hóa mật khẩu | Dùng BCryptPasswordEncoder | — |
| 8 | Spring Security | Phân quyền 4 role | — |

#### 2. Guest
| STT | Chức năng | Mô tả | API |
|---|---|---|---|
| 1 | Trang chủ | Sản phẩm bán >10 sp/shop, sort giảm dần | `GET /` |
| 2 | Xem/Tìm kiếm sản phẩm | Danh sách + chi tiết | `GET /api/products` |
| 3 | Xem/Tìm kiếm cửa hàng | Danh sách + chi tiết shop | `GET /api/shops` |
| 4 | Xem/Tìm kiếm người dùng | Danh sách + trang user public | `GET /api/users/{id}/public` |

#### 3. Customer
| STT | Chức năng | Mô tả | API |
|---|---|---|---|
| 1 | Đăng nhập | — | `POST /api/auth/login` |
| 2 | Đăng xuất | — | `POST /api/auth/logout` |
| 3 | Tạo mật khẩu mới | Quên mật khẩu qua email + OTP | `POST /api/auth/reset-password` |
| 4 | Quản lý tài khoản cá nhân | Đổi mật khẩu | `POST /api/customer/change-password` |
| 5 | Quản lý thông tin cá nhân | Sửa thông tin, avatar, ảnh bìa | `GET/PUT /api/customer/profile` |
| 6 | Quản lý địa chỉ | CRUD địa chỉ, đặt mặc định | `/api/customer/addresses` |
| 7 | Quản lý đơn hàng | Lịch sử, theo dõi, hủy | `GET /api/customer/orders` |
| 8 | Quản lý giỏ hàng | Xem, thêm, cập nhật | `/api/customer/cart` |
| 9 | Đặt hàng | Đặt hàng, thanh toán | `POST /api/customer/orders` |
| 10 | Phản hồi, đánh giá | Comment ≥ 50 ký tự + ảnh/video | `POST /api/customer/reviews` |
| 11 | Theo dõi sản phẩm | Yêu thích sản phẩm | `POST /api/customer/favorites/products` |
| 12 | Theo dõi cửa hàng | Yêu thích shop | `POST /api/customer/favorites/shops` |

#### 4. Giao diện (JSP)
- [ ] `views/guest/home.jsp` — Trang chủ
- [ ] `views/guest/product-list.jsp` — Danh sách sản phẩm
- [ ] `views/guest/product-detail.jsp` — Chi tiết sản phẩm
- [ ] `views/guest/shop-list.jsp` — Danh sách shop
- [ ] `views/guest/shop-detail.jsp` — Chi tiết shop
- [ ] `views/guest/user-public-profile.jsp` — Trang user public
- [ ] `views/auth/login.jsp`, `register.jsp`, `verify-otp.jsp`
- [ ] `views/auth/forgot-password.jsp`, `reset-password.jsp`
- [ ] `views/customer/profile.jsp`, `change-password.jsp`
- [ ] `views/customer/address-list.jsp`, `address-form.jsp`
- [ ] `views/customer/cart.jsp`, `checkout.jsp`
- [ ] `views/customer/order-history.jsp`, `order-detail.jsp`
- [ ] `views/customer/review-form.jsp`
- [ ] `views/customer/favorite-products.jsp`, `favorite-shops.jsp`
- [ ] `views/customer/viewed-products.jsp`
- [ ] `views/error/403.jsp`, `404.jsp`, `500.jsp`

#### 5. Template Bootstrap
- [ ] Chọn 01 template Bootstrap (NiceAdmin / Sneat / Soft UI Dashboard)
- [ ] Setup vào `webapp/static/`
- [ ] Tạo decorator `main-decorator.jsp`, `auth-decorator.jsp`
- [ ] **Thông báo cho B và C dùng chung**

### 📚 Deliverables
- `AuthService`, `UserService`, `AddressService`, `OtpService`, `MailService`, `CloudinaryService`, `FavoriteService`, `FollowService`, `NotificationService`
- `SecurityConfig`, `JwtProvider`, `JwtAuthenticationFilter`, `CustomUserDetailsService`
- Decorator `main`, `auth`
- Template Bootstrap dùng chung

### 📅 Timeline

| Tuần | Công việc |
|---|---|
| 1 | BaseEntity, Enum, Auth entities, Template Bootstrap |
| 2 | Register+OTP, Login+JWT, Logout, Forgot password |
| 3 | Guest home, Search, Profile, Address |
| 4 | Favorite, Follow, View log, Notification |
| 5 | Review, Comment, Bình luận |
| 6 | Test, fix bug, viết báo cáo |

---

## 👤 THÀNH VIÊN B — PRODUCT + CART + ORDER + PAYMENT

### 📦 Module sở hữu (16 bảng)

**Nhóm Sản phẩm:**
- `categories`, `products`, `product_images`
- `product_attributes`, `product_attribute_values`
- `product_reviews`, `review_media`

**Nhóm Giỏ hàng & Đơn hàng:**
- `carts`, `cart_items`
- `orders`, `order_items`, `order_status_history`

**Nhóm Voucher + Promotion:**
- `vouchers`, `voucher_usages`
- `promotions`, `promotion_products`

### 🎯 Chức năng chi tiết

#### 1. Sản phẩm
| STT | Chức năng | API |
|---|---|---|
| 1 | CRUD sản phẩm (Vendor) | `/api/vendor/products` |
| 2 | Danh sách sản phẩm (Guest/Customer) | `GET /api/products` |
| 3 | Chi tiết sản phẩm | `GET /api/products/{id}` |
| 4 | Tìm kiếm & lọc sản phẩm | `GET /api/products?search=&category=&sort=` |
| 5 | Quản lý danh mục (Admin) | CRUD `/api/admin/categories` |
| 6 | Quản lý thuộc tính sản phẩm (Admin) | CRUD `/api/admin/attributes` |
| 7 | Upload ảnh sản phẩm | Cloudinary |

#### 2. Giỏ hàng (lưu DB)
| STT | Chức năng | API |
|---|---|---|
| 1 | Xem giỏ hàng | `GET /api/customer/cart` |
| 2 | Thêm sản phẩm | `POST /api/customer/cart/items` |
| 3 | Cập nhật số lượng | `PUT /api/customer/cart/items/{id}` |
| 4 | Xóa sản phẩm | `DELETE /api/customer/cart/items/{id}` |

#### 3. Đặt hàng & Thanh toán
| STT | Chức năng | API |
|---|---|---|
| 1 | Đặt hàng | `POST /api/customer/orders` |
| 2 | Thanh toán COD | — |
| 3 | Thanh toán VNPAY | `POST /api/payment/vnpay` |
| 4 | Thanh toán MOMO | `POST /api/payment/momo` |
| 5 | Callback VNPAY/MOMO | `POST /api/payment/callback` |
| 6 | Cập nhật trạng thái đơn | `PATCH /api/vendor/orders/{id}/status` |
| 7 | Hủy đơn | `POST /api/customer/orders/{id}/cancel` |
| 8 | WebSocket notify | `/topic/order/{orderId}/status` |

**Trạng thái đơn hàng:**
`NEW → CONFIRMED → PICKED_UP → SHIPPING → DELIVERED`
`CANCELLED / RETURNED / REFUNDED`

#### 4. Đánh giá & Khuyến mãi
| STT | Chức năng | API |
|---|---|---|
| 1 | Đánh giá sản phẩm đã mua | `POST /api/customer/reviews` |
| 2 | Comment ≥ 50 ký tự + ảnh/video | — |
| 3 | Tạo voucher | CRUD `/api/vendor/vouchers` |
| 4 | Tạo promotion | CRUD `/api/vendor/promotions` |
| 5 | Giảm % sản phẩm | — |
| 6 | Giảm phí vận chuyển | — |

#### 5. Giao diện (JSP)
- [ ] `views/vendor/product-list.jsp`, `product-form.jsp`
- [ ] `views/vendor/order-list.jsp`, `order-detail.jsp`
- [ ] `views/vendor/voucher-list.jsp`, `promotion-list.jsp`
- [ ] `views/admin/category-list.jsp`, `category-form.jsp`
- [ ] `views/admin/attribute-list.jsp`, `attribute-form.jsp`
- [ ] `views/customer/checkout.jsp`, `payment.jsp`

### 📚 Deliverables
- `ProductService`, `CategoryService`, `CartService`, `OrderService`, `PaymentService`, `VoucherService`, `PromotionService`, `ReviewService`
- Tích hợp VNPAY/MOMO
- WebSocket topics: `/topic/shop/{shopId}/orders`, `/topic/order/{orderId}/status`

### 📅 Timeline

| Tuần | Công việc |
|---|---|
| 1 | Product, Order, Cart, Voucher entities |
| 2 | Product CRUD, Search, Category CRUD |
| 3 | Cart DB, Order create, COD |
| 4 | VNPAY/MOMO, Order status, WebSocket |
| 5 | Voucher, Promotion, Statistics |
| 6 | Test, fix bug |

---

## 👤 THÀNH VIÊN C — VENDOR + ADMIN + WALLET + STATISTICS

### 📦 Module sở hữu (10 bảng)

**Nhóm Shop & Vendor:**
- `shops`, `shop_levels`, `shop_staffs`, `shop_images`

**Nhóm Thanh toán & Ví:**
- `wallets`, `wallet_transactions`
- `transactions`, `withdraw_requests`

**Nhóm Vận chuyển & Hoa hồng:**
- `shipping_providers`, `commission_policies`

### 🎯 Chức năng chi tiết

#### 1. Vendor (Người bán)
| STT | Chức năng | API |
|---|---|---|
| 1 | Tạo cửa hàng mới | `POST /api/vendor/shops` |
| 2 | Quản lý shop cá nhân | `GET /api/vendor/shops` |
| 3 | Quản lý thông tin shop | `PUT /api/vendor/shops/{id}` |
| 4 | Upload avatar/cover/feature | Cloudinary |
| 5 | Quản lý nhân viên | CRUD `/api/vendor/shops/{id}/staffs` |
| 6 | Quản lý đơn hàng shop | `GET /api/vendor/orders` |
| 7 | Cập nhật trạng thái đơn | `PATCH /api/vendor/orders/{id}/status` |
| 8 | Quản lý sản phẩm shop | CRUD `/api/vendor/products` |
| 9 | Quản lý ví shop | `GET /api/vendor/wallet` |
| 10 | Xem lịch sử giao dịch | `GET /api/vendor/wallet/transactions` |
| 11 | Rút tiền | `POST /api/vendor/withdraw-requests` |
| 12 | Thống kê doanh thu | `GET /api/vendor/statistics/revenue` |

#### 2. Admin (Quản trị viên)
| STT | Chức năng | API |
|---|---|---|
| 1 | Thống kê doanh thu | `GET /api/admin/statistics/revenue` |
| 2 | Thống kê người dùng mới | `GET /api/admin/statistics/users` |
| 3 | Thống kê cửa hàng mới | `GET /api/admin/statistics/shops` |
| 4 | Quản lý người dùng | `GET /api/admin/users` |
| 5 | Quản lý cửa hàng | `GET /api/admin/shops` |
| 6 | Duyệt/cấm cửa hàng | `PATCH /api/admin/shops/{id}/status` |
| 7 | Quản lý sản phẩm | `GET /api/admin/products` |
| 8 | Duyệt/cấm sản phẩm | `PATCH /api/admin/products/{id}/status` |
| 9 | Quản lý đơn hàng | `GET /api/admin/orders` |
| 10 | Cập nhật trạng thái đơn | `PATCH /api/admin/orders/{id}/status` |
| 11 | Quản lý cấp độ user | CRUD `/api/admin/user-levels` |
| 12 | Quản lý cấp độ shop | CRUD `/api/admin/shop-levels` |
| 13 | Quản lý loại sản phẩm | CRUD `/api/admin/categories` |
| 14 | Quản lý thuộc tính SP | CRUD `/api/admin/attributes` |
| 15 | Quản lý đơn vị vận chuyển | CRUD `/api/admin/shipping-providers` |
| 16 | Quản lý chính sách hoa hồng | CRUD `/api/admin/commission-policies` |
| 17 | Quản lý giao dịch | `GET /api/admin/transactions` |
| 18 | Quản lý chương trình khuyến mãi | CRUD `/api/admin/promotions` |

**Loại thống kê:**
- Thời gian: `HOUR | DAY | MONTH | YEAR`
- Biểu đồ: `LINE | BAR | PIE`

#### 3. Giao diện (JSP)
- [ ] `views/vendor/dashboard.jsp`
- [ ] `views/vendor/shop-list.jsp`, `shop-form.jsp`
- [ ] `views/vendor/staff-list.jsp`, `staff-form.jsp`
- [ ] `views/vendor/order-list.jsp`, `order-detail.jsp`
- [ ] `views/vendor/wallet.jsp`, `withdraw-request.jsp`
- [ ] `views/vendor/statistics-revenue.jsp`
- [ ] `views/admin/dashboard.jsp`
- [ ] `views/admin/user-list.jsp`, `user-detail.jsp`
- [ ] `views/admin/shop-list.jsp`, `shop-detail.jsp`
- [ ] `views/admin/product-list.jsp`, `product-detail.jsp`
- [ ] `views/admin/order-list.jsp`, `order-detail.jsp`
- [ ] `views/admin/category-list.jsp`, `category-form.jsp`
- [ ] `views/admin/attribute-list.jsp`, `attribute-form.jsp`
- [ ] `views/admin/shipping-list.jsp`, `shipping-form.jsp`
- [ ] `views/admin/commission-list.jsp`, `commission-form.jsp`
- [ ] `views/admin/user-level-list.jsp`, `shop-level-list.jsp`
- [ ] `views/admin/promotion-list.jsp`, `promotion-form.jsp`
- [ ] `views/admin/transaction-list.jsp`
- [ ] `views/admin/statistics-revenue.jsp`
- [ ] `views/admin/statistics-user.jsp`
- [ ] `views/admin/statistics-shop.jsp`

### 📚 Deliverables
- `ShopService`, `ShopStaffService`, `WalletService`, `TransactionService`, `WithdrawService`, `ShippingProviderService`, `CommissionPolicyService`, `StatisticsService`, `AdminService`
- Decorator `vendor`, `admin`
- Chart.js dashboards

### 📅 Timeline

| Tuần | Công việc |
|---|---|
| 1 | Shop, Wallet, Shipping entities, Chart.js setup |
| 2 | Shop CRUD, Staff, Upload Cloudinary |
| 3 | Vendor order, Wallet, Withdraw |
| 4 | Admin CRUD user/shop/product/order |
| 5 | Admin statistics, Chart.js |
| 6 | Test, fix bug |

---

## 📊 BẢNG TỔNG HỢP PHÂN CÔNG

| Actor | Thành viên | Số bảng | Số chức năng |
|---|---|---|---|
| **Guest** | A | (dùng chung) | 4 |
| **Customer** | A | 11 | 12 |
| **Auth** | A | (dùng chung) | 8 |
| **Vendor** | B + C | 23 + 10 | 12 |
| **Admin** | C | (dùng chung) | 18 |

> **Lưu ý:** Vendor được chia giữa B và C:
> - **B** làm phần **sản phẩm, đơn hàng, khuyến mãi** của Vendor
> - **C** làm phần **shop, ví, doanh thu** của Vendor

---

## 🔗 DEPENDENCY — AI PHỤ THUỘC AI
