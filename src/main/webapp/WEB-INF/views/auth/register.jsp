<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head><title>Đăng ký · UTETra</title></head>
<body>
<section class="auth-experience auth-experience-register" aria-label="Đăng ký tài khoản UTETra">
<aside class="auth-story" aria-label="Một chút trà, thêm chút vui">
    <div class="auth-story-copy"><p class="auth-eyebrow">A NEW FACE. A LITTLE MORE JOY.</p>
        <h1>Một gu riêng.<br>Một góc <em>quen.</em></h1>
        <p class="auth-story-description">Tạo tài khoản, lưu lại những món yêu thích và tìm vị ngon cho mỗi ngày của bạn.</p>
    </div>
    <figure class="auth-story-photo"><img src="${pageContext.request.contextPath}/images/storefront-tea-hero.png" alt="Matcha latte và trà sữa trân châu — hai hương vị của UTETra" width="1536" height="1024" fetchpriority="high"><figcaption>THE LITTLE JOYS, EVERY DAY</figcaption><span class="auth-tea-seal" aria-hidden="true">tea time<br><em>good time.</em><b>✳</b></span></figure>
    <div class="auth-story-foot"><span>MATCHA · TRÀ SỮA · CÀ PHÊ</span><span aria-hidden="true">✳</span></div>
</aside>
<div class="auth-form-panel">
    <nav class="auth-tabs" aria-label="Tài khoản"><a href="/auth/login">Đăng nhập</a><a href="/auth/register" class="active" aria-current="page">Đăng ký</a></nav>
    <div class="auth-form-heading"><p class="auth-eyebrow">THÊM MỘT NGƯỜI, THÊM MỘT NIỀM VUI</p><h2>Hẹn bạn một ly trà.</h2><p>Tạo tài khoản để bắt đầu câu chuyện vị ngon.</p></div>
    <form id="registerForm">
        <div class="auth-field"><label for="fullName">Họ và tên</label><input type="text" id="fullName" class="form-control" placeholder="Tên của bạn" autocomplete="name" required></div>
        <div class="auth-field"><label for="email">Email</label><input type="email" id="email" class="form-control" placeholder="Nhập email của bạn" autocomplete="email" required></div>
        <div class="auth-field"><label for="password">Mật khẩu</label><input type="password" id="password" class="form-control" placeholder="Tối thiểu 6 ký tự" autocomplete="new-password" required minlength="6"></div>
        <div class="auth-field"><label for="phone">Số điện thoại <span>(tùy chọn)</span></label><input type="text" id="phone" class="form-control" placeholder="Số điện thoại của bạn" autocomplete="tel" inputmode="tel"></div>
        <button type="button" onclick="register()" class="btn auth-submit">Đăng ký</button>
    </form>
    <div id="otpSection" style="display: none;" class="auth-otp">
        <span class="auth-otp-symbol" aria-hidden="true">✳</span><h3>Kiểm tra hộp thư nhé.</h3><p>Mã OTP đã được gửi tới email của bạn.<br>Nhập mã để hoàn tất đăng ký tài khoản.</p>
        <div class="auth-field"><label for="otpCode">Mã xác thực OTP</label><input type="text" id="otpCode" class="form-control auth-otp-input" placeholder="Nhập 6 số" maxlength="6" inputmode="numeric" autocomplete="one-time-code"></div>
        <button type="button" onclick="verifyOtp()" class="btn auth-submit">Xác thực tài khoản</button>
    </div>
    <p class="auth-switch">Đã có tài khoản? <a href="/auth/login">Đăng nhập <span aria-hidden="true">↗</span></a></p>
</div>
</section>

<script>
        function register() {
            const data = {
                fullName: document.getElementById('fullName').value,
                email: document.getElementById('email').value,
                password: document.getElementById('password').value,
                phone: document.getElementById('phone').value
            };

            fetch('/api/auth/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            })
            .then(res => res.json())
            .then(resData => {
                if (resData.code === 200) {
                    alert('Đăng ký thành công! Vui lòng kiểm tra email để lấy mã OTP.');
                    // Ẩn form đăng ký, hiện form OTP
                    document.getElementById('registerForm').style.display = 'none';
                    document.getElementById('otpSection').style.display = 'block';
                } else {
                    alert('Lỗi: ' + resData.message);
                }
            })
            .catch(err => alert('Lỗi kết nối server!'));
        }

        function verifyOtp() {
            const email = document.getElementById('email').value;
            const otp = document.getElementById('otpCode').value;

            fetch('/api/auth/verify-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: email, otp: otp })
            })
            .then(res => res.json())
            .then(resData => {
                if (resData.code === 200) {
                    alert('Xác thực thành công! Bạn có thể đăng nhập ngay bây giờ.');
                    window.location.href = '/auth/login';
                } else {
                    alert('Lỗi: ' + resData.message);
                }
            })
            .catch(err => alert('Lỗi kết nối server!'));
        }
    </script>
</body>
</html>
