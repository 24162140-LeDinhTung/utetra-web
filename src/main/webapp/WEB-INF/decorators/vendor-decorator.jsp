<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Vendor Dashboard - UTETra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; overflow-x: hidden; }
        
        /* Navbar */
        .top-navbar { height: 60px; background-color: #0f172a; box-shadow: 0 2px 10px rgba(0,0,0,0.1); z-index: 1000; }
        .top-navbar .navbar-brand { color: #fff; font-weight: 600; font-size: 1.2rem; }
        .top-navbar .nav-link { color: #94a3b8; }
        .top-navbar .nav-link:hover { color: #fff; }

        /* Sidebar */
        .sidebar { width: 250px; background-color: #fff; min-height: calc(100vh - 60px); position: fixed; left: 0; top: 60px; border-right: 1px solid #e2e8f0; }
        .sidebar .nav-link { color: #475569; padding: 12px 20px; font-weight: 500; display: flex; align-items: center; gap: 10px; border-left: 3px solid transparent; transition: 0.2s; }
        .sidebar .nav-link:hover { color: #0f172a; background-color: #f1f5f9; border-left-color: #3b82f6; }
        .sidebar .nav-link.active { color: #0f172a; background-color: #f1f5f9; border-left-color: #3b82f6; }
        .sidebar-heading { color: #94a3b8; font-size: 0.75rem; text-transform: uppercase; font-weight: 600; letter-spacing: 1px; padding: 15px 20px 5px 20px; }

        /* Main Content */
        .main-content { margin-left: 250px; padding: 30px; min-height: calc(100vh - 60px); }
        
        /* Cards */
        .card { border: none; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); transition: 0.3s; }
    </style>
</head>
<body>

    <!-- Navbar trên cùng -->
    <nav class="navbar navbar-expand-lg top-navbar fixed-top px-4">
        <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/vendor/shops">
            <i class="bi bi-shop-window text-primary"></i> UTETra <span class="text-primary">Vendor</span>
        </a>
        <div class="ms-auto d-flex align-items-center">
            <div class="dropdown">
                <a href="#" class="nav-link dropdown-toggle text-white d-flex align-items-center gap-2" data-bs-toggle="dropdown">
                    <i class="bi bi-person-circle fs-5"></i> Chủ Cửa Hàng
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow">
                    <li><a class="dropdown-item" href="#"><i class="bi bi-person me-2"></i> Hồ sơ</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/login"><i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Sidebar bên trái -->
    <div class="sidebar pt-3">
        <ul class="nav flex-column">
            <span class="sidebar-heading">Quản lý Cửa hàng</span>
            <li class="nav-item">
                <a class="nav-link" href="${pageContext.request.contextPath}/vendor/shops">
                    <i class="bi bi-grid"></i> Danh sách Shop
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="${pageContext.request.contextPath}/vendor/withdraw">
                    <i class="bi bi-wallet2"></i> Ví & Rút tiền
                </a>
            </li>
            
            <span class="sidebar-heading">Kinh doanh</span>
            <li class="nav-item">
                <a class="nav-link" href="#">
                    <i class="bi bi-box-seam"></i> Quản lý Sản phẩm
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#">
                    <i class="bi bi-receipt"></i> Quản lý Đơn hàng
                </a>
            </li>
        </ul>
    </div>

    <!-- Nội dung chính -->
    <div class="main-content">
        <div class="container-fluid">
            <!-- Sitemesh 3 tự động nhúng body -->
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>