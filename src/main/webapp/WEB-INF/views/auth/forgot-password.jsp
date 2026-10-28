<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - UTEtra</title>
    <style>
        * { box-sizing: border-box; }

        /* ĐÂY LÀ CLASS QUAN TRỌNG ĐỂ ĐÈ LÊN DECORATOR */
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
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #444; font-size: 14px; }
        input[type=email] {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            transition: border-color .2s;
        }
        input[type=email]:focus { outline: none; border-color: #667eea; }
        button {
            width: 100%;
            margin-top: 20px;
            padding: 12px;
            background: #667eea;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: background .2s;
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
    <!-- BỌC TOÀN BỘ TRONG THẺ DIV NÀY -->
    <div class="auth-wrapper">
        <div class="card">
            <h1>🔑 Quên mật khẩu</h1>
            <p class="sub">Nhập email đã đăng ký. Chúng tôi sẽ gửi mã OTP đặt lại mật khẩu cho bạn.</p>

            <form id="forgotForm">
                <label for="email">Email</label>
                <input id="email" type="email" name="email" required placeholder="you@example.com" autofocus>
                <button type="submit" id="submitBtn">Gửi mã OTP</button>
            </form>

            <div id="message" class="msg"></div>

            <a href="/auth/login" class="back">← Quay lại đăng nhập</a>
        </div>
    </div>

    <script>
        const form = document.getElementById('forgotForm');
        const btn  = document.getElementById('submitBtn');
        const msg  = document.getElementById('message');

        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            msg.className = 'msg';
            msg.textContent = '';

            const email = document.getElementById('email').value.trim();
            if (!email) return;

            btn.disabled = true;
            btn.textContent = 'Đang gửi...';

            try {
                const res = await fetch('/api/auth/forgot-password', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email })
                });

                if (res.ok) {
                    msg.classList.add('success');
                    msg.textContent = '✅ Mã OTP đã được gửi. Đang chuyển tới trang nhập OTP...';
                    setTimeout(() => {
                        window.location.href = '/auth/reset-password?email=' + encodeURIComponent(email);
                    }, 1200);
                } else {
                    let data = {};
                    try { data = await res.json(); } catch (_) {}
                    msg.classList.add('error');
                    msg.textContent = '❌ ' + (data.message || 'Có lỗi xảy ra, vui lòng thử lại.');
                }
            } catch (err) {
                msg.classList.add('error');
                msg.textContent = '❌ Không kết nối được server. Kiểm tra mạng rồi thử lại.';
            } finally {
                btn.disabled = false;
                btn.textContent = 'Gửi mã OTP';
            }
        });
    </script>
</body>
</html>
