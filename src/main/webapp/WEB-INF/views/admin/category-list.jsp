<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-tags me-2 text-primary"></i>Danh mục Sản phẩm</h3>
    <a href="${pageContext.request.contextPath}/admin/category-form" class="btn btn-primary shadow-sm">
        <i class="bi bi-plus-circle me-1"></i> Thêm danh mục
    </a>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th width="80" class="ps-4">ID</th>
                    <th>Tên Danh mục</th>
                    <th>Slug</th>
                    <th>Danh mục cha</th>
                    <th width="150" class="text-end pe-4">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${categories}" var="c">
                    <tr>
                        <td class="ps-4 fw-bold">#${c.id}</td>
                        <td class="fw-bold text-dark">${c.name}</td>
                        <td class="text-muted">${c.slug}</td>
                        <td>
                            <!-- Giả sử Entity Category của bạn có trường parent -->
                            <c:choose>
                                <c:when test="${not empty c.parent}">
                                    <span class="badge bg-secondary">${c.parent.name}</span>
                                </c:when>
                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end pe-4">
                            <a href="${pageContext.request.contextPath}/admin/category-form?id=${c.id}" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-pencil"></i> Sửa
                            </a>
                            <form action="${pageContext.request.contextPath}/admin/category/delete" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa danh mục này?');">
                                <input type="hidden" name="id" value="${c.id}">
                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                    <i class="bi bi-trash"></i> Xóa
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty categories}">
                    <tr><td colspan="5" class="text-center py-5 text-muted"><i class="bi bi-inbox fs-1 d-block mb-2"></i>Chưa có danh mục nào.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>