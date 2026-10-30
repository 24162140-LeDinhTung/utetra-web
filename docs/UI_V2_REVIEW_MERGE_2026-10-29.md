# Ghép giao diện v2 và đơn giản hóa đánh giá — 29/10/2026

## Nguồn và trạng thái

- Nhánh người dùng yêu cầu: origin/test-merge-a-b-c-v2.
- Commit giao diện: 069fd74, tác giả hptrong1234567, “style: Cap nhat va hoan thien giao dien Phan C”.
- Bản hiện tại trước ghép: 9b70746 trên feature/product-cart-order.
- Điểm chung: 20b4967. Phía nhánh v2 chỉ có một commit mới từ điểm chung, gồm 44 file giao diện/tài nguyên; không có chức năng backend mới cần thay thế logic hiện tại.
- Đã dùng git merge --no-commit --no-ff, giải quyết 6 file xung đột. Không tạo commit hoặc push theo yêu cầu người dùng. Git giữ trạng thái merge chờ commit; các file đã giải quyết để có thể xem trước và commit khi được yêu cầu.

## Giao diện nhận từ thành viên

Giữ bố cục, tông xanh trà/kem, phông Lora, ảnh hero trà sữa/matcha, ảnh đồ uống, menu di động, thẻ cửa hàng và footer từ nhánh v2. Không tự thiết kế lại theme.

- Khách hàng: trang chủ, thực đơn, chi tiết sản phẩm/shop, giỏ, checkout, thanh toán, đơn hàng, hồ sơ, yêu thích, lịch sử xem và đánh giá.
- Auth: khung đăng nhập/đăng ký và layout có hình ảnh mới.
- Vendor/Admin: header, sidebar, kiểu bảng, form, thẻ số dư và bố cục responsive mới qua management-ui.css/js.
- Bổ sung thư viện phông Lora cùng giấy phép OFL; giữ các ảnh mà nhánh nhóm cung cấp.
- product-images.js thay ảnh demo/placeholder bằng ảnh đồ uống tương ứng, không ghi đè ảnh sản phẩm thật đã upload.

## Các quyết định khi giải quyết xung đột

1. main-decorator.jsp: dùng giao diện mới; giữ IIFE kiểm tra token hết hạn, khôi phục cookie và đăng xuất xóa token/cookie. Chỉ hiện liên kết customer/vendor/admin khi có quyền, kể cả ở footer. Các URL có context path.
2. admin-decorator.jsp và vendor-decorator.jsp: lấy bố cục mới; giữ sitemesh head để CSS từ trang con được tải và giữ đăng xuất xóa thông tin đăng nhập.
3. login.jsp: nhận toàn bộ bố cục mới nhưng giữ xử lý đăng nhập/điều hướng theo role của bản hiện tại; URL hỗ trợ context path.
4. review-form.jsp: dùng shell đánh giá của nhánh v2, chạy qua commerce.js hiện tại.
5. guest/product-detail.jsp: dùng shell giao diện v2; logic giá, chọn thuộc tính, thêm giỏ và hiển thị đánh giá vẫn ở commerce.js hiện tại.

Giữ các sửa trước: voucher theo shop và realtime, +/− tự lưu, thuộc tính dễ đọc, quyền chủ shop, VNPay/MoMo/IPN, QR trực tiếp, cộng ví/chống trùng và thu hồi doanh thu. Không nhận lại CommercePageController ghi repository trực tiếp hoặc logic cũ đánh dấu SUCCESS khi chưa thanh toán.

## Yêu cầu đánh giá mới

