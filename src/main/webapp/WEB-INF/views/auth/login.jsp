<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng nhập - UTETra</title>
</head>
<body>
    <div class="row justify-content-center align-items-center" style="min-height: 80vh;">
        <div class="col-md-5 col-lg-4">
            <div class="card shadow-lg border-0 rounded-4">
                <div class="card-body p-5">
                    <div class="text-center mb-4">
                        <h2 class="text-warning fw-bold mb-2">☕ UTETra</h2>
                        <p class="text-muted">Đăng nhập để đặt món ngay</p>
                    </div>
                    
                    <form id="loginForm">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Email</label>
                            <input type="email" id="email" class="form-control form-control-lg bg-light" placeholder="Nhập email của bạn" required>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold">Mật khẩu</label>
                            <input type="password" id="password" class="form-control form-control-lg bg-light" placeholder="Nhập mật khẩu" required>
                        </div>
                        
                        <button type="button" onclick="login()" class="btn btn-warning btn-lg w-100 fw-bold text-dark mb-3">
                            Đăng nhập
                        </button>
                    </form>

                    <div class="text-center mt-4">
                        <span class="text-muted">Chưa có tài khoản? </span>
                        <a href="/auth/register" class="text-warning fw-bold text-decoration-none">Đăng ký ngay</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function login() {
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            // Vô hiệu hóa nút bấm để tránh click đúp
            const btn = document.querySelector('button');
            btn.innerHTML = 'Đang xử lý...';
            btn.disabled = true;

            fetch('/api/auth/login', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json' 
                },
                body: JSON.stringify({ email: email, password: password })
            })
            .then(res => res.json())
            .then(data => {
                if (data.code === 200) {
                    // Lưu token vào localStorage
                    localStorage.setItem('accessToken', data.data.accessToken);
                    localStorage.setItem('userRole', data.data.roles[0]);
                    
                    alert('Đăng nhập thành công!');
                    
                    // Chuyển hướng dựa vào Role (nếu cần)
                    if (data.data.roles.includes("ROLE_ADMIN")) {
                        window.location.href = '/admin/dashboard';
                    } else if (data.data.roles.includes("ROLE_VENDOR")) {
                        window.location.href = '/vendor/dashboard';
                    } else {
                        window.location.href = '/'; // Chuyển về trang chủ
                    }
                } else {
                    alert('Lỗi: ' + data.message);
                    btn.innerHTML = 'Đăng nhập';
                    btn.disabled = false;
                }
            })
            .catch(err => {
                console.error(err);
                alert('Lỗi kết nối đến server!');
                btn.innerHTML = 'Đăng nhập';
                btn.disabled = false;
            });
        }
    </script>
</body>
</html>