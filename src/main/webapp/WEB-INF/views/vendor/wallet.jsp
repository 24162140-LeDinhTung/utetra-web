<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<h3 class="fw-bold text-dark mb-4"><i class="bi bi-wallet2 me-2 text-primary"></i>Quản lý Ví</h3>

<!-- ===== DROPDOWN CHỌN SHOP ===== -->
<div class="card border-0 shadow-sm rounded-3 mb-4">
    <div class="card-body d-flex align-items-center gap-3">
        <label class="fw-bold text-dark mb-0 text-nowrap">Đang xem ví của Cửa hàng:</label>
        <select class="form-select w-auto fw-bold text-primary" onchange="location = this.value;">
            <c:forEach items="${shops}" var="s">
                <option value="${pageContext.request.contextPath}/vendor/wallet/shops/${s.id}" 
                        ${s.id == shop.id ? 'selected' : ''}>
                    ${s.name} (ID: ${s.id})
                </option>
            </c:forEach>
        </select>
    </div>
</div>
<!-- =============================== -->

<div class="row">
    <div class="col-md-6">
        <div class="card bg-success text-white border-0 shadow-sm rounded-3">
            <div class="card-body text-center py-4">
                <h5 class="card-title text-uppercase mb-3">Số dư hiện tại</h5>
                <h1 class="display-4 fw-bold mb-3">
                    <fmt:formatNumber value="${wallet.balance}" type="currency" currencySymbol="đ"/>
                </h1>
                <a href="${pageContext.request.contextPath}/vendor/wallet/withdraw/create?shopId=${shop.id}" class="btn btn-light btn-lg px-4 fw-bold text-success">
                    Yêu cầu rút tiền
                </a>
            </div>
        </div>
    </div>
</div>

<h4 class="mt-5 mb-3 fw-bold">Lịch sử giao dịch</h4>
<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th class="ps-4">Ngày</th>
                    <th>Loại</th>
                    <th>Số tiền</th>
                    <th>Mô tả</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${transactions}" var="tx">
                    <tr>
                        <td class="ps-4">${tx.createdAt}</td>
                        <td>
                            <c:choose>
                                <c:when test="${tx.type == 'ORDER_INCOME'}"><span class="badge bg-success">Thu nhập</span></c:when>
                                <c:when test="${tx.type == 'WITHDRAW'}"><span class="badge bg-danger">Rút tiền</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${tx.type}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="fw-bold ${tx.amount > 0 ? 'text-success' : 'text-danger'}">
                            <fmt:formatNumber value="${tx.amount}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td class="text-muted">${tx.description}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty transactions}">
                    <tr>
                        <td colspan="4" class="text-center py-4 text-muted">Chưa có giao dịch nào.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>