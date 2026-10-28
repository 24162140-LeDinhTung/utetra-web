<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0"><i class="bi bi-receipt me-2 text-primary"></i>Chi tiết Đơn hàng: ${order.orderCode}</h3>
    <a href="${pageContext.request.contextPath}/vendor/orders?shopId=${order.shop.id}" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
    </a>
</div>

<c:if test="${not empty message}">
    <div class="alert alert-success shadow-sm">${message}</div>
</c:if>
<c:if test="${not empty error}">
    <div class="alert alert-danger shadow-sm">${error}</div>
</c:if>

<div class="row g-4">
    <!-- Cột trái: Thông tin khách và món ăn -->
    <div class="col-md-8">
        <!-- Thông tin khách hàng -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white py-3 fw-bold">Thông tin Giao hàng</div>
            <div class="card-body">
                <div class="row">
                    <div class="col-sm-6 mb-2">
                        <span class="text-muted d-block">Khách hàng:</span>
                        <span class="fw-bold">${order.user.fullName}</span>
                    </div>
                    <div class="col-sm-6 mb-2">
                        <span class="text-muted d-block">Số điện thoại:</span>
                        <span class="fw-bold">${order.user.phone}</span>
                    </div>
                    <div class="col-12 mt-2">
                        <span class="text-muted d-block">Địa chỉ nhận hàng:</span>
                        <span class="fw-bold text-primary">${order.shippingAddress}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Danh sách món ăn -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3 fw-bold">Danh sách Món</div>
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-muted">
                        <tr>
                            <th class="ps-4">Sản phẩm</th>
                            <th>Đơn giá</th>
                            <th class="text-center">SL</th>
                            <th class="text-end pe-4">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${items}" var="item">
                            <tr>
                                <td class="ps-4">
                                    <div class="d-flex align-items-center">
                                        <img src="${item.productImage}" alt="img" class="rounded me-3" style="width: 50px; height: 50px; object-fit: cover;">
                                        <div>
                                            <div class="fw-bold text-dark">${item.productName}</div>
                                            <div class="text-muted small">${item.selectedAttributes}</div>
                                        </div>
                                    </div>
                                </td>
                                <td><fmt:formatNumber value="${item.unitPrice}" type="currency" currencySymbol="đ"/></td>
                                <td class="text-center fw-bold">${item.quantity}</td>
                                <td class="text-end pe-4 text-danger fw-bold">
                                    <fmt:formatNumber value="${item.unitPrice * item.quantity}" type="currency" currencySymbol="đ"/>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div class="card-footer bg-light text-end py-3">
                <div class="mb-1">Tiền món: <fmt:formatNumber value="${order.subtotal}" type="currency" currencySymbol="đ"/></div>
                <div class="mb-1">Phí giao hàng: <fmt:formatNumber value="${order.shippingFee}" type="currency" currencySymbol="đ"/></div>
                <div class="mb-2">Giảm giá: -<fmt:formatNumber value="${order.discountAmount}" type="currency" currencySymbol="đ"/></div>
                <h4 class="fw-bold text-danger m-0">Tổng cộng: <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ"/></h4>
            </div>
        </div>
    </div>

    <!-- Cột phải: Trạng thái & Thanh toán -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white py-3 fw-bold">Trạng thái Đơn hàng</div>
            <div class="card-body">
                <div class="mb-3">
                    <span class="text-muted d-block mb-1">Trạng thái hiện tại:</span>
                    <h5 class="m-0">
                        <c:choose>
                            <c:when test="${order.status == 'NEW'}"><span class="badge bg-secondary">Mới</span></c:when>
                            <c:when test="${order.status == 'CONFIRMED'}"><span class="badge bg-info text-dark">Đã xác nhận</span></c:when>
                            <c:when test="${order.status == 'PICKED_UP'}"><span class="badge bg-primary">Đã lấy hàng</span></c:when>
                            <c:when test="${order.status == 'SHIPPING'}"><span class="badge bg-warning text-dark">Đang giao</span></c:when>
                            <c:when test="${order.status == 'DELIVERED'}"><span class="badge bg-success">Đã giao</span></c:when>
                            <c:otherwise><span class="badge bg-danger">${order.status}</span></c:otherwise>
                        </c:choose>
                    </h5>
                </div>
                
                <!-- Form chuyển trạng thái -->
                <c:if test="${nextStatus != null}">
                    <form action="${pageContext.request.contextPath}/vendor/orders/${order.id}/update-status" method="post" class="mt-4 pt-3 border-top">
                        <input type="hidden" name="newStatus" value="${nextStatus}">
                        <button type="submit" class="btn btn-primary w-100 fw-bold">
                            <i class="bi bi-arrow-right-circle me-1"></i> 
                            Chuyển sang: 
                            <c:choose>
                                <c:when test="${nextStatus == 'CONFIRMED'}">Đã xác nhận</c:when>
                                <c:when test="${nextStatus == 'PICKED_UP'}">Đã lấy hàng</c:when>
                                <c:when test="${nextStatus == 'SHIPPING'}">Đang giao</c:when>
                                <c:when test="${nextStatus == 'DELIVERED'}">Đã giao</c:when>
                            </c:choose>
                        </button>
                    </form>
                </c:if>
                <c:if test="${nextStatus == null}">
                    <div class="alert alert-success mt-3 mb-0 text-center fw-bold">
                        <i class="bi bi-check-circle-fill me-1"></i> Đơn hàng đã hoàn thành
                    </div>
                </c:if>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3 fw-bold">Thanh toán</div>
            <div class="card-body">
                <div class="mb-2">
                    <span class="text-muted d-block">Phương thức:</span>
                    <span class="fw-bold">
                        <c:choose>
                            <c:when test="${order.paymentMethod == 'COD'}">Tiền mặt (COD)</c:when>
                            <c:when test="${order.paymentMethod == 'VNPAY'}">VNPay</c:when>
                            <c:when test="${order.paymentMethod == 'MOMO'}">Ví MoMo</c:when>
                            <c:otherwise>${order.paymentMethod}</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div>
                    <span class="text-muted d-block">Trạng thái:</span>
                    <c:choose>
                        <c:when test="${order.paymentStatus == 'SUCCESS'}"><span class="badge bg-success">Đã thanh toán</span></c:when>
                        <c:when test="${order.paymentStatus == 'PENDING'}"><span class="badge bg-warning text-dark">Chưa thanh toán</span></c:when>
                        <c:otherwise><span class="badge bg-danger">${order.paymentStatus}</span></c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>