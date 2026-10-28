<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<h3 class="fw-bold text-dark mb-4">Tổng quan Hệ thống</h3>

<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="card bg-primary text-white h-100 border-0 shadow-sm rounded-3 p-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-uppercase mb-1 opacity-75">Doanh thu</h6>
                    <h3 class="mb-0 fw-bold"><fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="đ"/></h3>
                </div>
                <i class="bi bi-currency-dollar fs-1 opacity-50"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-success text-white h-100 border-0 shadow-sm rounded-3 p-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-uppercase mb-1 opacity-75">Đơn hàng</h6>
                    <h3 class="mb-0 fw-bold">${totalOrders}</h3>
                </div>
                <i class="bi bi-receipt fs-1 opacity-50"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-warning text-dark h-100 border-0 shadow-sm rounded-3 p-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-uppercase mb-1 opacity-75">Người dùng</h6>
                    <h3 class="mb-0 fw-bold">${totalUsers}</h3>
                </div>
                <i class="bi bi-people fs-1 opacity-50"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-info text-white h-100 border-0 shadow-sm rounded-3 p-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-uppercase mb-1 opacity-75">Cửa hàng</h6>
                    <h3 class="mb-0 fw-bold">${totalShops}</h3>
                </div>
                <i class="bi bi-shop fs-1 opacity-50"></i>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-4">
        <h5 class="fw-bold mb-3"><i class="bi bi-graph-up text-primary me-2"></i>Biểu đồ doanh thu</h5>
        <div style="height: 300px; background-color: #f8f9fa; display: flex; align-items: center; justify-content: center; border-radius: 8px;">
            <span class="text-muted"><i class="bi bi-bar-chart fs-1 d-block text-center mb-2"></i> Biểu đồ sẽ được cập nhật sau</span>
        </div>
    </div>
</div>