package com.utetra.service;

import com.utetra.dto.request.order.CreateOrderRequest;
import com.utetra.dto.response.cart.CartResponse;
import com.utetra.entity.Voucher;
import com.utetra.enums.VoucherType;
import com.utetra.repository.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrderQuoteService {
  private final CartService carts;
  private final ProductRepository products;
  private final VoucherRepository vouchers;
  private final VoucherUsageRepository usages;
  private final PaymentAvailability paymentAvailability;

  @Value("${commerce.shipping-fee:15000}")
  private BigDecimal shippingFee;

  public record Quote(
      BigDecimal subtotal,
      BigDecimal discountAmount,
      BigDecimal shippingFee,
      BigDecimal totalAmount) {}


  public record Offer(String code, String type, String discountType, BigDecimal value,
      BigDecimal minimum, BigDecimal maximum, java.time.LocalDateTime endsAt, boolean eligible) {}

  public java.util.List<Offer> offers(Long user, Long shop) {
    return offers(user, shop, null);
  }

  public java.util.List<Offer> offers(Long user, Long shop, java.util.List<Long> cartItemIds) {
    var now = LocalDateTime.now();
    return vouchers.findByShopIdAndIsDeletedFalseOrderByIdDesc(shop).stream()
        .filter(v -> !now.isBefore(v.getStartDate()) && now.isBefore(v.getEndDate()))
        .filter(v -> v.getUsageLimit() == null || v.getUsedCount() < v.getUsageLimit())
        .filter(v -> usages.countByVoucherIdAndUserId(v.getId(), user) == 0)
        .map(v -> {
          var request = new CreateOrderRequest();
          request.setShopId(shop); request.setPaymentMethod(com.utetra.enums.PaymentMethod.COD);
          request.setVoucherCode(v.getCode());
          request.setCartItemIds(cartItemIds);
          boolean eligible;
          try { quote(user, request); eligible = true; }
          catch (IllegalArgumentException e) { eligible = false; }
          return new Offer(v.getCode(), v.getVoucherType().name(), v.getDiscountType().name(),
              v.getDiscountValue(), v.getMinOrderAmount(), v.getMaxDiscountAmount(), v.getEndDate(), eligible);
        }).toList();
  }

  public Quote quote(Long user, CreateOrderRequest r) {
    paymentAvailability.requireAvailable(r.getPaymentMethod());
    CartResponse c =
        carts.getCart(user).stream()
            .filter(x -> x.getShopId().equals(r.getShopId()))
            .findFirst()
            .orElseThrow(() -> new IllegalArgumentException("Giỏ hàng trống"));
    var selected = CartSelection.select(c.getItems(), r.getCartItemIds(), CartResponse.Item::getCartItemId);
    if (selected.isEmpty()) throw new IllegalArgumentException("Giỏ hàng trống");
    BigDecimal subtotal = selected.stream().map(CartResponse.Item::getLineTotal)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
    if (selected.stream().anyMatch(i -> i.getUnavailableReason() != null))
      throw new IllegalArgumentException(
          "Giỏ hàng có món không còn hợp lệ. Hãy cập nhật hoặc xóa món trước.");
    var quantities = new java.util.HashMap<Long, Integer>();
    selected.forEach(i -> quantities.merge(i.getProductId(), i.getQuantity(), Math::addExact));
    quantities.forEach((id, quantity) -> {
      if (products.findById(id).orElseThrow().getStock() < quantity)
        throw new IllegalArgumentException("Không đủ tồn kho cho các món đã chọn");
    });
    BigDecimal discount = BigDecimal.ZERO;
    if (shippingFee.signum() < 0)
      throw new IllegalStateException("Phí giao hàng cấu hình không hợp lệ");
    BigDecimal shipping = shippingFee;
    if (r.getVoucherCode() != null && !r.getVoucherCode().isBlank()) {
      Voucher v =
          vouchers
              .findByCode(r.getVoucherCode().trim().toUpperCase(Locale.ROOT))
              .filter(x -> !Boolean.TRUE.equals(x.getIsDeleted()))
              .orElseThrow(() -> new IllegalArgumentException("Mã giảm giá không tồn tại"));
      LocalDateTime now = LocalDateTime.now();
      if (v.getShop() != null && !v.getShop().getId().equals(r.getShopId())
          || now.isBefore(v.getStartDate())
          || !now.isBefore(v.getEndDate())
          || subtotal.compareTo(v.getMinOrderAmount()) < 0
          || v.getUsageLimit() != null && v.getUsedCount() >= v.getUsageLimit()
          || usages.countByVoucherIdAndUserId(v.getId(), user) > 0)
        throw new IllegalArgumentException("Mã giảm giá không đủ điều kiện");
      if (v.getVoucherType() == VoucherType.SHIPPING)
        shipping =
            shipping.subtract(
                ProductPricing.discount(
                    shipping, v.getDiscountType(), v.getDiscountValue(), v.getMaxDiscountAmount()));
      else
        discount =
            ProductPricing.discount(
                subtotal,
                v.getDiscountType(),
                v.getDiscountValue(),
                v.getMaxDiscountAmount());
    }
    return new Quote(
        subtotal, discount, shipping, subtotal.subtract(discount).add(shipping));
  }
}
