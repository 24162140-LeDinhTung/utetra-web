package com.utetra.service;

import com.utetra.entity.*;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CommerceAccess {
  private final ShopRepository shops;
  private final ProductRepository products;

  public Shop shop(Long id, Long ownerId) {
    Shop s =
        shops
            .findById(id)
            .filter(x -> !Boolean.TRUE.equals(x.getIsDeleted()))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy cửa hàng"));
    if (!s.getOwner().getId().equals(ownerId))
      throw new AccessDeniedException("Bạn không quản lý cửa hàng này");
    return s;
  }

  public Product product(Long id) {
    return products
        .findById(id)
        .filter(p -> !Boolean.TRUE.equals(p.getIsDeleted()))
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sản phẩm"));
  }

  public Product product(Long shopId, Long id, Long ownerId) {
    shop(shopId, ownerId);
    Product p = product(id);
    if (!p.getShop().getId().equals(shopId))
      throw new AccessDeniedException("Sản phẩm không thuộc cửa hàng này");
    return p;
  }

  public void order(Order o, Long userId) {
    if (!o.getUser().getId().equals(userId))
      throw new AccessDeniedException("Bạn không có quyền truy cập đơn hàng này");
  }
}
