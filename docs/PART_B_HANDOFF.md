# Bàn giao phần B — UTETra

Cập nhật: 23/10/2026. Mã nguồn đã được chỉnh trực tiếp tại `D:\Year-3\Lap-trinh-web\SpringToolForEclipse-Workspace\utetra-web`.

## Phạm vi đã bổ sung

- Sản phẩm thuộc riêng từng shop. Bộ lọc kết hợp `shopId`, `categoryId`, `keyword`, sort và phân trang; loại sản phẩm bị xóa, chưa mở bán và shop/danh mục bị xóa khỏi API công khai.
- API trang chủ nhóm theo shop, tối đa 12 sản phẩm bán chạy mỗi shop, phân trang danh sách shop. Shop ít sản phẩm được trả về đúng số lượng thực tế.
- Vendor CRUD sản phẩm, tên slug riêng, kiểm tra chủ shop và sản phẩm thuộc đúng shop; danh mục/thuộc tính do admin quản lý. Upload/list/delete ảnh qua Cloudinary và DTO trả ảnh/thuộc tính đầy đủ.
- Giỏ hàng lưu DB theo user + shop; phân biệt lựa chọn thuộc tính, kiểm tra phụ thu và tồn kho. User được lấy từ JWT, không tin `userId` gửi từ client.
- Báo giá và đặt hàng từng shop; snapshot tên/ảnh/giá/thuộc tính; khóa hàng hóa theo thứ tự ID, cộng gộp số lượng các biến thể để tránh vượt tồn kho. Chỉ xóa cart items thuộc shop đang đặt.
- Đơn COD, VNPay, MoMo; lịch sử trạng thái; kiểm tra quyền xem/hủy/cập nhật đơn; hoàn lại tồn kho đúng một lần khi hủy hoặc trả hàng.
- Voucher theo shop hoặc voucher toàn hệ thống có sẵn, giới hạn lượt dùng, mỗi người một lượt, thời gian/minimum/cap; voucher giảm tiền món hoặc phí giao hàng. Không cho sửa điều kiện voucher đã được sử dụng.
- Promotion liên kết đúng sản phẩm của shop. Khi nhiều promotion cùng hiệu lực, dùng mức giảm tốt nhất cho từng sản phẩm; voucher được áp dụng sau giá promotion.
- Đánh giá chỉ khi người mua có sản phẩm trong đơn DELIVERED, 1–5 sao, tối thiểu 50 ký tự, 1–5 ảnh/video. Mỗi người một đánh giá cho sản phẩm.
- WebSocket gửi thông báo sau commit, xác thực JWT cho STOMP và kiểm tra quyền subscribe. Lỗi gửi thông báo không biến giao dịch đã commit thành lỗi đặt hàng.

## Quy ước xác thực và phản hồi

Các API khách hàng/vendor/admin dùng `Authorization: Bearer <accessToken>` từ module đăng nhập của A. Không thêm `userId` vào query để chọn người dùng.

API vendor yêu cầu role VENDOR/ADMIN **và** đúng chủ cửa hàng. ADMIN không tự động được giả làm chủ một shop; thao tác admin riêng nằm dưới `/api/admin/`.

DTO thành công trả trực tiếp theo endpoint. Lỗi trả `{code,message,data}`. Các trường nhập sai trả 400; truy cập ngoài quyền 403; không tìm thấy 404; trùng dữ liệu hoặc tranh chấp khóa 409; file quá lớn 413. Cổng thanh toán chưa cấu hình trả 503.

## API công khai

| Method | URL | Nội dung |
|---|---|---|
| GET | `/api/categories` | Danh mục đang dùng |
| GET | `/api/products?shopId=1&categoryId=2&keyword=tra&sort=best_selling&page=0&size=20` | Lọc đồng thời; size 1–100 |
| GET | `/api/products/{id}` | Chi tiết, shop, ảnh, thuộc tính; lưu lịch sử xem nếu có JWT |
| GET | `/api/products/{id}/reviews?page=0` | Đánh giá, phân trang |
| GET | `/api/products/home/shops?page=0` | Trang chủ nhiều shop; 6 shop/trang, 12 món/shop |
| GET | `/api/products/home` | Danh sách bán chạy toàn hệ thống, giữ tương thích API cũ |
| GET | `/api/products/shop/{shopId}` | Menu riêng một shop |

Sort hỗ trợ: `newest`, `best_selling`, `price_asc`, `price_desc`.

## API vendor

`GET /api/vendor/catalog/shops` trả shop của tài khoản hiện tại để chọn shop, không hard-code `shopId=1`.

Tiền tố chung: `/api/vendor/shops/{shopId}`.

