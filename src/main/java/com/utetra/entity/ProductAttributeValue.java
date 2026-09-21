package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "product_attribute_values")
@Getter
@Setter
public class ProductAttributeValue extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attribute_id", nullable = false)
    private ProductAttribute attribute;

    @Column(name = "value", nullable = false)
    private String value;

    @Column(name = "extra_price", precision = 12, scale = 2)
    private BigDecimal extraPrice = BigDecimal.ZERO;
}