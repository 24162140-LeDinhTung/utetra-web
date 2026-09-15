# 📘 TÀI LIỆU THIẾT KẾ HỆ THỐNG UTETRA
### Website chuỗi bán trà sữa — Đồ án cuối kỳ Lập trình Web

---

## PHẦN 1. CÔNG NGHỆ BẮT BUỘC SỬ DỤNG

### 1.1. Phiên bản chốt

| Thành phần | Phiên bản | Ghi chú |
|---|---|---|
| **Java** | **21 (LTS)** | Hỗ trợ Virtual Threads, ổn định đến 2031 |
| **Spring Boot** | **3.3.x** | Bản ổn định, hỗ trợ Java 21 |
| **Spring Security** | 6.x | Đi kèm Spring Boot 3.3 |
| **Spring Data JPA** | 3.x | Hibernate 6.x |
| **MySQL** | **8.4 LTS** | KHÔNG dùng 9.x (bản Innovation, không LTS) |
| **Build tool** | Maven | |
| **IDE** | Spring Tool Suite 4.28.0 | |
| **JDK** | OpenJDK 21 (Temurin / Zulu) | |

### 1.2. Danh sách công nghệ & mục đích

| # | Công nghệ | Sử dụng ở đâu |
|---|---|---|
| 1 | **Spring Boot** | Khung backend toàn hệ thống |
| 2 | **JSP + JSTL** | View layer (render HTML server-side) |
| 3 | **Sitemesh 3** | Decorator — layout dùng chung (main/vendor/admin) |
| 4 | **Bootstrap 5** | UI/UX responsive |
| 5 | **Spring Data JPA** | ORM, mapping entity ↔ table |
| 6 | **MySQL 8.4 LTS** | Cơ sở dữ liệu quan hệ |
| 7 | **Spring Security + JWT** | Xác thực & phân quyền 4 role |
| 8 | **WebSocket (STOMP + SockJS)** | Thông báo realtime (đơn hàng, chat) |
| 9 | **Cloudinary** | Lưu trữ ảnh/video (avatar, cover, sản phẩm, review) |
| 10 | **JavaMailSender** | Gửi OTP qua email |
| 11 | **Lombok** | Giảm boilerplate |
| 12 | **MapStruct** | Mapping DTO ↔ Entity |
| 13 | **Chart.js** | Biểu đồ thống kê Admin/Vendor |
| 14 | **Docker Compose** | Chạy MySQL đồng nhất cho cả nhóm |
| 15 | **Flyway** (khuyến nghị) | Migration DB versioning |
| 16 | **JJWT 0.12.x** | Tạo & verify JWT token |

### 1.3. Dependency chính trong `pom.xml`

```xml
<properties>
    <java.version>21</java.version>
    <jjwt.version>0.12.6</jjwt.version>
    <sitemesh.version>3.0.1</sitemesh.version>
    <mapstruct.version>1.6.3</mapstruct.version>
</properties>

<!-- Web, JSP, Sitemesh -->
spring-boot-starter-web
spring-boot-starter-security
spring-boot-starter-data-jpa
spring-boot-starter-validation
spring-boot-starter-mail
spring-boot-starter-websocket
spring-boot-starter-thymeleaf (không dùng nhưng đi kèm jstl)
tomcat-embed-jasper
jakarta.servlet.jsp.jstl-api
org.glassfish.web:jakarta.servlet.jsp.jstl
org.sitemesh:sitemesh:3.0.1

<!-- Database -->
mysql-connector-j
flyway-core

<!-- JWT -->
io.jsonwebtoken:jjwt-api:0.12.6
io.jsonwebtoken:jjwt-impl:0.12.6
io.jsonwebtoken:jjwt-jackson:0.12.6

<!-- Cloudinary -->
com.cloudinary:cloudinary-http45

<!-- Utilities -->
lombok
mapstruct
```

---

## PHẦN 2. KIẾN TRÚC HỆ THỐNG — MÔ HÌNH 3 TẦNG

### 2.1. Sơ đồ tổng quan

```
┌────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Browser (HTML/CSS/JS)                                   │  │
│  │  └─ JSP + JSTL + Bootstrap + Sitemesh Decorator          │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │ HTTP/HTTPS                    │ WebSocket (STOMP)  │
│           ▼                               ▼                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Controller Layer (@Controller / @RestController)        │  │
│  │  - GuestController, AuthController, CustomerController,  │  │
│  │    VendorController, AdminController, RestApiController  │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Security Layer                                          │  │
│  │  - JwtAuthenticationFilter → SecurityContext             │  │
│  │  - CustomUserDetailsService                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                       BUSINESS LAYER                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Service Interface + ServiceImpl                         │  │
│  │  - UserService, AuthService, ProductService,             │  │
│  │    OrderService, CartService, VoucherService,            │  │
│  │    ShopService, WalletService, PaymentService,           │  │
│  │    NotificationService, CloudinaryService, MailService   │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  - Business logic, Transaction (@Transactional)          │  │
│  │  - DTO Mapping (MapStruct)                               │  │
│  │  - Exception handling                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────────────┐
│                      DATA ACCESS LAYER                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Repository (Spring Data JPA)                            │  │
│  │  - UserRepository, ProductRepository, OrderRepository... │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  Entity (JPA @Entity) — extends BaseEntity               │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  External: MySQL (JPA) | Cloudinary (SDK) | SMTP (Mail)  │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

### 2.2. Cấu trúc package chuẩn

```
com.utetra
├── UtetraApplication.java
│
├── config/                  ← Cấu hình toàn hệ thống
│   ├── SecurityConfig.java
│   ├── WebSocketConfig.java
│   ├── SitemeshConfig.java
│   ├── CloudinaryConfig.java
│   ├── MailConfig.java
│   ├── JpaAuditingConfig.java
│   └── WebMvcConfig.java
│
├── security/                ← Xác thực & phân quyền
│   ├── JwtProvider.java
│   ├── JwtAuthenticationFilter.java
│   ├── CustomUserDetailsService.java
│   ├── UserPrincipal.java
│   └── JwtAuthenticationEntryPoint.java
│
├── controller/              ← Presentation layer
│   ├── guest/
│   ├── auth/
│   ├── customer/
│   ├── vendor/
│   ├── admin/
│   └── api/                 ← REST endpoint (JSON)
│
├── service/                 ← Business layer (interface)
│   └── impl/                ← Business layer (implement)
│
├── repository/              ← Data access layer
│
├── entity/                  ← JPA entities (KHÔNG chia con)
│
├── enums/                   ← TẤT CẢ enum dùng chung
│
├── constant/                ← Hằng số, prefix, message
│
├── dto/
│   ├── request/
│   └── response/
│
├── mapper/                  ← MapStruct mapper
│
├── websocket/               ← STOMP controller + handler
│
├── exception/               ← Custom exceptions + GlobalExceptionHandler
│
└── util/                    ← Helper (OtpUtil, SlugUtil, VNPayUtil...)
```

---

## PHẦN 3. LUỒNG HỆ THỐNG CHO CÁC CHỨC NĂNG

### 3.1. Luồng đăng ký + OTP

```
[Guest] Nhập form đăng ký (email, password, fullName)
        │
        ▼ POST /api/auth/register