| Method | Đường dẫn sau tiền tố | Nội dung |
|---|---|---|
| GET/POST | `/products` | Danh sách phân trang/tạo sản phẩm |
| GET/PUT/DELETE | `/products/{id}` | Chi tiết/sửa/xóa mềm |
| GET/POST | `/products/{id}/images` | Danh sách ảnh/upload multipart `file` |
| DELETE | `/products/{id}/images/{imageId}` | Xóa mềm ảnh |
| GET | `/orders?status=CONFIRMED&page=0&size=10` | Bỏ status để xem mọi trạng thái |
| GET | `/orders/{id}` | Đơn chi tiết của shop |
| PATCH | `/orders/{id}/status` | `{ "status":"PICKED_UP", "note":"Đã chuẩn bị xong" }` |
| GET/POST | `/vouchers` | Danh sách/tạo voucher |
| PUT/DELETE | `/vouchers/{id}` | Sửa/xóa mềm voucher |
| GET/POST | `/promotions` | Danh sách/tạo khuyến mãi |
| PUT/DELETE | `/promotions/{id}` | Sửa/xóa mềm khuyến mãi |

Tạo/sửa sản phẩm:

```json
{"categoryId":2,"name":"Trà sữa ô long","description":"Mô tả món","price":35000,"stock":100}
```

Sản phẩm mới là PENDING, cần admin duyệt ACTIVE. Giá sản phẩm/phụ thu sử dụng số nguyên VND.

Tạo voucher:

```json
{"code":"SHOP1SAVE","voucherType":"PRODUCT","discountType":"PERCENT","discountValue":10,"minOrderAmount":50000,"maxDiscountAmount":20000,"usageLimit":100,"startDate":"2026-10-23T00:00:00","endDate":"2026-12-31T23:59:59"}
```

`voucherType`: PRODUCT/SHIPPING. `discountType`: PERCENT/FIXED. `usageLimit` và `maxDiscountAmount` có thể bỏ trống. Mã dùng chung namespace toàn hệ thống, nên mỗi shop chọn mã khác nhau. Mức giảm không vượt giá trị áp dụng. Lượt voucher đã dùng không được hoàn lại khi hủy đơn trong chính sách hiện tại.

Tạo promotion:

```json
{"name":"Giảm cuối tuần","promotionType":"PERCENT","discountType":"PERCENT","discountValue":10,"startDate":"2026-10-23T00:00:00","endDate":"2026-12-31T23:59:59","productIds":[1,2]}
```

`promotionType` khớp `discountType` theo enum hiện có của dự án. Mọi productIds phải thuộc shop đang quản lý.

## API admin

- GET/POST `/api/admin/categories`; GET/PUT/DELETE `/api/admin/categories/{id}`. POST/PUT nhận form/query `name`, `slug`, `parentId` tùy chọn. Kiểm tra vòng lặp danh mục cha.
- GET `/api/admin/attributes?productId=1`; POST `/api/admin/attributes`; PUT/DELETE `/api/admin/attributes/{id}`.
- GET `/api/admin/catalog/products?page=0`; PATCH `/api/admin/catalog/products/{id}/status?status=ACTIVE` để duyệt. ARCHIVED để ẩn, BANNED để cấm.

Body thuộc tính:

```json
{"productId":1,"name":"Size","values":[{"value":"M","extraPrice":0},{"value":"L","extraPrice":5000}]}
```

Thuộc tính thuộc từng sản phẩm theo entity gốc. Sửa thuộc tính có thể làm lựa chọn cũ trong giỏ không còn hợp lệ; API báo để người dùng chọn lại. Đơn đã đặt vẫn giữ snapshot.

## API khách hàng

| Method | URL | Nội dung |
|---|---|---|
| GET | `/api/customer/cart` | Mảng giỏ, nhóm theo shop |
| POST | `/api/customer/cart/items` | Thêm món và lựa chọn |
| PUT | `/api/customer/cart/items/{id}` | `{ "quantity":2 }` |
| DELETE | `/api/customer/cart/items/{id}` | Xóa dòng giỏ của chính mình |
| POST | `/api/customer/orders/quote` | Tính lại tổng tiền theo giá/ưu đãi server |
| POST | `/api/customer/orders` | Tạo đơn trong transaction |
| GET | `/api/customer/orders?status=DELIVERED&page=0&size=10` | Bỏ status để lấy mọi đơn |
| GET | `/api/customer/orders/{id}` | Chi tiết đơn thuộc người mua |
| POST | `/api/customer/orders/{id}/cancel` | `{ "reason":"Đổi địa chỉ" }` |
| POST | `/api/customer/reviews/media` | Upload multipart `file` |
| POST | `/api/customer/reviews` | Gửi đánh giá |

Thêm giỏ hàng (selectedAttributes là **chuỗi JSON**):

