package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "user_levels")
@Getter
@Setter
public class UserLevel extends BaseEntity {

    @Column(name = "name", length = 100, nullable = false)
    private String name;

    @Column(name = "min_spent", precision = 15, scale = 2)
    private BigDecimal minSpent;

    @Column(name = "discount_percent")
    private Integer discountPercent = 0;

    @Column(name = "description", length = 500)
    private String description;
}