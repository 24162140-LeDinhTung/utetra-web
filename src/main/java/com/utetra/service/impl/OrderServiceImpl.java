package com.utetra.service.impl;

import com.utetra.dto.request.order.CancelOrderRequest;
import com.utetra.dto.request.order.CreateOrderRequest;
import com.utetra.dto.request.order.UpdateOrderStatusRequest;
import com.utetra.dto.response.order.OrderDetailResponse;
import com.utetra.dto.response.order.OrderResponse;
import com.utetra.entity.*;
import com.utetra.enums.OrderStatus;
import com.utetra.enums.PaymentStatus;
import com.utetra.exception.custom.InsufficientStockException;
import com.utetra.exception.custom.InvalidOrderStatusException;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.exception.custom.VoucherInvalidException;
import com.utetra.mapper.OrderMapper;
import com.utetra.repository.*;
import com.utetra.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderStatusHistoryRepository orderStatusHistoryRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final VoucherRepository voucherRepository;
    private final VoucherUsageRepository voucherUsageRepository;
    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final ProductRepository productRepository;
    private final OrderMapper orderMapper;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    @Transactional
    public OrderDetailResponse createOrder(Long userId, CreateOrderRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Shop shop = shopRepository.findById(request.getShopId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found: " + request.getShopId()));

        Cart cart = cartRepository.findByUserIdAndShopId(userId, request.getShopId())
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found for this shop"));
        List<CartItem> cartItems = cartItemRepository.findByCartId(cart.getId());

        if (cartItems.isEmpty()) {
            throw new ResourceNotFoundException("Cart is empty");
        }

        // 1. Validate tồn kho + tính subtotal
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem ci : cartItems) {
            Product product = ci.getProduct();
            if (product.getStock() < ci.getQuantity()) {
                throw new InsufficientStockException("Insufficient stock for product: " + product.getName());
            }
            subtotal = subtotal.add(product.getPrice().multiply(BigDecimal.valueOf(ci.getQuantity())));
        }

        // 2. Áp dụng voucher (nếu có)
        BigDecimal discountAmount = BigDecimal.ZERO;
        Voucher voucher = null;
        if (request.getVoucherCode() != null && !request.getVoucherCode().isBlank()) {
            voucher = voucherRepository.findByCode(request.getVoucherCode())
                    .orElseThrow(() -> new VoucherInvalidException("Voucher not found"));

            LocalDateTime now = LocalDateTime.now();
            if (now.isBefore(voucher.getStartDate()) || now.isAfter(voucher.getEndDate())) {
                throw new VoucherInvalidException("Voucher expired or not yet active");
            }
            if (subtotal.compareTo(voucher.getMinOrderAmount()) < 0) {
                throw new VoucherInvalidException("Order does not meet minimum amount for this voucher");
            }
            if (voucher.getUsageLimit() != null && voucher.getUsedCount() >= voucher.getUsageLimit()) {
                throw new VoucherInvalidException("Voucher usage limit reached");
            }

            if (voucher.getDiscountType().name().equals("PERCENT")) {
                discountAmount = subtotal.multiply(voucher.getDiscountValue())
                        .divide(BigDecimal.valueOf(100));
                if (voucher.getMaxDiscountAmount() != null
                        && discountAmount.compareTo(voucher.getMaxDiscountAmount()) > 0) {
                    discountAmount = voucher.getMaxDiscountAmount();
                }
            } else {
                discountAmount = voucher.getDiscountValue();
            }
        }

        // 3. Phí ship (đơn giản hóa cho đồ án — có thể để cố định hoặc 0)
        BigDecimal shippingFee = BigDecimal.ZERO;
        BigDecimal totalAmount = subtotal.subtract(discountAmount).add(shippingFee);

        // 4. Tạo Order
        Order order = new Order();
        order.setOrderCode("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        order.setUser(user);
        order.setShop(shop);
        order.setSubtotal(subtotal);
        order.setDiscountAmount(discountAmount);
        order.setShippingFee(shippingFee);
        order.setTotalAmount(totalAmount);
        order.setPaymentMethod(request.getPaymentMethod());
        order.setShippingAddress(request.getShippingAddress());

        if (request.getPaymentMethod().name().equals("COD")) {
            order.setStatus(OrderStatus.CONFIRMED);
            order.setPaymentStatus(PaymentStatus.PENDING);
        } else {
            order.setStatus(OrderStatus.NEW);
            order.setPaymentStatus(PaymentStatus.PENDING);
        }

        order = orderRepository.save(order);

        // 5. Tạo OrderItem (snapshot) + trừ stock + tăng soldCount
        for (CartItem ci : cartItems) {
            Product product = ci.getProduct();

            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(product);
            orderItem.setProductName(product.getName());
            orderItem.setProductImage(""); // TODO: lấy ảnh default khi có ProductImageService
            orderItem.setUnitPrice(product.getPrice());
            orderItem.setQuantity(ci.getQuantity());
            orderItem.setSelectedAttributes(ci.getSelectedAttributes());
            orderItemRepository.save(orderItem);

            product.setStock(product.getStock() - ci.getQuantity());
            product.setSoldCount(product.getSoldCount() + ci.getQuantity());
            productRepository.save(product);
        }

        // 6. Ghi lịch sử trạng thái
        OrderStatusHistory history = new OrderStatusHistory();
        history.setOrder(order);
        history.setStatus(order.getStatus());
        history.setNote("Order created");
        orderStatusHistoryRepository.save(history);

        // 7. Ghi nhận sử dụng voucher
        if (voucher != null) {
            voucher.setUsedCount(voucher.getUsedCount() + 1);
            voucherRepository.save(voucher);

            VoucherUsage usage = new VoucherUsage();
            usage.setVoucher(voucher);
            usage.setUser(user);
            usage.setOrder(order);
            voucherUsageRepository.save(usage);
        }

        // 8. Xóa cart item đã đặt
        cartItemRepository.deleteAll(cartItems);

        // 9. WebSocket thông báo Vendor có đơn mới
        messagingTemplate.convertAndSend("/topic/shop/" + shop.getId() + "/orders", order.getOrderCode());

        return getDetail(order.getId());
    }

    @Override
    @Transactional
    public void updateStatus(Long orderId, UpdateOrderStatusRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + orderId));

        validateStatusTransition(order.getStatus(), request.getStatus());

        order.setStatus(request.getStatus());
        orderRepository.save(order);

        OrderStatusHistory history = new OrderStatusHistory();
        history.setOrder(order);
        history.setStatus(request.getStatus());
        history.setNote(request.getNote());
        orderStatusHistoryRepository.save(history);

        messagingTemplate.convertAndSend("/topic/order/" + order.getId() + "/status", request.getStatus().name());
    }

    @Override
    @Transactional
    public void cancelOrder(Long userId, Long orderId, CancelOrderRequest request) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.NEW && order.getStatus() != OrderStatus.CONFIRMED) {
            throw new InvalidOrderStatusException("Cannot cancel order in status: " + order.getStatus());
        }

        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);

        OrderStatusHistory history = new OrderStatusHistory();
        history.setOrder(order);
        history.setStatus(OrderStatus.CANCELLED);
        history.setNote(request.getReason());
        orderStatusHistoryRepository.save(history);

        // Hoàn lại stock
        List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
        for (OrderItem item : items) {
            Product product = item.getProduct();
            product.setStock(product.getStock() + item.getQuantity());
            product.setSoldCount(product.getSoldCount() - item.getQuantity());
            productRepository.save(product);
        }

        messagingTemplate.convertAndSend("/topic/order/" + order.getId() + "/status", "CANCELLED");
    }

    @Override
    public OrderDetailResponse getDetail(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + orderId));
        List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
        List<OrderStatusHistory> histories = orderStatusHistoryRepository.findByOrderId(orderId);

        OrderDetailResponse response = new OrderDetailResponse();
        response.setId(order.getId());
        response.setOrderCode(order.getOrderCode());
        response.setShopId(order.getShop().getId());
        response.setShopName(order.getShop().getName());
        response.setSubtotal(order.getSubtotal());
        response.setDiscountAmount(order.getDiscountAmount());
        response.setShippingFee(order.getShippingFee());
        response.setTotalAmount(order.getTotalAmount());
        response.setStatus(order.getStatus().name());
        response.setPaymentMethod(order.getPaymentMethod().name());
        response.setPaymentStatus(order.getPaymentStatus().name());
        response.setShippingAddress(order.getShippingAddress());
        response.setCreatedAt(order.getCreatedAt());

        response.setItems(items.stream().map(i -> {
            OrderDetailResponse.Item item = new OrderDetailResponse.Item();
            item.setProductName(i.getProductName());
            item.setProductImage(i.getProductImage());
            item.setUnitPrice(i.getUnitPrice());
            item.setQuantity(i.getQuantity());
            item.setSelectedAttributes(i.getSelectedAttributes());
            return item;
        }).toList());

        response.setStatusHistory(histories.stream().map(h -> {
            OrderDetailResponse.StatusHistoryItem item = new OrderDetailResponse.StatusHistoryItem();
            item.setStatus(h.getStatus().name());
            item.setNote(h.getNote());
            item.setCreatedAt(h.getCreatedAt());
            return item;
        }).toList());

        return response;
    }

    @Override
    public Page<OrderResponse> getByUser(Long userId, OrderStatus status, Pageable pageable) {
        Page<Order> page = (status != null)
                ? orderRepository.findByUserIdAndStatus(userId, status, pageable)
                : orderRepository.findByUserId(userId, pageable);
        return page.map(orderMapper::toResponse);
    }

    @Override
    public Page<OrderResponse> getByShop(Long shopId, OrderStatus status, Pageable pageable) {
        Page<Order> page = orderRepository.findByShopIdAndStatus(shopId, status, pageable);
        return page.map(orderMapper::toResponse);
    }

    private void validateStatusTransition(OrderStatus current, OrderStatus next) {
        List<OrderStatus> validNext = switch (current) {
            case NEW -> List.of(OrderStatus.CONFIRMED, OrderStatus.CANCELLED);
            case CONFIRMED -> List.of(OrderStatus.PICKED_UP, OrderStatus.CANCELLED);
            case PICKED_UP -> List.of(OrderStatus.SHIPPING);
            case SHIPPING -> List.of(OrderStatus.DELIVERED, OrderStatus.RETURNED);
            case DELIVERED -> List.of(OrderStatus.REFUNDED);
            default -> List.of();
        };
        if (!validNext.contains(next)) {
            throw new InvalidOrderStatusException(
                    "Cannot transition order from " + current + " to " + next);
        }
    }
}