```json
{"productId":1,"quantity":2,"selectedAttributes":"{\"Size\":\"L\"}"}
```

Không có thuộc tính dùng `"{}"`. Tất cả thuộc tính hiện có phải được chọn; không chấp nhận tên/giá trị ngoài danh sách của sản phẩm.

Báo giá/đặt hàng:

```json
{"shopId":1,"shippingAddress":"Tên người nhận, điện thoại, địa chỉ đầy đủ","voucherCode":"SHOP1SAVE","paymentMethod":"COD"}
```

`paymentMethod`: COD/VNPAY/MOMO. Khi tạo đơn, frontend có thể gửi thêm `expectedTotalAmount` lấy từ quote; nếu tổng đã thay đổi, server từ chối để khách xác nhận lại. Trang checkout đã dùng trường này. Mỗi lần đặt chỉ đặt cart của một shop.

Body đánh giá:

```json
{"orderId":1,"productId":1,"rating":5,"comment":"Nội dung đánh giá thực tế dài ít nhất năm mươi ký tự.","mediaUrls":["https://res.cloudinary.com/TEN_CLOUD/image/upload/anh.jpg"]}
```

URL lấy từ API upload, không tự thay bằng URL tùy ý. File nhận JPG/PNG/WebP/GIF; review thêm MP4/WebM; tối đa 20 MB/tệp.

## Thanh toán và giao dịch

- POST `/api/payment/vnpay` hoặc `/api/payment/momo`, body `{ "orderId":1 }`, có JWT của người mua. Trả `paymentUrl` và `reference`.
- VNPay IPN: **GET** `/api/payment/vnpay/ipn`.
- MoMo IPN: **POST JSON** `/api/payment/momo/ipn`, phản hồi 204 khi đã xử lý.
- Hai IPN riêng thay cho URL callback chung trong bản phân công vì giao thức hai cổng khác nhau.
- VNPay HMAC-SHA512, MoMo HMAC-SHA256; kiểm tra merchant, reference, phương thức và số tiền. Callback lặp không tạo lịch sử hoặc xác nhận đơn lần nữa.
- Trang browser return chỉ đọc trạng thái từ server; không tự đánh dấu đã thanh toán dựa trên query string.
- Mỗi đơn có `payment_transactions` ghi nhận trạng thái và số tiền; COD cập nhật khi giao/hoàn tiền. Bảng này là sổ giao dịch thanh toán của B, chưa thay thế bảng `transactions`/ví thuộc C.
- Đơn trực tuyến chỉ chuyển CONFIRMED sau callback thành công. Thanh toán đến sau khi khách hủy được ghi nhận nhưng **không mở lại đơn**, lịch sử đánh dấu cần đối soát/hoàn tiền.
- Tạo lại payment khi lần trước đã thất bại tạo reference mới; khi còn pending dùng lại URL/reference. Nếu URL pending đã hết hạn ở gateway, khách cần hủy và đặt lại hoặc nhóm bổ sung luồng truy vấn/reconcile với gateway trước khi tạo lần thanh toán mới.

Trạng thái chính: NEW → CONFIRMED → PICKED_UP → SHIPPING → DELIVERED. Hủy chỉ trước khi lấy hàng. RETURNED trả tồn kho một lần; REFUNDED cho COD đã thanh toán và đã trả hàng, yêu cầu ghi chú. **Hoàn tiền trực tuyến chưa gọi API refund ngân hàng/MoMo; cần nối với module ví/đối soát của C.** Không giả báo refund thành công khi chưa hoàn tiền thật.

## WebSocket

- SockJS: `/ws`; native WebSocket: `/ws-native`.
- STOMP CONNECT phải có header `Authorization: Bearer <accessToken>`.
- Chủ shop subscribe `/topic/shop/{shopId}/orders`.
- Người mua hoặc chủ shop của đơn subscribe `/topic/order/{orderId}/status`.
- Payload `{orderId,status,paymentStatus}`. Client không được SEND để giả mạo thông báo.
- `OrderEvents.Changed` là điểm tích hợp nội bộ cho module thông báo/ví của A/C; event được phát trong transaction, listener WebSocket chạy AFTER_COMMIT. Chưa có cơ chế hàng đợi bền vững/retry cho thông báo.

## Cấu hình và cơ sở dữ liệu

File cấu hình mới `src/main/resources/application-commerce.yml` được import từ application.yml. Khai báo biến môi trường trong Run Configuration của IDE hoặc shell (file `.env` không tự được Spring đọc):