- Bỏ tối thiểu 50 ký tự ở DTO, service và form JavaScript.
- Bỏ bắt buộc có ảnh/video. mediaUrls thiếu, null hoặc danh sách rỗng đều được chấp nhận.
- Cho phép chỉ chấm sao, không có bình luận hay ảnh/video. Bình luận không có được lưu chuỗi rỗng để tương thích cột NOT NULL.
- Bình luận ngắn như “Ngon” được gửi và hiển thị ở trang sản phẩm.
- Giữ tối đa 5000 ký tự; nếu đính kèm thì tối đa 5 tệp, mỗi tệp tối đa 20 MB và kiểm tra định dạng/URL như trước.
- Giữ 1–5 sao, đơn phải thuộc người đang đăng nhập và DELIVERED, sản phẩm phải trong đơn, mỗi tài khoản đánh giá mỗi sản phẩm một lần.
- Cập nhật PART_B_HANDOFF và thêm chú thích thay đổi yêu cầu vào TASK_ASSIGNMENT, giữ nội dung phân công gốc để tham khảo lịch sử.

## Sửa thêm khi kiểm tra

- Tên alias month trong truy vấn doanh thu tháng xung đột từ khóa H2. Đổi thành revenue_month, giữ nguyên phép tính và thứ tự tháng. Thêm test HTTP mở dashboard với dữ liệu doanh thu để ngăn lỗi tái diễn.
- Thêm favicon SVG từ ảnh demo có sẵn để trình duyệt không tự gọi favicon.ico đang thiếu.
- Sửa URL tương đối theo context path ở liên kết/form đăng nhập/đăng ký và trang hồ sơ để dùng được khi chạy WAR dưới đường dẫn con.

## Kiểm tra

- Bộ Java: kiểm tra lại toàn bộ nghiệp vụ/QR/ví/migration và thêm đánh giá chỉ chấm sao, bình luận ngắn không media qua API, chặn bình luận quá dài, giữ chặn đơn chưa giao/khác người/đánh giá trùng; thêm kiểm tra dashboard.
- JavaScript: phiên đăng nhập, giỏ tự lưu, ưu đãi realtime, QR/thành công, fallback QR và gửi đánh giá không ảnh.
- Trình duyệt Chrome headless thật: giao diện desktop 1440×1000 và mobile 390×844; thử đăng nhập vendor/customer, mở menu và trang đánh giá, tạo đơn COD/giao hàng/gửi “Ngon” không ảnh rồi xem đánh giá ở trang sản phẩm.
- Chạy ứng dụng thử riêng cổng 18081, H2 bộ nhớ, migration V1–V8 và Hibernate update giống dev để bổ sung các cột entity có sẵn. Dữ liệu thao tác trình duyệt chỉ ở H2, không chạy test hoặc sửa dữ liệu trong MySQL đang dùng.
- Giới hạn: không kiểm tra thanh toán ngân hàng thật trong đợt sửa giao diện; không thay đổi cấu hình, secret, migration hay dữ liệu của người dùng.

## File đã nhận/chỉnh

