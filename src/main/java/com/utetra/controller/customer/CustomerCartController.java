package com.utetra.controller.customer;

import com.utetra.dto.request.cart.AddToCartRequest;
import com.utetra.dto.request.cart.UpdateCartItemRequest;
import com.utetra.dto.response.cart.CartResponse;
import com.utetra.service.CartService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customer/cart")
@RequiredArgsConstructor
public class CustomerCartController {

    private final CartService cartService;

    @GetMapping
    public List<CartResponse> getCart(@RequestParam Long userId) {
        return cartService.getCart(userId);
    }

    @PostMapping("/items")
    public int addItem(@RequestParam Long userId, @Valid @RequestBody AddToCartRequest request) {
        return cartService.addItem(userId, request);
    }

    @PutMapping("/items/{id}")
    public void updateItem(@RequestParam Long userId, @PathVariable Long id,
                            @Valid @RequestBody UpdateCartItemRequest request) {
        cartService.updateItem(userId, id, request);
    }

    @DeleteMapping("/items/{id}")
    public void removeItem(@RequestParam Long userId, @PathVariable Long id) {
        cartService.removeItem(userId, id);
    }
}