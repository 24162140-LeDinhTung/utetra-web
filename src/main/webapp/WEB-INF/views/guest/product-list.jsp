<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Menu Sản phẩm - UTETra</title>
</head>
<body>
    <div class="row">
        <!-- Cột Trái: Bộ lọc (Sidebar) -->
        <div class="col-md-3 mb-4">
            <div class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-warning text-dark fw-bold">
                    <i class="fas fa-filter"></i> Danh mục
                </div>
                <div class="list-group list-group-flush" id="category-list">
                    <a href="#" class="list-group-item list-group-item-action active" onclick="loadProducts(null, 0)">Tất cả sản phẩm</a>
                    <!-- Danh mục sẽ được JS đổ vào đây -->
                </div>
            </div>
        </div>

        <!-- Cột Phải: Danh sách sản phẩm -->
        <div class="col-md-9">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="fw-bold m-0">Tất cả sản phẩm</h4>
                <select class="form-select w-auto" id="sortSelect" onchange="loadProducts(currentCategory, 0)">
                    <option value="newest">Mới nhất</option>
                    <option value="price_asc">Giá thấp đến cao</option>
                    <option value="price_desc">Giá cao đến thấp</option>
                    <option value="best_selling">Bán chạy nhất</option>
                </select>
            </div>

            <div class="row g-4" id="product-grid">
                <!-- Sản phẩm sẽ được JS đổ vào đây -->
                <div class="text-center w-100 py-5">
                    <div class="spinner-border text-warning"></div>
                </div>
            </div>

            <!-- Phân trang -->
            <nav aria-label="Page navigation" class="mt-5">
                <ul class="pagination justify-content-center" id="pagination">
                    <!-- Nút phân trang sẽ được JS đổ vào đây -->
                </ul>
            </nav>
        </div>
    </div>

    <script>
        let currentCategory = null;
        let currentPage = 0;
        const pageSize = 12;

        // 1. Tải danh mục
        function loadCategories() {
            // Giả sử API lấy danh mục là /api/categories (Bạn cần nhờ B viết API này nếu chưa có)
            // Tạm thời tôi dùng dữ liệu mẫu, bạn có thể mở comment nếu B đã có API
            /*
            fetch('/api/categories')
                .then(res => res.json())
                .then(data => {
                    const list = document.getElementById('category-list');
                    data.forEach(cat => {
                        list.innerHTML += `<a href="#" class="list-group-item list-group-item-action" onclick="loadProducts(${cat.id}, 0)">${cat.name}</a>`;
                    });
                });
            */
        }

        // 2. Tải sản phẩm
        function loadProducts(categoryId, page) {
            currentCategory = categoryId;
            currentPage = page;
            
            const grid = document.getElementById('product-grid');
            grid.innerHTML = '<div class="text-center w-100 py-5"><div class="spinner-border text-warning"></div></div>';

            const sort = document.getElementById('sortSelect').value;
            
            // Xây dựng URL
            let url = `/api/products?page=${page}&size=${pageSize}&sort=${sort}`;
            if (categoryId) url += `&categoryId=${categoryId}`;

            fetch(url)
                .then(res => res.json())
                .then(data => {
                    grid.innerHTML = ''; // Xóa loading
                    
                    if (data.items && data.items.length > 0) {
                        data.items.forEach(product => {
                            const imgUrl = product.thumbnailUrl || 'https://via.placeholder.com/300x300?text=No+Image';
                            const price = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(product.price);
                            
                            grid.innerHTML += `
                                <div class="col-6 col-md-4">
                                    <div class="card h-100 shadow-sm border-0 rounded-4 overflow-hidden">
                                        <a href="/products/${product.id}">
                                            <img src="${imgUrl}" class="card-img-top" alt="${product.name}" style="height: 180px; object-fit: cover;">
                                        </a>
                                        <div class="card-body">
                                            <a href="/products/${product.id}" class="text-decoration-none text-dark">
                                                <h6 class="card-title fw-bold text-truncate">${product.name}</h6>
                                            </a>
                                            <p class="card-text text-danger fw-bold mb-0">${price}</p>
                                            <small class="text-muted">Đã bán: ${product.soldCount}</small>
                                        </div>
                                    </div>
                                </div>
                            `;
                        });
                        renderPagination(data.totalPages, page);
                    } else {
                        grid.innerHTML = '<p class="text-center text-muted w-100 py-5">Không tìm thấy sản phẩm nào.</p>';
                        document.getElementById('pagination').innerHTML = '';
                    }
                })
                .catch(err => {
                    grid.innerHTML = '<p class="text-danger text-center w-100">Lỗi kết nối server!</p>';
                });
        }

        // 3. Vẽ nút phân trang
        function renderPagination(totalPages, currentPage) {
            const pagination = document.getElementById('pagination');
            pagination.innerHTML = '';

            if (totalPages <= 1) return;

            // Nút Previous
            pagination.innerHTML += `
                <li class="page-item ${currentPage === 0 ? 'disabled' : ''}">
                    <a class="page-link" href="#" onclick="loadProducts(currentCategory, ${currentPage - 1})">Trước</a>
                </li>
            `;

            // Các số trang
            for (let i = 0; i < totalPages; i++) {
                pagination.innerHTML += `
                    <li class="page-item ${i === currentPage ? 'active' : ''}">
                        <a class="page-link" href="#" onclick="loadProducts(currentCategory, ${i})">${i + 1}</a>
                    </li>
                `;
            }

            // Nút Next
            pagination.innerHTML += `
                <li class="page-item ${currentPage === totalPages - 1 ? 'disabled' : ''}">
                    <a class="page-link" href="#" onclick="loadProducts(currentCategory, ${currentPage + 1})">Sau</a>
                </li>
            `;
        }

        // Khởi chạy
        document.addEventListener('DOMContentLoaded', () => {
            loadCategories();
            loadProducts(null, 0);
        });
    </script>
</body>
</html>