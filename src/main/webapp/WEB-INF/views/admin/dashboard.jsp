<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<h3 class="fw-bold text-dark mb-4">Tổng quan Hệ thống</h3>

<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="card bg-primary text-white h-100 border-0 shadow-sm rounded-3 p-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h6 class="text-uppercase mb-1 opacity-75">Doanh thu thực tế</h6>
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

<!-- PHẦN BIỂU ĐỒ DOANH THU -->
<div class="card border-0 shadow-sm rounded-3">
    <div class="card-body p-4">
        <h5 class="fw-bold mb-4"><i class="bi bi-bar-chart-fill text-primary me-2"></i>Biểu đồ doanh thu năm <span id="currentYear"></span></h5>
        
        <div style="position: relative; height: 350px; width: 100%;">
            <canvas id="revenueChart"></canvas>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Hiển thị năm hiện tại lên tiêu đề
        document.getElementById('currentYear').innerText = new Date().getFullYear();

        // Lấy dữ liệu 12 tháng từ Controller
        const labels = [
            <c:forEach items="${chartLabels}" var="label" varStatus="loop">
                "${label}"<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];
        
        const dataValues = [
            <c:forEach items="${chartData}" var="data" varStatus="loop">
                ${data}<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        const ctx = document.getElementById('revenueChart').getContext('2d');

        new Chart(ctx, {
            type: 'bar', // Đổi sang dạng cột cho 12 tháng dễ nhìn
            data: {
                labels: labels,
                datasets: [{
                    label: 'Doanh thu (VNĐ)',
                    data: dataValues,
                    backgroundColor: '#0d6efd', // Màu xanh dương
                    borderRadius: 5, // Bo góc cột
                    barPercentage: 0.6 // Độ rộng của cột
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let value = context.parsed.y;
                                return ' Doanh thu: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                if(value >= 1000000) return (value / 1000000) + 'Tr';
                                if(value >= 1000) return (value / 1000) + 'K';
                                return value;
                            }
                        },
                        grid: { borderDash: [5, 5] }
                    },
                    x: {
                        grid: { display: false }
                    }
                }
            }
        });
    });
</script>