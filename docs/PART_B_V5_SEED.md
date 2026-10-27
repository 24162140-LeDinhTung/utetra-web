# Dữ liệu mẫu phần B — migration V5

Ngày 27/10/2026. Dựa trên bản nhóm đã merge vào `origin/dev` tại commit `21d1186`.

## Cách chạy cho nhóm

1. Lấy bản code có V1–V5 trong `src/main/resources/db/migration/` và ảnh `static/images/part-b-demo.svg`.
2. Mở Docker Desktop, chạy `docker compose up -d` tại thư mục chứa `pom.xml` và `docker-compose.yml`. Cấu hình hiện tại dùng MySQL 8.4, cổng máy host 3307, database `utetra_db`; Adminer ở `http://localhost:8081`.
3. Chạy ứng dụng bằng **Run As → Spring Boot App**. Flyway tự chạy migration V5 một lần sau V4, trước `DataInitializer`. Không cần copy SQL vào thư mục `database/` hoặc import thủ công trong Adminer.
4. Xem log Flyway xác nhận đã migrate lên version 5; mở `http://localhost:8080/` hoặc `GET /api/products/home/shops`.

Chỉ dùng bộ dữ liệu này cho database phát triển/demo của đồ án. V5 tạo tài khoản có mật khẩu công khai phục vụ test; không triển khai bộ seed lên database production.

Nếu Flyway báo lỗi ở V1–V4/checksum thì gửi log để xử lý đúng migration đang lỗi. Không xóa database, volume Docker hay lịch sử Flyway để thử sửa lỗi. V5 không sửa schema cũ; việc schema do Hibernate tạo trước đây khác migration cần được xử lý riêng.

## Tài khoản demo

Mật khẩu chung: `PartB@123456`. Các tài khoản đều ACTIVE và đã xác minh email, không cần OTP.

| Email | Quyền | Dữ liệu |
|---|---|---|
| `partb.customer@utetra.test` | CUSTOMER | Giỏ của 2 shop, 4 đơn COD, 1 đánh giá |
| `partb.vendor1@utetra.test` | VENDOR | Shop mẫu Thủ Đức và Bình Thạnh |
| `partb.vendor2@utetra.test` | VENDOR | Shop mẫu Quận 7; dùng kiểm tra phân quyền khác chủ |
| `partb.admin@utetra.test` | ADMIN | Duyệt sản phẩm, quản lý danh mục/thuộc tính |

Đây là tài khoản mới riêng cho B. Các tài khoản `test@gmail.com`, `vendor@utetra.com`, `admin@utetra.com` của `DataInitializer` và mật khẩu đang có không bị sửa. V5 lấy ID theo email/slug/code, không giả định user/shop có ID 1, 2, 3. Các guard chỉ thêm dữ liệu thiếu; không reset dữ liệu demo đã được người dùng sửa sau khi tạo.

## Dữ liệu được thêm

- 3 shop ACTIVE, slug `part-b-demo-shop-1`, `part-b-demo-shop-2`, `part-b-demo-shop-3`. Đây là dữ liệu phụ thuộc tối thiểu để B test nhiều shop; không thêm ví, giao dịch ví hay yêu cầu rút tiền của C.
- 3 danh mục mẫu; mỗi shop có 12 sản phẩm ACTIVE còn hàng (36 món), giá 30.000–41.000 đồng. Tất cả có ảnh minh họa cục bộ, thuộc tính Size M (+0) / L (+5.000).
- Shop 1 thêm một món PENDING và một món hết hàng, tổng cộng 38 sản phẩm. Sản phẩm PENDING không xuất hiện ở danh sách công khai.
- 2 giỏ của khách demo, 3 dòng: shop 1 có cùng món với Size M và L, shop 2 có Size M.
- 9 voucher: mỗi shop có `BDEMO{n}SAVE10` (giảm 10%, tối thiểu 50.000, tối đa 20.000), `BDEMO{n}SHIP` (giảm phí ship tối đa 15.000, tối thiểu 50.000) và `BDEMO{n}EXPIRED` đã hết hạn. `{n}` là 1, 2 hoặc 3.
- 3 promotion `B-DEMO-S{n}-PROMO10`, giảm 10% cho món số 11–12 của shop tương ứng. Voucher/promotion đang hoạt động có hạn 365 ngày tính từ lần tạo dữ liệu.
- 4 đơn có snapshot món/giá/Size, lịch sử trạng thái và ledger `payment_transactions` khớp tổng tiền. Stock/sold_count của món mẫu đã tính các đơn chưa hủy.
- 1 lượt sử dụng voucher và 1 đánh giá trên món đã giao, kèm ảnh minh họa. Món thứ hai trong đơn đã giao chưa có đánh giá để test gửi đánh giá mới.

