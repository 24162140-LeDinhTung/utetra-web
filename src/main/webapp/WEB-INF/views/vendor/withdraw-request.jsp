<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-cash-coin me-2 text-primary"></i>Yêu cầu rút tiền</h3>
    <a href="${pageContext.request.contextPath}/vendor/wallet" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Quay lại Ví
    </a>
</div>

<c:if test="${not empty error}">
    <div class="alert alert-danger shadow-sm">${error}</div>
</c:if>

<div class="card border-0 shadow-sm rounded-3 w-50">
    <div class="card-body p-4">
        <form action="${pageContext.request.contextPath}/vendor/wallet/withdraw/save" method="post">
            
            <!-- DROPDOWN CHỌN SHOP -->
            <div class="mb-4">
                <label class="form-label fw-bold">Chọn Cửa hàng muốn rút <span class="text-danger">*</span></label>
                <select class="form-select form-select-lg" name="shopId" required>
                    <c:forEach items="${shops}" var="s">
                        <option value="${s.id}" ${s.id == selectedShopId ? 'selected' : ''}>
                            ${s.name} (ID: ${s.id})
                        </option>
                    </c:forEach>
                </select>
                <div class="form-text">Tiền sẽ được trừ vào ví của Cửa hàng bạn chọn.</div>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold">Số tiền muốn rút (VNĐ) <span class="text-danger">*</span></label>
                <input type="number" class="form-control form-control-lg" name="amount" min="10000" required placeholder="VD: 50000">
            </div>
            
            <div class="mb-4">
                <label class="form-label fw-bold">Số tài khoản ngân hàng <span class="text-danger">*</span></label>
                <input type="text" class="form-control form-control-lg" name="bankAccount" required placeholder="VD: 123456789 - Vietcombank">
            </div>

            <button type="submit" class="btn btn-success btn-lg w-100 shadow-sm">
                <i class="bi bi-send me-2"></i> Gửi yêu cầu
            </button>
        </form>
    </div>
</div>