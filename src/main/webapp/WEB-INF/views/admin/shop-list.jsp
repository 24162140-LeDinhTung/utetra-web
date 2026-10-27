<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý Cửa hàng (Admin)</title>
</head>
<body>
    <div class="container mt-4">
        <h3>Duyệt Cửa hàng mới</h3>
        
        <table class="table table-bordered mt-3">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tên Shop</th>
                    <th>Chủ sở hữu</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${shops}" var="shop">
                    <tr>
                        <td>${shop.id}</td>
                        <td>${shop.name}</td>
                        <td>${shop.owner.fullName}</td>
                        <td><span class="badge bg-warning text-dark">${shop.status}</span></td>
                        <td>
                            <form action="${pageContext.request.contextPath}/admin/shops/update-status" method="post" style="display:inline;">
                                <input type="hidden" name="shopId" value="${shop.id}">
                                <input type="hidden" name="status" value="ACTIVE">
                                <button type="submit" class="btn btn-sm btn-success">Duyệt</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/admin/shops/update-status" method="post" style="display:inline;">
                                <input type="hidden" name="shopId" value="${shop.id}">
                                <input type="hidden" name="status" value="BANNED">
                                <button type="submit" class="btn btn-sm btn-danger">Từ chối</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>