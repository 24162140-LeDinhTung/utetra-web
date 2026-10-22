<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Trang chủ - UTETra</title>
</head>
<body>
    <!-- Banner -->
    <div class="p-5 mb-4 bg-warning text-dark rounded-3 shadow-sm text-center">
        <div class="container-fluid py-5">
            <h1 class="display-5 fw-bold">☕ Trà Sữa UTETra</h1>
            <p class="fs-4">Trà sữa ngon mỗi ngày - Giao hàng tận nơi</p>
            <a href="/api/products" class="btn btn-dark btn-lg mt-3 px-4 rounded-pill">Xem Menu Ngay</a>
        </div>
    </div>

    <!-- Danh sách sản phẩm -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="fw-bold m-0">Sản phẩm nổi bật</h3>
        <a href="/api/products" class="text-decoration-none text-warning fw-bold">Xem tất cả <i class="fas fa-arrow-right"></i></a>
    </div>

    <div class="row g-4" id="product-list">
        <!-- Dữ liệu sẽ được JS đổ vào đây -->
        <div class="text-center w-100 py-5">
            <div class="spinner-border text-warning" role="status"></div>
            <p class="mt-2 text-muted">Đang tải sản phẩm...</p>
        </div>
    </div>

    <script>
        // Gọi API lấy danh sách sản phẩm
        fetch('/api/products?size=8')
            .then(res => res.json())
            .then(data => {
                const container = document.getElementById('product-list');
                container.innerHTML = ''; // Xóa loading

                if (data.items && data.items.length > 0) {
                    data.items.forEach(product => {
                        const imgUrl = product.thumbnailUrl || 'https://via.placeholder.com/300x300?text=No+Image';
                        const price = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(product.price);
                        
                        container.innerHTML += `
                            <div class="col-6 col-md-4 col-lg-3">
                                <div class="card h-100 shadow-sm border-0 rounded-4 overflow-hidden">
                                    <img src="${imgUrl}" class="card-img-top" alt="${product.name}" style="height: 200px; object-fit: cover;">
                                    <div class="card-body">
                                        <h6 class="card-title fw-bold text-truncate">${product.name}</h6>
                                        <p class="card-text text-danger fw-bold mb-2">${price}</p>
                                        <button onclick="addToCart(${product.id})" class="btn btn-outline-warning w-100 fw-bold">
                                            <i class="fas fa-cart-plus"></i> Thêm
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                } else {
                    container.innerHTML = '<p class="text-center text-muted w-100">Chưa có sản phẩm nào.</p>';
                }
            })
            .catch(err => {
                document.getElementById('product-list').innerHTML = '<p class="text-danger text-center w-100">Lỗi tải dữ liệu!</p>';
            });

        function addToCart(productId) {
            const token = localStorage.getItem('accessToken');
            if (!token) {
                alert('Vui lòng đăng nhập để thêm vào giỏ hàng!');
                window.location.href = '/auth/login';
                return;
            }
            // Tạm thời thông báo, phần Cart của B sẽ làm sau
            alert('Đã thêm sản phẩm ID ' + productId + ' vào giỏ (Tính năng đang phát triển)');
        }
    </script>
</body>
</html>