package com.utetra.service;

import com.utetra.dto.request.cart.AddToCartRequest;
import com.utetra.dto.request.cart.UpdateCartItemRequest;
import com.utetra.dto.response.cart.CartResponse;

import java.util.List;

public interface CartService {

    int addItem(Long userId, AddToCartRequest request);

    void updateItem(Long userId, Long cartItemId, UpdateCartItemRequest request);

    void removeItem(Long userId, Long cartItemId);

    List<CartResponse> getCart(Long userId);
}