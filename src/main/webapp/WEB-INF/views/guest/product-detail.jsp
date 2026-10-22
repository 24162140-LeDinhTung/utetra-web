<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết sản phẩm - UTETra</title>
</head>
<body>
    <div class="row" id="product-container">
        <!-- Nội dung sẽ được JS đổ vào -->
        <div class="text-center w-100 py-5">
            <div class="spinner-border text-warning"></div>
        </div>
    </div>

    <script>
        // Lấy ID sản phẩm từ URL (ví dụ: /products/5 -> ID = 5)
        const pathParts = window.location.pathname.split('/');
        const productId = pathParts[pathParts.length - 1];

        // Format tiền tệ VNĐ
        const formatMoney = (amount) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);

        fetch(`/api/products/${productId}`)
            .then(res => {
                if (!res.ok) throw new Error('Không tìm thấy sản phẩm');
                return res.json();
            })
            .then(product => {
                const container = document.getElementById('product-container');
                const imgUrl = (product.imageUrls && product.imageUrls.length > 0) ? product.imageUrls[0] : 'https://via.placeholder.com/600x600?text=No+Image';
                
                let attributesHtml = '';
                if (product.attributes && product.attributes.length > 0) {
                    product.attributes.forEach(attr => {
                        attributesHtml += `
                            <div class="mb-3">
                                <label class="fw-bold mb-2">${attr.attributeName}</label>
                                <div>
                                    ${attr.values.map(val => `
                                        <input type="radio" class="btn-check" name="attr_${attr.attributeId}" id="val_${val.valueId}" value="${val.value}" data-price="${val.extraPrice}" autocomplete="off" checked>
                                        <label class="btn btn-outline-warning btn-sm rounded-pill px-3" for="val_${val.valueId}">
                                            ${val.value} ${val.extraPrice > 0 ? `(+${formatMoney(val.extraPrice)})` : ''}
                                        </label>
                                    `).join('')}
                                </div>
                            </div>
                        `;
                    });
                }

                container.innerHTML = `
                    <div class="col-md-5 mb-4">
                        <div class="card shadow-sm border-0 rounded-4 overflow-hidden">
                            <img src="${imgUrl}" class="img-fluid w-100" style="object-fit: cover; aspect-ratio: 1/1;">
                        </div>
                    </div>
                    
                    <div class="col-md-7">
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
                                <li class="breadcrumb-item"><a href="/products">Sản phẩm</a></li>
                                <li class="breadcrumb-item active">${product.name}</li>
                            </ol>
                        </nav>

                        <h2 class="fw-bold mb-3">${product.name}</h2>
                        
                        <div class="d-flex align-items-center mb-3">
                            <h3 class="text-danger fw-bold me-3 mb-0">${formatMoney(product.price)}</h3>
                            <span class="badge bg-secondary">Đã bán: ${product.soldCount}</span>
                        </div>

                        <p class="text-muted mb-4">${product.description || 'Chưa có mô tả cho sản phẩm này.'}</p>

                        <hr>

                        <!-- Các thuộc tính (Size, Đá, Đường...) -->
                        ${attributesHtml}

                        <!-- Số lượng và Nút thêm vào giỏ -->
                        <div class="d-flex align-items-center mt-4 pt-3 border-top">
                            <div class="input-group me-3" style="width: 130px;">
                                <button class="btn btn-outline-secondary" type="button" onclick="changeQty(-1)">-</button>
                                <input type="number" id="quantity" class="form-control text-center" value="1" min="1" readonly>
                                <button class="btn btn-outline-secondary" type="button" onclick="changeQty(1)">+</button>
                            </div>
                            <button onclick="addToCart(${product.id})" class="btn btn-warning btn-lg fw-bold text-dark flex-grow-1">
                                <i class="fas fa-cart-plus"></i> Thêm vào giỏ hàng
                            </button>
                        </div>
                        
                        <div class="mt-4 p-3 bg-light rounded-3 text-muted small">
                            <i class="fas fa-store text-warning"></i> Bán bởi: <strong>${product.shopName}</strong>
                        </div>
                    </div>
                `;
            })
            .catch(err => {
                document.getElementById('product-container').innerHTML = `
                    <div class="alert alert-danger text-center w-100">
                        <h4>Lỗi!</h4>
                        <p>${err.message}</p>
                        <a href="/products" class="btn btn-warning">Quay lại danh sách</a>
                    </div>
                `;
            });

        function changeQty(amount) {
            const input = document.getElementById('quantity');
            let val = parseInt(input.value) + amount;
            if (val < 1) val = 1;
            input.value = val;
        }

        function addToCart(productId) {
            const token = localStorage.getItem('accessToken');
            if (!token) {
                alert('Vui lòng đăng nhập để mua hàng!');
                window.location.href = '/auth/login';
                return;
            }

            const quantity = document.getElementById('quantity').value;
            
            // Thu thập các thuộc tính đã chọn (Size, Đá...)
            const selectedAttrs = {};
            document.querySelectorAll('input[type="radio"]:checked').forEach(radio => {
                const attrName = radio.name;
                selectedAttrs[attrName] = radio.value;
            });

            const requestData = {
                productId: productId,
                quantity: parseInt(quantity),
                selectedAttributes: JSON.stringify(selectedAttrs) // Chuyển thành chuỗi JSON
            };

            // Gọi API thêm vào giỏ hàng của B
            fetch('/api/customer/cart/items', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + token 
                },
                body: JSON.stringify(requestData)
            })
            <!-- Thêm nút này bên cạnh nút Thêm vào giỏ -->
            <button onclick="toggleFavorite(${product.id})" class="btn btn-outline-danger btn-lg px-4 ms-2" id="btn-favorite" title="Yêu thích">
                <i class="far fa-heart"></i>
            </button>
            .then(res => res.json())
            .then(data => {
                if (res.status === 200) {
                    alert('Đã thêm vào giỏ hàng thành công!');
                } else {
                    alert('Lỗi: ' + (data.message || 'Không thể thêm vào giỏ'));
                }
            })
            .catch(err => alert('Lỗi kết nối server!'));
        }
        function toggleFavorite(productId) {
            const token = localStorage.getItem('accessToken');
            if (!token) {
                alert('Vui lòng đăng nhập để yêu thích sản phẩm!');
                window.location.href = '/auth/login';
                return;
            }

            fetch(`/api/customer/favorites/products/${productId}`, {
                method: 'POST',
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(res => res.json())
            .then(data => {
                if (data.code === 200) {
                    // Đổi icon từ rỗng sang đặc (hoặc ngược lại)
                    const icon = document.querySelector('#btn-favorite i');
                    if (icon.classList.contains('far')) {
                        icon.classList.replace('far', 'fas');
                        alert('Đã thêm vào danh sách yêu thích!');
                    } else {
                        icon.classList.replace('fas', 'far');
                        alert('Đã xóa khỏi danh sách yêu thích!');
                    }
                } else {
                    alert('Lỗi: ' + data.message);
                }
            })
            .catch(err => alert('Lỗi kết nối server!'));
        }
    </script>
    
</body>
</html>