[AuthController] → [AuthService.register()]
        │
        ├─► Kiểm tra email tồn tại? → Nếu có, throw EmailExistsException
        ├─► Mã hóa password bằng BCryptPasswordEncoder
        ├─► Sinh OTP 6 số (OtpUtil.generate())
        ├─► Lưu User (status=PENDING, emailVerified=false)
        ├─► Lưu OtpToken (code, expiredAt=now+5min, type=REGISTER)
        ├─► Gửi mail qua JavaMailSender
        │
        ▼ Trả về 200 OK + message "Kiểm tra email"
[Guest] Nhập OTP
        │
        ▼ POST /api/auth/verify-otp
[AuthService.verifyOtp()]
        │
        ├─► Tìm OtpToken theo email + code
        ├─► Kiểm tra hết hạn? → throw OtpExpiredException
        ├─► Update User: status=ACTIVE, emailVerified=true
        ├─► Xóa OtpToken
        │
        ▼ Trả về JWT (accessToken + refreshToken)
```

### 3.2. Luồng đăng nhập (JWT)

```
[User] Nhập email + password
        │
        ▼ POST /api/auth/login
[AuthService.login()]
        │
        ├─► AuthenticationManager.authenticate()
        ├─► Nếu sai → throw BadCredentialsException
        ├─► Nếu user.status = BANNED → throw AccountBannedException
        ├─► Tạo accessToken (15 phút) + refreshToken (7 ngày)
        ├─► Lưu RefreshToken vào DB
        │
        ▼ Trả về { accessToken, refreshToken, user info, roles }
[Client] Lưu localStorage (hoặc HttpOnly cookie)
[Các request sau] Gửi header: Authorization: Bearer <accessToken>
        │
        ▼ JwtAuthenticationFilter
        ├─► Đọc token từ header
        ├─► Verify signature + expiration
        ├─► Load UserDetails → set SecurityContext
        └─► Cho request đi tiếp
```

### 3.3. Luồng xem sản phẩm (Guest & Customer)

```
[Guest] Vào trang chủ /
        │
        ▼ GET / hoặc GET /api/products/home
[ProductService.getHomeProducts()]
        ├─► Lấy sản phẩm của các shop, mỗi shop >10 sản phẩm bán chạy
        ├─► Sắp xếp theo soldCount DESC
        ▼ Render home.jsp

[Guest] Xem danh mục /category/{slug}
        │
        ▼ GET /api/products?categoryId=X&page=0&size=20&sort=newest
[ProductService.search()]
        ├─► Filter theo category
        ├─► Phân trang (Pageable)
        ▼ Render product-list.jsp (lazy load khi scroll)

[Customer] Xem chi tiết /product/{slug}
        │
        ▼ GET /api/products/{id}
[ProductService.getDetail()]
        ├─► Lấy thông tin SP + ảnh + thuộc tính
        ├─► Lấy review (phân trang)
        ├─► Lưu ProductViewLog (nếu đã login)
        ▼ Render product-detail.jsp
```

### 3.4. Luồng giỏ hàng (Database)

```
[Customer] Nhấn "Thêm vào giỏ"
        │
        ▼ POST /api/customer/cart/items
[CartService.addItem(userId, productId, quantity, attrs)]
        │
        ├─► Tìm Cart theo userId + shopId (1 cart / shop)
        │   └─► Nếu chưa có → tạo mới
        ├─► Tìm CartItem tương ứng (cùng productId + attrs)
        │   ├─► Nếu có → cộng quantity
        │   └─► Nếu chưa → tạo CartItem mới
        ▼ Trả về số item trong giỏ

[Customer] Xem giỏ hàng /cart
        │
        ▼ GET /api/customer/cart
[CartService.getCart()]
        ├─► Lấy tất cả CartItem của user
        ├─► Nhóm theo shop (nếu mua nhiều shop)
        ├─► Tính tổng tiền tạm tính
        ▼ Render cart.jsp
```

### 3.5. Luồng đặt hàng + Thanh toán + WebSocket

```
[Customer] Chọn SP → Chọn voucher → Chọn phương thức → Đặt hàng
        │
        ▼ POST /api/customer/orders
[OrderService.createOrder(request)]
        │
        ├─► Validate: giỏ hàng, tồn kho, voucher hợp lệ
        ├─► Tính tiền: subtotal - discount + shippingFee
        ├─► Tạo Order (status=NEW, paymentStatus=PENDING)
        ├─► Tạo OrderItem cho từng sản phẩm
        ├─► Tạo OrderStatusHistory (NEW)
        ├─► Trừ stock, tăng soldCount
        ├─► Xóa CartItem tương ứng
        ├─► Tạo Transaction
        │
        ├─► [Nếu COD]  → order.status=CONFIRMED
        ├─► [Nếu VNPAY] → sinh paymentUrl → redirect
        ├─► [Nếu MOMO] → sinh paymentUrl → redirect
        │
        ├─► WebSocket: send /topic/shop/{shopId}/orders (Vendor nhận thông báo)
        │
        ▼ Trả về order code + redirect URL (nếu online payment)

[Payment Callback (VNPay/MOMO)]
        │
        ▼ POST /api/payment/callback
        ├─► Verify signature
        ├─► Update Transaction.status = SUCCESS/FAILED
        ├─► Update Order.paymentStatus
        ├─► WebSocket: notify Customer /topic/order/{id}/status
        ▼
```

### 3.6. Luồng xử lý đơn hàng (Vendor)

```
[Vendor] Xem đơn mới /vendor/orders?status=NEW
        │
        ▼ GET /api/vendor/shops/{shopId}/orders?status=NEW
[OrderService.getByShopAndStatus()]

[Vendor] Xác nhận đơn
        │
        ▼ PATCH /api/vendor/orders/{id}/status
        ├─► Body: { "status": "CONFIRMED" }
[OrderService.updateStatus()]
        ├─► Kiểm tra transition hợp lệ (NEW → CONFIRMED)
        ├─► Update Order.status
        ├─► Insert OrderStatusHistory
        ├─► WebSocket: /topic/order/{id}/status → Customer nhận
        ▼

Trạng thái: NEW → CONFIRMED → PICKED_UP → SHIPPING → DELIVERED
                                                   ↓
                                          CANCELLED / RETURNED / REFUNDED
