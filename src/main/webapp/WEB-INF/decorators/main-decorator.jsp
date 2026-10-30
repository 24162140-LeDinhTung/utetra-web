<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>UTETra</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <sitemesh:write property='head'/>
    <link href="${pageContext.request.contextPath}/css/customer-ui.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/customer-pages.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/product-images.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/part-b-demo.svg">
    <link href="${pageContext.request.contextPath}/css/account.css" rel="stylesheet">
</head>
<body class="customer-site d-flex flex-column min-vh-100">
    <a href="#main-content" class="customer-skip-link">Đến nội dung chính</a>
    <div class="customer-announcement"><span><i class="fa-solid fa-leaf" aria-hidden="true"></i> Một chút trà, thêm chút vui.</span><a href="${pageContext.request.contextPath}/products">Khám phá thực đơn ↗</a></div>

    <!-- HEADER -->
    <nav class="navbar navbar-expand-lg customer-navbar" aria-label="Điều hướng chính">
        <div class="container">
            <a class="navbar-brand customer-brand" href="${pageContext.request.contextPath}/"><span class="customer-brand-icon" aria-hidden="true"><i class="fa-solid fa-mug-hot"></i></span><span>UTETra<small>TEA · COFFEE · LITTLE JOYS</small></span></a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#customer-navigation" aria-controls="customer-navigation" aria-expanded="false" aria-label="Mở menu"><i class="fa-solid fa-bars" aria-hidden="true"></i></button>
            <div class="collapse navbar-collapse gap-3" id="customer-navigation">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/">Trang chủ</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/products">Thực đơn</a></li>
                    <c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/customer/cart">Giỏ hàng</a></li></c:if>
                    <c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/customer/orders">Đơn hàng</a></li></c:if>
                    <c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/customer/favorites">Yêu thích</a></li></c:if>
                </ul>
                <!-- Vùng chứa các nút Đăng nhập / Tài khoản -->
                <div class="d-flex" id="auth-buttons">
                    <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline-warning me-2">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-warning text-dark fw-bold">Đăng ký</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- MAIN CONTENT -->
    <main id="main-content" class="container customer-main flex-grow-1">
        <sitemesh:write property='body'/>
    </main>

    <!-- FOOTER -->
    <footer class="customer-footer mt-auto">
        <div class="container customer-footer-top">
            <div><a class="customer-brand" href="${pageContext.request.contextPath}/">UTETra<span class="customer-footer-leaf" aria-hidden="true">✳</span></a><p>Chọn vị bạn thích.<br>Thêm vui cho ngày của bạn.</p></div>
            <div><p class="customer-footer-label">KHÁM PHÁ</p><a href="${pageContext.request.contextPath}/">Cửa hàng</a><a href="${pageContext.request.contextPath}/products">Thực đơn đồ uống</a><c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/customer/favorites">Món yêu thích</a></c:if></div>
            <div><p class="customer-footer-label">GÓC CỦA BẠN</p><c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/customer/orders">Đơn hàng của bạn</a></c:if><c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/customer/profile">Tài khoản</a></c:if><c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/customer/history">Đã xem gần đây</a></c:if></div>
            <div class="customer-footer-message"><i class="fa-solid fa-mug-hot" aria-hidden="true"></i><p>Một ngày đẹp hơn,<br>bắt đầu từ một ly trà.</p></div>
        </div>
        <div class="container customer-footer-bottom"><p class="mb-0">© 2026 UTETra · Trà sữa ngon mỗi ngày</p><div><c:if test="${pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/vendor/products">Người bán</a></c:if><c:if test="${pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/admin/categories">Quản trị</a></c:if><a href="#main-content">Lên đầu trang ↑</a></div></div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- SCRIPT XỬ LÝ ĐỔI NÚT KHI ĐÃ ĐĂNG NHẬP -->
    <script>
      (() => {
        // Kiểm tra xem có token trong localStorage không
        let token = localStorage.getItem('accessToken');
        const contextPath = '${pageContext.request.contextPath}';
        // localStorage survives browser restarts; the session cookie does not.
        // Expiry here only controls navigation. The server still verifies the signature.
        if (token) {
            try {
                const payload = JSON.parse(atob(token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')));
                if (!payload.exp || payload.exp * 1000 <= Date.now()) throw new Error('expired');
                document.cookie = 'accessToken=' + encodeURIComponent(token) + '; path=/; SameSite=Lax' + (location.protocol === 'https:' ? '; Secure' : '');
            } catch (e) {
                clearLogin();
                token = null;
            }
        }

        if (token) {
            // Nếu có token, hiện menu tài khoản; module dùng chung tải tên và avatar
            document.getElementById('auth-buttons').innerHTML = `
                <div data-account-menu data-vendor="${pageContext.request.isUserInRole('ROLE_VENDOR')}" data-admin="${pageContext.request.isUserInRole('ROLE_ADMIN')}"><a href="${pageContext.request.contextPath}/customer/profile">Thông tin tài khoản</a></div>
            `;
        }

        function clearLogin() {
            // Xóa token và chuyển về trang chủ
            localStorage.removeItem('accessToken');
            localStorage.removeItem('userRole');
            localStorage.removeItem('userRoles');
            localStorage.removeItem('refreshToken');
            document.cookie = 'accessToken=; Max-Age=0; path=/; SameSite=Lax';
        }
        window.logout = function () {
            clearLogin();
            window.location.href = contextPath + '/';
        };
      })();
    </script>
    <sitemesh:write property='script'/>
    <script src="${pageContext.request.contextPath}/js/customer-ui.js" defer></script>
    <script src="${pageContext.request.contextPath}/js/product-images.js" defer></script>
    <script src="${pageContext.request.contextPath}/js/account-menu.js?v=20261029-2" data-context="${pageContext.request.contextPath}" defer></script>
</body>
</html>
