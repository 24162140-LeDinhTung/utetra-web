package com.utetra.dto.response;

import com.utetra.enums.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public final class CommerceDtos {
  private CommerceDtos() {}

  public record ShopItem(Long id, String name) {}

  public record CategoryItem(Long id, String name, String slug, Long parentId) {}

  public record VoucherItem(
      Long id,
      String code,
      VoucherType voucherType,
      DiscountType discountType,
      BigDecimal discountValue,
      BigDecimal minOrderAmount,
      BigDecimal maxDiscountAmount,
      Integer usageLimit,
      Integer usedCount,
      LocalDateTime startDate,
      LocalDateTime endDate) {}

  public record PromotionItem(
      Long id,
      String name,
      PromotionType promotionType,
      DiscountType discountType,
      BigDecimal discountValue,
      LocalDateTime startDate,
      LocalDateTime endDate,
      List<Long> productIds) {}
}
