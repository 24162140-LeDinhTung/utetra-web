<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi"><head><title>Đơn hàng của bạn · UTETra</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/commerce.css"></head>
<body>
<div class="customer-page-intro customer-page-intro--compact">
    <p class="customer-eyebrow">NHỮNG CUỘC HẸN VỚI VỊ NGON</p>
    <p class="customer-page-note">Xem lại các món đã chọn và theo dõi từng đơn hàng của bạn.</p>
</div>
<div class="customer-commerce" id="commerce" data-page="customer-orders" data-context="${pageContext.request.contextPath}">
<div id="notice" role="status" aria-live="polite"></div>
<div id="commerce-content"><p>Đang tải dữ liệu…</p></div></div>
<script src="${pageContext.request.contextPath}/js/commerce.js" defer></script>
</body></html>
