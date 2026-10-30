# Cập nhật giỏ hàng, trạng thái và tài khoản — 29/10/2026

Đã sửa trực tiếp trong bản đang ghép giao diện v2 tại `D:\Year-3\Lap-trinh-web\SpringToolForEclipse-Workspace\utetra-web`. Không commit, không push; giữ nguyên các chỉnh sửa/merge đang có từ công việc trước.

## 1. Trạng thái đơn bằng tiếng Việt

Áp dụng ở danh sách, bộ lọc, chi tiết, lịch sử, ô chuyển trạng thái của người bán, trang thanh toán và thông báo WebSocket. Giá trị enum trong API/database giữ nguyên để tương thích dữ liệu và cổng thanh toán.

| Mã trong hệ thống | Chữ hiển thị |
|---|---|
| NEW | Chờ thanh toán |
| CONFIRMED | Đã xác nhận |
| PICKED_UP | Đã lấy hàng |
| SHIPPING | Đang giao hàng |
| DELIVERED | Đã giao hàng |
| CANCELLED | Đã hủy |
| RETURNED | Đã trả hàng |
| REFUNDED | Đã hoàn tiền |
| Payment PENDING | Chờ thanh toán |
| Payment SUCCESS | Đã thanh toán |
| Payment FAILED | Thanh toán thất bại |

`COD` được hiển thị là “Tiền mặt khi nhận hàng”. Bổ sung nhãn tiếng Việt cho trạng thái sản phẩm tại các bảng quản lý do commerce.js dựng, và giữ màu trạng thái theo giao diện v2.

## 2. Chọn món trong giỏ để mua

- Mỗi dòng món/biến thể có một ô tick. Có chọn tất cả theo cửa hàng, trạng thái chọn một phần và tổng tiền các món đã chọn.
- Mặc định chọn các món đang có thể mua; món không hợp lệ bị khóa ô chọn và vẫn hiện lý do để khách sửa/xóa.
- Bỏ tick tất cả thì nút mua bị khóa. Tăng/giảm số lượng vẫn tự lưu, giữ nguyên lựa chọn đã tick trong lần tải lại giỏ đó.
- Màn hình điện thoại hiển thị từng món với ô tick, giá, nút số lượng, thành tiền và xóa, không phải kéo ngang tìm nút số lượng.
- Sang checkout chỉ hiện món đã chọn. Danh sách `cartItemIds` đi cùng yêu cầu xét ưu đãi, tính tiền và tạo đơn.
- Backend chỉ tính giá, điều kiện voucher, trừ tồn kho và xóa khỏi giỏ các dòng được chọn. Món khác cùng shop và món ở shop khác vẫn ở trong giỏ.
- Kiểm tra danh sách rỗng, ID trùng/null/không hợp lệ, món đã xóa, món của người khác hoặc khác shop. Không tin tổng tiền client; giữ kiểm tra giá thay đổi, khóa tồn kho và giao dịch như trước.
- Gộp số lượng biến thể cùng sản phẩm khi xét tồn kho. Món không chọn bị ẩn/hết hàng không cản việc mua món hợp lệ đã chọn.
- Không cần migration database. Client cũ bỏ qua `cartItemIds` vẫn mua toàn bộ giỏ của shop; giao diện mới luôn gửi danh sách cụ thể.

## 3. Xem chi tiết voucher và khuyến mãi

Trong `/vendor/vouchers` và `/vendor/promotions`, mỗi hàng có nút **Xem chi tiết**, độc lập với **Sửa** và **Xóa**.

- Hiện cửa hàng, mã/tên, tình trạng hiệu lực, kiểu/mức giảm, thời gian bắt đầu và kết thúc theo định dạng Việt Nam.
- Voucher có đơn tối thiểu, mức giảm tối đa, tiền món/phí giao hàng, lượt đã dùng/tổng lượt và quy định một lần mỗi tài khoản.
- Khuyến mãi có tên và ID từng sản phẩm áp dụng; tải tên qua API đã kiểm tra quyền chủ shop.
- Xem chi tiết không đổi biểu mẫu tạo/sửa. Có nút đóng; đổi shop vẫn dùng đúng dữ liệu của shop đang quản lý.

## 4. Avatar và menu tài khoản

Header khách hàng, người bán và quản trị dùng menu chung: avatar thực tế + tên hiển thị. Nếu chưa có tên thì dùng email; nếu chưa có ảnh thì dùng ảnh mặc định.

Bấm avatar/tên để mở email, **Thông tin tài khoản**, **Đăng xuất**. Có đóng bằng click ra ngoài hoặc Escape. Tên/email dựng bằng textContent để không thực thi HTML; ảnh chặn URL có giao thức không phù hợp.

Đăng xuất xóa cả token/cookie và các dữ liệu đăng nhập lưu trước đó. Khách chưa đăng nhập vẫn có Đăng nhập/Đăng ký.

## 5. Tách xem và sửa thông tin

- `/customer/profile`: chỉ xem avatar, họ tên, email đăng nhập, điện thoại và ngày tham gia. Có nút **Chỉnh sửa thông tin**.
- `/customer/profile/edit`: mới có biểu mẫu sửa tên/điện thoại và tải avatar, cùng nút quay lại trang xem. Email không cho đổi như trước.
- Lưu thông tin thành công quay lại trang xem; menu tài khoản tải lại tên/ảnh mới. Yêu thích và lịch sử xem vẫn truy cập qua các trang riêng đã có.
- Dùng chung một JSP với nhánh render do controller quyết định theo URL, và chuyển logic trình duyệt vào profile.js; chế độ xem không render form/file input.

