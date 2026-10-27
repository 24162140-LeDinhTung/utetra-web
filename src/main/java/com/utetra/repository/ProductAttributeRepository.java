package com.utetra.repository;

import com.utetra.entity.ProductAttribute;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductAttributeRepository extends JpaRepository<ProductAttribute, Long> {

  java.util.List<ProductAttribute> findByProductIdAndIsDeletedFalseOrderByIdAsc(Long id);
}
