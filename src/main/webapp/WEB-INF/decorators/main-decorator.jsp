<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>UTETra</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <sitemesh:write property='head'/>
</head>
<body class="d-flex flex-column min-vh-100 bg-light">

    <!-- HEADER -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand text-warning fw-bold" href="/">☕ UTETra</a>
            <div class="navbar-collapse d-flex flex-wrap gap-3">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link" href="/">Trang chủ</a></li>
                    <li class="nav-item"><a class="nav-link" href="/products">Sản phẩm</a></li>
                    <li class="nav-item"><a class="nav-link" href="/customer/cart">Giỏ hàng</a></li>
                    <li class="nav-item"><a class="nav-link" href="/customer/orders">Đơn hàng</a></li>
                    <li class="nav-item"><a class="nav-link" href="/vendor/products">Người bán</a></li>
                    <li class="nav-item"><a class="nav-link" href="/admin/categories">Quản trị</a></li>
                </ul>
                <!-- Vùng chứa các nút Đăng nhập / Tài khoản -->
                <div class="d-flex" id="auth-buttons">
                    <a href="/auth/login" class="btn btn-outline-warning me-2">Đăng nhập</a>
                    <a href="/auth/register" class="btn btn-warning text-dark fw-bold">Đăng ký</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- MAIN CONTENT -->
    <main class="container my-5 flex-grow-1">
        <sitemesh:write property='body'/>
    </main>

    <!-- FOOTER -->
    <footer class="bg-dark text-white text-center py-3 mt-auto">
        <p class="mb-0">© 2026 UTETra - Trà sữa ngon mỗi ngày</p>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- SCRIPT XỬ LÝ ĐỔI NÚT KHI ĐÃ ĐĂNG NHẬP -->
    <script>
        // Kiểm tra xem có token trong localStorage không
        const token = localStorage.getItem('accessToken');
        
        if (token) {
            // Nếu có token, đổi nút Đăng nhập/Đăng ký thành nút Tài khoản/Đăng xuất
            document.getElementById('auth-buttons').innerHTML = `
                <a href="/customer/profile" class="btn btn-outline-light me-2">Tài khoản</a>
                <button onclick="logout()" class="btn btn-danger fw-bold">Đăng xuất</button>
            `;
        }
        
        function logout() {
            // Xóa token và chuyển về trang chủ
            localStorage.removeItem('accessToken');
            localStorage.removeItem('userRole');
            window.location.href = '/';
        }
    </script>
    <sitemesh:write property='script'/>
</body>
</html>