# Rà soát và hoàn thiện phần B — 27/10/2026

## Ghép bản dev đã fetch — 28/10/2026

- Nhánh làm việc vẫn là `feature/product-cart-order`, đã fast-forward từ `277113d` đến `cb6587d` của `origin/dev` do người dùng fetch trong Eclipse. Không đổi nhánh `dev` và không push GitHub.
- Trước ghép, lưu cả file đã theo dõi và file mới vào stash `5eff35b2fc91aa9151bf47eb8344527ce74f0b4e` (`codex-part-b-before-dev-sync-2026-10-28`). Stash giữ nguyên để khôi phục; stash cũ `local config` không bị xóa. Bản sao file ngoài repo còn ở `C:/Users/Dell/Documents/Codex/2026-10-22/al/work/before-dev-sync-20261027-232331`.
- Đã áp dụng lại toàn bộ thay đổi phần B. `SecurityConfig.java` là file duy nhất xung đột văn bản: giữ `/WEB-INF/**`, `/test`, `/error` mới của nhóm và xử lý chuyển login/403 của phần B. `ProductRepository.java` tự ghép được nhưng đã kiểm tra lại logic.
- Giữ trang chủ và menu cửa hàng mới, các thay đổi favorites/history/profile/entity của nhóm. Bổ sung vào `HomeController.java` việc chặn shop không ACTIVE/đã xóa khi truy cập trực tiếp; `ProductRepository.java` loại món thuộc danh mục đã xóa và sắp xếp menu theo lượng bán.
- `views/guest/shop-detail.jsp`: menu mới gửi tất cả thuộc tính đang hoạt động (không chỉ Size), bỏ lựa chọn đã xóa, dùng context path cho API/login. Đây là sửa tương thích với validation giỏ hàng B, giữ cấu trúc giao diện của nhóm.
- `CommerceIntegrationTests.java`: điều chỉnh smoke test trang chủ theo giao diện mới, thêm kiểm tra trang shop/menu, danh mục đã xóa và shop đóng cửa.
- `application.yml` khớp nguyên vẹn bản trước ghép. Không reset MySQL, không sửa migration, không sửa ví/rút tiền C. Phần chỉnh sửa vẫn chưa commit và đã đưa về unstaged để người dùng xem trong Eclipse.
- Log kiểm tra bản ghép: `C:/Users/Dell/Documents/Codex/2026-10-22/al/work/part-b-merged-final-tests.log`.
- Kết quả bản ghép ngày 28/10: Maven BUILD SUCCESS, **26 tests, 0 failures, 0 errors**; Node auth navigation **2/2 pass**; không còn file unmerged hoặc dấu conflict. Test vẫn dùng H2 và HTTP cục bộ, chưa phải thanh toán gateway/MySQL end-to-end.

Đã đọc README.md, HELP.md, docs/TASK_ASSIGNMENT.md, docs/PART_B_HANDOFF.md và docs/PART_B_V5_SEED.md; đối chiếu với bản mã nguồn sau khi nhóm ghép phần C. Công việc ưu tiên backend, đồng thời sửa các điểm giao diện ảnh hưởng tới việc sử dụng phần B.

## Phạm vi theo phân công

| Nhóm chức năng B | Trạng thái mã nguồn và kiểm tra |
|---|---|
| Sản phẩm theo nhiều shop, tìm kiếm/lọc/phân trang, CRUD vendor | Có API và trang quản lý; kiểm tra quyền chủ shop và shop của sản phẩm. Bổ sung lọc shop ACTIVE. |
| Danh mục/thuộc tính admin, duyệt sản phẩm | Có API và trang quản lý; test vòng lặp danh mục, validation, phân quyền. |
| Ảnh sản phẩm/ảnh-video review | Có upload Cloudinary, kiểm tra loại và dung lượng, lưu URL; chưa thử dịch vụ Cloudinary thực tế trong lần này. |
| Giỏ hàng DB | Có giỏ theo user + shop, thuộc tính/phụ thu, cập nhật/xóa; sửa lỗi toàn trang khi một món không còn hợp lệ. |
| Đặt hàng COD, quote, snapshot và tồn kho | Đã kiểm tra tạo đơn, chỉ lấy giỏ shop đang chọn, khóa tồn kho chống bán vượt, không trừ kho nếu gateway thiếu cấu hình. |
| Trạng thái, hủy/trả hàng | Có kiểm tra chủ sở hữu, chuyển trạng thái, trả tồn kho; không tự xác nhận refund online. |
| Voucher/promotion | Có CRUD và giao diện; test giảm giá, giới hạn, shop, số lượt và giá phía server. |
| Review | Có kiểm tra mua hàng đã giao, độ dài, số sao, media và chống gửi lặp. |
| VNPay/MoMo | Có tạo URL, kiểm chữ ký/số tiền/reference, xử lý callback lặp và thanh toán sau hủy; test callback mô phỏng qua. Cần merchant sandbox và callback public để xác nhận tích hợp thật. |
| WebSocket | Có thông báo sau commit, kiểm quyền subscribe; test chặn người khác và client giả mạo thông báo. |
| Các trang JSP B | Có trang sản phẩm/đơn/voucher/promotion, danh mục/thuộc tính, checkout/payment; HTTP smoke test có đăng nhập đúng quyền. Chưa kiểm thử tay toàn bộ tương tác trong trình duyệt. |

