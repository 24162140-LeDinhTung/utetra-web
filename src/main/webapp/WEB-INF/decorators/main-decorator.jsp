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
</head>
<body class="d-flex flex-column min-vh-100 bg-light">

    <!-- HEADER -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand text-warning fw-bold" href="${pageContext.request.contextPath}/">☕ UTETra</a>
            <div class="navbar-collapse d-flex flex-wrap gap-3">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/">Trang chủ</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/products">Sản phẩm</a></li>
<c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}">                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/customer/cart">Giỏ hàng</a></li></c:if>
<c:if test="${pageContext.request.isUserInRole('ROLE_CUSTOMER') or pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}">                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/customer/orders">Đơn hàng</a></li></c:if>
<c:if test="${pageContext.request.isUserInRole('ROLE_VENDOR') or pageContext.request.isUserInRole('ROLE_ADMIN')}">                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/vendor/products">Người bán</a></li></c:if>
<c:if test="${pageContext.request.isUserInRole('ROLE_ADMIN')}">                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/categories">Quản trị</a></li></c:if>
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
    <main class="container my-5 flex-grow-1">
        <sitemesh:write property='body'/>
    </main>

    <!-- FOOTER -->
    <footer class="bg-dark text-white text-center py-3 mt-auto">
        <p class="mb-0">© 2026 UTETra - Trà sữa ngon mỗi ngày</p>
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
            // Nếu có token, đổi nút Đăng nhập/Đăng ký thành nút Tài khoản/Đăng xuất
            document.getElementById('auth-buttons').innerHTML = `
                <a href="${pageContext.request.contextPath}/customer/profile" class="btn btn-outline-light me-2">Tài khoản</a>
                <button onclick="logout()" class="btn btn-danger fw-bold">Đăng xuất</button>
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
</body>
</html>
