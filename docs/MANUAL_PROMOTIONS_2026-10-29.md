# Tách voucher và khuyến mãi chọn thủ công — 29/10/2026

## Hành vi mới

- Ô Mã giảm giá: khách nhập voucherCode. Không tự lấy khuyến mãi để điền vào đây.
- Ô Chọn khuyến mãi của cửa hàng: tải danh sách Promotion của shop, hiển thị tên/mức giảm/hạn dùng; không chứa các bản ghi Voucher. Mặc định không dùng khuyến mãi. Các khuyến mãi không áp dụng cho món đã tick bị vô hiệu hóa trong danh sách.
- Chọn/đổi khuyến mãi hoặc nhập/đổi voucher chỉ đánh dấu chờ tính lại; không tự áp dụng. Bấm Tính lại tổng tiền mới gọi quote. Đặt hàng bị khóa khi báo giá chưa cập nhật.
- Nhập voucher không làm mất lựa chọn khuyến mãi; chọn khuyến mãi không ghi đè mã voucher.
- Giỏ hàng/giá món giữ giá gốc cộng phụ thu; bỏ cơ chế tự chọn khuyến mãi tốt nhất trước đây.
- Backend chỉ giảm các món đã tick có liên kết với khuyến mãi đã chọn, nhân đúng số lượng. Không chọn promotionId thì không có giảm khuyến mãi.
- Voucher được xét trên tiền món sau giảm khuyến mãi; vẫn kiểm tra đơn tối thiểu, giới hạn, mỗi tài khoản một lần và shop. Voucher phí giao hàng vẫn giảm ở phần phí giao hàng.
- Báo giá hiện tổng giảm và tách riêng số tiền khuyến mãi/voucher tiền món. Đơn lưu giá gốc của từng dòng, tổng tiền gốc và tổng giảm để không phụ thuộc các chỉnh sửa khuyến mãi sau này; không thay số tiền của đơn đã tồn tại.
- Khi ưu đãi đổi, WebSocket/poll mỗi 5 giây cập nhật lại danh sách và vô hiệu báo giá cũ. Không tự thay bằng khuyến mãi khác. Chặn cả phản hồi quote cũ về trễ sau khi khách đổi thông tin.

## Backend

GET /api/customer/orders/promotions?shopId=...&cartItemIds=... là API mới, yêu cầu đăng nhập. Trả id, name, discountType, value, startDate, endsAt, productIds, eligible. Chỉ trả khuyến mãi còn hiệu lực, không bị xóa tại đúng shop; kiểm tra cartItemIds thuộc giỏ người dùng.

CreateOrderRequest thêm promotionId tùy chọn, phải dương nếu có. Quote và tạo đơn đều kiểm tra khuyến mãi tồn tại, chưa xóa, đúng shop, còn thời hạn và áp dụng cho ít nhất một món đã chọn. Mã hết hạn/xóa/sai shop/không liên quan bị từ chối; không tự bỏ qua hay tự chọn lại. Tạo đơn giữ kiểm tra expectedTotalAmount và khóa tồn kho hiện có.

API /offers cũ được giữ cho tương thích client cũ, nhưng giao diện checkout mới không gọi API đó để lấy lựa chọn khuyến mãi.

## File chính sửa

- ProductPricing.java: giá gốc, kiểm tra khuyến mãi chọn tay và mức giảm từng sản phẩm.
- OrderQuoteService.java: danh sách promotion và tính giảm lựa chọn + voucher riêng.
- OrderServiceImpl.java: cùng quy tắc giá khi đặt đơn, snapshot tổng giảm.
- CreateOrderRequest.java: promotionId.
- CustomerOrderController.java: endpoint danh sách khuyến mãi.
- static/js/commerce.js: ô chọn đúng nguồn dữ liệu, request promotionId, áp dụng bằng nút tính lại và chống quote cũ về trễ.
- Các JSP dùng commerce.js: tăng phiên bản URL tới 20261029-3 để tránh cache cũ.
- CommerceIntegrationTests.java: đổi kiểm thử tự giảm cũ theo chính sách mới; thêm kiểm tra đổi/xóa/hết hạn/sai shop, chỉ món được tick và cộng với voucher.
- commerce-ui.test.cjs: kiểm tra dropdown chứa khuyến mãi, voucher nhập độc lập và realtime.
- PART_B_HANDOFF.md, TASK_ASSIGNMENT.md: cập nhật quy tắc hiện hành; báo cáo trước có ghi chú thay thế.

Không thêm migration hay thư viện. Chưa commit/push.

## Kết quả kiểm tra

- 46/46 test Java thành công trên H2, không bỏ qua. Kiểm tra hồi quy thanh toán, cộng ví, quyền, tồn kho, giỏ chọn món và các tính năng cũ.
- 15/15 test JavaScript thành công.
- Chrome thật trên H2 riêng cổng 18081: tạo voucher VOUCHER và promotion khuyenmai. Dropdown chỉ chứa khuyenmai. Chọn mã không gọi quote, nút đặt hàng vẫn khóa. Giỏ gốc 60.000đ; chọn giảm khuyến mãi 10% được 6.000đ; voucher 10% tiếp theo được 5.400đ; phí giao 15.000đ; tổng quote và đơn đều 63.600đ. Không JavaScript pageerror; đã kiểm tra ảnh desktop và mobile, không tràn ngang toàn trang.
- Không thay đổi dữ liệu MySQL thật của người dùng.

Dừng rồi chạy lại Spring Boot App, Ctrl+F5 để nạp code mới. Khuyến mãi/voucher trên MySQL hiện có được dùng tiếp theo quy tắc mới, không cần xóa hoặc tạo lại.
