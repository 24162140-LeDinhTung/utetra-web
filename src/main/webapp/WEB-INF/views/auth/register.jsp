<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng ký - UTETra</title>
</head>
<body>
    <div class="row justify-content-center align-items-center" style="min-height: 80vh;">
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-lg border-0 rounded-4">
                <div class="card-body p-5">
                    <div class="text-center mb-4">
                        <h2 class="text-warning fw-bold mb-2">☕ UTETra</h2>
                        <p class="text-muted">Tạo tài khoản mới</p>
                    </div>
                    
                    <!-- FORM ĐĂNG KÝ -->
                    <form id="registerForm">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Họ và tên</label>
                            <input type="text" id="fullName" class="form-control bg-light" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Email</label>
                            <input type="email" id="email" class="form-control bg-light" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mật khẩu</label>
                            <input type="password" id="password" class="form-control bg-light" required minlength="6">
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold">Số điện thoại (tùy chọn)</label>
                            <input type="text" id="phone" class="form-control bg-light">
                        </div>
                        <button type="button" onclick="register()" class="btn btn-warning btn-lg w-100 fw-bold text-dark mb-3">
                            Đăng ký
                        </button>
                    </form>

                    <div class="text-center mt-4">
                        <span class="text-muted">Đã có tài khoản? </span>
                        <a href="/auth/login" class="text-warning fw-bold text-decoration-none">Đăng nhập</a>
                    </div>

                    <!-- FORM NHẬP OTP (Ẩn ban đầu) -->
                    <div id="otpSection" style="display: none;" class="mt-4 pt-4 border-top">
                        <h5 class="text-center text-success">Nhập mã OTP</h5>
                        <p class="text-muted text-center small">Mã đã được gửi tới email của bạn</p>
                        <div class="mb-3">
                            <input type="text" id="otpCode" class="form-control form-control-lg text-center fw-bold" placeholder="Nhập 6 số" maxlength="6">
                        </div>
                        <button type="button" onclick="verifyOtp()" class="btn btn-success w-100 fw-bold">
                            Xác thực tài khoản
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

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