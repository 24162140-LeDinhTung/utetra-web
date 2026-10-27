<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Lịch sử xem - UTETra</title>
</head>
<body>
    <h3 class="fw-bold mb-4"><i class="fas fa-history text-primary"></i> Sản phẩm bạn đã xem</h3>
    
    <div class="row g-4" id="history-list">
        <div class="text-center w-100 py-5">
            <div class="spinner-border text-primary"></div>
        </div>
    </div>

    <script>
        const token = localStorage.getItem('accessToken');
        if (!token) window.location.href = '/auth/login';

        fetch('/api/customer/history', { headers: { 'Authorization': 'Bearer ' + token } })
        .then(res => res.json())
        .then(data => {
            const container = document.getElementById('history-list');
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
                                    <p class="text-danger fw-bold mb-0">${price}</p>
                                </div>
                            </div>
                        </div>
                    `;
                });
            } else {
                container.innerHTML = '<p class="text-center text-muted w-100 py-5">Bạn chưa xem sản phẩm nào.</p>';
            }
        });
    </script>
</body>
</html>