```

### 3.7. Luồng Vendor tạo Shop

```
[Customer] Nhấn "Trở thành người bán"
        │
        ▼ POST /api/vendor/shops
[ShopService.createShop(userId, request)]
        ├─► Upload ảnh lên Cloudinary (avatar, cover)
        ├─► Tạo Shop (status=PENDING)
        ├─► Cấp role ROLE_VENDOR cho User
        ├─► Gửi notification cho Admin
        ▼

[Admin] Duyệt shop
        ▼ PATCH /api/admin/shops/{id}/status
        ├─► Update Shop.status = ACTIVE
        ├─► WebSocket notify Vendor
        ▼
```

### 3.8. Luồng Admin thống kê

```
[Admin] Vào dashboard /admin/dashboard
        │
        ▼ GET /api/admin/statistics/revenue?type=day&chart=line
[StatisticsService.getRevenue(type, chart)]
        ├─► Query SUM(total_amount) FROM orders
        │   WHERE created_at BETWEEN ... GROUP BY DATE(created_at)
        ├─► Trả về { labels[], data[] }
        ▼
[View] Dùng Chart.js render biểu đồ

Loại thống kê:
  - Doanh thu (theo sản phẩm, đơn hàng, hệ thống)
  - Người dùng mới
  - Cửa hàng mới
Thời gian: HOUR | DAY | MONTH | YEAR
Biểu đồ: LINE | BAR | PIE
```

### 3.9. Luồng WebSocket thông báo

```
[Client] Kết nối ws://localhost:8080/ws
        │
        ▼ STOMP connect với JWT trong header
[WebSocketConfig] → verify JWT → set Principal
        │
        ▼ Subscribe các topic:
        ├─ /topic/user/{userId}/notifications   (mọi user)
        ├─ /topic/shop/{shopId}/orders          (vendor)
        ├─ /topic/order/{orderId}/status        (customer)
        └─ /topic/admin/notifications           (admin)

[Backend] Khi có sự kiện → SimpMessagingTemplate.convertAndSend()
        ├─ Đơn hàng mới → gửi Vendor
        ├─ Đơn đổi trạng thái → gửi Customer
        ├─ Shop được duyệt → gửi Vendor
        ▼
[Client] Hiển thị toast notification
```

---

## PHẦN 4. MÔ HÌNH QUAN HỆ ĐỐI TƯỢNG (ERD)

### 4.1. Sơ đồ quan hệ tổng quát

```
       ┌─────────┐          ┌──────────┐         ┌──────────┐
       │  User   │──1:n─────│ Address  │         │Category  │
       └────┬────┘          └──────────┘         └────┬─────┘
            │                                          │
            │ 1:n                                      │ 1:n
            │                                          │
            ▼                                          ▼
       ┌─────────┐   n:1    ┌─────────┐   1:n    ┌─────────┐
       │  Shop   │─────────│ Product │─────────│Product  │
       └────┬────┘          └────┬────┘          Image   │
            │                    │              └─────────┘
            │                    │
            │                    │ 1:n
            │                    ▼
            │              ┌──────────────┐
            │              │ProductReview │
            │              └──────┬───────┘
            │                     │ 1:n
            │                     ▼
            │              ┌──────────────┐
            │              │ ReviewMedia  │
            │              └──────────────┘
            │
            │ 1:n
            ▼
       ┌─────────┐   1:n   ┌─────────┐   n:1   ┌─────────┐
       │  Order  │────────│OrderItem│─────────│ Product │
       └────┬────┘         └─────────┘         └─────────┘
            │
            │ 1:n
            ▼
       ┌──────────────┐   1:n   ┌──────────────┐
       │OrderStatus   │         │ Transaction  │
       │History       │         └──────────────┘
       └──────────────┘
```

### 4.2. Danh sách entity + quan hệ

| Entity | Table | Quan hệ chính |
|---|---|---|
| `User` | `users` | 1:n Address, 1:n Order, 1:n Cart, n:n Role, n:1 UserLevel |
| `Role` | `roles` | n:n User |
| `UserLevel` | `user_levels` | 1:n User |
| `Address` | `addresses` | n:1 User |
| `OtpToken` | `otp_tokens` | n:1 User |
| `RefreshToken` | `refresh_tokens` | n:1 User |
| `Shop` | `shops` | n:1 User (owner), n:1 ShopLevel, 1:n Product, 1:n ShopStaff |
| `ShopLevel` | `shop_levels` | 1:n Shop |
| `ShopStaff` | `shop_staffs` | n:1 Shop, n:1 User |
| `ShopImage` | `shop_images` | n:1 Shop |
| `ShopFollow` | `shop_follows` | n:1 Shop, n:1 User |
| `Category` | `categories` | 1:n Product, self-ref parent |
| `Product` | `products` | n:1 Shop, n:1 Category, 1:n ProductImage/Review |
| `ProductImage` | `product_images` | n:1 Product |
| `ProductAttribute` | `product_attributes` | 1:n ProductAttributeValue |
| `ProductAttributeValue` | `product_attribute_values` | n:1 Product, n:1 Attribute |
| `ProductReview` | `product_reviews` | n:1 Product, n:1 User, 1:n ReviewMedia |
| `ReviewMedia` | `review_media` | n:1 Review |
| `ProductViewLog` | `product_view_logs` | n:1 User, n:1 Product |
| `ProductFavorite` | `product_favorites` | n:1 User, n:1 Product |
| `Cart` | `carts` | n:1 User, n:1 Shop, 1:n CartItem |
| `CartItem` | `cart_items` | n:1 Cart, n:1 Product |
| `Order` | `orders` | n:1 User, n:1 Shop, 1:n OrderItem, 1:n OrderStatusHistory |
| `OrderItem` | `order_items` | n:1 Order, n:1 Product |
| `OrderStatusHistory` | `order_status_history` | n:1 Order |
| `Voucher` | `vouchers` | n:1 Shop (nullable), 1:n VoucherUsage |
| `VoucherUsage` | `voucher_usages` | n:1 Voucher, n:1 User, n:1 Order |
| `Wallet` | `wallets` | 1:1 Shop, 1:n WalletTransaction |
| `WalletTransaction` | `wallet_transactions` | n:1 Wallet |
| `Transaction` | `transactions` | n:1 Order |
| `WithdrawRequest` | `withdraw_requests` | n:1 Shop |
| `ShippingProvider` | `shipping_providers` | 1:n Order |
| `CommissionPolicy` | `commission_policies` | n:1 ShopLevel, n:1 Category |
| `Notification` | `notifications` | n:1 User |


### 4.3. Các enum trạng thái (BẮT BUỘC — package `com.utetra.enums`)

```java
UserStatus      : PENDING | ACTIVE | BANNED
ShopStatus      : PENDING | ACTIVE | BANNED | CLOSED
ProductStatus   : PENDING | ACTIVE | ARCHIVED | BANNED | OUT_OF_STOCK
OrderStatus     : NEW | CONFIRMED | PICKED_UP | SHIPPING
                  | DELIVERED | CANCELLED | RETURNED | REFUNDED
