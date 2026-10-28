<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-shop me-2 text-primary"></i>Duyệt Cửa hàng mới</h3>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th width="80" class="ps-4">ID</th>
                    <th>Tên Shop</th>
                    <th>Chủ sở hữu</th>
                    <th>Trạng thái</th>
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
                        <td>${shop.owner.fullName}</td>
                        <td>
                            <c:choose>
                                <c:when test="${shop.status == 'ACTIVE'}"><span class="badge bg-success">Hoạt động</span></c:when>
                                <c:when test="${shop.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ duyệt</span></c:when>
                                <c:when test="${shop.status == 'BANNED'}"><span class="badge bg-danger">Bị khóa</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${shop.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end pe-4">
                            <form action="${pageContext.request.contextPath}/admin/shops/update-status" method="post" style="display:inline;">
                                <input type="hidden" name="shopId" value="${shop.id}">
                                <input type="hidden" name="status" value="ACTIVE">
                                <button type="submit" class="btn btn-sm btn-success"><i class="bi bi-check-circle"></i> Duyệt</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/admin/shops/update-status" method="post" style="display:inline;">
                                <input type="hidden" name="shopId" value="${shop.id}">
                                <input type="hidden" name="status" value="BANNED">
                                <button type="submit" class="btn btn-sm btn-danger"><i class="bi bi-x-circle"></i> Từ chối</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty shops}">
                    <tr><td colspan="5" class="text-center py-5 text-muted"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Không có cửa hàng nào cần duyệt.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>