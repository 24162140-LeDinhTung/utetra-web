package com.utetra.service.impl;

import com.utetra.dto.request.cart.AddToCartRequest;
import com.utetra.dto.request.cart.UpdateCartItemRequest;
import com.utetra.dto.response.cart.CartResponse;
import com.utetra.entity.Cart;
import com.utetra.entity.CartItem;
import com.utetra.entity.Product;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.mapper.CartMapper;
import com.utetra.repository.CartItemRepository;
import com.utetra.repository.CartRepository;
import com.utetra.repository.ProductRepository;
import com.utetra.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.utetra.entity.User;
import com.utetra.repository.UserRepository;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CartServiceImpl implements CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final CartMapper cartMapper;
    
    private final UserRepository userRepository;

    @Override
    public int addItem(Long userId, AddToCartRequest request) {
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + request.getProductId()));

        Long shopId = product.getShop().getId();

        Cart cart = cartRepository.findByUserIdAndShopId(userId, shopId)
        		.orElseGet(() -> {
        		    Cart newCart = new Cart();
        		    User user = userRepository.findById(userId)
        		            .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        		    newCart.setUser(user);
        		    newCart.setShop(product.getShop());
        		    return cartRepository.save(newCart);
        		});

        Optional<CartItem> existing = cartItemRepository
                .findByCartIdAndProductIdAndSelectedAttributes(
                        cart.getId(), product.getId(), request.getSelectedAttributes());

        if (existing.isPresent()) {
            CartItem item = existing.get();
            item.setQuantity(item.getQuantity() + request.getQuantity());
            cartItemRepository.save(item);
        } else {
            CartItem item = new CartItem();
            item.setCart(cart);
            item.setProduct(product);
            item.setQuantity(request.getQuantity());
            item.setSelectedAttributes(request.getSelectedAttributes());
            cartItemRepository.save(item);
        }

        return cartItemRepository.findByCartId(cart.getId()).size();
    }

    @Override
    public void updateItem(Long userId, Long cartItemId, UpdateCartItemRequest request) {
        CartItem item = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new ResourceNotFoundException("Cart item not found: " + cartItemId));
        item.setQuantity(request.getQuantity());
        cartItemRepository.save(item);
    }

    @Override
    public void removeItem(Long userId, Long cartItemId) {
        CartItem item = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new ResourceNotFoundException("Cart item not found: " + cartItemId));
        cartItemRepository.delete(item);
    }

    @Override
    public List<CartResponse> getCart(Long userId) {
        List<Cart> carts = cartRepository.findByUserId(userId);
        List<CartResponse> result = new ArrayList<>();

        for (Cart cart : carts) {
            List<CartItem> items = cartItemRepository.findByCartId(cart.getId());

            CartResponse response = new CartResponse();
            response.setShopId(cart.getShop().getId());
            response.setShopName(cart.getShop().getName());

            List<CartResponse.Item> itemResponses = new ArrayList<>();
            BigDecimal subtotal = BigDecimal.ZERO;

            for (CartItem ci : items) {
                CartResponse.Item itemResp = cartMapper.toItemResponse(ci);
                BigDecimal lineTotal = ci.getProduct().getPrice()
                        .multiply(BigDecimal.valueOf(ci.getQuantity()));
                itemResp.setLineTotal(lineTotal);
                itemResponses.add(itemResp);
                subtotal = subtotal.add(lineTotal);
            }

            response.setItems(itemResponses);
            response.setSubtotal(subtotal);
            result.add(response);
        }

        return result;
    }
}