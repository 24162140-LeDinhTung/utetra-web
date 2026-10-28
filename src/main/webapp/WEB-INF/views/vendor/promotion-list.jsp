<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<h3 class="fw-bold text-dark mb-4"><i class="bi bi-tags me-2 text-primary"></i>Khuyến mãi sản phẩm</h3>

<div class="card border-0 shadow-sm rounded-3 mb-4">
    <div class="card-body d-flex align-items-center gap-3">
        <label class="fw-bold text-dark mb-0 text-nowrap">Cửa hàng đang quản lý:</label>
        <form action="${pageContext.request.contextPath}/vendor/promotions" method="get" class="m-0">
            <select class="form-select w-auto" name="shopId" onchange="this.form.submit()">
                <c:forEach items="${shops}" var="s">
                    <option value="${s.id}" ${s.id == selectedShopId ? 'selected' : ''}>${s.name} (ID: ${s.id})</option>
                </c:forEach>
            </select>
        </form>
    </div>
</div>

<div class="row g-4">
    <div class="col-md-7">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white py-3"><h5 class="mb-0 fw-bold">Danh sách Khuyến mãi</h5></div>
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">Tên</th>
                            <th>Mức giảm</th>
                            <th>Hiệu lực</th>
                            <th class="text-end pe-4">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${promotions}" var="p">
                            <tr>
                                <td class="ps-4 fw-bold text-dark">${p.name}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.discountType.toString() == 'PERCENT'}">${p.discountValue}%</c:when>
                                        <c:otherwise><fmt:formatNumber value="${p.discountValue}" type="currency" currencySymbol="đ"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="${p.startDate.dayOfMonth < 10}">0</c:if>${p.startDate.dayOfMonth}/<c:if test="${p.startDate.monthValue < 10}">0</c:if>${p.startDate.monthValue}/${p.startDate.year}
                                    - 
                                    <c:if test="${p.endDate.dayOfMonth < 10}">0</c:if>${p.endDate.dayOfMonth}/<c:if test="${p.endDate.monthValue < 10}">0</c:if>${p.endDate.monthValue}/${p.endDate.year}
                                </td>
                                <td class="text-end pe-4">
                                    <a href="${pageContext.request.contextPath}/vendor/promotions?shopId=${selectedShopId}&editId=${p.id}" class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/vendor/promotion/delete" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa khuyến mãi này?');">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <input type="hidden" name="shopId" value="${selectedShopId}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty promotions}">
                            <tr><td colspan="4" class="text-center py-5 text-muted">Chưa có dữ liệu.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="col-md-5">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white py-3">
                <h5 class="mb-0 fw-bold">${editPromotion != null ? 'Cập nhật Khuyến mãi' : 'Tạo mới'}</h5>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/vendor/promotion/save" method="post">
                    <input type="hidden" name="shopId" value="${selectedShopId}">
                    <input type="hidden" name="id" value="${editPromotion.id}">
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tên khuyến mãi</label>
                        <input type="text" class="form-control" name="name" required placeholder="VD: Khuyến mãi hè" value="${editPromotion.name}">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Loại khuyến mãi</label>
                        <select class="form-select" name="promotionType">
                            <!-- Sửa theo PromotionType: PERCENT, FIXED -->
                            <option value="PERCENT" ${editPromotion != null && editPromotion.promotionType.toString() == 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                            <option value="FIXED" ${editPromotion != null && editPromotion.promotionType.toString() == 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                        </select>
                    </div>

                    <div class="row">
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Kiểu giảm</label>
                            <select class="form-select" name="discountType">
                                <!-- Sửa theo DiscountType: PERCENT, FIXED -->
                                <option value="PERCENT" ${editPromotion != null && editPromotion.discountType.toString() == 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                                <option value="FIXED" ${editPromotion != null && editPromotion.discountType.toString() == 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Mức giảm</label>
                            <input type="number" class="form-control" name="discountValue" required value="${editPromotion != null ? editPromotion.discountValue : 10}">
                        </div>
                    </div>
                    
                    <div class="row mb-4">
                        <div class="col-6">
                            <label class="form-label fw-bold">Bắt đầu</label>
                            <input type="datetime-local" class="form-control" name="startDate" required
                                   value="${editPromotion != null && editPromotion.startDate != null ? editPromotion.startDate : ''}">
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-bold">Kết thúc</label>
                            <input type="datetime-local" class="form-control" name="endDate" required
                                   value="${editPromotion != null && editPromotion.endDate != null ? editPromotion.endDate : ''}">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-success w-100"><i class="bi bi-save me-1"></i> Lưu Khuyến mãi</button>
                    
                    <c:if test="${editPromotion != null}">
                        <a href="${pageContext.request.contextPath}/vendor/promotions?shopId=${selectedShopId}" class="btn btn-light w-100 mt-2 border">Hủy cập nhật</a>
                    </c:if>
                </form>
            </div>
        </div>
    </div>
</div>