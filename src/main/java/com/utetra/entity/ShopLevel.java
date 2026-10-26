package com.utetra.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shop_levels")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ShopLevel extends BaseEntity {
    @Column(nullable = false, length = 50)
    private String name; // VD: Đồng, Bạc, Vàng

    @Column(name = "commission_rate")
    private Double commissionRate; // % hoa hồng
}