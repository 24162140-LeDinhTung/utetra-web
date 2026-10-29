<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi"><head><title>Chi tiết đơn hàng · UTETra</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/commerce.css"></head>
<body>
<div class="customer-page-intro customer-page-intro--compact">
    <p class="customer-eyebrow">TỪ CỬA HÀNG ĐẾN TAY BẠN</p>
    <p class="customer-page-note">Thông tin món, thanh toán và hành trình đơn hàng ở cùng một nơi.</p>
</div>
<div class="customer-commerce" id="commerce" data-page="customer-order" data-context="${pageContext.request.contextPath}">
<div id="notice" role="status" aria-live="polite"></div>
<div id="commerce-content"><p>Đang tải dữ liệu…</p></div></div>
<script src="${pageContext.request.contextPath}/js/commerce.js" defer></script>
</body></html>
