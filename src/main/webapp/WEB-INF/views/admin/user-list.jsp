<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-people me-2 text-primary"></i>Danh sách Người dùng</h3>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th class="ps-4">ID</th>
                    <th>Họ Tên</th>
                    <th>Email</th>
                    <th>Trạng thái</th>
                    <th>Vai trò</th>
                    <th width="150" class="text-end pe-4">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${users}" var="u">
                    <tr>
                        <td class="ps-4 fw-bold">#${u.id}</td>
                        <td class="fw-bold text-dark">${u.fullName}</td>
                        <td>${u.email}</td>
                        <td>
                            <span class="badge ${u.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">
                                ${u.status}
                            </span>
                        </td>
                        <td>
                            <c:forEach items="${u.roles}" var="r">
                                <span class="badge bg-secondary">${r.name}</span>
                            </c:forEach>
                        </td>
                        <td class="text-end pe-4">
                            <c:set var="isVendor" value="false" />
                            <c:forEach items="${u.roles}" var="r">
                                <c:if test="${r.name == 'ROLE_VENDOR' || r.name == 'ROLE_ADMIN'}">
                                    <c:set var="isVendor" value="true" />
                                </c:if>
                            </c:forEach>

                            <c:if test="${isVendor}">
                                <button type="button" class="btn btn-sm btn-outline-primary shadow-sm" onclick="viewShops(${u.id}, '${u.fullName}')">
                                    <i class="bi bi-shop"></i> Xem Shop
                                </button>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty users}">
                    <tr><td colspan="6" class="text-center py-5 text-muted">Chưa có người dùng nào.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- MODAL HIỂN THỊ DANH SÁCH SHOP -->
<div class="modal fade" id="shopModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-light border-0">
                <h5 class="modal-title fw-bold" id="shopModalLabel">
                    <i class="bi bi-shop text-primary me-2"></i>Danh sách Shop của: <span id="modalUserName" class="text-primary"></span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-muted">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Tên Shop</th>
                            <th>Trạng thái</th>
                            <th width="100" class="text-end pe-4">Hành động</th>
                        </tr>
                    </thead>
                    <tbody id="shopTableBody">
                        <!-- Dữ liệu sẽ được điền bằng JavaScript -->
                    </tbody>
                </table>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';

    // Nhận toàn bộ danh sách Shop từ Backend truyền sang (Dùng c:out để tránh lỗi ký tự đặc biệt)
    const allShops = [
        <c:forEach items="${allShops}" var="s">
            {
                id: ${s.id},
                ownerId: ${s.owner.id},
                name: "<c:out value='${s.name}'/>",
                status: "${s.status}"
            },
        </c:forEach>
    ];

    function viewShops(userId, userName) {
        document.getElementById('modalUserName').innerText = userName;
        const tbody = document.getElementById('shopTableBody');
        tbody.innerHTML = '';

        // Ép kiểu cả 2 về Number để so sánh chính xác 100%
        const userShops = allShops.filter(shop => Number(shop.ownerId) === Number(userId));

        if (userShops.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center py-4 text-muted"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Người dùng này chưa có cửa hàng nào.</td></tr>';
        } else {
            userShops.forEach(shop => {
                let badgeClass = 'bg-secondary';
                if (shop.status === 'ACTIVE') badgeClass = 'bg-success';
                else if (shop.status === 'PENDING') badgeClass = 'bg-warning text-dark';
                else if (shop.status === 'BANNED') badgeClass = 'bg-danger';

                tbody.innerHTML += `
                    <tr id="shop-row-\${shop.id}">
                        <td class="ps-4 fw-bold">#\${shop.id}</td>
                        <td class="fw-bold text-dark">\${shop.name}</td>
                        <td><span class="badge \${badgeClass}">\${shop.status}</span></td>
                        <td class="text-end pe-4">
                            <button onclick="deleteShop(\${shop.id})" class="btn btn-sm btn-outline-danger" title="Xóa Shop">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                `;
            });
        }

        const modal = new bootstrap.Modal(document.getElementById('shopModal'));
        modal.show();
    }

    function deleteShop(shopId) {
        if (!confirm('Bạn có chắc chắn muốn xóa cửa hàng này? (Hành động này không thể hoàn tác)')) {
            return;
        }

        const formData = new URLSearchParams();
        formData.append('shopId', shopId);

        fetch(`${contextPath}/admin/users/shops/delete`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        })
        .then(async response => {
            // Đọc dữ liệu dạng text trước để tránh lỗi parse JSON nếu Server trả về HTML (lỗi 500)
            const textData = await response.text();

            try {
                const data = JSON.parse(textData); // Thử parse sang JSON
                if (response.ok) {
                    alert(data.message);
                    window.location.reload(); // Tải lại trang để cập nhật danh sách
                } else {
                    alert('Lỗi từ Server: ' + (data.message || 'Không xác định'));
                }
            } catch (e) {
                // Nếu không phải JSON (tức là lỗi HTML), in ra lỗi HTML đó
                console.error("Server trả về lỗi HTML:", textData);
                alert('Lỗi Database! Không thể xóa Shop này do vướng dữ liệu liên quan (Sản phẩm, Ví, v.v...).');
            }
        })
        .catch(error => {
            console.error('Lỗi Fetch:', error);
            alert('Không thể kết nối đến server!');
        });
    }
</script>
