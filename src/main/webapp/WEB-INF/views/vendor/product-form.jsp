<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0">
        <i class="bi bi-pencil-square me-2 text-primary"></i>
        ${product.id == null ? 'Thêm Sản phẩm Mới' : 'Cập nhật Sản phẩm'}
    </h3>
    <a href="${pageContext.request.contextPath}/vendor/products?shopId=${shopId}" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Quay lại
    </a>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-4">
        <form action="${pageContext.request.contextPath}/vendor/product-form/save" method="post">
            
            <!-- ID ẩn: Nếu là Sửa thì có ID, Thêm thì rỗng -->
            <input type="hidden" name="id" value="${product.id}">
            <input type="hidden" name="shopId" value="${shopId}">

            <div class="row g-4">
                <div class="col-md-12">
                    <label class="form-label fw-bold">Tên Sản phẩm <span class="text-danger">*</span></label>
                    <input type="text" class="form-control form-control-lg" name="name" value="${product.name}" required placeholder="VD: Trà sữa trân châu">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Danh mục <span class="text-danger">*</span></label>
                    <select class="form-select form-select-lg" name="categoryId" required>
                        <option value="">-- Chọn danh mục --</option>
                        <c:forEach items="${categories}" var="c">
                            <!-- Tự động selected nếu danh mục trùng với danh mục cũ -->
                            <option value="${c.id}" ${product.category != null && product.category.id == c.id ? 'selected' : ''}>
                                ${c.name}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Giá bán (VNĐ) <span class="text-danger">*</span></label>
                    <input type="number" class="form-control form-control-lg" name="price" value="${product.price}" required min="0" step="1000" placeholder="VD: 35000">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Số lượng tồn kho <span class="text-danger">*</span></label>
                    <input type="number" class="form-control form-control-lg" name="stock" value="${product.stock != null ? product.stock : 100}" required min="0">
                </div>

                <div class="col-md-12">
                    <label class="form-label fw-bold">Mô tả sản phẩm</label>
                    <textarea class="form-control" name="description" rows="4" placeholder="Mô tả về hương vị, nguyên liệu...">${product.description}</textarea>
                </div>
            </div>

            <hr class="my-4">
            
            <div class="d-flex justify-content-end gap-2">
                <a href="${pageContext.request.contextPath}/vendor/products?shopId=${shopId}" class="btn btn-light border px-4">Hủy bỏ</a>
                <button type="submit" class="btn btn-primary px-4"><i class="bi bi-save me-2"></i> Lưu Thông Tin</button>
            </div>
        </form>
    </div>
</div>