- `docs/PART_B_HANDOFF.md`
- `docs/TASK_ASSIGNMENT.md`
- `src/main/java/com/utetra/dto/request/review/CreateReviewRequest.java`
- `src/main/java/com/utetra/entity/ProductReview.java`
- `src/main/java/com/utetra/repository/OrderRepository.java`
- `src/main/java/com/utetra/service/impl/ReviewServiceImpl.java`
- `src/main/resources/static/css/auth-ui.css`
- `src/main/resources/static/css/customer-pages.css`
- `src/main/resources/static/css/customer-ui.css`
- `src/main/resources/static/css/management-ui.css`
- `src/main/resources/static/css/product-images.css`
- `src/main/resources/static/fonts/Lora-Italic-Variable.ttf`
- `src/main/resources/static/fonts/Lora-Variable.ttf`
- `src/main/resources/static/fonts/OFL-Lora.txt`
- `src/main/resources/static/images/customer-avatar.svg`
- `src/main/resources/static/images/drinks/cacao-sua.webp`
- `src/main/resources/static/images/drinks/matcha-latte.jpg`
- `src/main/resources/static/images/drinks/sua-tuoi-tran-chau.webp`
- `src/main/resources/static/images/drinks/tra-chanh-day.png`
- `src/main/resources/static/images/drinks/tra-dao-cam-sa.webp`
- `src/main/resources/static/images/drinks/tra-dau.jpg`
- `src/main/resources/static/images/drinks/tra-kem-cheese.jpg`
- `src/main/resources/static/images/drinks/tra-sua-matcha.png`
- `src/main/resources/static/images/drinks/tra-sua-o-long.jpg`
- `src/main/resources/static/images/drinks/tra-sua-socola.jpg`
- `src/main/resources/static/images/drinks/tra-sua-truyen-thong.png`
- `src/main/resources/static/images/drinks/tra-vai.jpg`
- `src/main/resources/static/images/storefront-tea-hero.png`
- `src/main/resources/static/js/commerce.js`
- `src/main/resources/static/js/customer-ui.js`
- `src/main/resources/static/js/management-ui.js`
- `src/main/resources/static/js/product-images.js`
- `src/main/webapp/WEB-INF/decorators/admin-decorator.jsp`
- `src/main/webapp/WEB-INF/decorators/auth-decorator.jsp`
- `src/main/webapp/WEB-INF/decorators/main-decorator.jsp`
- `src/main/webapp/WEB-INF/decorators/vendor-decorator.jsp`
- `src/main/webapp/WEB-INF/views/auth/login.jsp`
- `src/main/webapp/WEB-INF/views/auth/register.jsp`
- `src/main/webapp/WEB-INF/views/customer/cart.jsp`
- `src/main/webapp/WEB-INF/views/customer/checkout.jsp`
- `src/main/webapp/WEB-INF/views/customer/favorite-products.jsp`
- `src/main/webapp/WEB-INF/views/customer/order-detail.jsp`
- `src/main/webapp/WEB-INF/views/customer/order-history.jsp`
- `src/main/webapp/WEB-INF/views/customer/payment.jsp`
- `src/main/webapp/WEB-INF/views/customer/profile.jsp`
- `src/main/webapp/WEB-INF/views/customer/review-form.jsp`
- `src/main/webapp/WEB-INF/views/customer/view-history.jsp`
- `src/main/webapp/WEB-INF/views/guest/home.jsp`
- `src/main/webapp/WEB-INF/views/guest/product-detail.jsp`
- `src/main/webapp/WEB-INF/views/guest/product-list.jsp`
- `src/main/webapp/WEB-INF/views/guest/shop-detail.jsp`
- `src/test/java/com/utetra/CommerceIntegrationTests.java`
- `src/test/js/commerce-ui.test.cjs`

## Kết quả cuối

- **39/39 test Java thành công** (0 lỗi, 0 bỏ qua).
- **7/7 test JavaScript thành công**. JSDOM báo không hỗ trợ điều hướng trang trong test gửi đánh giá; điều hướng thật đã được xác minh riêng bằng Chrome.
- Chrome: trang chủ, login, vendor sản phẩm, review desktop/mobile đã chụp và xem; review “Ngon” không ảnh gửi thành công và hiển thị ở trang sản phẩm.
- Chrome: /admin/dashboard, /admin/users, /admin/categories trả 200; dashboard mobile không tràn ngang. Đăng xuất xóa token và cookie đúng.
- Không có lỗi JavaScript trong hai lượt kiểm tra Chrome; home/vendor/admin mobile đều không tràn ngang ở viewport 390px.
- Kiểm tra cú pháp các JS mới và diff whitespace đều qua. Không còn file xung đột Git.
- Không commit, không push. Merge đang chờ người dùng yêu cầu commit.

Ảnh kiểm tra nằm tại C:/Users/Dell/Documents/Codex/2026-10-22/al/work/ với tiền tố ui-v2- (desktop-home, mobile-home, login, vendor, mobile-vendor, review, mobile-review, admin, mobile-admin, products). Script kiểm tra và log ở cùng thư mục, không đưa vào source production.
