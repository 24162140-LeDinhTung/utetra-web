<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Giao diện hiển thị thông tin Cửa hàng -->
<div class="text-center mb-5">
    <h2 class="fw-bold text-warning">${shop.name}</h2>
    <p class="text-muted"><i class="bi bi-geo-alt-fill"></i> ${shop.address}</p>
</div>

<!-- Danh sách sản phẩm của Cửa hàng -->
<div class="row">
    <c:if test="${empty products}">
        <div class="col-12 text-center text-muted">
            <p>Cửa hàng hiện chưa có sản phẩm nào.</p>
        </div>
    </c:if>

    <c:forEach items="${products}" var="product">
        <div class="col-md-3 mb-4">
            <div class="card h-100 shadow-sm">
                
                <!-- Xử lý ảnh sản phẩm -->
                <c:choose>
                    <c:when test="${not empty product.images}">
                        <img src="${product.images[0].imageUrl}" class="card-img-top" alt="${product.name}" style="height: 200px; object-fit: cover;">
                    </c:when>
                    <c:otherwise>
                        <img src="${pageContext.request.contextPath}/images/part-b-demo.svg" class="card-img-top" alt="No Image" style="height: 200px; object-fit: cover;">
                    </c:otherwise>
                </c:choose>

                <div class="card-body">
                    <h6 class="card-title fw-bold">${product.name}</h6>
                    <p class="text-danger fw-bold mb-1">
                        <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="₫"/>
                    </p>
                    <p class="text-muted small mb-2">Đã bán: ${product.soldCount} · Còn: ${product.stock}</p>
                    
                    <!-- Mỗi thuộc tính còn hoạt động đều cần được chọn trước khi thêm giỏ. -->
                    <c:forEach items="${product.attributes}" var="attr">
                        <c:if test="${not attr.isDeleted}">
                            <div class="mb-2">
                                <label class="form-label small fw-bold mb-1" for="attr-${product.id}-${attr.id}">Chọn <c:out value="${attr.name}"/>:</label>
                                <select class="form-select form-select-sm product-option" id="attr-${product.id}-${attr.id}" data-product-id="${product.id}" data-attribute="<c:out value='${attr.name}'/>">
                                    <c:forEach items="${attr.values}" var="val">
                                      <c:if test="${not val.isDeleted}">
                                        <option value="<c:out value='${val.value}'/>">
                                            <c:out value="${val.value}"/>
                                            <c:if test="${val.extraPrice > 0}">
                                                (+<fmt:formatNumber value="${val.extraPrice}" type="currency" currencySymbol="₫"/>)
                                            </c:if>
                                        </option>
                                      </c:if>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
                
                <div class="card-footer bg-white border-top-0">
                    <!-- Nút thêm vào giỏ hàng (Truyền thêm biến hasSize) -->
                    <button class="btn btn-warning btn-sm w-100 fw-bold text-dark" 
                            onclick="addToCart(${product.id}, this)">
                        <i class="bi bi-cart-plus"></i> Thêm vào giỏ
                    </button>
                </div>
            </div>
        </div>
    </c:forEach>
</div>

<!-- ĐOẠN JAVASCRIPT XỬ LÝ GỌI API GIỎ HÀNG -->
<script>
    function addToCart(productId, buttonElement) {
        // Đổi trạng thái nút để tránh click nhiều lần
        const originalText = buttonElement.innerHTML;
        buttonElement.innerHTML = 'Đang thêm...';
        buttonElement.disabled = true;

        // 1. Xây dựng object thuộc tính dựa trên lựa chọn của người dùng
        const attributesData = Object.create(null);
        document.querySelectorAll('.product-option[data-product-id="' + productId + '"]').forEach(select => {
            attributesData[select.dataset.attribute] = select.value;
        });

        // Đóng gói thành chuỗi JSON (ví dụ: {"Size":"L"})
        const selectedAttributesJson = JSON.stringify(attributesData);

        // 2. Gửi API
        fetch('${pageContext.request.contextPath}/api/customer/cart/items', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                productId: productId,
                quantity: 1,
                selectedAttributes: selectedAttributesJson // Gửi chuỗi JSON động
            })
        })
        .then(async response => {
            // Xử lý lỗi xác thực
            if (response.status === 401 || response.status === 403) {
                alert('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng!');
                window.location.href = '${pageContext.request.contextPath}/auth/login';
                return;
            }
            
            // Đọc dữ liệu trả về (bao gồm cả lỗi 400)
            const data = await response.json();

            // Nếu có lỗi (như thiếu size, hết hàng,...)
            if (!response.ok) {
                throw new Error(data.message || 'Lỗi khi thêm vào giỏ hàng');
            }

            // Thành công
            alert('Đã thêm sản phẩm vào giỏ hàng thành công! 🎉');
            
        })
        .catch(error => {
            console.error('Lỗi:', error);
            alert(error.message);
        })
        .finally(() => {
            // Khôi phục lại trạng thái nút
            buttonElement.innerHTML = originalText;
            buttonElement.disabled = false;
        });
    }
</script>
