package com.utetra.service.impl;

import com.utetra.dto.request.order.*;
import com.utetra.dto.response.order.*;
import com.utetra.entity.*;
import com.utetra.enums.*;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderServiceImpl implements OrderService {
  private final OrderRepository orders;
  private final PaymentTransactionRepository paymentTransactions;
  private final OrderItemRepository orderItems;
  private final OrderStatusHistoryRepository histories;
  private final CartRepository carts;
  private final CartItemRepository cartItems;
  private final UserRepository users;
  private final ProductRepository products;
  private final VoucherRepository vouchers;
  private final VoucherUsageRepository usages;
  private final CommerceAccess access;
  private final ProductPricing pricing;
  private final PaymentAvailability paymentAvailability;
  private final ApplicationEventPublisher events;
  private final OrderWalletSettlement settlement;

  @Value("${commerce.shipping-fee:15000}")
  private BigDecimal shippingFee;

  private Order order(Long id) {
    return orders
        .findById(id)
        .filter(o -> !Boolean.TRUE.equals(o.getIsDeleted()))
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn hàng"));
  }

  private Order lock(Long id) {
    return orders
        .lockById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn hàng"));
  }

  public OrderDetailResponse createOrder(Long userId, CreateOrderRequest r) {
    paymentAvailability.requireAvailable(r.getPaymentMethod());
    User user =
        users
            .lockById(userId)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người mua"));
    Cart cart =
        carts
            .findByUserIdAndShopId(userId, r.getShopId())
            .orElseThrow(() -> new IllegalArgumentException("Giỏ hàng cửa hàng này đang trống"));
    List<CartItem> lines = cartItems.findByCartId(cart.getId());
    if (lines.isEmpty()) throw new IllegalArgumentException("Giỏ hàng đang trống");
    // Lock products in a stable order and aggregate all variants before reserving stock.
    Map<Long, Integer> quantities = new TreeMap<>();
    for (CartItem i : lines) {
      if (i.getQuantity() < 1) throw new IllegalArgumentException("Số lượng không hợp lệ");
      quantities.merge(i.getProduct().getId(), i.getQuantity(), Math::addExact);
    }
    Map<Long, Product> locked = new HashMap<>();
    for (var e : quantities.entrySet()) {
      Product p =
          products
              .lockById(e.getKey())
              .orElseThrow(() -> new ResourceNotFoundException("Sản phẩm không tồn tại"));
      pricing.purchasable(p);
      if (!p.getShop().getId().equals(r.getShopId()))
        throw new IllegalArgumentException("Giỏ hàng chứa sản phẩm khác cửa hàng");
      if (p.getStock() < e.getValue())
        throw new IllegalArgumentException("Không đủ tồn kho: " + p.getName());
      locked.put(p.getId(), p);
    }
    BigDecimal subtotal = BigDecimal.ZERO;
    Map<Long, BigDecimal> prices = new HashMap<>();
    for (CartItem i : lines) {
      BigDecimal price =
          pricing.unitPrice(locked.get(i.getProduct().getId()), i.getSelectedAttributes());
      prices.put(i.getId(), price);
      subtotal = subtotal.add(price.multiply(BigDecimal.valueOf(i.getQuantity())));
    }
    BigDecimal productDiscount = BigDecimal.ZERO;
    if (shippingFee.signum() < 0)
      throw new IllegalStateException("Phí giao hàng cấu hình không hợp lệ");
    BigDecimal shipping = shippingFee;
    Voucher voucher = null;
    if (r.getVoucherCode() != null && !r.getVoucherCode().isBlank()) {
      voucher =
          vouchers
              .lockByCode(r.getVoucherCode().trim().toUpperCase(Locale.ROOT))
              .orElseThrow(() -> new IllegalArgumentException("Mã giảm giá không tồn tại"));
      LocalDateTime now = LocalDateTime.now();
      if (voucher.getShop() != null && !voucher.getShop().getId().equals(r.getShopId()))
        throw new IllegalArgumentException("Mã giảm giá thuộc cửa hàng khác");
      if (now.isBefore(voucher.getStartDate())
          || !now.isBefore(voucher.getEndDate())
          || subtotal.compareTo(voucher.getMinOrderAmount()) < 0
          || voucher.getUsageLimit() != null && voucher.getUsedCount() >= voucher.getUsageLimit()
          || usages.countByVoucherIdAndUserId(voucher.getId(), userId) > 0)
        throw new IllegalArgumentException("Mã giảm giá chưa đủ điều kiện hoặc đã hết lượt");
      if (voucher.getVoucherType() == VoucherType.SHIPPING)
        shipping =
            shipping.subtract(
                ProductPricing.discount(
                    shipping,
                    voucher.getDiscountType(),
                    voucher.getDiscountValue(),
                    voucher.getMaxDiscountAmount()));
      else
        productDiscount =
            ProductPricing.discount(
                subtotal,
                voucher.getDiscountType(),
                voucher.getDiscountValue(),
                voucher.getMaxDiscountAmount());
    }
    Order o = new Order();
    o.setOrderCode("UTE-" + UUID.randomUUID().toString().replace("-", ""));
    o.setUser(user);
    o.setShop(cart.getShop());
    o.setSubtotal(subtotal);
    o.setDiscountAmount(productDiscount);
    o.setShippingFee(shipping);
    o.setTotalAmount(subtotal.subtract(productDiscount).add(shipping));
    if (r.getExpectedTotalAmount() != null
        && r.getExpectedTotalAmount().compareTo(o.getTotalAmount()) != 0)
      throw new IllegalArgumentException(
          "Giá hoặc ưu đãi đã thay đổi. Vui lòng xem lại tổng tiền trước khi đặt hàng");
    o.setShippingAddress(r.getShippingAddress().trim());
    o.setPaymentMethod(r.getPaymentMethod());
    o.setPaymentStatus(
        o.getTotalAmount().signum() == 0 ? PaymentStatus.SUCCESS : PaymentStatus.PENDING);
    o.setStatus(
        r.getPaymentMethod() == PaymentMethod.COD || o.getTotalAmount().signum() == 0
            ? OrderStatus.CONFIRMED
            : OrderStatus.NEW);
    orders.save(o);
    PaymentTransaction transaction = new PaymentTransaction();
    transaction.setOrder(o);
    transaction.setReference("UTE" + UUID.randomUUID().toString().replace("-", ""));
    transaction.setProvider(o.getPaymentMethod());
    transaction.setAmount(o.getTotalAmount());
    transaction.setStatus(o.getPaymentStatus());
    paymentTransactions.save(transaction);
    for (CartItem i : lines) {
      Product p = locked.get(i.getProduct().getId());
      OrderItem line = new OrderItem();
      line.setOrder(o);
      line.setProduct(p);
      line.setProductName(p.getName());
      line.setProductImage(pricing.image(p));
      line.setUnitPrice(prices.get(i.getId()));
      line.setQuantity(i.getQuantity());
      line.setSelectedAttributes(i.getSelectedAttributes());
      orderItems.save(line);
    }
    quantities.forEach(
        (id, qty) -> {
          Product p = locked.get(id);
          p.setStock(p.getStock() - qty);
          p.setSoldCount(Math.addExact(p.getSoldCount(), qty));
          products.save(p);
        });
    if (voucher != null) {
      voucher.setUsedCount(voucher.getUsedCount() + 1);
      events.publishEvent(new OfferEvents.Changed(r.getShopId()));
      vouchers.save(voucher);
      VoucherUsage usage = new VoucherUsage();
      usage.setVoucher(voucher);
      usage.setUser(user);
      usage.setOrder(o);
      usages.save(usage);
    }
    cartItems.deleteAll(lines);
    history(o, "Đặt hàng");
    publish(o);
    return detail(o);
  }

  public void cancelOrder(Long userId, Long id, CancelOrderRequest r) {
    Order o = lock(id);
    access.order(o, userId);
    if (o.getStatus() != OrderStatus.NEW && o.getStatus() != OrderStatus.CONFIRMED)
      throw new IllegalArgumentException("Chỉ được hủy đơn chưa lấy hàng");
    change(o, OrderStatus.CANCELLED, r.getReason());
  }

  public void updateStatus(Long shopId, Long ownerId, Long id, UpdateOrderStatusRequest r) {
    access.shop(shopId, ownerId);
    Order o = lock(id);
    if (!o.getShop().getId().equals(shopId))
      throw new AccessDeniedException("Đơn hàng không thuộc cửa hàng");
    List<OrderStatus> allowed =
        switch (o.getStatus()) {
          case NEW -> List.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED);
          case CONFIRMED -> List.of(OrderStatus.PICKED_UP, OrderStatus.CANCELLED);
          case PICKED_UP -> List.of(OrderStatus.SHIPPING);
          case SHIPPING -> List.of(OrderStatus.DELIVERED, OrderStatus.RETURNED);
          case DELIVERED -> List.of(OrderStatus.RETURNED);
          case RETURNED -> List.of(OrderStatus.REFUNDED);
          default -> List.of();
        };
    if (!allowed.contains(r.getStatus()))
      throw new IllegalArgumentException("Chuyển trạng thái đơn không hợp lệ");
    if (r.getStatus() == OrderStatus.CONFIRMED
        && o.getPaymentMethod() != PaymentMethod.COD
        && o.getPaymentStatus() != PaymentStatus.SUCCESS)
      throw new IllegalArgumentException("Đơn thanh toán trực tuyến chưa được thanh toán");
    change(o, r.getStatus(), r.getNote());
  }

  private void change(Order o, OrderStatus next, String note) {
    if ((next == OrderStatus.CANCELLED
            || next == OrderStatus.RETURNED
            || next == OrderStatus.REFUNDED)
        && (note == null || note.isBlank()))
      throw new IllegalArgumentException("Vui lòng nhập lý do");
    // Never mark online money refunded without a verified gateway refund (owned by wallet module).
    if (next == OrderStatus.REFUNDED
        && (o.getPaymentMethod() != PaymentMethod.COD
            || o.getPaymentStatus() != PaymentStatus.SUCCESS))
      throw new IllegalArgumentException(
          "Hoàn tiền trực tuyến phải được xác nhận qua module ví/cổng thanh toán");
    if (next == OrderStatus.CANCELLED || next == OrderStatus.RETURNED) {
      Map<Long, Integer> qty = new TreeMap<>();
      for (OrderItem i : orderItems.findByOrderId(o.getId()))
        qty.merge(i.getProduct().getId(), i.getQuantity(), Integer::sum);
      qty.forEach(
          (id, n) -> {
            Product p = products.lockById(id).orElseThrow();
            p.setStock(p.getStock() + n);
            p.setSoldCount(Math.max(0, p.getSoldCount() - n));
            products.save(p);
          });
    }
    if (next == OrderStatus.DELIVERED && o.getPaymentMethod() == PaymentMethod.COD)
      o.setPaymentStatus(PaymentStatus.SUCCESS);
    if (next == OrderStatus.REFUNDED) o.setPaymentStatus(PaymentStatus.REFUNDED);
    if (o.getPaymentMethod() == PaymentMethod.COD) {
      if (next == OrderStatus.CANCELLED
          || next == OrderStatus.RETURNED && o.getPaymentStatus() == PaymentStatus.PENDING)
        o.setPaymentStatus(PaymentStatus.FAILED);
      paymentTransactions
          .findFirstByOrderIdOrderByIdDesc(o.getId())
          .ifPresent(
              t -> {
                t.setStatus(o.getPaymentStatus());
                paymentTransactions.save(t);
              });
    }
    o.setStatus(next);
    orders.save(o);
    settlement.reconcile(o.getId());
    history(o, note);
    publish(o);
  }

  private void history(Order o, String note) {
    OrderStatusHistory h = new OrderStatusHistory();
    h.setOrder(o);
    h.setStatus(o.getStatus());
    h.setNote(note);
    histories.save(h);
  }

  private void publish(Order o) {
    events.publishEvent(
        new OrderEvents.Changed(
            o.getId(), o.getShop().getId(), o.getStatus().name(), o.getPaymentStatus().name()));
  }

  @Transactional(readOnly = true)
  public OrderDetailResponse getDetail(Long userId, Long id) {
    Order o = order(id);
    access.order(o, userId);
    return detail(o);
  }

  @Transactional(readOnly = true)
  public OrderDetailResponse getVendorDetail(Long shop, Long owner, Long id) {
    access.shop(shop, owner);
    Order o = order(id);
    if (!o.getShop().getId().equals(shop))
      throw new AccessDeniedException("Đơn không thuộc cửa hàng");
    return detail(o);
  }

  @Transactional(readOnly = true)
  public Page<OrderResponse> getByUser(Long userId, OrderStatus status, Pageable page) {
    return (status == null
            ? orders.findByUserId(userId, page)
            : orders.findByUserIdAndStatus(userId, status, page))
        .map(this::summary);
  }

  @Transactional(readOnly = true)
  public Page<OrderResponse> getByShop(Long shop, Long owner, OrderStatus status, Pageable page) {
    access.shop(shop, owner);
    return (status == null
            ? orders.findByShopId(shop, page)
            : orders.findByShopIdAndStatus(shop, status, page))
        .map(this::summary);
  }

  private OrderResponse summary(Order o) {
    OrderResponse r = new OrderResponse();
    r.setId(o.getId());
    r.setOrderCode(o.getOrderCode());
    r.setShopName(o.getShop().getName());
    r.setTotalAmount(o.getTotalAmount());
    r.setStatus(o.getStatus().name());
    r.setPaymentMethod(o.getPaymentMethod().name());
    r.setPaymentStatus(o.getPaymentStatus().name());
    r.setCreatedAt(o.getCreatedAt());
    return r;
  }

  private OrderDetailResponse detail(Order o) {
    OrderDetailResponse r = new OrderDetailResponse();
    r.setId(o.getId());
    r.setOrderCode(o.getOrderCode());
    r.setShopId(o.getShop().getId());
    r.setShopName(o.getShop().getName());
    r.setSubtotal(o.getSubtotal());
    r.setDiscountAmount(o.getDiscountAmount());
    r.setShippingFee(o.getShippingFee());
    r.setTotalAmount(o.getTotalAmount());
    r.setStatus(o.getStatus().name());
    r.setPaymentMethod(o.getPaymentMethod().name());
    r.setPaymentStatus(o.getPaymentStatus().name());
    r.setShippingAddress(o.getShippingAddress());
    r.setCreatedAt(o.getCreatedAt());
    r.setItems(
        orderItems.findByOrderId(o.getId()).stream()
            .map(
                i -> {
                  OrderDetailResponse.Item x = new OrderDetailResponse.Item();
                  x.setProductId(i.getProduct().getId());
                  x.setProductName(i.getProductName());
                  x.setProductImage(i.getProductImage());
                  x.setUnitPrice(i.getUnitPrice());
                  x.setQuantity(i.getQuantity());
                  x.setSelectedAttributes(i.getSelectedAttributes());
                  return x;
                })
            .toList());
    r.setStatusHistory(
        histories.findByOrderId(o.getId()).stream()
            .sorted(Comparator.comparing(OrderStatusHistory::getId))
            .map(
                h -> {
                  OrderDetailResponse.StatusHistoryItem x =
                      new OrderDetailResponse.StatusHistoryItem();
                  x.setStatus(h.getStatus().name());
                  x.setNote(h.getNote());
                  x.setCreatedAt(h.getCreatedAt());
                  return x;
                })
            .toList());
    return r;
  }
}
