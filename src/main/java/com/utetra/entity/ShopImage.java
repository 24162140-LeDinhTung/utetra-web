package com.utetra.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shop_images")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ShopImage extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id")
    private Shop shop;

    @Column(nullable = false)
    private String url;
}