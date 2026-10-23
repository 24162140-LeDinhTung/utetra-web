package com.utetra.service.impl;

import com.utetra.dto.request.promotion.CreatePromotionRequest;
import com.utetra.dto.response.CommerceDtos.PromotionItem;
import com.utetra.entity.*;
import com.utetra.enums.DiscountType;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import java.math.BigDecimal;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class PromotionServiceImpl implements PromotionService {
  private final PromotionRepository promotions;
  private final PromotionProductRepository links;
  private final CommerceAccess access;

  private Promotion own(Long shop, Long owner, Long id) {
    access.shop(shop, owner);
    return promotions
        .findById(id)
        .filter(p -> !Boolean.TRUE.equals(p.getIsDeleted()) && p.getShop().getId().equals(shop))
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy khuyến mãi"));
  }

  @Transactional(readOnly = true)
  public List<PromotionItem> list(Long shop, Long owner) {
    access.shop(shop, owner);
    return promotions.findByShopIdAndIsDeletedFalseOrderByIdDesc(shop).stream()
        .map(this::dto)
        .toList();
  }

  public PromotionItem save(Long shop, Long owner, Long id, CreatePromotionRequest r) {
    if (!r.getStartDate().isBefore(r.getEndDate())
        || r.getDiscountValue().signum() <= 0
        || r.getDiscountType() == DiscountType.PERCENT
            && r.getDiscountValue().compareTo(BigDecimal.valueOf(100)) > 0
        || r.getProductIds() == null
        || r.getProductIds().isEmpty())
      throw new IllegalArgumentException("Khuyến mãi cần thời gian, mức giảm và sản phẩm hợp lệ");
    if (!r.getPromotionType().name().equals(r.getDiscountType().name()))
      throw new IllegalArgumentException("Loại khuyến mãi phải khớp loại giảm giá");
    List<Product> selected =
        r.getProductIds().stream().distinct().map(pid -> access.product(shop, pid, owner)).toList();
    Promotion p = id == null ? new Promotion() : own(shop, owner, id);
    p.setShop(access.shop(shop, owner));
    p.setName(r.getName().trim());
    p.setPromotionType(r.getPromotionType());
    p.setDiscountType(r.getDiscountType());
    p.setDiscountValue(r.getDiscountValue());
    p.setStartDate(r.getStartDate());
    p.setEndDate(r.getEndDate());
    promotions.save(p);
    if (id != null) {
      links.deleteByPromotionId(id);
      links.flush();
    }
    for (Product product : selected) {
      PromotionProduct link = new PromotionProduct();
      link.setPromotion(p);
      link.setProduct(product);
      links.save(link);
    }
    return dto(p);
  }

  public void delete(Long shop, Long owner, Long id) {
    Promotion p = own(shop, owner, id);
    p.setIsDeleted(true);
    promotions.save(p);
  }

  private PromotionItem dto(Promotion p) {
    return new PromotionItem(
        p.getId(),
        p.getName(),
        p.getPromotionType(),
        p.getDiscountType(),
        p.getDiscountValue(),
        p.getStartDate(),
        p.getEndDate(),
        links.findByPromotionIdAndIsDeletedFalse(p.getId()).stream()
            .map(l -> l.getProduct().getId())
            .toList());
  }
}