## Thay đổi lần này

| File | Tác dụng |
|---|---|
| `src/main/java/com/utetra/service/PaymentAvailability.java` (mới) | Kiểm tra sự hiện diện của cấu hình VNPay/MoMo; COD luôn khả dụng. Chỉ báo code/available/message, không tiết lộ secret. Có cấu hình không đồng nghĩa gateway đã xác thực được. |
| `src/main/java/com/utetra/controller/api/PaymentController.java` | Thêm GET `/api/payment/methods`, yêu cầu đăng nhập theo SecurityConfig. |
| `src/main/java/com/utetra/service/OrderQuoteService.java` | Từ chối báo giá với phương thức online chưa cấu hình, thông báo chọn COD. |
| `src/main/java/com/utetra/service/impl/OrderServiceImpl.java` | Kiểm tra phương thức trước khi tạo đơn/trừ kho/xóa giỏ. Tránh đơn chờ thanh toán không thể mở cổng do thiếu key. |
| `src/main/resources/static/js/commerce.js` | Checkout vô hiệu hóa phương thức chưa cấu hình; khi API trả 401 thì xóa trạng thái đăng nhập cũ và chuyển về đăng nhập. |
| `src/main/java/com/utetra/repository/ProductRepository.java` | Truy vấn công khai chỉ lấy sản phẩm của shop ACTIVE. |
| `src/main/java/com/utetra/service/impl/ProductServiceImpl.java` | Trang chủ chỉ liệt kê shop ACTIVE; chi tiết món của shop không ACTIVE bị chặn. Không ảnh hưởng quyền chủ shop xem sản phẩm riêng. |
| `src/main/java/com/utetra/service/ProductPricing.java` | Chặn thêm giỏ/đặt hàng khi shop không ACTIVE. Lỗi validation đọc giá không đánh dấu rollback transaction bên ngoài khi trang giỏ bắt lỗi để hiển thị lý do. Transaction đặt hàng vẫn rollback khi validation thất bại. |
| `src/main/java/com/utetra/service/impl/ReviewServiceImpl.java` | Danh sách review công khai không mở cho sản phẩm thuộc shop bị khóa/đóng hoặc danh mục đã xóa. |
| `src/main/java/com/utetra/service/impl/CategoryServiceImpl.java` | Sửa thông báo lỗi vòng lặp danh mục bị lỗi mã hóa tiếng Việt. |
| `src/main/java/com/utetra/config/SecurityConfig.java` | Trang customer thiếu phiên hợp lệ chuyển về login như vendor/admin; API sai quyền trả 403 thay vì chuyển hướng HTML. Giữ dòng `/WEB-INF/**` người dùng đã thêm và các quy tắc bảo vệ API. |
| `src/main/webapp/WEB-INF/decorators/main-decorator.jsp` | Không hiện trạng thái đăng nhập khi token đã hết hạn; phục hồi cookie điều hướng từ token localStorage còn hạn; logout xóa cả cookie và dữ liệu đăng nhập. Bọc script để không trùng biến token của trang profile. Server vẫn xác minh JWT, không tin kiểm tra thời hạn trên client. |
| `src/test/java/com/utetra/CommerceIntegrationTests.java` | Test shop không ACTIVE, rollback/giữ giỏ, thiếu cấu hình gateway, cookie trang profile và HTTP 401/403. Cập nhật fixture shop ACTIVE và test JSP dùng JWT đúng quyền theo cấu hình mới của nhóm. |
| `src/test/js/auth-navigation.test.cjs` (mới) | Test token hợp lệ/hết hạn/hỏng, cookie điều hướng, logout và đường dẫn context bằng Node. Không phải test trình duyệt thật. |
| `docs/PART_B_HANDOFF.md` | Thêm thông báo cập nhật, phân biệt kết quả hiện tại với lịch sử cũ. |
| `docs/PART_B_COMPLETION_2026-10-27.md` (mới) | Báo cáo này, danh sách file và bước kiểm tra. |