| Mã đơn | Shop | Trạng thái | Thanh toán | Tổng tiền |
|---|---|---|---|---:|
| `B-DEMO-CONFIRMED` | Thủ Đức | CONFIRMED | COD / PENDING | 75.000 |
| `B-DEMO-SHIPPING` | Bình Thạnh | SHIPPING | COD / PENDING | 75.000 |
| `B-DEMO-DELIVERED` | Thủ Đức | DELIVERED | COD / SUCCESS mô phỏng | 69.900 |
| `B-DEMO-CANCELLED` | Quận 7 | CANCELLED | COD / FAILED | 75.000 |

Đơn DELIVERED: 30.000 + 31.000 − 6.100 voucher + 15.000 phí giao hàng = 69.900. Khách demo đã dùng `BDEMO1SAVE10`; mã này phải bị từ chối nếu cùng khách dùng lại. Muốn kiểm tra voucher hợp lệ với khách demo, dùng `BDEMO1SHIP` ở shop 1 hoặc `BDEMO2SAVE10` ở shop 2.

Tất cả đơn và đánh giá là dữ liệu mô phỏng, không đại diện giao dịch hoặc nhận xét thật. Seed dùng ảnh SVG cục bộ để không phụ thuộc dịch vụ ảnh bên ngoài. Luồng tạo review/upload mới vẫn cần Cloudinary đúng cấu hình; ảnh seed không phải kết quả kiểm thử upload. Seed không tạo thanh toán VNPay/MoMo thành công giả và không ghi nhận doanh thu vào ví C. Module ví của C cần tự khởi tạo ví qua luồng của C khi muốn test ví cho các shop này.

## Gợi ý kiểm tra phần B

1. Không đăng nhập: `/api/products/home/shops` có 3 shop mẫu và menu tương ứng; lọc theo shop/category/keyword không lẫn món của shop khác.
2. Đăng nhập khách demo: xem `/customer/cart`, đổi số lượng, thử thêm món hết hàng; đặt một đơn COD thật qua chức năng của ứng dụng.
3. Thử voucher hoạt động, hết hạn, đã dùng và voucher của shop khác. So sánh quote với tổng đơn.
4. Đăng nhập vendor1: chọn giữa hai shop, xem đơn, chuyển CONFIRMED → PICKED_UP → SHIPPING → DELIVERED. Vendor2 không được xem/sửa đơn shop của vendor1.
5. Khách xem đơn DELIVERED, gửi đánh giá món số 2 bằng ảnh tải lên Cloudinary; món số 1 đã có đánh giá phải bị chặn khi gửi lại.
6. Admin duyệt món `part-b-demo-pending`; sau duyệt món xuất hiện công khai.

Lấy các ID thực từ API, không dùng ID cố định theo ví dụ tài liệu. Thao tác test có thể đổi trạng thái hoặc sử dụng hết voucher; khởi động lại ứng dụng không reset dữ liệu vì Flyway chỉ chạy V5 một lần.

## File thay đổi trong lần bổ sung này

Chỉ thêm 4 file:

- `src/main/resources/db/migration/V5__seed_part_b_demo_data.sql`
- `src/main/resources/static/images/part-b-demo.svg`
- `src/test/java/com/utetra/PartBSeedMigrationTests.java`
- `docs/PART_B_V5_SEED.md`

Không sửa `DataInitializer`, `SecurityConfig`, `JwtAuthenticationFilter`, `ErrorController`, V1–V4 hoặc code nghiệp vụ của thành viên khác.

## Kiểm tra kỹ thuật

Test riêng `PartBSeedMigrationTests` thực thi V1–V5 trên H2 chế độ MySQL, với database mới và database có dữ liệu/ID lớn. Test kiểm tra chạy lại không tạo trùng, giữ nguyên dữ liệu cũ, hash mật khẩu, số lượng và quan hệ các bảng, giá trị đơn, stock/sold_count và trạng thái thanh toán. Đây là kiểm tra SQL/fixture, không thay thế chạy trên MySQL 8.4 hoặc test giao diện/gateway.

Lệnh chạy: `mvn -Dtest=PartBSeedMigrationTests test`.

Kết quả ngày 27/10/2026: **BUILD SUCCESS — 2 tests, 0 failures, 0 errors**. Mã nguồn hiện tại biên dịch được trong lần chạy này. Chưa chạy V5 trên MySQL 8.4 thật, chưa kiểm thử toàn bộ ứng dụng hoặc các module của A/C.

## Tin nhắn có thể gửi nhóm

> Mình đã thêm V5 seed dữ liệu demo phần B theo bản dev mới: 3 shop, 36 món đang bán + 2 món test trạng thái, thuộc tính/ảnh, giỏ hàng, đơn COD, voucher/promotion và đánh giá. Có tài khoản test và hướng dẫn trong docs/PART_B_V5_SEED.md. Chỉ thêm V5__seed_part_b_demo_data.sql, ảnh part-b-demo.svg, PartBSeedMigrationTests.java và tài liệu hướng dẫn; không sửa DataInitializer, SecurityConfig, JwtAuthenticationFilter, ErrorController hoặc V1–V4. Hai test migration H2 đều pass, nhờ nhóm chạy thêm trên MySQL 8.4. Nhớ lấy cả file ảnh kèm V5.
