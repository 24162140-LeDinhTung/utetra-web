<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi"><head><title>UTETra · Cửa hàng trà sữa</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/commerce.css"></head>
<body>
<section class="customer-menu-intro"><div><p class="customer-eyebrow">THE MENU · CHỌN VỊ BẠN YÊU</p><p class="customer-menu-tagline">Một ly ngon.<br>Một ngày <em>vui.</em></p><p>Tìm món hợp gu, từ cửa hàng bạn thích.</p></div><div class="customer-menu-stamp" aria-hidden="true"><i class="fa-solid fa-mug-hot"></i><span>GOOD SIPS.<br>GOOD MOODS.</span><b>✳</b></div></section>
<div id="commerce" data-page="products" data-context="${pageContext.request.contextPath}">
<div id="notice" role="status" aria-live="polite"></div>
<div id="commerce-content"><p>Đang tải dữ liệu…</p></div></div>
<script src="${pageContext.request.contextPath}/js/commerce.js" defer></script>
</body></html>
