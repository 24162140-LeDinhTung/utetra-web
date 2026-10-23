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
  public Page<OrderResponse> getOrders(
      @PathVariable Long shopId,
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @RequestParam(required = false) OrderStatus status,
      @RequestParam(defaultValue = "0") int page,
      @RequestParam(defaultValue = "10") int size) {
    Pageable pageable =
        PageRequest.of(
            Math.max(0, page),
            Math.max(1, Math.min(100, size)),
            org.springframework.data.domain.Sort.by(
                org.springframework.data.domain.Sort.Direction.DESC, "id"));
    return orderService.getByShop(shopId, principal.getId(), status, pageable);
  }

  @PatchMapping("/{id}/status")
  public void updateStatus(
      @PathVariable Long shopId,
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @PathVariable Long id,
      @Valid @RequestBody UpdateOrderStatusRequest request) {
    orderService.updateStatus(shopId, principal.getId(), id, request);
  }

  @GetMapping("/{id}")
  public com.utetra.dto.response.order.OrderDetailResponse detail(
      @PathVariable Long shopId,
      @PathVariable Long id,
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal) {
    return orderService.getVendorDetail(shopId, principal.getId(), id);
  }
}
