<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Admin</title>
    <!-- Nhúng Chart.js để vẽ biểu đồ -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <h3 class="mb-4 fw-bold text-dark">Tổng quan Hệ thống</h3>

    <!-- Hàng chứa các thẻ thống kê (Cards) -->
    <div class="row g-4 mb-4">
        <!-- Thẻ Doanh thu -->
        <div class="col-md-3">
            <div class="card bg-primary text-white h-100 border-0 shadow-sm">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase mb-1">Doanh thu</h6>
                            <h4 class="mb-0 fw-bold">
                                <fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="đ"/>
                            </h4>
                        </div>
                        <i class="bi bi-currency-dollar fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Thẻ Đơn hàng -->
        <div class="col-md-3">
            <div class="card bg-success text-white h-100 border-0 shadow-sm">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase mb-1">Đơn hàng</h6>
                            <h4 class="mb-0 fw-bold">${totalOrders}</h4>
                        </div>
                        <i class="bi bi-receipt fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Thẻ Người dùng -->
        <div class="col-md-3">
            <div class="card bg-warning text-dark h-100 border-0 shadow-sm">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase mb-1">Người dùng</h6>
                            <h4 class="mb-0 fw-bold">${totalUsers}</h4>
                        </div>
                        <i class="bi bi-people fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Thẻ Cửa hàng -->
        <div class="col-md-3">
            <div class="card bg-info text-white h-100 border-0 shadow-sm">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-uppercase mb-1">Cửa hàng</h6>
                            <h4 class="mb-0 fw-bold">${totalShops}</h4>
                        </div>
                        <i class="bi bi-shop fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Biểu đồ -->
    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <h5 class="fw-bold mb-3"><i class="bi bi-graph-up me-2"></i>Biểu đồ doanh thu (Demo)</h5>
            <canvas id="revenueChart" style="max-height: 400px;"></canvas>
        </div>
    </div>

    <!-- Script vẽ biểu đồ -->
    <script>
        const ctx = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6'],
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: [5000000, 8000000, 6000000, 12000000, 9000000, 15000000],
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' }
                }
            }
        });
    </script>
</body>
</html>