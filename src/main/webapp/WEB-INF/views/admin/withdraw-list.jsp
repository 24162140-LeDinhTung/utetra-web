<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-cash-coin me-2 text-primary"></i>Duyệt Yêu cầu rút tiền</h3>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th class="ps-4">ID</th>
                    <th>Shop</th>
                    <th>Số tiền</th>
                    <th>STK Ngân hàng</th>
                    <th>Trạng thái</th>
                    <th class="text-end pe-4">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${requests}" var="req">
                    <tr>
                        <td class="ps-4 fw-bold">#${req.id}</td>
                        <td class="text-primary fw-bold">${req.wallet.shop.name}</td>
                        <td class="text-danger fw-bold">
                            <fmt:formatNumber value="${req.amount}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td>${req.bankAccount}</td>
                        <td><span class="badge bg-warning text-dark">${req.status}</span></td>
                        <td class="text-end pe-4">
                            <a href="${pageContext.request.contextPath}/admin/withdraw/approve/${req.id}" class="btn btn-sm btn-success" onclick="return confirm('Duyệt yêu cầu này?')"><i class="bi bi-check-circle"></i> Duyệt</a>
                            <a href="${pageContext.request.contextPath}/admin/withdraw/reject/${req.id}" class="btn btn-sm btn-danger" onclick="return confirm('Từ chối yêu cầu này?')"><i class="bi bi-x-circle"></i> Từ chối</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty requests}">
                    <tr><td colspan="6" class="text-center py-5 text-muted"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Không có yêu cầu rút tiền nào.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>