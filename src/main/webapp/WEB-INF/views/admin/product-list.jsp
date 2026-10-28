<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-box-seam me-2 text-primary"></i>Danh sách Sản phẩm</h3>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th class="ps-4">ID</th>
                    <th>Tên Sản phẩm</th>
                    <th>Giá bán</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${products}" var="p">
                    <tr>
                        <td class="ps-4 fw-bold">#${p.id}</td>
                        <td class="fw-bold text-dark">${p.name}</td>
                        <td class="text-danger fw-bold">
                            <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td><span class="badge bg-info text-dark">${p.status}</span></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty products}">
                    <tr><td colspan="4" class="text-center py-5 text-muted">Chưa có sản phẩm nào.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>