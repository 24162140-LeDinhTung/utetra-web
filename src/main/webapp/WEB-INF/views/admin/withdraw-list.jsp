<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Duyệt rút tiền (Admin)</title>
</head>
<body>
    <div class="container mt-4">
        <h3>Danh sách yêu cầu rút tiền</h3>
        
        <table class="table table-bordered mt-3">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Shop</th>
                    <th>Số tiền</th>
                    <th>STK Ngân hàng</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${requests}" var="req">
                    <tr>
                        <td>${req.id}</td>
                        <td>${req.wallet.shop.name}</td>
                        <td class="text-danger fw-bold">
                            <fmt:formatNumber value="${req.amount}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td>${req.bankAccount}</td>
                        <td><span class="badge bg-warning text-dark">${req.status}</span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/withdraw/approve/${req.id}" class="btn btn-sm btn-success">Duyệt</a>
                            <a href="${pageContext.request.contextPath}/admin/withdraw/reject/${req.id}" class="btn btn-sm btn-danger">Từ chối</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>