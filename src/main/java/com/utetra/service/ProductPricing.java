package com.utetra.service;

import com.utetra.entity.*;
import com.utetra.enums.*;
import com.utetra.repository.*;
import java.math.*;
import java.time.LocalDateTime;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

@Service
@RequiredArgsConstructor
// Cart rendering catches validation failures to show an unavailable item instead of failing the page.
@Transactional(readOnly = true, noRollbackFor = IllegalArgumentException.class)
public class ProductPricing {
  private final ProductAttributeRepository attributes;
  private final ProductAttributeValueRepository values;
  private final PromotionProductRepository promotions;
  private final PromotionRepository promotionRepository;
  private final ProductImageRepository images;
  private final ObjectMapper json = new ObjectMapper();

  public record Selection(String json, BigDecimal extra) {}

  public Selection selection(Product p, String raw) {
    try {
      Map<String, String> selected =
          raw == null || raw.isBlank()
              ? new TreeMap<>()
              : new TreeMap<>(json.readValue(raw, new TypeReference<Map<String, String>>() {}));
      BigDecimal extra = BigDecimal.ZERO;
      Set<String> known = new HashSet<>();
      for (ProductAttribute a :
          attributes.findByProductIdAndIsDeletedFalseOrderByIdAsc(p.getId())) {
        known.add(a.getName());
        String value = selected.get(a.getName());
        if (value == null) throw new IllegalArgumentException("Vui lòng chọn " + a.getName());
        ProductAttributeValue v =
            values.findByAttributeIdAndIsDeletedFalseOrderByIdAsc(a.getId()).stream()
                .filter(x -> x.getValue().equals(value) && x.getProduct().getId().equals(p.getId()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Tùy chọn sản phẩm không hợp lệ"));
        extra = extra.add(v.getExtraPrice() == null ? BigDecimal.ZERO : v.getExtraPrice());
      }
      if (!known.equals(selected.keySet()))
        throw new IllegalArgumentException("Thuộc tính không thuộc sản phẩm");
      return new Selection(json.writeValueAsString(selected), extra);
    } catch (IllegalArgumentException e) {
      throw e;
    } catch (Exception e) {
      throw new IllegalArgumentException("Thuộc tính phải là đối tượng JSON tên:giá trị");
    }
  }

  // Product/cart prices are undiscounted until checkout explicitly selects a promotion.
  public BigDecimal unitPrice(Product p, String selected) {
    return p.getPrice().add(selection(p, selected).extra()).setScale(0, RoundingMode.HALF_UP);
  }

  public Promotion selectedPromotion(Long shop, Long id, Set<Long> productIds) {
    if (id == null) return null;
    Promotion promo = promotionRepository.findById(id)
        .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại"));
    LocalDateTime now = LocalDateTime.now();
    if (Boolean.TRUE.equals(promo.getIsDeleted()) || !promo.getShop().getId().equals(shop)
        || now.isBefore(promo.getStartDate()) || !now.isBefore(promo.getEndDate()))
      throw new IllegalArgumentException("Khuyến mãi không còn hiệu lực hoặc thuộc cửa hàng khác");
    if (promotions.findByPromotionIdAndIsDeletedFalse(id).stream()
        .noneMatch(link -> productIds.contains(link.getProduct().getId())))
      throw new IllegalArgumentException("Khuyến mãi không áp dụng cho các món đã chọn");
    return promo;
  }

  public BigDecimal promotionDiscount(Product p, BigDecimal price, Promotion promo) {
    if (promo == null || promotions.findByPromotionIdAndIsDeletedFalse(promo.getId()).stream()
        .noneMatch(link -> link.getProduct().getId().equals(p.getId()))) return BigDecimal.ZERO;
    return discount(price, promo.getDiscountType(), promo.getDiscountValue(), null);
  }

  public static BigDecimal discount(
      BigDecimal base, DiscountType type, BigDecimal value, BigDecimal cap) {
    BigDecimal d =
        type == DiscountType.PERCENT
            ? base.multiply(value).divide(BigDecimal.valueOf(100), 0, RoundingMode.DOWN)
            : value;
    if (cap != null) d = d.min(cap);
    return d.max(BigDecimal.ZERO).min(base);
  }

  public String image(Product p) {
    return images.findByProductIdAndIsDeletedFalseOrderBySortOrderAscIdAsc(p.getId()).stream()
        .findFirst()
        .map(ProductImage::getImageUrl)
        .orElse("");
  }

  public void purchasable(Product p) {
    if (Boolean.TRUE.equals(p.getIsDeleted())
        || Boolean.TRUE.equals(p.getShop().getIsDeleted())
        || p.getShop().getStatus() != ShopStatus.ACTIVE
        || Boolean.TRUE.equals(p.getCategory().getIsDeleted())
        || p.getStatus() != ProductStatus.ACTIVE)
      throw new IllegalArgumentException("Sản phẩm không còn được mở bán: " + p.getName());
  }
}
