package com.utetra.repository;

import com.utetra.entity.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PromotionRepository extends JpaRepository<Promotion, Long> {

  java.util.List<Promotion> findByShopIdAndIsDeletedFalseOrderByIdDesc(Long id);
}
