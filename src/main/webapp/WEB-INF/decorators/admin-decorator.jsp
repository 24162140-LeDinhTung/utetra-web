<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - UTETra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <link href="${pageContext.request.contextPath}/css/management-ui.css" rel="stylesheet">
    <sitemesh:write property='head'/>
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/part-b-demo.svg">
    <link href="${pageContext.request.contextPath}/css/account.css" rel="stylesheet">
</head>
<body class="management-site management-admin" data-management-role="admin">
    <a class="management-skip" href="#management-main">Đến nội dung chính</a>
    <nav class="navbar navbar-expand-lg top-navbar fixed-top" aria-label="Thanh công cụ Admin">
        <div class="management-header-brand">
            <button class="management-menu-toggle" type="button" data-bs-toggle="offcanvas" data-bs-target="#management-sidebar" aria-controls="management-sidebar" aria-label="Mở menu quản lý"><i class="bi bi-list" aria-hidden="true"></i></button>
            <a class="navbar-brand management-brand" href="${pageContext.request.contextPath}/admin/dashboard"><span class="management-brand-icon"><i class="bi bi-cup-hot" aria-hidden="true"></i></span><span>UTETra<small>TEA · COFFEE · LITTLE JOYS</small></span></a>
            <span class="management-role">Admin</span>
        </div>
        <div class="management-header-trail"><span>WORKSPACE</span><p class="management-current-section">KHÔNG GIAN QUẢN TRỊ</p></div>
        <div class="management-header-actions ms-auto d-flex align-items-center">
            <a class="management-storefront-link" href="${pageContext.request.contextPath}/">Xem website <i class="bi bi-arrow-up-right" aria-hidden="true"></i></a>
            <div data-account-menu><a href="${pageContext.request.contextPath}/customer/profile">Thông tin tài khoản</a></div>
        </div>
    </nav>
    <aside class="sidebar offcanvas-lg offcanvas-start" id="management-sidebar" tabindex="-1" aria-labelledby="management-sidebar-title" data-context="${pageContext.request.contextPath}">
        <div class="offcanvas-header"><p class="management-mobile-title" id="management-sidebar-title">UTETra <span>Admin</span></p><button type="button" class="btn-close" data-bs-dismiss="offcanvas" data-bs-target="#management-sidebar" aria-label="Đóng menu"></button></div>
        <div class="offcanvas-body">
            <p class="management-sidebar-kicker">KHÔNG GIAN QUẢN TRỊ</p>
            <ul class="nav flex-column" aria-label="Điều hướng Admin">
                <li class="sidebar-heading" role="presentation">Tổng quan</li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard"><i class="bi bi-speedometer2" aria-hidden="true"></i><span>Dashboard</span></a></li>
<li class="sidebar-heading" role="presentation">Quản lý hệ thống</li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/shops"><i class="bi bi-shop" aria-hidden="true"></i><span>Duyệt Cửa hàng</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/withdraw"><i class="bi bi-cash-coin" aria-hidden="true"></i><span>Duyệt Rút tiền</span></a></li>
<li class="sidebar-heading" role="presentation">Người dùng & Sản phẩm</li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/users"><i class="bi bi-people" aria-hidden="true"></i><span>Quản lý User</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/products"><i class="bi bi-box-seam" aria-hidden="true"></i><span>Quản lý Sản phẩm</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/categories"><i class="bi bi-tags" aria-hidden="true"></i><span>Quản lý Danh mục</span></a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/attributes"><i class="bi bi-sliders" aria-hidden="true"></i><span>Thuộc tính sản phẩm</span></a></li>
            </ul>
            <div class="management-sidebar-note"><span aria-hidden="true">✳</span><p>Chăm chút từng trải nghiệm.<br>Cùng UTETra, mỗi ngày.</p><small>THE LITTLE JOYS, EVERY DAY</small></div>
        </div>
    </aside>
    <main id="management-main" class="main-content">
        <div class="management-page-meta"><p>ADMIN · UTETRA WORKSPACE</p><span>Mỗi ngày, thêm một chút chăm chút.</span></div>
        <div class="container-fluid">
            <sitemesh:write property='body'/>
        </div>
        <footer class="management-footer"><span>© 2026 UTETra · Trà sữa ngon mỗi ngày</span><a href="${pageContext.request.contextPath}/">Về website <span aria-hidden="true">↗</span></a></footer>
    </main>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/management-ui.js" defer></script>
    <script src="${pageContext.request.contextPath}/js/account-menu.js" data-context="${pageContext.request.contextPath}" defer></script>
</body>
</html>
