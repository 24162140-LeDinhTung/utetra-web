package com.utetra.service.impl;

import com.utetra.dto.response.product.ProductFavoriteResponse;
import com.utetra.dto.response.shop.ShopResponse;
import com.utetra.entity.*;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Implements the existing shared interface so the customer controller can start. */
@Service
@RequiredArgsConstructor
@Transactional
public class FavoriteServiceImpl implements FavoriteService {
  private final ProductFavoriteRepository favorites;
  private final ShopFollowRepository follows;
  private final ProductViewLogRepository views;
  private final ShopRepository shops;
  private final UserRepository users;
  private final CommerceAccess access;
  private final ProductPricing pricing;

  public void toggleFavoriteProduct(Long userId, Long productId) {
    users.lockById(userId).orElseThrow();
    Product p = access.product(productId);
    var existing = favorites.findByUserIdAndProductId(userId, productId);
    if (existing.isPresent()) {
      favorites.delete(existing.get());
    } else {
      ProductFavorite f = new ProductFavorite();
      f.setUserId(userId);
      f.setProduct(p);
      favorites.save(f);
    }
  }

  @Transactional(readOnly = true)
  public List<ProductFavoriteResponse> getFavoriteProducts(Long userId) {
    return favorites.findByUserId(userId).stream()
        .filter(f -> !Boolean.TRUE.equals(f.getProduct().getIsDeleted()))
        .map(f -> product(f.getProduct()))
        .toList();
  }

  public void toggleFollowShop(Long userId, Long shopId) {
    users.lockById(userId).orElseThrow();
    Shop shop =
        shops
            .findById(shopId)
            .filter(s -> !Boolean.TRUE.equals(s.getIsDeleted()))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy cửa hàng"));
    var existing = follows.findByUserIdAndShopId(userId, shopId);
    if (existing.isPresent()) follows.delete(existing.get());
    else {
      ShopFollow f = new ShopFollow();
      f.setUserId(userId);
      f.setShop(shop);
      follows.save(f);
    }
  }

  @Transactional(readOnly = true)
  public List<ShopResponse> getFollowedShops(Long userId) {
    return follows.findByUserId(userId).stream()
        .filter(f -> !Boolean.TRUE.equals(f.getShop().getIsDeleted()))
        .map(
            f -> {
              ShopResponse r = new ShopResponse();
              r.setId(f.getShop().getId());
              r.setName(f.getShop().getName());
              return r;
            })
        .toList();
  }

  public void logProductView(Long userId, Long productId) {
    ProductViewLog v = new ProductViewLog();
    v.setUserId(userId);
    v.setProduct(access.product(productId));
    views.save(v);
  }

  @Transactional(readOnly = true)
  public List<ProductFavoriteResponse> getViewHistory(Long userId) {
    Set<Long> seen = new HashSet<>();
    return views.findByUserIdOrderByCreatedAtDesc(userId).stream()
        .filter(
            v ->
                !Boolean.TRUE.equals(v.getProduct().getIsDeleted())
                    && seen.add(v.getProduct().getId()))
        .limit(100)
        .map(v -> product(v.getProduct()))
        .toList();
  }

  private ProductFavoriteResponse product(Product p) {
    ProductFavoriteResponse r = new ProductFavoriteResponse();
    r.setProductId(p.getId());
    r.setProductName(p.getName());
    r.setPrice(p.getPrice());
    r.setThumbnailUrl(pricing.image(p));
    return r;
  }
}
