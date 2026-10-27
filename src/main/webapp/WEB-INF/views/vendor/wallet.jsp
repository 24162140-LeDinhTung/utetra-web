<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Ví Cửa hàng</title>
</head>
<body>
    <div class="container mt-4">
        <h3>Quản lý Ví - Shop: ${shop.name}</h3>
        
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="card bg-success text-white">
                    <div class="card-body text-center">
                        <h5 class="card-title">Số dư hiện tại</h5>
                        <h1 class="display-4">
                            <fmt:formatNumber value="${wallet.balance}" type="currency" currencySymbol="đ"/>
                        </h1>
                        <a href="${pageContext.request.contextPath}/vendor/withdraw/create?shopId=${shop.id}" class="btn btn-light mt-3">
                            Yêu cầu rút tiền
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <h4 class="mt-5">Lịch sử giao dịch</h4>
        <table class="table table-striped mt-3">
            <thead>
                <tr>
                    <th>Ngày</th>
                    <th>Loại</th>
                    <th>Số tiền</th>
                    <th>Mô tả</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${transactions}" var="tx">
                    <tr>
                        <td>${tx.createdAt}</td>
                        <td>
                            <c:choose>
                                <c:when test="${tx.type == 'ORDER_INCOME'}"><span class="text-success">Thu nhập đơn hàng</span></c:when>
                                <c:when test="${tx.type == 'WITHDRAW'}"><span class="text-danger">Rút tiền</span></c:when>
                                <c:otherwise>${tx.type}</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <span class="${tx.amount > 0 ? 'text-success' : 'text-danger'}">
                                <fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="đ"/>
                            </span>
                        </td>
                        <td>${tx.description}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>