PaymentMethod   : COD | VNPAY | MOMO
PaymentStatus   : PENDING | SUCCESS | FAILED | REFUNDED
VoucherType     : PRODUCT | SHIPPING
DiscountType    : PERCENT | FIXED
NotificationType: ORDER | PROMO | SYSTEM | CHAT
RoleName        : ROLE_GUEST | ROLE_CUSTOMER | ROLE_VENDOR | ROLE_ADMIN
WalletTxType    : ORDER_INCOME | WITHDRAW | COMMISSION | REFUND
StaffRole       : MANAGER | STAFF
MediaType       : IMAGE | VIDEO
OtpType         : REGISTER | FORGOT_PASSWORD | CHANGE_EMAIL
StatisticsType  : HOUR | DAY | MONTH | YEAR
ChartType       : LINE | BAR | PIE
```

---

## PHẦN 5. QUY ĐỊNH ĐẶT TÊN (NAMING CONVENTION)

### 5.1. Database (MySQL)

| Đối tượng | Quy tắc | Ví dụ |
|---|---|---|
| Table | `snake_case`, **số nhiều** | `users`, `order_items` |
| Column | `snake_case` | `full_name`, `shop_id` |
| Primary key | Luôn là `id` (BIGINT AUTO_INCREMENT) | `id` |
| Foreign key | `<singular>_id` | `user_id`, `product_id` |
| Boolean | Prefix `is_` / `has_` | `is_default`, `is_read` |
| Timestamp | `created_at`, `updated_at`, `deleted_at` | — |
| Enum | `VARCHAR(50)` | `status`, `type` |
| Index | `idx_<table>_<col>` | `idx_users_email` |
| Unique | `uk_<table>_<col>` | `uk_users_email` |
| FK | `fk_<table>_<ref_table>` | `fk_orders_users` |

### 5.2. Java Class

| Đối tượng | Quy tắc | Ví dụ |
|---|---|---|
| Entity | `PascalCase`, số ít, = table singular | `User`, `OrderItem` |
| Enum | `PascalCase` + giá trị `ALL_CAPS` | `OrderStatus.NEW` |
| Repository | `<Entity>Repository` | `UserRepository` |
| Service (interface) | `<Entity>Service` | `OrderService` |
| Service (impl) | `<Entity>ServiceImpl` | `OrderServiceImpl` |
| Controller | `<Actor><Entity>Controller` | `AdminUserController` |
| DTO Request | `<Action><Entity>Request` | `CreateOrderRequest` |
| DTO Response | `<Entity>Response` / `<Entity>Dto` | `OrderResponse` |
| Mapper | `<Entity>Mapper` | `OrderMapper` |
| Custom Exception | `<Reason>Exception` | `EmailExistsException` |
| Config | `<Tech>Config` | `SecurityConfig` |

### 5.3. Java Field & Method

| Đối tượng | Quy tắc | Ví dụ |
|---|---|---|
| Field | `camelCase` | `fullName`, `createdAt` |
| Hằng số | `UPPER_SNAKE_CASE` | `MAX_OTP_ATTEMPTS` |
| Method — tạo | `create*` | `createOrder(req)` |
| Method — cập nhật | `update*` | `updateProfile(id, req)` |
| Method — xóa mềm | `softDelete*` | `softDeleteProduct(id)` |
| Method — xóa cứng | `hardDelete*` | `hardDeleteCartItem(id)` |
| Method — lấy 1 | `getById` / `getBy<Field>` | `getUserByEmail(email)` |
| Method — lấy nhiều | `getAll` / `getBy<Cond>` | `getOrdersByUser(id)` |
| Method — tìm | `search*` | `searchProducts(req)` |
| Method — đếm | `count*` | `countOrdersByShop(id)` |
| Method — kiểm tra | `exists*` / `is*` | `existsByEmail(email)` |
| Method — xử lý | `process*` | `processPayment(req)` |

### 5.4. REST API Endpoint

```
Prefix chuẩn: /api/<actor>/<resource>

Guest/Public:
  GET    /api/products
  GET    /api/products/{id}
  GET    /api/shops
  GET    /api/users/{id}/public

Auth:
  POST   /api/auth/register
  POST   /api/auth/verify-otp
  POST   /api/auth/login
  POST   /api/auth/refresh-token
  POST   /api/auth/logout
  POST   /api/auth/forgot-password
  POST   /api/auth/reset-password

Customer:
  GET    /api/customer/profile
  PUT    /api/customer/profile
  GET    /api/customer/addresses
  POST   /api/customer/addresses
  GET    /api/customer/cart
  POST   /api/customer/cart/items
  POST   /api/customer/orders
  GET    /api/customer/orders?status=NEW
  POST   /api/customer/orders/{id}/cancel
  POST   /api/customer/reviews

Vendor:
  GET    /api/vendor/shops
  POST   /api/vendor/shops
  GET    /api/vendor/shops/{shopId}/products
  GET    /api/vendor/shops/{shopId}/orders?status=NEW
  PATCH  /api/vendor/orders/{id}/status
  GET    /api/vendor/shops/{shopId}/wallet
  GET    /api/vendor/shops/{shopId}/statistics/revenue

Admin:
  GET    /api/admin/statistics/revenue?type=day&chart=line
  GET    /api/admin/users
  GET    /api/admin/shops
  PATCH  /api/admin/shops/{id}/status
  GET    /api/admin/transactions
```

### 5.5. WebSocket Topic

```
/topic/user/{userId}/notifications      → thông báo 1 user
/topic/shop/{shopId}/orders             → đơn mới cho vendor
/topic/order/{orderId}/status           → trạng thái đơn cho customer
/topic/admin/notifications              → thông báo cho admin

/app/chat.send                          → gửi chat
```

### 5.6. Cấu trúc JSP + Sitemesh

```
src/main/webapp/
├── WEB-INF/
│   ├── decorators/
│   │   ├── main-decorator.jsp       (Guest/Customer)
│   │   ├── vendor-decorator.jsp     (Vendor dashboard)
│   │   ├── admin-decorator.jsp      (Admin dashboard)
│   │   └── auth-decorator.jsp       (Login/Register)
│   ├── views/
│   │   ├── guest/
│   │   ├── auth/
│   │   ├── customer/
│   │   ├── vendor/
│   │   ├── admin/
│   │   └── error/
│   └── web.xml
└── static/
    ├── css/
    ├── js/
    └── images/
