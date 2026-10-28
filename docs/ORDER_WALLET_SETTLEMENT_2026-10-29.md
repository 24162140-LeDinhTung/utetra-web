# Cộng doanh thu vào ví shop — 29/10/2026

Theo yêu cầu mới của nhóm:

- COD: chỉ cộng khi đơn chuyển thành DELIVERED (đã giao); việc tạo đơn, xác nhận, lấy hàng và đang giao không cộng tiền.
- VNPay/MoMo: cộng khi backend kiểm tra chữ ký, đúng giao dịch/số tiền và nhận xác nhận thanh toán SUCCESS từ cổng. Trở về trang web hoặc bấm cập nhật trạng thái không tự cộng tiền.
- Doanh thu cộng = tổng thanh toán − phí giao hàng; đã phản ánh các giảm giá trong đơn. Ví dụ tiền món sau giảm là 54.000đ, phí giao hàng 15.000đ, khách trả 69.000đ thì ví shop tăng 54.000đ.

## Chống cộng trùng và cập nhật đồng thời

OrderWalletSettlement chạy trong cùng transaction với cập nhật đơn/thanh toán. Khóa đơn, shop và ví khi xử lý; ledger lưu order_id cùng loại ORDER_INCOME. Ràng buộc UNIQUE(order_id,type) và kiểm tra bản ghi ngăn cùng đơn cộng hai lần, kể cả callback lặp, callback nhiều giao dịch hay sau đó giao hàng lại. Ghi ledger thất bại thì transaction cập nhật đơn/thanh toán và ví cùng rollback. Các thao tác cộng/rút tiền của WalletService cũng khóa ví để không ghi đè số dư nhau.

Tự tạo ví nếu shop chưa có. Giao dịch trước đây không có order_id được giữ nguyên; không cộng bù hàng loạt cho đơn cũ.

## Hủy/trả sau khi đã cộng

Khi hủy hoặc trả đơn đã cộng, ghi một bút toán REFUND mang số tiền âm để thu hồi doanh thu của shop, chỉ ghi một lần. Đây là điều chỉnh sổ ví nội bộ, không gọi API hoàn tiền khách hàng. Đơn online thanh toán đến muộn sau khi đã hủy vẫn lưu thanh toán thành công để đối soát nhưng không ghi doanh thu shop.

Nếu shop đã rút số tiền đó trước khi đơn bị trả, số dư nội bộ có thể âm, thể hiện khoản shop cần bù; kiểm tra số dư khi rút sẽ chặn việc rút thêm. Chưa tự động chuyển tiền thật ra/vào tài khoản ngân hàng.

## File thay đổi

- service/OrderWalletSettlement.java: quyết định thời điểm cộng, ghi thu hồi và chống trùng theo đơn.
- service/impl/OrderServiceImpl.java: tích hợp khi đổi trạng thái đơn COD/hủy/trả.
- service/impl/PaymentServiceImpl.java: tích hợp sau callback online đã xác thực.
- entity/WalletTransaction.java: thêm orderId và unique theo order/type.
- repository/ShopRepository.java, WalletRepository.java: khóa khi cập nhật đồng thời.
- repository/WalletTransactionRepository.java: tìm bút toán theo đơn và loại.
- service/impl/WalletServiceImpl.java: đọc ví theo shop; khóa số dư trước cộng/rút; từ chối số tiền không dương.
- db/migration/V7__link_wallet_income_to_order.sql: thêm cột, FK và unique; không xóa số dư/dữ liệu cũ.
- CommerceIntegrationTests.java: COD chưa giao/đã giao, gọi lại đồng thời, trả/hoàn không trừ hai lần; VNPay/MoMo thành công và callback lặp; giao hàng sau online không cộng lại; online trả tiền sau hủy không cộng; hủy đơn online đã trả thu hồi doanh thu.
- PartBSeedMigrationTests.java: kiểm tra migration V7 sau V1–V6, giữ ledger demo cũ.

Các file Java nằm trong src/main/java/com/utetra; migration nằm trong src/main/resources; kiểm thử trong src/test/java/com/utetra.

## Phạm vi kiểm thử

Test tích hợp dùng H2 và callback ký bằng secret giả. Không phát sinh thanh toán/rút ngân hàng thật. Migration kiểm thử với H2 MySQL mode; chưa áp dụng lên MySQL thật của người dùng.

Kết quả: **34/34 test Java thành công**, 0 lỗi, 0 bỏ qua. Lệnh: `mvn -Dmaven.repo.local=C:/Users/Dell/.m2/repository test`.
