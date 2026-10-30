<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0">
        <i class="bi bi-shop me-2 text-primary"></i>
        ${shop.id == null ? 'Tạo Cửa hàng Mới' : 'Cập nhật Cửa hàng'}
    </h3>
    <a href="${pageContext.request.contextPath}/vendor/my-shops" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Quay lại
    </a>
</div>

<c:if test="${not empty error}">
    <div class="alert alert-danger shadow-sm">${error}</div>
</c:if>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-4">
        <form action="${pageContext.request.contextPath}/vendor/my-shops/save" method="post">
            <input type="hidden" name="id" value="${shop.id}">

            <div class="row g-4">
                <div class="col-md-6">
                    <label class="form-label fw-bold">Tên Cửa hàng <span class="text-danger">*</span></label>
                    <input type="text" class="form-control form-control-lg" name="name" value="${shop.name}" required placeholder="VD: Trà Sữa Mộc">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Ảnh đại diện (URL)</label>
                    <input type="text" class="form-control form-control-lg" name="avatarUrl" value="${shop.avatarUrl}" placeholder="https://...">
                </div>

                <div class="col-md-12">
                    <label class="form-label fw-bold">Ảnh bìa (URL)</label>
                    <input type="text" class="form-control form-control-lg" name="coverUrl" value="${shop.coverUrl}" placeholder="https://...">
                </div>

                <div class="col-md-12">
                    <label class="form-label fw-bold">Mô tả Cửa hàng</label>
                    <textarea class="form-control" name="description" rows="4" placeholder="Giới thiệu về cửa hàng của bạn...">${shop.description}</textarea>
                </div>
            </div>

            <hr class="my-4">

            <div class="d-flex justify-content-end gap-2">
                <a href="${pageContext.request.contextPath}/vendor/my-shops" class="btn btn-light border px-4">Hủy bỏ</a>
                <button type="submit" class="btn btn-primary px-4"><i class="bi bi-save me-2"></i> Lưu Thông Tin</button>
            </div>
        </form>
    </div>
</div>
