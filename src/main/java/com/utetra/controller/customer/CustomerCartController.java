package com.utetra.controller.customer;

import com.utetra.dto.request.cart.AddToCartRequest;
import com.utetra.dto.request.cart.UpdateCartItemRequest;
import com.utetra.dto.response.cart.CartResponse;
import com.utetra.service.CartService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customer/cart")
@RequiredArgsConstructor
public class CustomerCartController {

  private final CartService cartService;

  @GetMapping
  public List<CartResponse> getCart(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal) {
    return cartService.getCart(principal.getId());
  }

  @PostMapping("/items")
  public int addItem(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @Valid @RequestBody AddToCartRequest request) {
    return cartService.addItem(principal.getId(), request);
  }

  @PutMapping("/items/{id}")
  public void updateItem(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @PathVariable Long id,
      @Valid @RequestBody UpdateCartItemRequest request) {
    cartService.updateItem(principal.getId(), id, request);
  }

  @DeleteMapping("/items/{id}")
  public void removeItem(
      @org.springframework.security.core.annotation.AuthenticationPrincipal
          com.utetra.security.UserPrincipal principal,
      @PathVariable Long id) {
    cartService.removeItem(principal.getId(), id);
  }
}
