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
    <div class="alert alert-danger shadow-sm"><c:out value="${error}"/></div>
</c:if>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-4">
        <form action="${pageContext.request.contextPath}/vendor/my-shops/save" method="post" enctype="multipart/form-data" id="shop-form">
            <input type="hidden" name="id" value="${shop.id}">

            <div class="row g-4">
                <div class="col-md-6">
                    <label class="form-label fw-bold">Tên Cửa hàng <span class="text-danger">*</span></label>
                    <input type="text" class="form-control form-control-lg" name="name" value="<c:out value='${shop.name}'/>" maxlength="255" required placeholder="VD: Trà Sữa Mộc">
                </div>

                <div class="col-md-6">
                    <label class="form-label fw-bold">Ảnh đại diện</label>
                    <input type="file" class="form-control form-control-lg" name="avatarFile" accept="image/jpeg,image/png,image/webp,image/gif" data-shop-image="avatar-preview">
                    <p class="form-text">Chọn ảnh JPG, PNG, WebP hoặc GIF, tối đa 20 MB. Không chọn ảnh mới để giữ ảnh hiện tại.</p>
                    <img id="avatar-preview" src="<c:out value='${shop.avatarUrl}'/>" ${empty shop.avatarUrl ? 'hidden' : ''} alt="Ảnh cửa hàng" style="max-width:100%;max-height:200px;object-fit:contain" data-original="<c:out value='${shop.avatarUrl}'/>">
                </div>

                <div class="col-md-12">
                    <label class="form-label fw-bold">Ảnh bìa</label>
                    <input type="file" class="form-control form-control-lg" name="coverFile" accept="image/jpeg,image/png,image/webp,image/gif" data-shop-image="cover-preview">
                    <p class="form-text">Chọn ảnh JPG, PNG, WebP hoặc GIF, tối đa 20 MB. Không chọn ảnh mới để giữ ảnh hiện tại.</p>
                    <img id="cover-preview" src="<c:out value='${shop.coverUrl}'/>" ${empty shop.coverUrl ? 'hidden' : ''} alt="Ảnh cửa hàng" style="max-width:100%;max-height:200px;object-fit:contain" data-original="<c:out value='${shop.coverUrl}'/>">
                </div>

                <div class="col-md-12">
                    <label class="form-label fw-bold">Mô tả Cửa hàng</label>
                    <textarea class="form-control" name="description" rows="4" maxlength="500" placeholder="Giới thiệu về cửa hàng của bạn..."><c:out value="${shop.description}"/></textarea>
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

<script src="${pageContext.request.contextPath}/js/shop-form.js?v=20261030-1" defer></script>
