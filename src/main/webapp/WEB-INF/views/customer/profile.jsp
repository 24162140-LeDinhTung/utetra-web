<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Trang cá nhân - UTETra</title>
</head>
<body>
    <div class="row">
        <!-- Cột trái: Menu -->
        <div class="col-md-3 mb-4">
            <div class="card shadow-sm border-0 rounded-4 mb-4 text-center p-4">
                <img id="avatarImg" src="https://via.placeholder.com/150" class="rounded-circle mx-auto mb-3 shadow" style="width: 120px; height: 120px; object-fit: cover;">
                <h5 id="userFullName" class="fw-bold mb-1">Đang tải...</h5>
                <p id="userEmail" class="text-muted small mb-3"></p>
                
                <input type="file" id="avatarFile" class="form-control form-control-sm mb-2" accept="image/*">
                <button onclick="uploadAvatar()" class="btn btn-warning fw-bold btn-sm w-100">Cập nhật ảnh</button>
            </div>

            <div class="list-group shadow-sm border-0 rounded-4 overflow-hidden">
                <a href="#" class="list-group-item list-group-item-action active fw-bold" id="menu-info" onclick="showTab('info')">Thông tin cá nhân</a>
                <a href="#" class="list-group-item list-group-item-action fw-bold" id="menu-favorites" onclick="showTab('favorites')">Sản phẩm yêu thích</a>
                <a href="#" class="list-group-item list-group-item-action fw-bold" id="menu-history" onclick="showTab('history')">Sản phẩm đã xem</a>
            </div>
        </div>

        <!-- Cột phải: Nội dung -->
        <div class="col-md-9">
            <!-- TAB 1: THÔNG TIN -->
            <div id="tab-info" class="card shadow-sm border-0 rounded-4">
                <div class="card-header bg-white border-0 pt-4 px-4">
                    <h5 class="fw-bold text-warning"><i class="fas fa-user-edit"></i> Thông tin cá nhân</h5>
                </div>
                <div class="card-body px-4 pb-4">
                    <form id="profileForm">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Họ và tên</label>
                            <input type="text" id="fullName" class="form-control bg-light" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Email (Không thể đổi)</label>
                            <input type="email" id="email" class="form-control bg-light" disabled>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-bold">Số điện thoại</label>
                            <input type="text" id="phone" class="form-control bg-light">
                        </div>
                        <button type="button" onclick="updateProfile()" class="btn btn-warning fw-bold px-4">Lưu thay đổi</button>
                    </form>
                </div>
            </div>

            <!-- TAB 2: YÊU THÍCH -->
            <div id="tab-favorites" class="card shadow-sm border-0 rounded-4 d-none">
                <div class="card-body">
                    <h5 class="fw-bold mb-3 text-danger"><i class="fas fa-heart"></i> Sản phẩm yêu thích</h5>
                    <div class="row g-3" id="favorite-list"></div>
                </div>
            </div>

            <!-- TAB 3: LỊCH SỬ XEM -->
            <div id="tab-history" class="card shadow-sm border-0 rounded-4 d-none">
                <div class="card-body">
                    <h5 class="fw-bold mb-3 text-primary"><i class="fas fa-history"></i> Sản phẩm đã xem</h5>
                    <div class="row g-3" id="history-list"></div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const token = localStorage.getItem('accessToken');
        if (!token) window.location.href = '/auth/login';

        // --- XỬ LÝ TAB ---
        function showTab(tabName) {
            document.getElementById('tab-info').classList.add('d-none');
            document.getElementById('tab-favorites').classList.add('d-none');
            document.getElementById('tab-history').classList.add('d-none');
            document.getElementById('tab-' + tabName).classList.remove('d-none');

            document.getElementById('menu-info').classList.remove('active');
            document.getElementById('menu-favorites').classList.remove('active');
            document.getElementById('menu-history').classList.remove('active');
            document.getElementById('menu-' + tabName).classList.add('active');

            if (tabName === 'favorites') loadFavorites();
            if (tabName === 'history') loadHistory();
        }

        // --- TAB 1: PROFILE ---
        function loadProfile() {
            fetch('/api/customer/profile', { headers: { 'Authorization': 'Bearer ' + token } })
            .then(res => res.json())
            .then(resData => {
                if (resData.code === 200) {
                    const user = resData.data;
                    document.getElementById('userFullName').innerText = user.fullName || 'Chưa cập nhật';
                    document.getElementById('userEmail').innerText = user.email;
                    document.getElementById('fullName').value = user.fullName || '';
                    document.getElementById('email').value = user.email;
                    document.getElementById('phone').value = user.phone || '';
                    if (user.avatarUrl) document.getElementById('avatarImg').src = user.avatarUrl;
                }
            });
        }

        function updateProfile() {
            const data = {
                fullName: document.getElementById('fullName').value,
                phone: document.getElementById('phone').value
            };
            fetch('/api/customer/profile', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
                body: JSON.stringify(data)
            })
            .then(res => res.json())
            .then(resData => {
                if (resData.code === 200) { alert('Cập nhật thành công!'); loadProfile(); }
                else alert('Lỗi: ' + resData.message);
            });
        }

        function uploadAvatar() {
            const fileInput = document.getElementById('avatarFile');
            if (fileInput.files.length === 0) return alert('Vui lòng chọn ảnh!');
            const formData = new FormData();
            formData.append('file', fileInput.files[0]);

            fetch('/api/customer/profile/avatar', {
                method: 'POST',
                headers: { 'Authorization': 'Bearer ' + token },
                body: formData
            })
            .then(res => res.json())
            .then(resData => {
                if (resData.code === 200) {
                    alert('Cập nhật ảnh thành công!');
                    document.getElementById('avatarImg').src = resData.data;
                } else alert('Lỗi upload ảnh!');
            });
        }

        // --- TAB 2: YÊU THÍCH ---
        function loadFavorites() {
            const list = document.getElementById('favorite-list');
            list.innerHTML = '<div class="spinner-border text-warning"></div>';
            fetch('/api/customer/favorites/products', { headers: { 'Authorization': 'Bearer ' + token } })
            .then(res => res.json())
            .then(data => {
                list.innerHTML = '';
                if(data.code === 200 && data.data.length > 0) {
                    data.data.forEach(p => {
                        const imgUrl = p.thumbnailUrl || 'https://via.placeholder.com/150';
                        list.innerHTML += `
                            <div class="col-6 col-md-4">
                                <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                                    <img src="${imgUrl}" style="height: 120px; object-fit: cover;">
                                    <div class="card-body p-2 text-center">
                                        <h6 class="text-truncate small fw-bold">${p.productName}</h6>
                                        <a href="/products/${p.productId}" class="btn btn-sm btn-outline-warning w-100 mt-2">Xem</a>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                } else {
                    list.innerHTML = '<p class="text-muted w-100">Chưa có sản phẩm yêu thích nào.</p>';
                }
            });
        }

        // --- TAB 3: LỊCH SỬ XEM ---
        function loadHistory() {
            const list = document.getElementById('history-list');
            list.innerHTML = '<div class="spinner-border text-primary"></div>';
            fetch('/api/customer/history', { headers: { 'Authorization': 'Bearer ' + token } })
            .then(res => res.json())
            .then(data => {
                list.innerHTML = '';
                if(data.code === 200 && data.data.length > 0) {
                    data.data.forEach(p => {
                        const imgUrl = p.thumbnailUrl || 'https://via.placeholder.com/150';
                        list.innerHTML += `
                            <div class="col-6 col-md-4">
                                <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                                    <img src="${imgUrl}" style="height: 120px; object-fit: cover;">
                                    <div class="card-body p-2 text-center">
                                        <h6 class="text-truncate small fw-bold">${p.productName}</h6>
                                        <a href="/products/${p.productId}" class="btn btn-sm btn-outline-primary w-100 mt-2">Xem lại</a>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                } else {
                    list.innerHTML = '<p class="text-muted w-100">Chưa có lịch sử xem.</p>';
                }
            });
        }

        loadProfile();
    </script>
</body>
</html>