> Đã thay thế phần khuyến mãi tự giảm giá bằng lựa chọn thủ công theo yêu cầu mới: xem MANUAL_PROMOTIONS_2026-10-29.md.

# Menu quản lý, voucher thủ công và xem chi tiết — 29/10/2026

## Các thay đổi

1. Menu avatar có “Về quản lý cửa hàng” cho ROLE_VENDOR và “Về trang quản trị” cho ROLE_ADMIN. Quyền được server đưa vào trang; khách hàng không có các nút này. Việc ẩn/hiện nút không thay thế kiểm tra quyền ở backend.
2. Ô chọn đổi thành “Chọn voucher của cửa hàng”, mặc định không dùng voucher. Chọn/nhập mã không gửi yêu cầu áp dụng ngay. Thay đổi mã xóa báo giá cũ, khóa đặt hàng và hiện hướng dẫn bấm Tính lại tổng tiền. Chỉ nút này tính tiền theo mã; lúc tạo đơn backend vẫn kiểm tra lại. Khuyến mãi giảm giá sản phẩm theo thời gian vẫn là cơ chế riêng, không đổi thành voucher.
3. Giữ cột ID sản phẩm thật từ API trên bảng vendor. Gắn phiên bản vào URL commerce.js, commerce.css và account-menu.js để trình duyệt không tiếp tục dùng bản cache cũ. Cần chạy lại ứng dụng để nạp các route Java mới.
4. Bổ sung Xem chi tiết chỉ đọc cho:
   - Sản phẩm vendor: ID, tên, shop, danh mục, mô tả, giá, tồn, đã bán, trạng thái, ảnh.
   - Món trong giỏ: thông tin món, lựa chọn thuộc tính, lượng/giá/thành tiền và khả dụng; xem được dữ liệu dòng giỏ kể cả khi sản phẩm không còn công khai.
   - Danh mục admin: ID/tên/slug/danh mục cha.
   - Thuộc tính admin: ID, sản phẩm, tên, giá trị và phụ thu.
   - Sản phẩm trong bảng quản lý thuộc tính/duyệt sản phẩm của admin, gồm cả chưa mở bán/đã ẩn.
   - Cửa hàng của vendor: trang chỉ đọc, kiểm tra đúng chủ shop.
   - Cửa hàng trong danh sách admin và popup shop của người dùng: trang chỉ đọc dành cho admin.
   Voucher, khuyến mãi, đơn hàng và hồ sơ đã có chế độ xem riêng, được giữ lại.

Các hộp chi tiết đóng bằng nút hoặc Escape, đưa focus về nút mở; nội dung phía JS được escape. Trang chi tiết shop dùng c:out. Không thêm nút Lưu hay gửi yêu cầu sửa/xóa trong chế độ xem.

## Backend mới

- GET /vendor/my-shops/{id}: chỉ chủ shop được xem, người bán khác nhận 403.
- GET /admin/users/shops/{id}: chi tiết shop cho admin.
- GET /api/admin/catalog/products/{id}: dữ liệu chi tiết sản phẩm cho admin, vendor/khách không được truy cập.

Không thêm migration và không thay dependencies.

## Các file chính

- static/js/commerce.js: cột ID, trạng thái voucher chờ tính lại, hộp chi tiết sản phẩm/giỏ/danh mục/thuộc tính.
- static/js/account-menu.js và ba decorators main/vendor/admin: liên kết quản lý theo role.
- static/css/commerce.css: hộp chi tiết có cuộn khi dài trên điện thoại.
- controller/vendor/VendorShopController.java: route chi tiết và kiểm tra sở hữu.
- controller/admin/AdminUserController.java, AdminAttributeController.java: chi tiết shop/sản phẩm cho admin.
- views/vendor/shop-detail.jsp (mới): trang thông tin shop chỉ đọc.
- views/vendor/shop-list.jsp, views/admin/shop-list.jsp, views/admin/user-list.jsp: thêm link chi tiết.
- Các JSP đang dùng commerce.js/commerce.css: cập nhật phiên bản đường dẫn tài nguyên.
- CommerceIntegrationTests.java và ba file test JS: thêm kiểm tra quyền, menu, voucher thủ công và chi tiết không ghi dữ liệu.

## Kiểm chứng

- 43 test Java hồi quy thành công trong details-java-tests.log.
- Kiểm thử Java mới managementDetailsRespectRolesAndShopOwnership chạy riêng thành công: chủ shop xem được, chủ shop khác bị 403, admin xem được, vendor không gọi được API chi tiết sản phẩm admin. Kiểm tra cả cờ quyền menu do server render.
- 15/15 test JavaScript thành công trong details-js-tests.log.
- Chrome thực tế trên H2 riêng, port 18081: menu vendor/admin/customer đúng quyền; xem chi tiết shop/sản phẩm/danh mục/thuộc tính; cột ID; chọn voucher chưa gọi quote, bấm nút mới gọi, đổi mã xóa báo giá; không có JavaScript pageerror. Kiểm tra hộp chi tiết sản phẩm ở desktop và mobile 390px, không tràn ngang toàn trang.
- git diff --check theo CRLF không lỗi.

Không thao tác thay đổi MySQL thật, không commit/push. Chạy lại Spring Boot App và Ctrl+F5 trình duyệt để nạp bản mới.