```

### 5.7. Git Convention

| Branch | Mục đích |
|---|---|
| `main` | Bản release ổn định |
| `dev` | Nhánh tích hợp chung |
| `feature/<module>-<name>` | Vd: `feature/auth-jwt`, `feature/order-create` |
| `bugfix/<issue>` | Sửa lỗi |
| `hotfix/<issue>` | Sửa khẩn cấp từ main |

**Commit message:** `<type>(<scope>): <subject>`
```
feat(auth): add JWT login
fix(order): correct total amount calculation
docs(api): update endpoint list
refactor(product): extract Cloudinary service
```

---

## PHẦN 6. BASE ENTITY & CONSTANT CHUẨN

### 6.1. BaseEntity (mọi entity kế thừa)

```java
package com.utetra.entity;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter @Setter
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "is_deleted")
    private Boolean isDeleted = false;
}
```

### 6.2. Constant chung

```java
public final class AppConstants {
    public static final String API_PREFIX = "/api";
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int OTP_LENGTH = 6;
    public static final int OTP_EXPIRE_MINUTES = 5;
    public static final int JWT_ACCESS_EXPIRE_MINUTES = 15;
    public static final int JWT_REFRESH_EXPIRE_DAYS = 7;
    public static final int MIN_REVIEW_LENGTH = 50;
}

public final class SecurityConstants {
    public static final String JWT_HEADER = "Authorization";
    public static final String JWT_PREFIX = "Bearer ";
    public static final String[] PUBLIC_ENDPOINTS = {
        "/", "/api/products/**", "/api/shops/**",
        "/api/auth/**", "/static/**", "/ws/**"
    };
}
```
# 📊 TỔNG KẾT SỐ BẢNG CẦN THIẾT

## Tóm tắt: **35 bảng** (đủ cho đồ án, không thừa không thiếu)

---

## PHẦN 1. DANH SÁCH 35 BẢNG THEO NHÓM

### 🔹 Nhóm 1: User & Auth (7 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 1 | `users` | |
| 2 | `roles` | |
| 3 | `user_roles` | |
| 4 | `user_levels` | Cấp độ + chiết khấu mua hàng |
| 5 | `addresses` | Địa chỉ giao hàng |
| 6 | `otp_tokens` | OTP register/forgot (tách riêng) |
| 7 | `refresh_tokens` | JWT refresh |

### 🔹 Nhóm 2: Shop & Vendor (4 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 8 | `shops` | |
| 9 | `shop_levels` | Cấp độ + % hoa hồng |
| 10 | `shop_staffs` | Nhân viên/đối tác |
| 11 | `shop_images` | Ảnh cover/feature |

### 🔹 Nhóm 3: Sản phẩm (7 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 12 | `categories` | |
| 13 | `products` | |
| 14 | `product_images` | |
| 15 | `product_attributes` | Size, Topping, Đường, Đá... |
| 16 | `product_attribute_values` | |
| 17 | `product_reviews` | |
| 18 | `review_media` | Ảnh/video review |

### 🔹 Nhóm 4: Giỏ hàng & Đơn hàng (7 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 19 | `carts` | |
| 20 | `cart_items` | |
| 21 | `orders` | |
| 22 | `order_items` | Có snapshot sản phẩm |
| 23 | `order_status_history` | |
| 24 | `vouchers` | Mã giảm giá |
| 25 | `voucher_usages` | |

### 🔹 Nhóm 5: Thanh toán & Ví (4 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 26 | `wallets` | Ví shop |
| 27 | `wallet_transactions` | |
| 28 | `transactions` | Giao dịch thanh toán |
| 29 | `withdraw_requests` | Yêu cầu rút tiền |

### 🔹 Nhóm 6: Vận chuyển & Hoa hồng (2 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 30 | `shipping_providers` | |
| 31 | `commission_policies` | Chính sách hoa hồng |

### 🔹 Nhóm 7: Tương tác & Hệ thống (4 bảng)
| # | Bảng | Ghi chú |
|---|---|---|
| 32 | `product_favorites` | Yêu thích SP |
| 33 | `shop_follows` | Theo dõi shop |
| 34 | `product_view_logs` | Lịch sử xem |
| 35 | `notifications` | |

---

## PHẦN 2. BẢNG **TÙY CHỌN** (làm nếu còn thời gian)

| # | Bảng | Khi nào cần |
|---|---|---|
| 36 | `promotions` | Nếu làm chương trình khuyến mãi tự động (ngoài voucher) |
| 37 | `promotion_products` | SP thuộc promotion |

### CẤU TRÚC THƯ MỤC:
# 📁 CẤU TRÚC THƯ MỤC HỆ THỐNG UTETRA

Dưới đây là cấu trúc thư mục **hoàn chỉnh** cho dự án `utetra-web` — từ root repo đến từng file trong `src/main`.

---

## PHẦN 1. CẤU TRÚC TỔNG QUAN (ROOT REPO)

```
utetra-web/
│
├── .gitignore                              # Loại trừ file rác
├── .gitattributes                          # Chuẩn hóa line ending
├── .env.example                            # Mẫu biến môi trường
├── README.md                               # Giới thiệu dự án
├── docker-compose.yml                      # Chạy MySQL cho cả nhóm
├── pom.xml                                 # Maven config
│
├── docs/                                   # 📚 Tài liệu dự án
│   ├── SYSTEM_DESIGN.md
│   ├── NAMING_CONVENTION.md
│   ├── COLUMN_NAMING.md
│   ├── API_ENDPOINTS.md
│   ├── ERD.md
│   ├── PERMISSION_MATRIX.md
│   ├── SETUP_GUIDE.md
│   ├── TASK_ASSIGNMENT.md
│   └── diagrams/
│       ├── architecture.png
│       ├── erd.png
│       └── use-case.png
│
├── database/                               # 🗄️ Script SQL
│   ├── V1__init_schema.sql
│   ├── V2__seed_data.sql
│   └── README.md
│
└── src/
    ├── main/
    │   ├── java/com/utetra/                # ☕ Source code Java
    │   ├── resources/                      # ⚙️ Config + migration
    │   └── webapp/                         # 🎨 JSP + static files
    │
    └── test/
        └── java/com/utetra/                # 🧪 Unit test
