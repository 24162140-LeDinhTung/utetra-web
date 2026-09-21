package com.utetra.controller.customer;

import com.utetra.dto.request.order.CancelOrderRequest;
import com.utetra.dto.request.order.CreateOrderRequest;
import com.utetra.dto.response.order.OrderDetailResponse;
import com.utetra.dto.response.order.OrderResponse;
import com.utetra.enums.OrderStatus;
import com.utetra.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customer/orders")
@RequiredArgsConstructor
public class CustomerOrderController {

    private final OrderService orderService;

    @PostMapping
    public OrderDetailResponse createOrder(@RequestParam Long userId,
                                            @Valid @RequestBody CreateOrderRequest request) {
        return orderService.createOrder(userId, request);
    }

    @GetMapping
    public Page<OrderResponse> getOrders(@RequestParam Long userId,
                                          @RequestParam(required = false) OrderStatus status,
                                          @RequestParam(defaultValue = "0") int page,
                                          @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return orderService.getByUser(userId, status, pageable);
    }

    @GetMapping("/{id}")
    public OrderDetailResponse getDetail(@PathVariable Long id) {
        return orderService.getDetail(id);
    }

    @PostMapping("/{id}/cancel")
    public void cancelOrder(@RequestParam Long userId, @PathVariable Long id,
                             @Valid @RequestBody CancelOrderRequest request) {
        orderService.cancelOrder(userId, id, request);
    }
}