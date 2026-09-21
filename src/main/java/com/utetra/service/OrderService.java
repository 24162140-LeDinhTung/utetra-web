package com.utetra.service;

import com.utetra.dto.request.order.CancelOrderRequest;
import com.utetra.dto.request.order.CreateOrderRequest;
import com.utetra.dto.request.order.UpdateOrderStatusRequest;
import com.utetra.dto.response.order.OrderDetailResponse;
import com.utetra.dto.response.order.OrderResponse;
import com.utetra.enums.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface OrderService {

    OrderDetailResponse createOrder(Long userId, CreateOrderRequest request);

    void updateStatus(Long orderId, UpdateOrderStatusRequest request);

    void cancelOrder(Long userId, Long orderId, CancelOrderRequest request);

    OrderDetailResponse getDetail(Long orderId);

    Page<OrderResponse> getByUser(Long userId, OrderStatus status, Pageable pageable);

    Page<OrderResponse> getByShop(Long shopId, OrderStatus status, Pageable pageable);
}