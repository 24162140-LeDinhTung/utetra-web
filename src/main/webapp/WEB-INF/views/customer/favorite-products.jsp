<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<header class="customer-page-intro">
    <p class="customer-eyebrow">DÀNH RIÊNG CHO GU CỦA BẠN</p>
    <h1>Những món thương nhớ</h1>
    <p class="customer-page-note">Lưu lại vị yêu thích, để lần chọn món tiếp theo thêm dễ dàng.</p>
</header>
<div class="card shadow-sm border-0 p-4 customer-collection customer-collection--favorites">
    <h4 class="fw-bold mb-4 text-danger"><i class="bi bi-heart-fill"></i> Sản phẩm yêu thích</h4>
    
    <div class="row">
        <c:if test="${empty favorites}">
            <div class="col-12 text-muted customer-empty">Bạn chưa yêu thích sản phẩm nào.</div>
        </c:if>

        <c:forEach items="${favorites}" var="item">
            <div class="col-6 col-md-4 col-lg-3 mb-4">

                <div class="card h-100 border mt-1 customer-collection-card">
                    <c:choose>
                        <c:when test="${not empty item.thumbnailUrl}">
                            <img src="${item.thumbnailUrl}" class="card-img-top" alt="${item.productName}" style="height: 150px; object-fit: cover;">
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/images/part-b-demo.svg" class="card-img-top" alt="Ảnh minh họa đồ uống" style="height: 150px; object-fit: cover;">
                        </c:otherwise>
                    </c:choose>
                    
                    <div class="card-body text-center">
                        <h6 class="fw-bold">${item.productName}</h6>
                        <p class="text-danger mb-0">
                            <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="₫"/>
                        </p>
                    </div>
                    
                    <div class="card-footer bg-white border-top-0">
                        <c:if test="${not empty item.productId}">
                            <a href="${pageContext.request.contextPath}/products/${item.productId}" class="btn btn-outline-warning w-100">
                                Xem
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>