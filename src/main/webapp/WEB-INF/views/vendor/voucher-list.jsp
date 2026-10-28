<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<h3 class="fw-bold text-dark mb-4"><i class="bi bi-ticket-perforated me-2 text-primary"></i>Voucher của hàng</h3>

<div class="card border-0 shadow-sm rounded-3 mb-4">
    <div class="card-body d-flex align-items-center gap-3">
        <label class="fw-bold text-dark mb-0 text-nowrap">Cửa hàng đang quản lý:</label>
        <form action="${pageContext.request.contextPath}/vendor/vouchers" method="get" class="m-0">
            <select class="form-select w-auto" name="shopId" onchange="this.form.submit()">
                <c:forEach items="${shops}" var="s">
                    <option value="${s.id}" ${s.id == selectedShopId ? 'selected' : ''}>${s.name} (ID: ${s.id})</option>
                </c:forEach>
            </select>
        </form>
    </div>
</div>

<div class="row g-4">
    <!-- Cột trái: Danh sách -->
    <div class="col-md-7">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white py-3">
                <h5 class="mb-0 fw-bold">Danh sách Voucher</h5>
            </div>
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">Mã</th>
                            <th>Mức giảm</th>
                            <th>Lượt dùng</th>
                            <th class="text-end pe-4">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${vouchers}" var="v">
                            <tr>
                                <td class="ps-4 fw-bold text-primary">${v.code}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${v.discountType.toString() == 'PERCENT'}">${v.discountValue}%</c:when>
                                        <c:otherwise><fmt:formatNumber value="${v.discountValue}" type="currency" currencySymbol="đ"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${v.usedCount} / ${v.usageLimit != null ? v.usageLimit : '∞'}</td>
                                <td class="text-end pe-4">
                                    <a href="${pageContext.request.contextPath}/vendor/vouchers?shopId=${selectedShopId}&editId=${v.id}" class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/vendor/voucher/delete" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa voucher này?');">
                                        <input type="hidden" name="id" value="${v.id}">
                                        <input type="hidden" name="shopId" value="${selectedShopId}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty vouchers}">
                            <tr><td colspan="4" class="text-center py-5 text-muted">Chưa có dữ liệu.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Cột phải: Form tạo mới / cập nhật -->
    <div class="col-md-5">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white py-3">
                <h5 class="mb-0 fw-bold">${editVoucher != null ? 'Cập nhật Voucher' : 'Tạo mới'}</h5>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/vendor/voucher/save" method="post">
                    <input type="hidden" name="shopId" value="${selectedShopId}">
                    <input type="hidden" name="id" value="${editVoucher.id}">
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Mã voucher</label>
                        <input type="text" class="form-control" name="code" required placeholder="VD: SALE50" value="${editVoucher.code}">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Loại Voucher</label>
                        <select class="form-select" name="voucherType">
                            <!-- Sửa theo VoucherType: PRODUCT, SHIPPING -->
                            <option value="PRODUCT" ${editVoucher != null && editVoucher.voucherType.toString() == 'PRODUCT' ? 'selected' : ''}>Giảm giá sản phẩm</option>
                            <option value="SHIPPING" ${editVoucher != null && editVoucher.voucherType.toString() == 'SHIPPING' ? 'selected' : ''}>Giảm phí vận chuyển</option>
                        </select>
                    </div>

                    <div class="row">
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Kiểu giảm</label>
                            <select class="form-select" name="discountType">
                                <!-- Sửa theo DiscountType: PERCENT, FIXED -->
                                <option value="PERCENT" ${editVoucher != null && editVoucher.discountType.toString() == 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                                <option value="FIXED" ${editVoucher != null && editVoucher.discountType.toString() == 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Mức giảm</label>
                            <input type="number" class="form-control" name="discountValue" required value="${editVoucher != null ? editVoucher.discountValue : 10}">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Đơn tối thiểu</label>
                            <input type="number" class="form-control" name="minOrderAmount" value="${editVoucher != null && editVoucher.minOrderAmount != null ? editVoucher.minOrderAmount : 0}">
                        </div>
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Giảm tối đa</label>
                            <input type="number" class="form-control" name="maxDiscountAmount" placeholder="Không giới hạn" value="${editVoucher.maxDiscountAmount}">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Tổng số lượt</label>
                        <input type="number" class="form-control" name="usageLimit" placeholder="Không giới hạn" value="${editVoucher.usageLimit}">
                    </div>
                    <div class="row mb-4">
                        <div class="col-6">
                            <label class="form-label fw-bold">Bắt đầu</label>
                            <input type="datetime-local" class="form-control" name="startDate" required 
                                   value="${editVoucher != null && editVoucher.startDate != null ? editVoucher.startDate : ''}">
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-bold">Kết thúc</label>
                            <input type="datetime-local" class="form-control" name="endDate" required
                                   value="${editVoucher != null && editVoucher.endDate != null ? editVoucher.endDate : ''}">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-success w-100"><i class="bi bi-save me-1"></i> Lưu Voucher</button>
                    
                    <c:if test="${editVoucher != null}">
                        <a href="${pageContext.request.contextPath}/vendor/vouchers?shopId=${selectedShopId}" class="btn btn-light w-100 mt-2 border">Hủy cập nhật</a>
                    </c:if>
                </form>
            </div>
        </div>
    </div>
</div>