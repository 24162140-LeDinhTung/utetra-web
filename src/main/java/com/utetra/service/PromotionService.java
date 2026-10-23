package com.utetra.service;

import com.utetra.dto.request.promotion.CreatePromotionRequest;
import com.utetra.dto.response.CommerceDtos.PromotionItem;
import java.util.List;

public interface PromotionService {
  List<PromotionItem> list(Long shopId, Long ownerId);

  PromotionItem save(Long shopId, Long ownerId, Long id, CreatePromotionRequest request);

  void delete(Long shopId, Long ownerId, Long id);
}
