package com.utetra.repository;

import com.utetra.entity.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {

  java.util.List<ProductImage> findByProductIdAndIsDeletedFalseOrderBySortOrderAscIdAsc(Long id);
}
