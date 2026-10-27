package com.utetra.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "commission_policies")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class CommissionPolicy extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_level_id")
    private ShopLevel shopLevel;

    @Column(name = "commission_rate")
    private Double commissionRate;

    private String description;
}