<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - UTEtra</title>
    <style>
        * { box-sizing: border-box; }
        
        /* LỚP PHỦ TOÀN MÀN HÌNH ĐỂ ĐÈ LÊN DECORATOR */
        .auth-wrapper {
            position: fixed;
            inset: 0;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 99999;
            padding: 20px;
            font-family: 'Segoe UI', Tahoma, sans-serif;
            overflow-y: auto; /* Đề phòng màn hình điện thoại bị ngắn */
        }

        .card {
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            width: 100%;
            max-width: 420px;
        }
        h1 { margin: 0 0 8px; font-size: 24px; color: #333; }
        p.sub { margin: 0 0 24px; color: #666; font-size: 14px; line-height: 1.5; }
        label { display: block; margin: 12px 0 6px; font-weight: 600; color: #444; font-size: 14px; }
        input {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            transition: border-color .2s;
        }
        input:focus { outline: none; border-color: #667eea; }
        input[readonly] { background: #f5f5f5; cursor: not-allowed; }
        button {
            width: 100%;
            margin-top: 24px;
            padding: 12px;
            background: #667eea;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
        }
        button:hover { background: #5568d3; }
        button:disabled { background: #aaa; cursor: not-allowed; }
        .msg { margin-top: 16px; padding: 12px; border-radius: 8px; font-size: 14px; display: none; line-height: 1.5; }
        .msg.success { background: #e6ffed; color: #1a7f37; display: block; }
        .msg.error   { background: #ffe9e9; color: #c0392b; display: block; }
        .back { display: block; text-align: center; margin-top: 18px; font-size: 14px; color: #667eea; text-decoration: none; }
        .back:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <!-- BỌC TOÀN BỘ VÀO TRONG THẺ DIV NÀY -->
    <div class="auth-wrapper">
        <div class="card">
            <h1>🔒 Đặt lại mật khẩu</h1>
            <p class="sub">Nhập mã OTP đã nhận qua email và mật khẩu mới của bạn.</p>

            <form id="resetForm">
                <label for="email">Email</label>
                <input id="email" type="email" value="${email}" required
                       ${not empty email ? 'readonly' : ''}
                       placeholder="you@example.com">

                <label for="otp">Mã OTP (6 chữ số)</label>
                <input id="otp" type="text" required maxlength="10"
                       placeholder="Nhập mã trong email" autofocus
                       autocomplete="one-time-code" inputmode="numeric">

                <label for="newPassword">Mật khẩu mới</label>
                <input id="newPassword" type="password" required minlength="6"
                       placeholder="Tối thiểu 6 ký tự">

                <label for="confirmPassword">Xác nhận mật khẩu</label>
                <input id="confirmPassword" type="password" required minlength="6"
                       placeholder="Nhập lại mật khẩu">

                <button type="submit" id="submitBtn">Đặt lại mật khẩu</button>
            </form>

            <div id="message" class="msg"></div>

            <a href="/auth/login" class="back">← Quay lại đăng nhập</a>
        </div>
    </div>

    <script>
        const form = document.getElementById('resetForm');
        const btn  = document.getElementById('submitBtn');
        const msg  = document.getElementById('message');

        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            msg.className = 'msg';
            msg.textContent = '';

            const email    = document.getElementById('email').value.trim();
            const otp      = document.getElementById('otp').value.trim();
            const password = document.getElementById('newPassword').value;
            const confirm  = document.getElementById('confirmPassword').value;

            if (password !== confirm) {
                msg.classList.add('error');
                msg.textContent = '❌ Mật khẩu xác nhận không khớp.';
                return;
            }
            if (password.length < 6) {
                msg.classList.add('error');
                msg.textContent = '❌ Mật khẩu phải có ít nhất 6 ký tự.';
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Đang xử lý...';

            try {
                const res = await fetch('/api/auth/reset-password', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        email:       email,
                        otp:         otp,
                        newPassword: password
                    })
                });

                if (res.ok) {
                    msg.classList.add('success');
                    msg.textContent = '✅ Đặt lại mật khẩu thành công! Đang chuyển về trang đăng nhập...';
                    setTimeout(() => window.location.href = '/auth/login', 2000);
                } else {
                    let data = {};
                    try { data = await res.json(); } catch (_) {}
                    msg.classList.add('error');
                    msg.textContent = '❌ ' + (data.message || 'Mã OTP không đúng hoặc đã hết hạn.');
                }
            } catch (err) {
                msg.classList.add('error');
                msg.textContent = '❌ Không kết nối được server.';
            } finally {
                btn.disabled = false;
                btn.textContent = 'Đặt lại mật khẩu';
            }
        });
    </script>
</body>
</html>