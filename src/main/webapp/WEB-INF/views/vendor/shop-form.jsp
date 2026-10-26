<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>${shop != null ? 'Sửa' : 'Tạo'} Cửa hàng</title>
</head>
<body>
    <div class="container mt-4">
        <div class="card">
            <div class="card-header">
                <h4>${shop != null ? 'Cập nhật thông tin' : 'Đăng ký mở'} Cửa hàng</h4>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/vendor/shops/save" method="post">
                    <input type="hidden" name="id" value="${shop.id}">
                    
                    <div class="mb-3">
                        <label class="form-label">Tên Cửa hàng <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="name" value="${shop.name}" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" name="description" rows="3">${shop.description}</textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Ảnh đại diện (URL)</label>
                        <input type="text" class="form-control" name="avatarUrl" value="${shop.avatarUrl}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Ảnh bìa (URL)</label>
                        <input type="text" class="form-control" name="coverUrl" value="${shop.coverUrl}">
                    </div>

                    <button type="submit" class="btn btn-primary">Lưu thông tin</button>
                    <a href="${pageContext.request.contextPath}/vendor/shops" class="btn btn-secondary">Hủy</a>
                </form>
            </div>
        </div>
    </div>
</body>
</html>