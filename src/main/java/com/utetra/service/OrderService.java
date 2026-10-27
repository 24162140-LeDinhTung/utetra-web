package com.utetra.service;

import com.utetra.dto.request.order.*;
import com.utetra.dto.response.order.*;
import com.utetra.enums.OrderStatus;
import org.springframework.data.domain.*;

public interface OrderService {
  OrderDetailResponse createOrder(Long userId, CreateOrderRequest request);

  void updateStatus(Long shopId, Long ownerId, Long orderId, UpdateOrderStatusRequest request);

  void cancelOrder(Long userId, Long orderId, CancelOrderRequest request);

  OrderDetailResponse getDetail(Long userId, Long orderId);

  OrderDetailResponse getVendorDetail(Long shopId, Long ownerId, Long orderId);

  Page<OrderResponse> getByUser(Long userId, OrderStatus status, Pageable pageable);

  Page<OrderResponse> getByShop(Long shopId, Long ownerId, OrderStatus status, Pageable pageable);
}
