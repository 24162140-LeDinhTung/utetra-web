<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<h3 class="fw-bold text-dark mb-4"><i class="bi bi-receipt me-2 text-primary"></i>Quản lý Đơn hàng</h3>

<div class="card border-0 shadow-sm rounded-3 mb-4">
    <div class="card-body d-flex flex-wrap gap-3 align-items-center">
        
        <!-- FORM CHỌN SHOP ĐỘNG -->
        <form action="${pageContext.request.contextPath}/vendor/orders" method="get" class="d-flex align-items-center gap-2 m-0">
            <label class="fw-bold mb-0 text-nowrap">Cửa hàng:</label>
            <select class="form-select w-auto" name="shopId" onchange="this.form.submit()">
                <c:forEach items="${shops}" var="s">
                    <option value="${s.id}" ${s.id == selectedShopId ? 'selected' : ''}>
                        ${s.name} (ID: ${s.id})
                    </option>
                </c:forEach>
            </select>
        </form>

        <div class="d-flex align-items-center gap-2">
            <label class="fw-bold mb-0 text-nowrap">Trạng thái:</label>
            <select class="form-select w-auto">
                <option>Tất cả</option>
                <option>Chờ xác nhận</option>
                <option>Đang giao</option>
                <option>Đã giao</option>
                <option>Đã hủy</option>
            </select>
        </div>
        
        <button class="btn btn-primary ms-auto"><i class="bi bi-search me-1"></i> Lọc</button>
    </div>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-muted">
                <tr>
                    <th class="ps-4">Mã Đơn</th>
                    <th>Khách hàng</th>
                    <th>Tổng tiền</th>
                    <th>Ngày đặt</th>
                    <th>Trạng thái</th>
                    <th>Thanh toán</th>
                    <th class="text-end pe-4">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${orders}" var="o">
                    <tr>
                        <td class="ps-4 fw-bold text-primary">${o.orderCode}</td>
                        <td>
                            <!-- Hiển thị tên khách hàng -->
                            <div class="fw-bold text-dark">${o.user.fullName}</div>
                            <div class="text-muted small">${o.user.phone}</div>
                        </td>
                        <td class="text-danger fw-bold">
                            <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td>
                            <c:if test="${o.createdAt.dayOfMonth < 10}">0</c:if>${o.createdAt.dayOfMonth}/<c:if test="${o.createdAt.monthValue < 10}">0</c:if>${o.createdAt.monthValue}/${o.createdAt.year} 
                            <br/>
                            <span class="text-muted small">${o.createdAt.hour}:<c:if test="${o.createdAt.minute < 10}">0</c:if>${o.createdAt.minute}</span>
                        </td>
                        <td>
                            <!-- Map màu sắc theo OrderStatus -->
                            <c:choose>
                                <c:when test="${o.status.toString() == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ xác nhận</span></c:when>
                                <c:when test="${o.status.toString() == 'CONFIRMED'}"><span class="badge bg-info text-dark">Đã xác nhận</span></c:when>
                                <c:when test="${o.status.toString() == 'SHIPPING'}"><span class="badge bg-primary">Đang giao</span></c:when>
                                <c:when test="${o.status.toString() == 'DELIVERED'}"><span class="badge bg-success">Đã giao</span></c:when>
                                <c:when test="${o.status.toString() == 'CANCELLED'}"><span class="badge bg-danger">Đã hủy</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${o.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <!-- Map màu sắc theo PaymentStatus -->
                            <c:choose>
                                <c:when test="${o.paymentStatus.toString() == 'PAID'}"><span class="badge bg-success">Đã thanh toán</span></c:when>
                                <c:when test="${o.paymentStatus.toString() == 'PENDING'}"><span class="badge bg-warning text-dark">Chưa thanh toán</span></c:when>
                                <c:when test="${o.paymentStatus.toString() == 'FAILED'}"><span class="badge bg-danger">Thất bại</span></c:when>
                                <c:otherwise><span class="badge bg-secondary">${o.paymentStatus}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-end pe-4">
                            <a href="${pageContext.request.contextPath}/vendor/orders/${o.id}" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-eye"></i> Chi tiết
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty orders}">
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                            Chưa có đơn hàng nào trong cửa hàng này.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>