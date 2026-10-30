<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<header class="customer-page-intro">
    <p class="customer-eyebrow">TÌM LẠI MỘT HƯƠNG VỊ</p>
    <h1>Có thể bạn vẫn thích</h1>
    <p class="customer-page-note">Những món đã ghé xem, dành cho lúc bạn muốn chọn lại.</p>
</header>
<div class="card shadow-sm border-0 p-4 customer-collection customer-collection--history">
    <h4 class="fw-bold mb-4 text-primary"><i class="bi bi-clock-history"></i> Sản phẩm đã xem</h4>
    
    <div class="row">
        <c:if test="${empty history}">
            <div class="col-12 text-muted customer-empty">Bạn chưa xem sản phẩm nào.</div>
        </c:if>

        <c:forEach items="${history}" var="item">
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
                            <a href="${pageContext.request.contextPath}/products/${item.productId}" class="btn btn-outline-primary w-100">
                                Xem lại
                            </a>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>