package com.utetra.repository;

import com.utetra.entity.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {

  org.springframework.data.domain.Page<ProductReview> findByProductIdAndIsDeletedFalse(
      Long id, org.springframework.data.domain.Pageable pageable);

  boolean existsByUserIdAndProductIdAndIsDeletedFalse(Long userId, Long productId);
}
