# QR VNPay hiển thị tại trang thanh toán — 29/10/2026

## Hành vi

Khi mở trang thanh toán của đơn VNPay đang NEW/chưa SUCCESS, web tự gọi POST /api/payment/vnpay/qr. Backend kiểm tra người sở hữu đơn, tạo yêu cầu genqr ký HMACSHA512 theo đặc tả Merchant hosted QR v1.0.1 (vnp_Version=2.1.1), dùng số tiền chốt trong database nhân 100 và mã tham chiếu riêng.

Chỉ khi VNPay trả code=00 và qrcontent thì backend tạo ảnh PNG bằng ZXing tại máy chủ. Không gửi dữ liệu QR tới dịch vụ vẽ QR bên ngoài, không dùng link website làm mã chuyển tiền thay thế. Không tạo QR từ số tài khoản/ngân hàng tự đoán.

Trang hiển thị ảnh và thời gian còn lại (15 phút); QR đã tạo được dùng lại khi tải trang trong thời hạn. Hết hạn có nút tạo lại. Nếu sandbox chưa cấp quyền Merchant hosted QR, API lỗi/timeout/không trả JSON hợp lệ, trang báo lỗi và vẫn có nút Mở cổng VNPAY theo luồng cũ.

Trang nhận thông báo WebSocket, đồng thời kiểm tra trạng thái mỗi 5 giây. Khi IPN hợp lệ cập nhật thanh toán SUCCESS, trang tự hiển thị kết quả và gỡ QR. Việc tạo/hiển thị/quét QR không tự đánh dấu thanh toán hay cộng ví; chỉ IPN đã xác thực thực hiện việc đó theo luồng sẵn có.

## Database và luồng dự phòng

V8__vnpay_hosted_qr.sql thêm qr_content và qr_expires_at vào payment_transactions, giữ dữ liệu cũ. Mã tham chiếu tạo QR khác mã tham chiếu mở cổng pay để không dùng sai loại giao dịch. Không ghi đè QR cache bằng URL thanh toán.

QR sandbox chỉ dùng cho thử nghiệm, không hứa quét bằng app ngân hàng thật sẽ chuyển được tiền. Quyền gọi genqr và công cụ/app test QR cần được VNPay cấp cho merchant. Đưa web lên mạng không tự kích hoạt quyền này.

## File

- pom.xml: ZXing core 3.5.3.
- PaymentTransaction.java và V8: lưu QR và hạn sử dụng.
- PaymentService.java, PaymentServiceImpl.java: API tạo, ký, gọi VNPay, cache và xử lý lỗi.
- PaymentQrImage.java: dựng ảnh PNG từ qrcontent.
- PaymentController.java: endpoint QR có xác thực và kiểm tra chủ đơn trong service.
- commerce.js: tự tải QR, đếm giờ, tạo lại, tự cập nhật trạng thái và phương án dự phòng.
- CommerceIntegrationTests.java: máy chủ VNPay giả để kiểm tra chữ ký, số tiền, chống truy cập đơn người khác, cache, ảnh giải mã đúng nội dung, callback thành công và từ chối merchant.
- PartBSeedMigrationTests.java: V1–V8 trên H2 MySQL mode.
- commerce-ui.test.cjs: tự hiện QR, gỡ khi nhận SUCCESS và giữ nút mở cổng khi lỗi.

## Xác minh thực tế còn lại

Test tự động dùng VNPay giả, không dùng secret thật. Chưa xác nhận terminal sandbox hiện tại được mở Merchant hosted QR. Khi chạy lại web bằng cấu hình VNPay hiện có, mở một đơn VNPay mới để xem ảnh QR hoặc thông báo phản hồi; nếu chưa được cấp quyền, gửi yêu cầu hỗ trợ Merchant hosted QR/genqr cho VNPay.

Đặc tả tham khảo: tài liệu VNPAYQR-GenQR-DeepLink-Techspec.pdf (VPG_DTKN_HOSTEDQR 1.0.1, 01/2024), bản đính kèm tại https://github.com/user-attachments/files/26433247/VNPAYQR-GenQR-DeepLink-Techspec.pdf. Tài liệu được tìm qua PR thư viện bên thứ ba; cần đối chiếu bản VNPay cung cấp cho merchant nếu khác phiên bản.

Kết quả kiểm thử cuối: **36/36 Java và 6/6 JavaScript thành công**; kiểm tra cú pháp commerce.js và Git diff whitespace qua.
