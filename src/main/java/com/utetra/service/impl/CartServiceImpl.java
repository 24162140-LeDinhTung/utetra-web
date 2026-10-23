package com.utetra.service.impl;

import com.utetra.dto.request.cart.*;
import com.utetra.dto.response.cart.CartResponse;
import com.utetra.entity.*;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import java.math.BigDecimal;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class CartServiceImpl implements CartService {
  private final CartRepository carts;
  private final CartItemRepository items;
  private final UserRepository users;
  private final CommerceAccess access;
  private final ProductPricing pricing;

  private User lockUser(Long id) {
    return users
        .lockById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
  }

  private CartItem own(Long userId, Long id) {
    CartItem i =
        items
            .findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy mục giỏ hàng"));
    if (!i.getCart().getUser().getId().equals(userId))
      throw new AccessDeniedException("Giỏ hàng không thuộc bạn");
    return i;
  }

  private void stock(Cart c, Product p, Long ignore, int quantity) {
    if (quantity < 1) throw new IllegalArgumentException("Số lượng phải lớn hơn 0");
    int total = quantity;
    for (CartItem i : items.findByCartId(c.getId()))
      if (i.getProduct().getId().equals(p.getId()) && !i.getId().equals(ignore))
        total = Math.addExact(total, i.getQuantity());
    if (total > p.getStock())
      throw new IllegalArgumentException("Không đủ tồn kho: " + p.getName());
  }

  public int addItem(Long userId, AddToCartRequest r) {
    User u = lockUser(userId);
    Product p = access.product(r.getProductId());
    pricing.purchasable(p);
    String attrs = pricing.selection(p, r.getSelectedAttributes()).json();
    Cart c =
        carts
            .findByUserIdAndShopId(userId, p.getShop().getId())
            .orElseGet(
                () -> {
                  Cart n = new Cart();
                  n.setUser(u);
                  n.setShop(p.getShop());
                  return carts.save(n);
                });
    CartItem i =
        items
            .findByCartIdAndProductIdAndSelectedAttributes(c.getId(), p.getId(), attrs)
            .orElseGet(
                () -> {
                  CartItem n = new CartItem();
                  n.setCart(c);
                  n.setProduct(p);
                  n.setSelectedAttributes(attrs);
                  n.setQuantity(0);
                  return n;
                });
    int qty = Math.addExact(i.getQuantity(), r.getQuantity());
    stock(c, p, i.getId(), qty);
    i.setQuantity(qty);
    items.save(i);
    return items.findByCartId(c.getId()).size();
  }

  public void updateItem(Long userId, Long id, UpdateCartItemRequest r) {
    lockUser(userId);
    CartItem i = own(userId, id);
    pricing.purchasable(i.getProduct());
    stock(i.getCart(), i.getProduct(), id, r.getQuantity());
    i.setQuantity(r.getQuantity());
    items.save(i);
  }

  public void removeItem(Long userId, Long id) {
    lockUser(userId);
    items.delete(own(userId, id));
  }

  @Transactional(readOnly = true)
  public List<CartResponse> getCart(Long userId) {
    return carts.findByUserId(userId).stream()
        .map(
            c -> {
              CartResponse r = new CartResponse();
              r.setShopId(c.getShop().getId());
              r.setShopName(c.getShop().getName());
              r.setItems(
                  items.findByCartId(c.getId()).stream()
                      .map(
                          i -> {
                            CartResponse.Item x = new CartResponse.Item();
                            x.setCartItemId(i.getId());
                            x.setProductId(i.getProduct().getId());
                            x.setProductName(i.getProduct().getName());
                            x.setProductImage(pricing.image(i.getProduct()));
                            try {
                              pricing.purchasable(i.getProduct());
                              x.setUnitPrice(
                                  pricing.unitPrice(i.getProduct(), i.getSelectedAttributes()));
                              if (i.getQuantity() > i.getProduct().getStock())
                                x.setUnavailableReason("Không đủ tồn kho");
                            } catch (IllegalArgumentException ex) {
                              x.setUnitPrice(i.getProduct().getPrice());
                              x.setUnavailableReason(ex.getMessage());
                            }
                            x.setQuantity(i.getQuantity());
                            x.setSelectedAttributes(i.getSelectedAttributes());
                            x.setLineTotal(
                                x.getUnitPrice().multiply(BigDecimal.valueOf(x.getQuantity())));
                            return x;
                          })
                      .toList());
              r.setSubtotal(
                  r.getItems().stream()
                      .map(CartResponse.Item::getLineTotal)
                      .reduce(BigDecimal.ZERO, BigDecimal::add));
              return r;
            })
        .filter(c -> !c.getItems().isEmpty())
        .toList();
  }
}
