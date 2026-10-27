<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý Cửa hàng</title>
</head>
<body>
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3>Danh sách Cửa hàng của tôi</h3>
            <a href="${pageContext.request.contextPath}/vendor/shops/create" class="btn btn-primary">
                <i class="bi bi-plus-circle"></i> Tạo cửa hàng mới
            </a>
        </div>

        <c:if test="${not empty message}">
            <div class="alert alert-success">${message}</div>
        </c:if>

        <table class="table table-bordered table-hover">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tên Shop</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${shops}" var="shop">
                    <tr>
                        <td>${shop.id}</td>
                        <td>${shop.name}</td>
                        <td>
                            <c:choose>
                                <c:when test="${shop.status == 'ACTIVE'}"><span class="badge bg-success">Hoạt động</span></c:when>
                                <c:when test="${shop.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ duyệt</span></c:when>
                                <c:when test="${shop.status == 'BANNED'}"><span class="badge bg-danger">Bị khóa</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${shop.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${shop.createdAt}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/vendor/shops/edit/${shop.id}" class="btn btn-sm btn-info">Sửa</a>
                            <a href="${pageContext.request.contextPath}/vendor/shops/${shop.id}/wallet" class="btn btn-sm btn-success">Xem Ví</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty shops}">
                    <tr><td colspan="5" class="text-center">Bạn chưa có cửa hàng nào.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</body>
</html>