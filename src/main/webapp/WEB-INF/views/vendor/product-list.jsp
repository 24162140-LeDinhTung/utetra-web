<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-box-seam me-2 text-primary"></i>Sản phẩm Cửa hàng</h3>
    <a href="${pageContext.request.contextPath}/vendor/product-form?shopId=${selectedShopId}" class="btn btn-success shadow-sm">
    	<i class="bi bi-plus-lg me-1"></i> Thêm sản phẩm
	</a>
</div>

<div class="card border-0 shadow-sm rounded-3 mb-4">
    <div class="card-body d-flex align-items-center gap-3">
        <label class="fw-bold text-dark mb-0 text-nowrap">Cửa hàng đang quản lý:</label>
        
        <!-- FORM CHỌN SHOP ĐỘNG -->
        <form action="${pageContext.request.contextPath}/vendor/products" method="get" id="shopSelectForm" class="m-0">
            <select class="form-select w-auto" name="shopId" onchange="document.getElementById('shopSelectForm').submit()">
                <c:forEach items="${shops}" var="s">
                    <option value="${s.id}" ${s.id == selectedShopId ? 'selected' : ''}>
                        ${s.name} (ID: ${s.id})
                    </option>
                </c:forEach>
            </select>
        </form>
    </div>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th width="80" class="ps-4">ID</th>
                    <th>Tên Sản phẩm</th>
                    <th>Giá bán</th>
                    <th>Tồn kho</th>
                    <th>Đã bán</th>
                    <th>Trạng thái</th>
                    <th width="150" class="text-end pe-4">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${products}" var="p">
                    <tr>
                        <td class="ps-4 fw-bold">#${p.id}</td>
                        <td>
                            <span class="fw-bold text-dark">${p.name}</span>
                        </td>
                        <td class="text-danger fw-bold">
                            <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td>${p.stock}</td>
                        <td>${p.soldCount}</td>
                        <td>
                            <span class="badge ${p.status == 'ACTIVE' ? 'bg-success' : 'bg-warning text-dark'}">${p.status}</span>
                        </td>
                        <td class="text-end pe-4">
    						<!-- Nút Sửa: Chuyển hướng sang form kèm theo ID sản phẩm -->
    						<a href="${pageContext.request.contextPath}/vendor/product-form?shopId=${selectedShopId}&id=${p.id}" class="btn btn-sm btn-outline-secondary">
        						<i class="bi bi-pencil"></i>
    						</a>
    						<!-- Nút Xóa: Gửi form POST ẩn để xóa mềm -->
    						<form action="${pageContext.request.contextPath}/vendor/product/delete" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');">
        						<input type="hidden" name="id" value="${p.id}">
        						<input type="hidden" name="shopId" value="${selectedShopId}">
        						<button type="submit" class="btn btn-sm btn-outline-danger">
            						<i class="bi bi-trash"></i>
       						 	</button>
    						</form>
						</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty products}">
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                            Chưa có sản phẩm nào trong cửa hàng này.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>