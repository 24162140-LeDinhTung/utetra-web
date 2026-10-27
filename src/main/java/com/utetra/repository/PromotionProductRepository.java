package com.utetra.repository;

import com.utetra.entity.PromotionProduct;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PromotionProductRepository extends JpaRepository<PromotionProduct, Long> {

  java.util.List<PromotionProduct> findByProductIdAndIsDeletedFalse(Long id);

  java.util.List<PromotionProduct> findByPromotionIdAndIsDeletedFalse(Long id);

  void deleteByPromotionId(Long id);
}
