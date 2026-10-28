# Bàn giao ghép nhánh và hoàn thiện phần B — 29/10/2026

## Bản được so sánh

- Bản phần B trước khi ghép: `b4c4664`, nhánh `feature/product-cart-order`.
- Bản thành viên nhóm: `origin/feature/test-merge-a-b-c`, commit `51204e8`.
- Nhánh sao lưu: `backup/part-b-before-team-20261028`.
- Ghép tại máy; không push lên GitHub và không sửa trực tiếp nhánh dev.

## Quyết định khi ghép

Giữ dashboard quản trị, quản lý người dùng, giao diện đánh giá, quên/đặt lại mật khẩu, trang shop/ví và migration V6 từ bản nhóm. Giữ các API/service của B để xử lý sản phẩm, giỏ, đơn, voucher và promotion.

Không dùng các POST trong CommercePageController của bản nhóm vì chúng ghi trực tiếp vào repository, bỏ qua kiểm tra chủ shop, thuộc tính, tồn kho, voucher và trạng thái thanh toán. Giữ controller trang mỏng và gọi API đã kiểm tra nghiệp vụ. Cũng không giữ đoạn cộng ví trực tiếp trong controller khi chuyển DELIVERED: đoạn này chưa bảo đảm chống cộng trùng/hoàn tiền. Luồng quyết toán thu nhập ví cần được tích hợp riêng với phần C; không coi thanh toán thành công là đã quyết toán/rút tiền ngân hàng.

Giữ cấu hình JWT, chuyển hướng đăng nhập, UTF-8 và kết nối database đã sửa trước đó. Trang vendor/admin được thêm nội dung head để CSS của phần B hiển thị đúng.

## Yêu cầu đã xử lý

1. **Voucher**: xác nhận mỗi tài khoản được dùng một lần cho mỗi mã; nhiều tài khoản vẫn dùng cùng mã đến tổng giới hạn. Xem báo giá không tiêu hao lượt. Đặt đơn thành công mới ghi nhận lượt. Giữ chính sách hiện tại: hủy đơn không hoàn lại lượt, mã đã dùng không được sửa điều kiện. Có test hai khách dùng được cùng mã, khách thứ ba bị chặn khi tổng giới hạn là hai.
2. **Danh sách ưu đãi tại checkout**: giữ ô nhập tay, thêm danh sách mã của đúng shop, hiển thị loại giảm, giá trị, đơn tối thiểu, mức giảm tối đa. Lọc mã đã dùng, hết hạn, hết tổng lượt, xóa mềm; đánh dấu mã chưa đủ điều kiện. Tạo/sửa/xóa voucher và promotion, hoặc có khách dùng voucher sẽ phát thông báo WebSocket sau commit. Trang tải lại danh sách và vô hiệu báo giá cũ; kiểm tra nền mỗi 5 giây hỗ trợ hết hạn theo thời gian hoặc mất kết nối. Server vẫn kiểm tra lại giá và điều kiện khi tạo đơn.
   - Voucher là ưu đãi người mua có thể chọn. Promotion giảm giá sản phẩm tự động vẫn dùng mức tốt nhất của từng món theo thiết kế sẵn; không cộng lặp bằng cách chọn như voucher.
3. **Giỏ hàng**: nút +/− tự gửi cập nhật, tải lại thành tiền, bỏ nút Lưu. Nhập số trực tiếp cũng lưu khi thay đổi. Không giảm dưới một; lỗi tồn kho hiển thị thông báo và phục hồi số lượng cũ. Đơn đã tạo giữ số lượng chốt lúc mua.
4. **Menu theo quyền**: khách chưa đăng nhập chỉ thấy mục công khai; customer không thấy quản trị/người bán; vendor không thấy quản trị; admin thấy các khu vực được cấp quyền. Dùng quyền phía server, vẫn chặn truy cập API bằng URL. Các liên kết hỗ trợ context path khi chạy WAR.
5. **Thuộc tính**: giỏ, checkout và chi tiết đơn hiển thị `Kích cỡ: L · Đường: 50%` thay chuỗi JSON. Nội dung được escape HTML.

