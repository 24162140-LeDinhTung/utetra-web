<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>UTETra</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <sitemesh:write property='head'/>
    <link href="${pageContext.request.contextPath}/css/customer-ui.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/customer-pages.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/product-images.css" rel="stylesheet">
</head>
<body class="customer-site d-flex flex-column min-vh-100">
    <a href="#main-content" class="customer-skip-link">Đến nội dung chính</a>
    <div class="customer-announcement"><span><i class="fa-solid fa-leaf" aria-hidden="true"></i> Một chút trà, thêm chút vui.</span><a href="/products">Khám phá thực đơn ↗</a></div>

    <!-- HEADER -->
    <nav class="navbar navbar-expand-lg customer-navbar" aria-label="Điều hướng chính">
        <div class="container">
            <a class="navbar-brand customer-brand" href="/"><span class="customer-brand-icon" aria-hidden="true"><i class="fa-solid fa-mug-hot"></i></span><span>UTETra<small>TEA · COFFEE · LITTLE JOYS</small></span></a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#customer-navigation" aria-controls="customer-navigation" aria-expanded="false" aria-label="Mở menu"><i class="fa-solid fa-bars" aria-hidden="true"></i></button>
            <div class="collapse navbar-collapse gap-3" id="customer-navigation">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link" href="/">Trang chủ</a></li>
                    <li class="nav-item"><a class="nav-link" href="/products">Thực đơn</a></li>
                    <li class="nav-item"><a class="nav-link" href="/customer/cart">Giỏ hàng</a></li>
                    <li class="nav-item"><a class="nav-link" href="/customer/orders">Đơn hàng</a></li>
                    <li class="nav-item"><a class="nav-link" href="/customer/favorites">Yêu thích</a></li>
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
    <main id="main-content" class="container customer-main flex-grow-1">
        <sitemesh:write property='body'/>
    </main>

    <!-- FOOTER -->
    <footer class="customer-footer mt-auto">
        <div class="container customer-footer-top">
            <div><a class="customer-brand" href="/">UTETra<span class="customer-footer-leaf" aria-hidden="true">✳</span></a><p>Chọn vị bạn thích.<br>Thêm vui cho ngày của bạn.</p></div>
            <div><p class="customer-footer-label">KHÁM PHÁ</p><a href="/">Cửa hàng</a><a href="/products">Thực đơn đồ uống</a><a href="/customer/favorites">Món yêu thích</a></div>
            <div><p class="customer-footer-label">GÓC CỦA BẠN</p><a href="/customer/orders">Đơn hàng của bạn</a><a href="/customer/profile">Tài khoản</a><a href="/customer/history">Đã xem gần đây</a></div>
            <div class="customer-footer-message"><i class="fa-solid fa-mug-hot" aria-hidden="true"></i><p>Một ngày đẹp hơn,<br>bắt đầu từ một ly trà.</p></div>
        </div>
        <div class="container customer-footer-bottom"><p class="mb-0">© 2026 UTETra · Trà sữa ngon mỗi ngày</p><div><a href="/vendor/products">Người bán</a><a href="/admin/categories">Quản trị</a><a href="#main-content">Lên đầu trang ↑</a></div></div>
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
    <script src="${pageContext.request.contextPath}/js/customer-ui.js" defer></script>
    <script src="${pageContext.request.contextPath}/js/product-images.js" defer></script>
</body>
</html>
