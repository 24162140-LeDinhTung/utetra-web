<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <title>UTETra · Cửa hàng trà sữa</title>
    <!-- Nhúng CSS -->
</head>
<body>
    <div class="container my-5">
        <div class="text-center mb-5">
            <h2 class="fw-bold text-warning">UTETRA · CÁC CỬA HÀNG</h2>
            <p class="text-muted">Mỗi cửa hàng, một menu riêng</p>
        </div>

        <div class="row">
            <c:forEach items="${shops}" var="shop">
                <div class="col-md-4 mb-4">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title">${shop.name}</h5>
                            <p class="card-text text-muted">
                                <i class="bi bi-geo-alt-fill"></i> ${shop.address}
                            </p>
                            <!-- Lấy số lượng sản phẩm từ Map productCounts -->
                            <p class="fw-bold text-success">
                                <i class="bi bi-cup-straw"></i> ${productCounts[shop.id]} món đang bán
                            </p>
                        </div>
                        <div class="card-footer bg-white border-top-0 pb-3">
                            <a href="${pageContext.request.contextPath}/shops/${shop.id}" class="btn btn-outline-warning w-100 fw-bold">
                                Xem Menu Cửa Hàng
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</body>
</html>