## Sửa bổ sung khi rà soát

- Đăng xuất ở trang vendor/admin xóa token và cookie trước khi về đăng nhập.
- Sửa ảnh xem trước đánh giá bị JSP hiểu nhầm biến JavaScript; dùng DOM API. Giữ hỗ trợ ảnh và video MP4/WebM cả xem trước lẫn danh sách đánh giá.
- Giữ Local Storage của bản nhóm: mặc định `./uploads`, có thể cấu hình `app.upload.dir`; URL `/uploads/**` được phục vụ công khai và bỏ qua SiteMesh. Chặn đuôi HTML/SVG/script, đóng stream sau upload, kiểm tra tiền tố khi xóa file. URL media đánh giá chỉ nhận upload theo người dùng hoặc ảnh Cloudinary cũ.
- Lịch sử ví truy vấn đúng walletId thay vì toàn bộ giao dịch hệ thống. Trang xem ví/form rút/POST rút kiểm tra chủ shop; chặn số tiền không dương và thông tin ngân hàng trống.
- Nạp application-commerce.yml bằng config import để nhận biến môi trường thanh toán và tránh profile commerce ghi đè cấu hình giả của test.
- Sửa V6 dùng cột `note` đúng schema V4 (entity description ánh xạ sang note), sửa kiểm tra trùng dùng walletId thay shopId; dữ liệu ví/rút là dữ liệu demo, không phải tiền thật.

## Kiểm thử và giới hạn

- Kết quả cuối: **32/32 test Java và 4/4 test JavaScript thành công**. Kiểm tra cú pháp commerce.js và Git diff whitespace cũng qua.
- Java: `mvn -Dmaven.repo.local=C:/Users/Dell/.m2/repository test`.
- JavaScript: cài jsdom 26.1.0 trong `src/test/js` theo package.json rồi `node --test src/test/js/*.test.cjs` từ gốc repo (Node tự tìm dependency cùng thư mục test).
- JavaScript đã qua 4/4 test: khôi phục phiên/đăng xuất, loại token hết hạn, giỏ tự lưu/Size và checkout chọn mã/nhận thông báo thay đổi.
- Java có test dữ liệu/giới hạn voucher, sửa/xóa/hết hạn/đơn tối thiểu, phân quyền menu/API/kênh WebSocket, quyền ví khác chủ, phạm vi lịch sử ví, upload, lỗi broker, cùng các test đơn hàng/tồn kho/payment callback trước đó.
- Không sửa V1–V5. V6 đang ở nhánh chưa merge của nhóm được sửa trước khi bàn giao. Nếu máy nào đã áp dụng V6 cũ, cần kiểm tra lịch sử Flyway trước khi đồng bộ bản migration sửa; không xóa database để né lỗi.
- Migration V1–V6 được kiểm tra trên H2 ở chế độ MySQL, cả database mới và dữ liệu có ID khác. Không đồng nghĩa đã chạy migration trên MySQL thật.
- UI test dùng DOM mô phỏng và API giả; HTTP integration chạy Spring Boot/JSP thật với H2. Chưa kiểm tra trực quan toàn bộ trang trong trình duyệt thật, chưa chạy VNPay/MoMo với tiền thật hoặc thông báo IPN từ nhà cung cấp. VNPay sandbox đang chờ cấu hình IPN từ trước là việc riêng.
- Upload local cần thư mục lưu bền vững khi deploy; chạy nhiều server phải chia sẻ nơi lưu. Ảnh local của từng máy không tự đồng bộ qua Git.

## Các file có thay đổi so với bản B ban đầu

Danh sách bao gồm cả file nhận từ nhánh thành viên và file chỉnh khi ghép:

