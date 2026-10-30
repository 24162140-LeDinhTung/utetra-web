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
  private final com.utetra.service.OrderQuoteService quoteService;

  @GetMapping("/promotions")
  public java.util.List<com.utetra.service.OrderQuoteService.PromotionOffer> promotions(
      @org.springframework.security.core.annotation.AuthenticationPrincipal com.utetra.security.UserPrincipal principal,
      @RequestParam Long shopId, @RequestParam(required = false) java.util.List<Long> cartItemIds) {
    return quoteService.promotions(principal.getId(), shopId, cartItemIds);
  }

  @GetMapping("/offers")
  public java.util.List<com.utetra.service.OrderQuoteService.Offer> offers(
      @org.springframework.security.core.annotation.AuthenticationPrincipal com.utetra.security.UserPrincipal principal,
      @RequestParam Long shopId,
      @RequestParam(required = false) java.util.List<Long> cartItemIds) {
    return quoteService.offers(principal.getId(), shopId, cartItemIds);
  }

  @PostMapping("/quote")
  public com.utetra.service.OrderQuoteService.Quote quote(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @Valid @RequestBody CreateOrderRequest request) {
    return quoteService.quote(principal.getId(), request);
  }

  @PostMapping
  public OrderDetailResponse createOrder(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @Valid @RequestBody CreateOrderRequest request) {
    return orderService.createOrder(principal.getId(), request);
  }

  @GetMapping
  public Page<OrderResponse> getOrders(
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
    return orderService.getByUser(principal.getId(), status, pageable);
  }

  @GetMapping("/{id}")
  public OrderDetailResponse getDetail(
      @PathVariable Long id,
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal) {
    return orderService.getDetail(principal.getId(), id);
  }

  @PostMapping("/{id}/cancel")
  public void cancelOrder(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @PathVariable Long id,
      @Valid @RequestBody CancelOrderRequest request) {
    orderService.cancelOrder(principal.getId(), id, request);
  }
}
