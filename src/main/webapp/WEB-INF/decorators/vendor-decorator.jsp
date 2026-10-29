<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendor Dashboard - UTETra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="${pageContext.request.contextPath}/css/management-ui.css" rel="stylesheet">
</head>
<body class="management-site management-vendor" data-management-role="vendor">
    <a class="management-skip" href="#management-main">Đến nội dung chính</a>
    <nav class="navbar navbar-expand-lg top-navbar fixed-top" aria-label="Thanh công cụ Vendor">
        <div class="management-header-brand">
            <button class="management-menu-toggle" type="button" data-bs-toggle="offcanvas" data-bs-target="#management-sidebar" aria-controls="management-sidebar" aria-label="Mở menu quản lý"><i class="bi bi-list" aria-hidden="true"></i></button>
            <a class="navbar-brand management-brand" href="${pageContext.request.contextPath}/vendor/my-shops"><span class="management-brand-icon"><i class="bi bi-cup-hot" aria-hidden="true"></i></span><span>UTETra<small>TEA · COFFEE · LITTLE JOYS</small></span></a>
            <span class="management-role">Vendor</span>
        </div>
        <div class="management-header-trail"><span>WORKSPACE</span><p class="management-current-section">KHÔNG GIAN CỬA HÀNG</p></div>
        <div class="management-header-actions ms-auto d-flex align-items-center">
            <a class="management-storefront-link" href="${pageContext.request.contextPath}/">Xem website <i class="bi bi-arrow-up-right" aria-hidden="true"></i></a>
            <div class="dropdown">
                <a href="#" class="nav-link dropdown-toggle management-user-menu d-flex align-items-center gap-2" data-bs-toggle="dropdown" aria-label="Mở menu tài khoản Chủ Cửa Hàng" aria-expanded="false"><span class="management-user-icon"><i class="bi bi-person" aria-hidden="true"></i></span><span class="management-user-label">Chủ Cửa Hàng</span></a>
                <ul class="dropdown-menu dropdown-menu-end shadow"><li><a class="dropdown-item" href="#"><i class="bi bi-person me-2"></i> Hồ sơ</a></li><li><hr class="dropdown-divider"></li><li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth/login"><i class="bi bi-box-arrow-right me-2"></i> Đăng xuất</a></li></ul>
            </div>
        </div>
    </nav>
    <aside class="sidebar offcanvas-lg offcanvas-start" id="management-sidebar" tabindex="-1" aria-labelledby="management-sidebar-title" data-context="${pageContext.request.contextPath}">
        <div class="offcanvas-header"><p class="management-mobile-title" id="management-sidebar-title">UTETra <span>Vendor</span></p><button type="button" class="btn-close" data-bs-dismiss="offcanvas" data-bs-target="#management-sidebar" aria-label="Đóng menu"></button></div>
        <div class="offcanvas-body">
            <p class="management-sidebar-kicker">KHÔNG GIAN CỬA HÀNG</p>
            <ul class="nav flex-column" aria-label="Điều hướng Vendor">
                <li class="sidebar-heading" role="presentation">Quản lý Cửa hàng</li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/my-shops"><i class="bi bi-grid" aria-hidden="true"></i><span>Danh sách Shop</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/wallet"><i class="bi bi-wallet2" aria-hidden="true"></i><span>Ví & Rút tiền</span></a></li>
<li class="sidebar-heading" role="presentation">Kinh doanh</li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/products"><i class="bi bi-box-seam" aria-hidden="true"></i><span>Quản lý Sản phẩm</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/orders"><i class="bi bi-receipt" aria-hidden="true"></i><span>Quản lý Đơn hàng</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/vouchers"><i class="bi bi-ticket-perforated" aria-hidden="true"></i><span>Quản lý Voucher</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/promotions"><i class="bi bi-tags" aria-hidden="true"></i><span>Khuyến mãi</span></a></li>
            </ul>
            <div class="management-sidebar-note"><span aria-hidden="true">✳</span><p>Chăm chút từng món ngon.<br>Thêm vui cho mỗi cuộc hẹn.</p><small>THE LITTLE JOYS, EVERY DAY</small></div>
        </div>
    </aside>
    <main id="management-main" class="main-content">
        <div class="management-page-meta"><p>VENDOR · UTETRA WORKSPACE</p><span>Mỗi ngày, thêm một chút chăm chút.</span></div>
        <div class="container-fluid">
            <sitemesh:write property='body'/>
        </div>
        <footer class="management-footer"><span>© 2026 UTETra · Trà sữa ngon mỗi ngày</span><a href="${pageContext.request.contextPath}/">Về website <span aria-hidden="true">↗</span></a></footer>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/management-ui.js" defer></script>
</body>
</html>