- `.gitignore`
- `pom.xml`
- `src/main/java/com/utetra/config/JspViewConfig.java`
- `src/main/java/com/utetra/config/SecurityConfig.java`
- `src/main/java/com/utetra/config/SitemeshConfig.java`
- `src/main/java/com/utetra/config/WebMvcConfig.java`
- `src/main/java/com/utetra/controller/admin/AdminDashboardController.java`
- `src/main/java/com/utetra/controller/admin/AdminUserController.java`
- `src/main/java/com/utetra/controller/auth/AuthPageController.java`
- `src/main/java/com/utetra/controller/customer/CustomerOrderController.java`
- `src/main/java/com/utetra/controller/customer/CustomerReviewController.java`
- `src/main/java/com/utetra/controller/vendor/VendorProductController.java`
- `src/main/java/com/utetra/controller/vendor/VendorShopController.java`
- `src/main/java/com/utetra/controller/vendor/VendorWalletController.java`
- `src/main/java/com/utetra/entity/WalletTransaction.java`
- `src/main/java/com/utetra/repository/OrderRepository.java`
- `src/main/java/com/utetra/security/OrderSocketAuthorization.java`
- `src/main/java/com/utetra/service/CatalogManagementService.java`
- `src/main/java/com/utetra/service/CloudinaryService.java`
- `src/main/java/com/utetra/service/OfferEvents.java`
- `src/main/java/com/utetra/service/OrderQuoteService.java`
- `src/main/java/com/utetra/service/StorageService.java`
- `src/main/java/com/utetra/service/impl/CloudinaryServiceImpl.java`
- `src/main/java/com/utetra/service/impl/LocalStorageServiceImpl.java`
- `src/main/java/com/utetra/service/impl/OrderServiceImpl.java`
- `src/main/java/com/utetra/service/impl/PromotionServiceImpl.java`
- `src/main/java/com/utetra/service/impl/ReviewServiceImpl.java`
- `src/main/java/com/utetra/service/impl/UserServiceImpl.java`
- `src/main/java/com/utetra/service/impl/VoucherServiceImpl.java`
- `src/main/java/com/utetra/service/impl/WalletServiceImpl.java`
- `src/main/resources/application.yml`
- `src/main/resources/db/migration/V6__seed_wallet_and_withdraw_data.sql`
- `src/main/resources/static/js/commerce.js`
- `src/main/webapp/WEB-INF/decorators/admin-decorator.jsp`
- `src/main/webapp/WEB-INF/decorators/main-decorator.jsp`
- `src/main/webapp/WEB-INF/decorators/vendor-decorator.jsp`
- `src/main/webapp/WEB-INF/views/admin/dashboard.jsp`
- `src/main/webapp/WEB-INF/views/admin/product-list.jsp`
- `src/main/webapp/WEB-INF/views/admin/shop-list.jsp`
- `src/main/webapp/WEB-INF/views/admin/user-list.jsp`
- `src/main/webapp/WEB-INF/views/admin/withdraw-list.jsp`
- `src/main/webapp/WEB-INF/views/auth/forgot-password.jsp`
- `src/main/webapp/WEB-INF/views/auth/login.jsp`
- `src/main/webapp/WEB-INF/views/auth/reset-password.jsp`
- `src/main/webapp/WEB-INF/views/customer/review-form.jsp`
- `src/main/webapp/WEB-INF/views/guest/product-detail.jsp`
- `src/main/webapp/WEB-INF/views/vendor/shop-form.jsp`
- `src/main/webapp/WEB-INF/views/vendor/shop-list.jsp`
- `src/main/webapp/WEB-INF/views/vendor/wallet.jsp`
- `src/main/webapp/WEB-INF/views/vendor/withdraw-request.jsp`
- `src/test/java/com/utetra/CommerceIntegrationTests.java`
- `src/test/java/com/utetra/MergeBoundaryTests.java`
- `src/test/java/com/utetra/PartBSeedMigrationTests.java`
- `src/test/js/commerce-ui.test.cjs`
- `src/test/js/package.json`