`src/main/resources/application.yml` đã được người dùng sửa trước lúc bắt đầu. Không chỉnh file đó trong lần này. Không sửa V1–V5, không xóa database hoặc dữ liệu. Không sửa nghiệp vụ ví/rút tiền/doanh thu của C, DataInitializer, JwtAuthenticationFilter hoặc ErrorController. Chưa commit/push.

## Kết quả kiểm tra

- `mvn -Dmaven.repo.local=C:/Users/Dell/.m2/repository test`: BUILD SUCCESS, 25 tests, 0 failures, 0 errors, 0 skipped.
- `node --test src/test/js/auth-navigation.test.cjs`: 2 tests pass.
- `node --check src/main/resources/static/js/commerce.js`: thành công.
- Java test sử dụng profile test với H2 trong bộ nhớ và cổng HTTP ngẫu nhiên, không chạy trên MySQL của người dùng.
- Log cuối: `C:/Users/Dell/Documents/Codex/2026-10-22/al/work/part-b-final-tests.log`.
- Không dùng kết quả H2 để khẳng định mọi khác biệt MySQL đều đã được kiểm tra. Bộ Maven vẫn có warning mapper/deprecation sẵn có, không có lỗi build.

## Kiểm tra trên máy đang chạy

1. Trong Eclipse/STS, Refresh dự án (F5), dừng phiên Spring Boot App cũ rồi chạy lại. Không cần xóa database hoặc chạy lại V5 thủ công.
2. Mở trang chủ, tải lại trang; đăng xuất rồi đăng nhập bằng tài khoản demo trong PART_B_V5_SEED.md nếu phiên cũ đã hết hạn. Bấm Tài khoản: phiên hợp lệ phải mở profile; thiếu/hết phiên chuyển login.
3. Với khách demo, thêm món từ hai shop, vào giỏ, chọn một shop và đặt COD. Kiểm tra chỉ giỏ shop đó được đặt; shop còn lại còn nguyên.
4. Thử voucher hợp lệ/chưa đủ điều kiện, kiểm tra tổng tiền từ nút tính lại. VNPay/MoMo thiếu key phải bị vô hiệu hóa.
5. Với vendor sở hữu shop, mở đơn mới, chuyển CONFIRMED → PICKED_UP → SHIPPING → DELIVERED. Vendor khác không được thao tác đơn này.
6. Kiểm tra cửa hàng BANNED/CLOSED/PENDING qua dữ liệu test riêng: không xuất hiện trong catalog, không tạo đơn mới; đơn cũ vẫn có thể được xem/xử lý theo quyền chủ shop.

## Phần chưa thể xác nhận hoàn tất chỉ bằng mã nguồn

- VNPay cần VNPAY_TMN_CODE, VNPAY_HASH_SECRET, URL return và URL IPN public đã đăng ký; MoMo cần MOMO_PARTNER_CODE, MOMO_ACCESS_KEY, MOMO_SECRET_KEY, MOMO_IPN_URL và URL return. Các key nên khai báo bằng biến môi trường, không commit. QR tài khoản cá nhân không thay thế merchant gateway và callback xác nhận.
- Chưa thực hiện một lượt thanh toán sandbox từ giao diện → gateway → IPN → cập nhật đơn với tài khoản của nhóm. Không tự tạo kết quả thanh toán thành công.
- Chưa upload ảnh/video thật vào Cloudinary của nhóm. Cần kiểm tra bằng tài khoản dịch vụ của nhóm.
- Ví, rút tiền, đối soát, refund online và thống kê là phần C. B đã có PaymentTransaction và OrderEvents để nhóm tích hợp. Không tạo dòng tiền giả vào ví.
- Token refresh/revoke và gia cố toàn bộ hệ thống xác thực là module A; lần này chỉ sửa tích hợp điều hướng và logout cục bộ. Không khẳng định token đã phát hành bị revoke phía server sau logout.
- URL thanh toán pending hết hạn và việc đối soát gateway vẫn theo giới hạn ghi trong PART_B_HANDOFF.md; không tự mở lại thanh toán khi chưa truy vấn được trạng thái giao dịch cũ.

Có thể kiểm tra phần B cục bộ/COD ngay sau khi restart. Chưa nên gọi toàn bộ tích hợp thanh toán thực tế là hoàn tất 100%.
