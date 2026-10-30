<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head><title>UTETra · Một chút trà, thêm chút vui</title></head>
<body>
    <section class="storefront-hero" aria-labelledby="storefront-title">
        <div class="storefront-hero-copy">
            <p class="customer-eyebrow"><span aria-hidden="true">✳</span> MỘT LY TRÀ. MỘT NIỀM VUI.</p>
            <h1 id="storefront-title">Chậm một nhịp.<br>Thưởng một <em>vị.</em></h1>
            <p class="storefront-hero-description">Trà sữa thân quen, matcha dịu êm hay cà phê đậm vị.<br>Hôm nay, bạn muốn chiều mình bằng món gì?</p>
            <div class="storefront-hero-actions"><a href="${pageContext.request.contextPath}/products" class="btn btn-success">Khám phá thực đơn <span aria-hidden="true">↗</span></a><a href="#storefront-shops" class="customer-text-link">Chọn cửa hàng <span aria-hidden="true">↓</span></a></div>
            <div class="storefront-hero-notes"><span><i class="fa-solid fa-leaf" aria-hidden="true"></i> Đa dạng hương vị</span><span><i class="fa-solid fa-mug-hot" aria-hidden="true"></i> Chọn theo gu bạn</span><span><i class="fa-solid fa-bag-shopping" aria-hidden="true"></i> Đặt món dễ dàng</span></div>
        </div>
        <div class="storefront-hero-art"><img src="${pageContext.request.contextPath}/images/storefront-tea-hero.png" alt="Matcha latte và trà sữa trân châu trong ánh nắng dịu" width="1536" height="1024" fetchpriority="high"><span class="storefront-hero-seal" aria-hidden="true">tea time<br><strong>good time.</strong><span>✳</span></span><div class="storefront-art-caption"><span>THE LITTLE JOYS, EVERY DAY</span><span>01 / TEA &amp; COFFEE</span></div></div>
    </section>
    <div class="storefront-ticker" aria-hidden="true"><span>TRÀ SỮA</span><i>✳</i><span>MATCHA</span><i>✳</i><span>CÀ PHÊ</span><i>✳</i><span>THÊM MỘT CHÚT VUI</span><i>✳</i><span>UTETRA</span></div>
    <section id="storefront-shops" class="storefront-shops" aria-labelledby="storefront-shops-title">
        <div class="storefront-section-heading"><div><p class="customer-eyebrow">GHÉ MỘT CHÚT, CHỌN MỘT LY</p><h2 id="storefront-shops-title">Mỗi cửa hàng,<br>một <em>gu riêng.</em></h2></div><p>Chọn cửa hàng bạn thích.<br>Thực đơn riêng đang chờ bạn khám phá.</p></div>
        <div class="storefront-shop-grid">
            <c:forEach items="${shops}" var="shop" varStatus="loop">
                <article class="storefront-shop-card" data-reveal>
                    <div class="storefront-shop-art" aria-hidden="true"><span class="storefront-shop-number">0${loop.index + 1}</span><i class="fa-solid fa-store"></i><span class="storefront-shop-art-label">YOUR NEXT TEA STOP</span><span class="storefront-shop-flower">✳</span></div>
                    <div class="storefront-shop-info"><p class="customer-eyebrow">UTETRA · CỬA HÀNG</p><h3><c:out value="${shop.name}"/></h3><p class="storefront-shop-address"><i class="fa-solid fa-location-dot" aria-hidden="true"></i> <c:out value="${shop.address}"/></p><div class="storefront-shop-bottom"><span class="storefront-shop-count"><i class="fa-solid fa-mug-hot" aria-hidden="true"></i> ${productCounts[shop.id]} món đang bán</span><a href="${pageContext.request.contextPath}/shops/${shop.id}" class="customer-circle-link" aria-label="Xem menu <c:out value='${shop.name}'/>"><span aria-hidden="true">↗</span></a></div><a href="${pageContext.request.contextPath}/shops/${shop.id}" class="storefront-shop-menu-link">Xem thực đơn cửa hàng <span aria-hidden="true">→</span></a></div>
                </article>
            </c:forEach>
        </div>
        <c:if test="${empty shops}"><div class="customer-empty"><i class="fa-solid fa-mug-hot" aria-hidden="true"></i><h3>Hẹn bạn một ly trà</h3><p>Các cửa hàng sẽ sớm có mặt tại đây.</p></div></c:if>
    </section>
    <section class="storefront-invitation" data-reveal><span class="storefront-invitation-symbol" aria-hidden="true">✳</span><div><p class="customer-eyebrow">A LITTLE SIP OF HAPPINESS</p><h2>Ngày của bạn,<br>vị của <em>bạn.</em></h2></div><div><p>Một mình thư giãn hay cùng bạn bè chuyện trò,<br>luôn có một món hợp với khoảnh khắc này.</p><a href="${pageContext.request.contextPath}/products" class="btn btn-light">Tìm món hợp gu <span aria-hidden="true">↗</span></a></div></section>
</body>
</html>
