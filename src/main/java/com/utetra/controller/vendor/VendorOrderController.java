package com.utetra.controller.vendor;

import com.utetra.dto.request.order.UpdateOrderStatusRequest;
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
@RequestMapping("/api/vendor/shops/{shopId}/orders")
@RequiredArgsConstructor
public class VendorOrderController {

    private final OrderService orderService;

    @GetMapping
    public Page<OrderResponse> getOrders(@PathVariable Long shopId,
                                          @RequestParam(required = false) OrderStatus status,
                                          @RequestParam(defaultValue = "0") int page,
                                          @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return orderService.getByShop(shopId, status, pageable);
    }

    @PatchMapping("/{id}/status")
    public void updateStatus(@PathVariable Long shopId, @PathVariable Long id,
                              @Valid @RequestBody UpdateOrderStatusRequest request) {
        orderService.updateStatus(id, request);
    }
}