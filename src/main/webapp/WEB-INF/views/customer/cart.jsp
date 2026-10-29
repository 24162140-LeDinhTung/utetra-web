<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi"><head><title>Giỏ hàng · UTETra</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/commerce.css?v=20261029-2"></head>
<body>
<div class="customer-page-intro customer-page-intro--compact">
    <p class="customer-eyebrow">MỘT CHÚT NGỌT NGÀO CHO HÔM NAY</p>
    <p class="customer-page-note">Những món bạn chọn, sẵn sàng cho một cuộc hẹn thật ngon.</p>
</div>
<nav class="customer-flow" aria-label="Các bước đặt hàng">
    <ol><li class="customer-flow-current" aria-current="step"><span class="customer-flow-number" aria-hidden="true">01</span><span>Giỏ hàng</span></li><li><span class="customer-flow-number" aria-hidden="true">02</span><span>Thông tin đặt hàng</span></li><li><span class="customer-flow-number" aria-hidden="true">03</span><span>Thanh toán</span></li></ol>
</nav>
<div class="customer-commerce" id="commerce" data-page="cart" data-context="${pageContext.request.contextPath}">
<div id="notice" role="status" aria-live="polite"></div>
<div id="commerce-content"><p>Đang tải dữ liệu…</p></div></div>
<script src="${pageContext.request.contextPath}/js/commerce.js?v=20261029-4" defer></script>
</body></html>
