package com.utetra.repository;

import com.utetra.entity.ProductAttribute;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductAttributeRepository extends JpaRepository<ProductAttribute, Long> {
}