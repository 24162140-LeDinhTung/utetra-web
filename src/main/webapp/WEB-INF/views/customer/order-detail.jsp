<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-dark m-0">Chi tiết Đơn hàng: <span class="text-danger">${order.orderCode}</span></h3>
    <a href="${pageContext.request.contextPath}/customer/orders" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Quay lại danh sách
    </a>
</div>

<div class="row g-4">
    <div class="col-md-8">
        <!-- Thông tin giao hàng -->
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

        <!-- Danh sách món -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3 fw-bold">Danh sách Món</div>
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light text-muted">
                        <tr>
                            <th class="ps-4">Sản phẩm</th>
                            <th>Đơn giá</th>
                            <th class="text-center">SL</th>
                            <th class="text-end">Thành tiền</th>
                            <th class="text-center">Hành động</th> <!-- CỘT ĐÁNH GIÁ -->
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
                                <td class="text-end">
                                    <fmt:formatNumber value="${item.unitPrice * item.quantity}" type="currency" currencySymbol="đ"/>
                                </td>
                                
                                <!-- NÚT ĐÁNH GIÁ: Chỉ hiện khi đơn đã giao -->
                                <td class="text-center pe-4">
                                    <c:if test="${order.status == 'DELIVERED'}">
                                        <a href="${pageContext.request.contextPath}/customer/review?productId=${item.product.id}&orderId=${order.id}" 
                                           class="btn btn-sm btn-warning text-dark fw-bold">
                                            <i class="bi bi-star-fill"></i> Đánh giá
                                        </a>
                                    </c:if>
                                    <c:if test="${order.status != 'DELIVERED'}">
                                        <span class="text-muted small">Chờ giao hàng</span>
                                    </c:if>
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

    <!-- Trạng thái & Thanh toán -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white py-3 fw-bold">Trạng thái Đơn hàng</div>
            <div class="card-body text-center py-4">
                <c:choose>
                    <c:when test="${order.status == 'NEW'}"><h4><span class="badge bg-secondary p-3 w-100">Mới</span></h4></c:when>
                    <c:when test="${order.status == 'CONFIRMED'}"><h4><span class="badge bg-info text-dark p-3 w-100">Đã xác nhận</span></h4></c:when>
                    <c:when test="${order.status == 'PICKED_UP'}"><h4><span class="badge bg-primary p-3 w-100">Đã lấy hàng</span></h4></c:when>
                    <c:when test="${order.status == 'SHIPPING'}"><h4><span class="badge bg-warning text-dark p-3 w-100">Đang giao</span></h4></c:when>
                    <c:when test="${order.status == 'DELIVERED'}"><h4><span class="badge bg-success p-3 w-100">Đã giao</span></h4></c:when>
                    <c:otherwise><h4><span class="badge bg-danger p-3 w-100">${order.status}</span></h4></c:otherwise>
                </c:choose>
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