## File tạo mới

| File | Tác dụng |
|---|---|
| `src/main/java/com/utetra/service/CartSelection.java` | Kiểm tra và lọc đúng các dòng giỏ đã chọn, dùng chung cho báo giá/tạo đơn |
| `src/main/resources/static/js/account-menu.js` | Menu avatar/tên dùng chung, lấy hồ sơ và đăng xuất |
| `src/main/resources/static/css/account.css` | Bố cục avatar/menu và thông tin chỉ đọc |
| `src/main/resources/static/js/profile.js` | Tải/xem hồ sơ, xử lý lưu và tải ảnh trong chế độ sửa |
| `src/test/js/account-profile.test.cjs` | Kiểm thử menu hiển thị an toàn, đóng menu và trang xem không ghi dữ liệu |
| `docs/CART_ACCOUNT_DETAILS_2026-10-29.md` | Báo cáo này |

## File chỉnh sửa trong lượt này

| File | Thay đổi |
|---|---|
| `src/main/java/com/utetra/dto/request/order/CreateOrderRequest.java` | Nhận danh sách cartItemIds có validation |
| `src/main/java/com/utetra/controller/customer/CustomerOrderController.java` | Nhận danh sách món khi xét ưu đãi |
| `src/main/java/com/utetra/service/OrderQuoteService.java` | Báo giá, tồn kho và voucher dựa trên lựa chọn |
| `src/main/java/com/utetra/service/impl/OrderServiceImpl.java` | Chỉ đặt/trừ tồn/xóa các dòng đã chọn |
| `src/main/java/com/utetra/controller/customer/CustomerPageController.java` | Route xem/sửa hồ sơ riêng |
| `src/main/resources/static/js/commerce.js` | Checkbox giỏ, checkout chọn món, nhãn tiếng Việt, chi tiết ưu đãi |
| `src/main/resources/static/js/customer-ui.js` | Giữ badge màu khi nhãn trạng thái đã dịch |
| `src/main/resources/static/css/commerce.css` | Checkbox, nút số lượng, bảng thông tin chi tiết |
| `src/main/resources/static/css/customer-ui.css` | Cột checkbox và bố cục giỏ trên điện thoại |
| `src/main/webapp/WEB-INF/decorators/main-decorator.jsp` | Thay hai nút tài khoản bằng chỗ gắn menu chung |
| `src/main/webapp/WEB-INF/decorators/vendor-decorator.jsp` | Avatar/tên thật và link hồ sơ hoạt động |
| `src/main/webapp/WEB-INF/decorators/admin-decorator.jsp` | Menu tài khoản chung cho quản trị |
| `src/main/webapp/WEB-INF/views/customer/profile.jsp` | Tách nội dung xem/sửa, giữ giao diện nhóm |
| `src/test/java/com/utetra/CommerceIntegrationTests.java` | Thêm 4 kiểm thử backend và render hồ sơ |
| `src/test/js/commerce-ui.test.cjs` | Thêm kiểm thử lựa chọn, giá/voucher, nhãn trạng thái, chi tiết ưu đãi |
| `docs/PART_B_HANDOFF.md` | Liên kết báo cáo mới |

Các thay đổi giao diện v2 và đánh giá từ lượt trước vẫn giữ nguyên; xem `UI_V2_REVIEW_MERGE_2026-10-29.md` để phân biệt.

## Kiểm chứng

- **43/43 test Java thành công**, không lỗi/không bỏ qua. Chạy Maven với database H2 kiểm thử.
- **13/13 test JavaScript thành công**. Bao gồm lưu số lượng tức thì, giữ tick, chỉ hiện/gửi dòng đã chọn, ưu đãi theo lựa chọn, trạng thái tiếng Việt nhưng gửi enum đúng, chi tiết voucher/khuyến mãi độc lập với sửa, menu an toàn và trang hồ sơ chỉ đọc.
- Chrome thực tế ở 1440px và 390px trên ứng dụng/database H2 riêng cổng 18081: xem chi tiết voucher/khuyến mãi và tên sản phẩm; xem/sửa hồ sơ; menu tên/ảnh mặc định; mua một món với số lượng hai, món bỏ tick còn trong DB; trạng thái Việt; đăng xuất xóa cookie/localStorage. Không có JavaScript pageerror, không tràn ngang toàn trang ở các màn hình kiểm tra.
- Đã mở ảnh chụp để kiểm tra bố cục hồ sơ, giỏ trên điện thoại và chi tiết khuyến mãi. Giao diện/logic thanh toán VNPay, cộng ví và callback cũ vẫn qua bộ kiểm thử hồi quy.
- `git diff HEAD --check` với cấu hình CRLF phù hợp: không lỗi khoảng trắng, không có file xung đột chưa giải quyết.
- Không chạy giao dịch tiền thật, không sửa/xóa dữ liệu MySQL của bạn. Phiên bản đang chạy trong Eclipse cần dừng và Run lại; trình duyệt Ctrl+F5 để nạp JS/CSS mới. Không thay thư viện trong pom.xml nên không cần Force Update Maven chỉ để áp dụng lượt sửa này.
