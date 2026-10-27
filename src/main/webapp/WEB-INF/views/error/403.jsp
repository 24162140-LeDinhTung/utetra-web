<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Lỗi Truy Cập</title>
    <!-- Nhúng Bootstrap (nếu decorator chưa nhúng) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8 text-center">
                <div class="card shadow border-0 p-5">
                    <!-- Icon ổ khóa -->
                    <h1 class="display-1 text-danger mb-4">403</h1>
                    <h3 class="text-dark mb-3">${errorTitle}</h3>
                    <p class="text-muted fs-5 mb-4">${errorMessage}</p>
                    
                    <div class="d-flex justify-content-center gap-3">
                        <a href="${pageContext.request.contextPath}/" class="btn btn-primary px-4 py-2">
                            Về trang chủ
                        </a>
                        <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-outline-danger px-4 py-2">
                            Đăng xuất
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>