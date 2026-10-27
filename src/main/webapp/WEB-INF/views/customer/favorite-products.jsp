<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sản phẩm yêu thích - UTETra</title>
</head>
<body>
    <h3 class="fw-bold mb-4"><i class="fas fa-heart text-danger"></i> Sản phẩm yêu thích của bạn</h3>
    
    <div class="row g-4" id="favorite-list">
        <div class="text-center w-100 py-5">
            <div class="spinner-border text-warning"></div>
        </div>
    </div>

    <script>
        const token = localStorage.getItem('accessToken');
        if (!token) window.location.href = '/auth/login';

        fetch('/api/customer/favorites/products', { headers: { 'Authorization': 'Bearer ' + token } })
        .then(res => res.json())
        .then(data => {
            const container = document.getElementById('favorite-list');
            container.innerHTML = '';
            if (data.code === 200 && data.data.length > 0) {
                data.data.forEach(product => {
                    const imgUrl = product.thumbnailUrl || 'https://via.placeholder.com/300x300';
                    const price = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(product.price);
                    container.innerHTML += `
                        <div class="col-6 col-md-4 col-lg-3">
                            <div class="card h-100 shadow-sm border-0 rounded-4 overflow-hidden">
                                <a href="/products/${product.productId}">
                                    <img src="${imgUrl}" class="card-img-top" style="height: 200px; object-fit: cover;">
                                </a>
                                <div class="card-body text-center">
                                    <h6 class="fw-bold text-truncate"><a href="/products/${product.productId}" class="text-dark text-decoration-none">${product.productName}</a></h6>
                                    <p class="text-danger fw-bold mb-2">${price}</p>
                                    <button onclick="removeFavorite(${product.productId})" class="btn btn-sm btn-outline-danger w-100">
                                        <i class="fas fa-trash"></i> Bỏ yêu thích
                                    </button>
                                </div>
                            </div>
                        </div>
                    `;
                });
            } else {
                container.innerHTML = `
                    <div class="text-center w-100 py-5">
                        <img src="https://cdn-icons-png.flaticon.com/512/1136/1136684.png" width="100" class="mb-3 opacity-50">
                        <h5 class="text-muted">Bạn chưa có sản phẩm yêu thích nào.</h5>
                        <a href="/products" class="btn btn-warning mt-3">Khám phá ngay</a>
                    </div>
                `;
            }
        });

        function removeFavorite(productId) {
            if(!confirm('Bạn muốn bỏ yêu thích sản phẩm này?')) return;
            fetch(`/api/customer/favorites/products/${productId}`, {
                method: 'POST',
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(res => res.json())
            .then(data => { if(data.code === 200) window.location.reload(); });
        }
    </script>
</body>
</html>