<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head><title>Đăng nhập · UTETra</title></head>
<body>
<section class="auth-experience auth-experience-login" aria-label="Đăng nhập UTETra">
<aside class="auth-story" aria-label="Một chút trà, thêm chút vui">
    <div class="auth-story-copy"><p class="auth-eyebrow">WELCOME TO YOUR LITTLE TEA CORNER</p>
        <h1>Một chút trà.<br>Thêm chút <em>vui.</em></h1>
        <p class="auth-story-description">Trà sữa thân quen, matcha dịu êm hay cà phê đậm vị.<br>Gu của bạn đang chờ, ghé một chút nhé.</p>
    </div>
    <figure class="auth-story-photo"><img src="${pageContext.request.contextPath}/images/storefront-tea-hero.png" alt="Matcha latte và trà sữa trân châu — hai hương vị của UTETra" width="1536" height="1024" fetchpriority="high"><figcaption>THE LITTLE JOYS, EVERY DAY</figcaption><span class="auth-tea-seal" aria-hidden="true">tea time<br><em>good time.</em><b>✳</b></span></figure>
    <div class="auth-story-foot"><span>MATCHA · TRÀ SỮA · CÀ PHÊ</span><span aria-hidden="true">✳</span></div>
</aside>
<div class="auth-form-panel">
    <nav class="auth-tabs" aria-label="Tài khoản"><a href="/auth/login" class="active" aria-current="page">Đăng nhập</a><a href="/auth/register">Đăng ký</a></nav>
    <div class="auth-form-heading"><p class="auth-eyebrow">RẤT VUI ĐƯỢC GẶP LẠI BẠN</p><h2>Chào bạn trở lại.</h2><p>Đăng nhập để tiếp tục chọn món yêu thích.</p></div>
    <form id="loginForm">
        <div class="auth-field"><label for="email">Email</label><input type="email" id="email" class="form-control" placeholder="Nhập email của bạn" autocomplete="email" required></div>
        <div class="auth-field"><div class="auth-label-row"><label for="password">Mật khẩu</label><a href="/auth/forgot-password">Quên mật khẩu?</a></div><input type="password" id="password" class="form-control" placeholder="Nhập mật khẩu" autocomplete="current-password" required></div>
        <button type="button" onclick="login()" class="btn auth-submit">Đăng nhập</button>
    </form>
    <p class="auth-switch">Chưa có tài khoản? <a href="/auth/register">Đăng ký ngay <span aria-hidden="true">↗</span></a></p>
    <div class="auth-form-note"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M20 4C10 3 3 8 6 15c7 4 14-2 14-11Z" fill="currentColor"/><path d="m4 20 11-11" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg><span>Chọn vị bạn thích, thêm vui cho ngày của bạn.</span></div>
</div>
</section>

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
                    document.cookie = "accessToken=" + data.data.accessToken + "; path=/";
					localStorage.setItem('userRoles', JSON.stringify(data.data.roles)); 
                    
                    alert('Đăng nhập thành công!');
                    
                    // Chuyển hướng dựa vào Role (nếu cần)
                    if (data.data.roles.includes("ROLE_ADMIN")) {
                        window.location.href = '/admin/categories';
                    } else if (data.data.roles.includes("ROLE_VENDOR")) {
                        window.location.href = '/vendor/products';
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
