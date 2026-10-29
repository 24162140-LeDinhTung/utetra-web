<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi"><head><title>Thông tin đặt hàng · UTETra</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/commerce.css"></head>
<body>
<div class="customer-page-intro customer-page-intro--compact">
    <p class="customer-eyebrow">GẦN HƠN MỘT LY NGON</p>
    <p class="customer-page-note">Kiểm tra món, điền địa chỉ và chọn cách thanh toán phù hợp với bạn.</p>
</div>
<nav class="customer-flow" aria-label="Các bước đặt hàng">
    <ol><li><span class="customer-flow-number" aria-hidden="true">01</span><span>Giỏ hàng</span></li><li class="customer-flow-current" aria-current="step"><span class="customer-flow-number" aria-hidden="true">02</span><span>Thông tin đặt hàng</span></li><li><span class="customer-flow-number" aria-hidden="true">03</span><span>Thanh toán</span></li></ol>
</nav>
<div class="customer-commerce" id="commerce" data-page="checkout" data-context="${pageContext.request.contextPath}">
<div id="notice" role="status" aria-live="polite"></div>
<div id="commerce-content"><p>Đang tải dữ liệu…</p></div></div>
<script src="${pageContext.request.contextPath}/js/commerce.js" defer></script>
</body></html>