```

---

## PHẦN 2. CẤU TRÚC `src/main/java/com/utetra/`

```
com/utetra/
│
├── UtetraApplication.java                  # Main class
│
├── config/                                 # ⚙️ Cấu hình toàn hệ thống
│   ├── SecurityConfig.java                 # Spring Security + JWT
│   ├── WebSocketConfig.java                # STOMP + SockJS
│   ├── SitemeshConfig.java                 # Decorator
│   ├── CloudinaryConfig.java               # Cloudinary SDK
│   ├── MailConfig.java                     # JavaMailSender
│   ├── JpaAuditingConfig.java              # @CreatedDate, @LastModifiedDate
│   ├── WebMvcConfig.java                   # Static resources, CORS
│   ├── SwaggerConfig.java                  # (optional) API docs
│   └── FlywayConfig.java                   # (optional)
│
├── security/                               # 🔐 Xác thực & phân quyền
│   ├── JwtProvider.java                    # Tạo & verify JWT
│   ├── JwtAuthenticationFilter.java        # Filter đọc JWT
│   ├── CustomUserDetailsService.java       # Load user từ DB
│   ├── UserPrincipal.java                  # Wrapper UserDetails
│   ├── JwtAuthenticationEntryPoint.java    # 401 handler
│   └── JwtAccessDeniedHandler.java         # 403 handler
│
├── controller/                             # 🎯 Presentation layer
│   ├── guest/
│   │   ├── HomeController.java
│   │   ├── GuestProductController.java
│   │   ├── GuestShopController.java
│   │   └── GuestUserController.java
│   ├── auth/
│   │   ├── AuthController.java
│   │   ├── RegisterController.java
│   │   └── PasswordController.java
│   ├── customer/
│   │   ├── CustomerProfileController.java
│   │   ├── CustomerAddressController.java
│   │   ├── CustomerCartController.java
│   │   ├── CustomerOrderController.java
│   │   ├── CustomerReviewController.java
│   │   ├── CustomerFavoriteController.java
│   │   └── CustomerCheckoutController.java
│   ├── vendor/
│   │   ├── VendorShopController.java
│   │   ├── VendorProductController.java
│   │   ├── VendorOrderController.java
│   │   ├── VendorStaffController.java
│   │   ├── VendorWalletController.java
│   │   ├── VendorVoucherController.java
│   │   └── VendorStatisticsController.java
│   ├── admin/
│   │   ├── AdminDashboardController.java
│   │   ├── AdminUserController.java
│   │   ├── AdminShopController.java
│   │   ├── AdminProductController.java
│   │   ├── AdminOrderController.java
│   │   ├── AdminCategoryController.java
│   │   ├── AdminAttributeController.java
│   │   ├── AdminShippingController.java
│   │   ├── AdminCommissionController.java
│   │   ├── AdminLevelController.java
│   │   ├── AdminPromotionController.java
│   │   └── AdminTransactionController.java
│   └── api/                                # REST endpoint (JSON)
│       ├── AuthApiController.java
│       ├── ProductApiController.java
│       ├── CartApiController.java
│       ├── OrderApiController.java
│       ├── PaymentApiController.java
│       ├── ReviewApiController.java
│       ├── SearchApiController.java
│       ├── UploadApiController.java
│       └── StatisticsApiController.java
│
├── service/                                # 🧠 Business layer (interface)
│   ├── AuthService.java
│   ├── UserService.java
│   ├── AddressService.java
│   ├── OtpService.java
│   ├── MailService.java
│   ├── CloudinaryService.java
│   ├── RoleService.java
│   ├── UserLevelService.java
│   ├── ShopService.java
│   ├── ShopLevelService.java
│   ├── ShopStaffService.java
│   ├── CategoryService.java
│   ├── ProductService.java
│   ├── ProductAttributeService.java
│   ├── ProductReviewService.java
│   ├── CartService.java
│   ├── OrderService.java
│   ├── VoucherService.java
│   ├── PromotionService.java
│   ├── PaymentService.java
│   ├── WalletService.java
│   ├── TransactionService.java
│   ├── WithdrawService.java
│   ├── ShippingProviderService.java
│   ├── CommissionPolicyService.java
│   ├── NotificationService.java
│   ├── StatisticsService.java
│   ├── FavoriteService.java
│   ├── FollowService.java
│   └── impl/                               # 🧠 Business layer (impl)
│       ├── AuthServiceImpl.java
│       ├── UserServiceImpl.java
│       ├── ... (tương ứng 1-1 với interface)
│
├── repository/                             # 🗄️ Data access layer
│   ├── UserRepository.java
│   ├── RoleRepository.java
│   ├── UserRoleRepository.java
│   ├── UserLevelRepository.java
│   ├── AddressRepository.java
│   ├── OtpTokenRepository.java
│   ├── RefreshTokenRepository.java
│   ├── ShopRepository.java
│   ├── ShopLevelRepository.java
│   ├── ShopStaffRepository.java
│   ├── ShopImageRepository.java
│   ├── ShopFollowRepository.java
│   ├── CategoryRepository.java
│   ├── ProductRepository.java
│   ├── ProductImageRepository.java
│   ├── ProductAttributeRepository.java
│   ├── ProductAttributeValueRepository.java
│   ├── ProductReviewRepository.java
│   ├── ReviewMediaRepository.java
│   ├── ProductViewLogRepository.java
│   ├── ProductFavoriteRepository.java
│   ├── CartRepository.java
│   ├── CartItemRepository.java
│   ├── OrderRepository.java
│   ├── OrderItemRepository.java
│   ├── OrderStatusHistoryRepository.java
│   ├── VoucherRepository.java
│   ├── VoucherUsageRepository.java
│   ├── PromotionRepository.java
│   ├── PromotionProductRepository.java
│   ├── WalletRepository.java
│   ├── WalletTransactionRepository.java
│   ├── TransactionRepository.java
│   ├── WithdrawRequestRepository.java
│   ├── ShippingProviderRepository.java
│   ├── CommissionPolicyRepository.java
│   └── NotificationRepository.java
│
├── entity/                                 # 📦 JPA entities (KHÔNG chia con)
│   ├── BaseEntity.java
│   ├── User.java
│   ├── Role.java
│   ├── UserRole.java
│   ├── UserLevel.java
│   ├── Address.java
│   ├── OtpToken.java
│   ├── RefreshToken.java
│   ├── Shop.java
│   ├── ShopLevel.java
│   ├── ShopStaff.java
│   ├── ShopImage.java
│   ├── ShopFollow.java
│   ├── Category.java
│   ├── Product.java
│   ├── ProductImage.java
│   ├── ProductAttribute.java
│   ├── ProductAttributeValue.java
│   ├── ProductReview.java
│   ├── ReviewMedia.java
│   ├── ProductViewLog.java
│   ├── ProductFavorite.java
│   ├── Cart.java
│   ├── CartItem.java
│   ├── Order.java
│   ├── OrderItem.java
│   ├── OrderStatusHistory.java
│   ├── Voucher.java
│   ├── VoucherUsage.java
│   ├── Promotion.java
│   ├── PromotionProduct.java
│   ├── Wallet.java
│   ├── WalletTransaction.java
│   ├── Transaction.java
│   ├── WithdrawRequest.java
│   ├── ShippingProvider.java
│   ├── CommissionPolicy.java
│   └── Notification.java
│
├── enums/                                  # 🏷️ TẤT CẢ enum dùng chung
│   ├── UserStatus.java
│   ├── ShopStatus.java
│   ├── ProductStatus.java
│   ├── OrderStatus.java
│   ├── PaymentMethod.java
│   ├── PaymentStatus.java
│   ├── VoucherType.java
│   ├── DiscountType.java
│   ├── NotificationType.java
│   ├── RoleName.java
│   ├── WalletTxType.java
│   ├── StaffRole.java
│   ├── MediaType.java
│   ├── OtpType.java
│   ├── StatisticsType.java
│   ├── ChartType.java
│   ├── PromotionType.java
│   └── WithdrawStatus.java
│
├── constant/                               # 📌 Hằng số
│   ├── AppConstants.java
│   ├── SecurityConstants.java
│   ├── MessageConstants.java
│   ├── ApiPathConstants.java
│   └── CloudinaryConstants.java
│
├── dto/                                    # 📨 Data Transfer Object
│   ├── request/
│   │   ├── auth/
│   │   │   ├── RegisterRequest.java
│   │   │   ├── LoginRequest.java
│   │   │   ├── VerifyOtpRequest.java
│   │   │   ├── ForgotPasswordRequest.java
│   │   │   └── ResetPasswordRequest.java
│   │   ├── user/
│   │   │   ├── UpdateProfileRequest.java
│   │   │   ├── ChangePasswordRequest.java
│   │   │   └── CreateAddressRequest.java
│   │   ├── product/
│   │   │   ├── CreateProductRequest.java
│   │   │   ├── UpdateProductRequest.java
│   │   │   └── ProductSearchRequest.java
│   │   ├── shop/
│   │   │   ├── CreateShopRequest.java
│   │   │   └── UpdateShopRequest.java
│   │   ├── cart/
│   │   │   ├── AddToCartRequest.java
│   │   │   └── UpdateCartItemRequest.java
│   │   ├── order/
│   │   │   ├── CreateOrderRequest.java
│   │   │   ├── UpdateOrderStatusRequest.java
│   │   │   └── CancelOrderRequest.java
│   │   ├── review/
│   │   │   └── CreateReviewRequest.java
│   │   ├── voucher/
│   │   │   └── CreateVoucherRequest.java
│   │   ├── promotion/
│   │   │   └── CreatePromotionRequest.java
│   │   ├── wallet/
│   │   │   └── CreateWithdrawRequest.java
│   │   └── admin/
│   │       ├── CreateCategoryRequest.java
│   │       ├── CreateShippingProviderRequest.java
│   │       └── UpdateUserStatusRequest.java
│   └── response/
│       ├── ApiResponse.java                # { code, message, data }
│       ├── PageResponse.java               # Phân trang
│       ├── auth/
│       │   ├── LoginResponse.java
│       │   └── TokenResponse.java
│       ├── user/
│       │   ├── UserResponse.java
│       │   ├── UserProfileResponse.java
│       │   └── AddressResponse.java
│       ├── product/
│       │   ├── ProductResponse.java
│       │   ├── ProductDetailResponse.java
│       │   └── ProductSearchResponse.java
│       ├── shop/
│       │   └── ShopResponse.java
│       ├── cart/
│       │   └── CartResponse.java
│       ├── order/
│       │   ├── OrderResponse.java
│       │   └── OrderDetailResponse.java
│       ├── review/
│       │   └── ReviewResponse.java
│       ├── statistics/
│       │   ├── RevenueStatisticResponse.java
│       │   └── ChartDataResponse.java
│       └── notification/
│           └── NotificationResponse.java
│
├── mapper/                                 # 🔄 MapStruct mappers
│   ├── UserMapper.java
│   ├── AddressMapper.java
│   ├── ShopMapper.java
│   ├── ProductMapper.java
│   ├── CartMapper.java
│   ├── OrderMapper.java
│   ├── ReviewMapper.java
│   ├── VoucherMapper.java
│   ├── WalletMapper.java
│   └── NotificationMapper.java
│
├── websocket/                              # 🔌 WebSocket
│   ├── NotificationController.java
│   ├── NotificationService.java
│   ├── OrderWebSocketHandler.java
│   └── ChatController.java
│
├── exception/                              # ⚠️ Exception handling
│   ├── GlobalExceptionHandler.java
│   ├── custom/
│   │   ├── AppException.java
│   │   ├── ResourceNotFoundException.java
│   │   ├── EmailExistsException.java
│   │   ├── OtpExpiredException.java
│   │   ├── OtpInvalidException.java
│   │   ├── AccountBannedException.java
│   │   ├── AccountNotVerifiedException.java
│   │   ├── InvalidTokenException.java
│   │   ├── InsufficientStockException.java
│   │   ├── InvalidOrderStatusException.java
│   │   ├── VoucherInvalidException.java
│   │   ├── PermissionDeniedException.java
│   │   ├── FileUploadException.java
│   │   └── PaymentFailedException.java
│   └── ErrorResponse.java
│
├── util/                                   # 🛠️ Helper
│   ├── OtpUtil.java
│   ├── SlugUtil.java
│   ├── VNPayUtil.java
│   ├── MoMoUtil.java
│   ├── DateTimeUtil.java
│   ├── SecurityUtil.java
│   ├── FileUtil.java
│   ├── PaginationUtil.java
│   └── ValidationUtil.java
│
└── validator/                              # ✔️ Custom validator
    ├── EmailValidator.java
    ├── PhoneValidator.java
    ├── PasswordValidator.java
    └── annotation/
        ├── ValidEmail.java
        └── ValidPhone.java
