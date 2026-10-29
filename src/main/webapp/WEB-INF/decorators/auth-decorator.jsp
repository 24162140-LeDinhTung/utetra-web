<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>UTETra</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <sitemesh:write property='head'/>
    <link href="${pageContext.request.contextPath}/css/auth-ui.css" rel="stylesheet">
</head>
<body class="auth-site bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <header class="auth-site-header">
        <div class="auth-announcement"><span><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M20 4C10 3 3 8 6 15c7 4 14-2 14-11Z" fill="currentColor"/><path d="m4 20 11-11" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg> Một chút trà, thêm chút vui.</span><span>YOUR LITTLE TEA CORNER</span></div>
        <div class="auth-header-inner"><a href="/" class="auth-brand" aria-label="UTETra — Trang chủ"><span class="auth-brand-icon"><svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5 9h12v7a5 5 0 0 1-5 5h-2a5 5 0 0 1-5-5V9Z" fill="currentColor"/><path d="M17 10h2a3 3 0 1 1 0 6h-2M9 3c-2 2 2 2 0 4m4-5c-2 2 2 2 0 4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg></span><span>UTETra<small>TEA · COFFEE · LITTLE JOYS</small></span></a><a href="/" class="auth-home-link"><span aria-hidden="true">←</span> Về trang chủ</a></div>
    </header>
    <main id="auth-main" class="container auth-container">
        <sitemesh:write property='body'/>
    </main>
    <footer class="auth-site-footer"><span>© 2026 UTETra · Trà sữa ngon mỗi ngày</span><span>Chọn vị bạn thích. Thêm vui cho ngày của bạn. <b aria-hidden="true">✳</b></span></footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <sitemesh:write property='script'/>
</body>
</html>
