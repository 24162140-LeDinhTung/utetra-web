<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-shop me-2 text-primary"></i>Danh sách Cửa hàng của tôi</h3>
    <a href="${pageContext.request.contextPath}/vendor/my-shops/create" class="btn btn-primary shadow-sm">
        <i class="bi bi-plus-circle me-1"></i> Tạo cửa hàng mới
    </a>
</div>

<c:if test="${not empty message}">
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th width="80" class="ps-4">ID</th>
                    <th>Tên Shop</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th width="200" class="text-end pe-4">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${shops}" var="shop">
                    <tr>
                        <td class="ps-4 fw-bold">#${shop.id}</td>
                        <td>
                            <div class="fw-bold text-dark">${shop.name}</div>
                            <div class="text-muted small">${shop.description}</div>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${shop.status == 'ACTIVE'}"><span class="badge bg-success">Hoạt động</span></c:when>
                                <c:when test="${shop.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ duyệt</span></c:when>
                                <c:when test="${shop.status == 'BANNED'}"><span class="badge bg-danger">Bị khóa</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${shop.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-muted">
                            <i class="bi bi-calendar3 me-1"></i> ${shop.createdAt}
                        </td>
                        <td class="text-end pe-4">
                            <a href="${pageContext.request.contextPath}/vendor/my-shops/edit/${shop.id}" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-pencil"></i> Sửa
                            </a>
                            <a href="${pageContext.request.contextPath}/vendor/wallet/shops/${shop.id}" class="btn btn-sm btn-success">
                                <i class="bi bi-wallet2"></i> Xem Ví
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty shops}">
                    <tr><td colspan="5" class="text-center py-4 text-muted">Bạn chưa có cửa hàng nào.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>