```

---

## PHẦN 3. CẤU TRÚC `src/main/resources/`

```
resources/
│
├── application.yml                         # Config chính
├── application-dev.yml                     # Dev profile
├── application-prod.yml                    # Prod profile
├── application-test.yml                    # Test profile
├── logback-spring.xml                      # Log config
│
├── db/
│   └── migration/                          # Flyway
│       ├── V1__init_schema.sql
│       ├── V2__seed_roles.sql
│       ├── V3__seed_categories.sql
│       ├── V4__seed_user_levels.sql
│       └── V5__seed_shop_levels.sql
│
├── templates/                              # Email templates (Thymeleaf)
│   ├── email/
│   │   ├── otp-register.html
│   │   ├── otp-forgot-password.html
│   │   ├── order-confirmation.html
│   │   ├── order-status-changed.html
│   │   └── welcome.html
│   └── fragments/
│       └── email-layout.html
│
├── messages/                               # i18n (nếu cần)
│   ├── messages.properties
│   └── messages_vi.properties
│
└── static/                                 # Static resources (fallback)
    ├── css/
    ├── js/
    └── images/
```

---

## PHẦN 4. CẤU TRÚC `src/main/webapp/`

```
webapp/
│
├── WEB-INF/
│   │
│   ├── web.xml                             # Servlet config
│   │
│   ├── decorators/                         # 🎨 Sitemesh layouts
│   │   ├── main-decorator.jsp              # Guest/Customer
│   │   ├── vendor-decorator.jsp            # Vendor dashboard
│   │   ├── admin-decorator.jsp             # Admin dashboard
│   │   └── auth-decorator.jsp              # Login/Register
│   │
│   ├── fragments/                          # 🧩 JSP fragments (dùng chung)
│   │   ├── header.jsp
│   │   ├── footer.jsp
│   │   ├── navbar-guest.jsp
│   │   ├── navbar-customer.jsp
│   │   ├── sidebar-vendor.jsp
│   │   ├── sidebar-admin.jsp
│   │   ├── breadcrumb.jsp
│   │   ├── pagination.jsp
│   │   ├── toast.jsp
│   │   └── modal-confirm.jsp
│   │
│   └── views/                              # 📄 JSP pages theo actor
│       │
│       ├── guest/
│       │   ├── home.jsp
│       │   ├── product-list.jsp
│       │   ├── product-detail.jsp
│       │   ├── shop-list.jsp
│       │   ├── shop-detail.jsp
│       │   ├── user-public-profile.jsp
│       │   └── search-result.jsp
│       │
│       ├── auth/
│       │   ├── login.jsp
│       │   ├── register.jsp
│       │   ├── verify-otp.jsp
│       │   ├── forgot-password.jsp
│       │   └── reset-password.jsp
│       │
│       ├── customer/
│       │   ├── profile.jsp
│       │   ├── change-password.jsp
│       │   ├── address-list.jsp
│       │   ├── address-form.jsp
│       │   ├── cart.jsp
│       │   ├── checkout.jsp
│       │   ├── order-history.jsp
│       │   ├── order-detail.jsp
│       │   ├── order-tracking.jsp
│       │   ├── review-form.jsp
│       │   ├── favorite-products.jsp
│       │   ├── favorite-shops.jsp
│       │   └── viewed-products.jsp
│       │
│       ├── vendor/
│       │   ├── dashboard.jsp
│       │   ├── shop-create.jsp
│       │   ├── shop-list.jsp
│       │   ├── shop-detail.jsp
│       │   ├── shop-edit.jsp
│       │   ├── product-list.jsp
│       │   ├── product-form.jsp
│       │   ├── product-detail.jsp
│       │   ├── order-list.jsp
│       │   ├── order-detail.jsp
│       │   ├── staff-list.jsp
│       │   ├── staff-form.jsp
│       │   ├── voucher-list.jsp
│       │   ├── voucher-form.jsp
│       │   ├── promotion-list.jsp
│       │   ├── promotion-form.jsp
│       │   ├── wallet.jsp
│       │   ├── withdraw-request.jsp
│       │   ├── statistics-revenue.jsp
│       │   └── statistics-product.jsp
│       │
│       ├── admin/
│       │   ├── dashboard.jsp
│       │   ├── user-list.jsp
│       │   ├── user-detail.jsp
│       │   ├── shop-list.jsp
│       │   ├── shop-detail.jsp
│       │   ├── product-list.jsp
│       │   ├── product-detail.jsp
│       │   ├── order-list.jsp
│       │   ├── order-detail.jsp
│       │   ├── category-list.jsp
│       │   ├── category-form.jsp
│       │   ├── attribute-list.jsp
│       │   ├── attribute-form.jsp
│       │   ├── shipping-list.jsp
│       │   ├── shipping-form.jsp
│       │   ├── commission-list.jsp
│       │   ├── commission-form.jsp
│       │   ├── user-level-list.jsp
│       │   ├── user-level-form.jsp
│       │   ├── shop-level-list.jsp
│       │   ├── shop-level-form.jsp
│       │   ├── promotion-list.jsp
│       │   ├── promotion-form.jsp
│       │   ├── voucher-list.jsp
│       │   ├── transaction-list.jsp
│       │   ├── withdraw-list.jsp
│       │   ├── statistics-revenue.jsp
│       │   ├── statistics-user.jsp
│       │   └── statistics-shop.jsp
│       │
│       └── error/
│           ├── 403.jsp
│           ├── 404.jsp
│           ├── 500.jsp
│           └── error.jsp
│
└── static/                                 # 🎨 Static files (css, js, img)
    ├── css/
    │   ├── bootstrap.min.css
    │   ├── main.css
    │   ├── vendor.css
    │   ├── admin.css
    │   ├── auth.css
    │   └── customer.css
    │
    ├── js/
    │   ├── bootstrap.bundle.min.js
    │   ├── jquery.min.js
    │   ├── chart.min.js
    │   ├── sockjs.min.js
    │   ├── stomp.min.js
    │   ├── main.js
    │   ├── auth.js
    │   ├── cart.js
    │   ├── order.js
    │   ├── product.js
    │   ├── review.js
    │   ├── vendor.js
    │   ├── admin.js
    │   ├── websocket.js
    │   └── statistics.js
    │
    ├── images/
    │   ├── logo.png
    │   ├── banner/
    │   ├── icons/
    │   └── placeholder.png
    │
    └── fonts/
        └── ...
