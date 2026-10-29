# Chuyển khoản ngân hàng SePay — 29/10/2026

## Đã triển khai
- Thêm phương thức SEPAY bên cạnh COD/VNPAY/MOMO. Mặc định chưa bật khi thiếu cấu hình.
- POST /api/payment/sepay/qr: chỉ chủ đơn được lấy QR của đơn SEPAY đang chờ thanh toán. QR chứa tài khoản nhận, số tiền VND chính xác, mã SP + 32 ký tự hex riêng cho giao dịch. Tải lại trang dùng lại cùng mã.
- QR qua https://vietqr.app/img, hiển thị tên ngân hàng, chủ tài khoản, số tài khoản, số tiền và nội dung để khách đối chiếu. Đây là chuyển tiền thật.
- POST /api/payment/sepay/webhook: xác thực Authorization: Apikey <khóa bí mật>. Sai/thiếu khóa trả HTTP 401; không dựa vào trình duyệt quay về để ghi nhận thanh toán.
- Chỉ nhận giao dịch tiền vào đúng ngân hàng, tài khoản đã cấu hình, mã tham chiếu đầy đủ trong content và đúng số tiền. Không cộng dồn các khoản chuyển thiếu. Không tự nhận chuyển thừa.
- Lưu ID giao dịch SePay làm khóa chính trong sepay_receipts, khóa đơn khi xử lý, cập nhật giao dịch/đơn/ví cùng transaction. Gửi lặp không cộng doanh thu hai lần. Xung đột khóa duy nhất giữa hai request đồng thời sẽ rollback; bật retry trên SePay để gửi lại an toàn.
- Khi thành công: đơn mới thành CONFIRMED, thanh toán SUCCESS; dùng cơ chế ví hiện có để cộng doanh thu sau giảm giá, không cộng phí giao hàng vào ví shop. WebSocket + kiểm tra mỗi 5 giây cập nhật giao diện.
- Tiền đến sau hủy được ghi nhận thanh toán để đối soát, không khôi phục đơn hoặc cộng doanh thu shop. Hoàn tiền ngân hàng thực tế vẫn do người quản trị xử lý.
- Chuyển khoản lần hai với ID ngân hàng khác cho cùng đơn không cộng ví lần hai; phải đối soát/hoàn khoản thừa thủ công.

## Cấu hình còn cần trên máy chạy web
Eclipse → Run Configurations → Spring Boot App hiện tại → Environment:

| Biến | Giá trị |
| --- | --- |
| SEPAY_BANK | TPBank |
| SEPAY_ACCOUNT_NUMBER | Số tài khoản TPBank đã liên kết SePay |
| SEPAY_ACCOUNT_NAME | Tên chủ tài khoản ngân hàng, không dấu |
| SEPAY_WEBHOOK_KEY | Khóa bí mật ngẫu nhiên riêng, khuyến nghị ít nhất 32 byte |

Không commit khóa. File .env.example chỉ là ví dụ; Spring Boot không tự nạp file .env. Không dùng API token quản trị SePay làm khóa webhook. Không cần đưa mật khẩu ngân hàng vào dự án.

Khởi động lại web và giữ ngrok http 8080 đang chạy. Flyway tự áp dụng V9__sepay_receipts.sql, không xóa database hay sửa checksum V1–V8.

## Cấu hình trên SePay (chưa thao tác thay người dùng)
- Tích hợp WebHooks → thêm webhook.
- URL: https://unclog-wool-pacemaker.ngrok-free.dev/api/payment/sepay/webhook
- Sự kiện: tiền vào; chọn đúng tài khoản TPBank.
- Content-Type application/json; bật tự động gửi lại khi lỗi.
- Bảo mật: API Key, nhập cùng giá trị SEPAY_WEBHOOK_KEY. SePay gửi Authorization: Apikey <khóa>.
- Có thể để bộ lọc tiền tố trống và tắt bỏ qua giao dịch không có mã. Backend tự lọc content để tìm mã SP... chính xác; không cần cấu hình parser mã thanh toán của SePay.
- Nếu URL ngrok thay đổi, cập nhật URL webhook. Máy chạy web/ngrok phải hoạt động để nhận thông báo.

## Cách thử sau cấu hình
1. Đăng nhập customer, tạo đơn mới chọn Chuyển khoản ngân hàng (SePay).
2. Kiểm tra QR có tài khoản nhận đúng, tổng tiền đúng, nội dung SP... riêng.
3. Dùng app ngân hàng của người chuyển, giữ nguyên nội dung, chuyển đúng số tiền một lần.
4. Kiểm tra SePay có giao dịch và webhook trả {"success":true}, web đổi Đã thanh toán, ví shop tăng đúng tiền món sau giảm giá.
5. Gửi lại cùng webhook và tải lại trang: số dư không tăng lần hai.

Chưa chuyển tiền thật để kiểm thử trong phiên lập trình. Không tự động thực hiện rút tiền ngân hàng; số dư ví là sổ ghi nhận nội bộ.

## Tài liệu chính thức
- https://docs.sepay.vn/tich-hop-webhooks.html
- https://developer.sepay.vn/vi/sepay-webhooks/tao-webhook
- https://developer.sepay.vn/vi/sepay-webhooks/tao-qr-va-form-thanh-toan

## Các file của lần tích hợp này
- src/main/java/com/utetra/enums/PaymentMethod.java: thêm SEPAY.
- src/main/java/com/utetra/service/PaymentAvailability.java: kiểm tra bốn biến cấu hình trước khi mở lựa chọn.
- src/main/java/com/utetra/service/PaymentService.java: khai báo tạo QR, nhận webhook.
- src/main/java/com/utetra/service/impl/PaymentServiceImpl.java: tạo mã riêng, QR và đối chiếu giao dịch; tái sử dụng xử lý đơn/ví hiện có.
- src/main/java/com/utetra/controller/api/PaymentController.java: API lấy QR, webhook và lỗi xác thực HTTP 401.
- src/main/java/com/utetra/config/SecurityConfig.java: cho SePay gọi đúng endpoint webhook; việc xác thực khóa nằm trong dịch vụ thanh toán.
- src/main/java/com/utetra/entity/SepayReceipt.java và repository/SepayReceiptRepository.java: lưu ID ngân hàng chống xử lý trùng.
- src/main/resources/db/migration/V9__sepay_receipts.sql: tạo bảng lưu ID; không thay migration cũ.
- src/main/resources/application-commerce.yml và .env.example: cấu hình từ môi trường, không chứa khóa thật.
- src/main/resources/static/js/commerce.js: phương thức mới ở checkout, hiển thị QR/thông tin ngân hàng, cập nhật trạng thái.
- Các JSP dùng commerce.js: tăng mã phiên bản asset để tránh cache bản cũ.
- src/test/java/com/utetra/CommerceIntegrationTests.java: kiểm thử xác thực, đối chiếu, chống trùng/đồng thời, bảo vệ đơn khác, tiền đến sau hủy.
- src/test/java/com/utetra/PartBSeedMigrationTests.java: kiểm tra chạy migration V9 trên cơ sở dữ liệu mới và có dữ liệu.
- src/test/js/commerce-ui.test.cjs: kiểm tra thông tin QR SePay và cập nhật khi server xác nhận.
- docs/PART_B_HANDOFF.md: dẫn tới hướng dẫn này.
