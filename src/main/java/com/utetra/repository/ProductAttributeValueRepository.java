package com.utetra.repository;

import com.utetra.entity.ProductAttributeValue;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductAttributeValueRepository
    extends JpaRepository<ProductAttributeValue, Long> {

  java.util.List<ProductAttributeValue> findByAttributeIdAndIsDeletedFalseOrderByIdAsc(Long id);
}