```

---

## PHẦN 5. CẤU TRÚC `src/test/java/com/utetra/`

```
test/java/com/utetra/
│
├── UtetraApplicationTests.java
│
├── unit/
│   ├── service/
│   │   ├── AuthServiceTest.java
│   │   ├── OrderServiceTest.java
│   │   └── CartServiceTest.java
│   └── util/
│       ├── OtpUtilTest.java
│       └── VNPayUtilTest.java
│
└── integration/
    ├── AuthControllerTest.java
    ├── ProductControllerTest.java
    └── OrderControllerTest.java
```

---

## PHẦN 6. NGUYÊN TẮC TỔ CHỨC THƯ MỤC

| # | Nguyên tắc | Lý do |
|---|---|---|
| 1 | Mỗi entity có 1 repository, 1 service (interface + impl), có thể có 1 controller | Nhất quán |
| 2 | Entity **KHÔNG** chia sub-package | Tránh phức tạp, dễ tìm |
| 3 | Enum tập trung ở `enums/` | Không tạo enum rải rác |
| 4 | Controller chia theo **actor** (`guest`, `auth`, `customer`, `vendor`, `admin`, `api`) | Dễ phân quyền |
| 5 | DTO chia `request/` và `response/`, bên trong chia theo module | Tránh 1 folder quá nhiều file |
| 6 | JSP chia theo **actor** giống controller | Dễ map |
| 7 | Decorator chỉ 4 file: main, auth, vendor, admin | Đủ dùng |
| 8 | Fragments chứa header/footer/sidebar tái sử dụng | DRY |
| 9 | Static files chia rõ css/js/images/fonts | Chuẩn |
| 10 | Docs tách riêng khỏi source | Sạch repo |


