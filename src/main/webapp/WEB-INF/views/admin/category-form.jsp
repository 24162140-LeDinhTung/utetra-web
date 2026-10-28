<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0">
        <i class="bi bi-tag me-2 text-primary"></i>
        ${category.id == null ? 'Thêm Danh mục Mới' : 'Cập nhật Danh mục'}
    </h3>
    <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Quay lại
    </a>
</div>

<div class="card border-0 shadow-sm rounded-3 w-50">
    <div class="card-body p-4">
        <form action="${pageContext.request.contextPath}/admin/category-form/save" method="post">
            <input type="hidden" name="id" value="${category.id}">
            
            <div class="mb-3">
                <label class="form-label fw-bold">Tên Danh mục <span class="text-danger">*</span></label>
                <input type="text" class="form-control" name="name" value="${category.name}" required placeholder="VD: Trà sữa">
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">Danh mục cha (Tùy chọn)</label>
                <select class="form-select" name="parentId">
                    <option value="">-- Không có danh mục cha --</option>
                    <c:forEach items="${parentCategories}" var="p">
                        <!-- Không cho chọn chính nó làm cha -->
                        <c:if test="${p.id != category.id}">
                            <option value="${p.id}" ${category.parent != null && category.parent.id == p.id ? 'selected' : ''}>
                                ${p.name}
                            </option>
                        </c:if>
                    </c:forEach>
                </select>
            </div>

            <button type="submit" class="btn btn-primary w-100 mt-3">
                <i class="bi bi-save me-1"></i> Lưu Danh mục
            </button>
        </form>
    </div>
</div>