| Biến | Ý nghĩa |
|---|---|
| SHIPPING_FEE | Phí giao hàng mặc định; 15000 VND |
| PAYMENT_RETURN_URL | URL public của `/customer/payment`, bao gồm context path nếu deploy WAR |
| VNPAY_TMN_CODE | Mã merchant sandbox của nhóm |
| VNPAY_HASH_SECRET | Secret sandbox; không commit |
| VNPAY_URL | Mặc định URL sandbox VNPay |
| MOMO_PARTNER_CODE | Partner sandbox |
| MOMO_ACCESS_KEY | Access key sandbox |
| MOMO_SECRET_KEY | Secret sandbox; không commit |
| MOMO_IPN_URL | URL HTTPS public đến `/api/payment/momo/ipn` |
| MOMO_URL | Mặc định endpoint sandbox MoMo |

VNPay IPN phải đăng ký URL HTTPS public với VNPay. Localhost không nhận được callback từ server gateway. Cloudinary dùng cấu hình hiện có trong dự án; chưa thực hiện upload thật hay giao dịch thật trong quá trình sửa.

`V3__commerce_part_b.sql` là migration bổ sung bảng B bằng CREATE TABLE IF NOT EXISTS, không xóa dữ liệu. Bao gồm schema shop tối thiểu để triển khai mới; C tiếp tục mở rộng Shop bằng migration riêng. Bảng cũ tạo bởi Hibernate được giữ nguyên; cần xem schema thực tế khi chuyển từ dev (`ddl-auto=update`) sang prod (`validate`). Chưa áp dụng migration vào MySQL thật của nhóm.

## Môi trường Tomcat

Trước khi sửa, `pom.xml` đã dùng Spring Boot 4.1.1 và `tomcat.version=11.0.24`. Eclipse của máy lại khai báo Apache Tomcat 10.1.59, web facet 6.0. Đây là sự lệch môi trường có sẵn; chưa thay đổi bản cài Tomcat hoặc hạ Spring Boot.

Đã nâng SiteMesh từ 3.2.0 lên 3.3.0-RC1 và cấu hình JSP alwaysInclude để phù hợp runtime Boot/Tomcat trong Maven. Nếu nhóm bắt buộc deploy lên Tomcat 10.1, cần đồng bộ phiên bản Spring Boot/dependencies trước; không chỉ sửa một số `tomcat.version`. Bản này chưa được xác nhận deploy được lên Tomcat 10.1.

## Kết quả kiểm tra đã lưu và giới hạn

Trước yêu cầu dừng kiểm thử, log `tests-final.log` ghi **20 test: 19 pass, 1 fail**. Test fail là render JSP do đường dẫn decorator bị ghép lặp `/WEB-INF/decorators/`. Đã sửa lại tên decorator sau khi đọc log nhưng **chưa chạy lại**.

Các test đã qua ở thời điểm đó bao gồm tìm kiếm nhiều shop, giỏ/đơn và phân quyền, cạnh tranh tồn kho, voucher/promotion, đánh giá, callback VNPay/MoMo, quyền WebSocket, chữ ký, migration với H2 và khởi động context. Migration H2 không tương đương xác minh MySQL thật.

Sau đó có thêm chỉnh sửa ledger COD, expectedTotalAmount, khóa cập nhật voucher/sản phẩm, validation và xử lý lỗi. **Không chạy lại test hoặc build cho bản cuối theo yêu cầu của người dùng**, nên không coi kết quả cũ là xác nhận toàn bộ bản cuối đã ổn.

Các bài test nằm trong `src/test/`, chỉ dùng H2 bộ nhớ, không dùng DB MySQL nhóm. Có thể chủ động chạy `mvn test` sau này khi nhóm muốn kiểm tra lại.

## Các điểm bàn giao cho A/C

- A: dùng các endpoint cart/order/review phía trên và gửi JWT; xem `shopId` trong DTO thay vì giả định một shop.
- C: cung cấp dữ liệu Shop và owner đúng. B dùng cấu trúc Shop tối thiểu hiện có (`owner`, `name`, `isDeleted`); chưa có status/staff nên quyền vendor dựa trên owner.
- C: nối PaymentTransaction/OrderEvents với ví, sổ `transactions`, đối soát và refund online. B không tự tạo dòng tiền giả.
- FavoriteServiceImpl trước đây trống làm ứng dụng không khởi động; đã triển khai các phương thức của interface hiện hữu để giữ module A có thể hoạt động và giữ nút yêu thích ở trang sản phẩm.

Tài liệu giao thức tham khảo: [VNPay Payment](https://sandbox.vnpayment.vn/apis/docs/thanh-toan-pay/pay.html), [MoMo One-time Payment](https://developers.momo.vn/v3/vi/docs/payment/api/wallet/onetime/), [MoMo IPN](https://developers.momo.vn/v3/docs/payment/api/result-handling/notification/), [SiteMesh compatibility](https://github.com/sitemesh/sitemesh3/blob/master/JAKARTA_UPGRADE.md).
