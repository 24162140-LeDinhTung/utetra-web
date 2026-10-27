package com.utetra.entity;

import com.utetra.enums.ShopStatus;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;
import java.math.BigDecimal;

@Entity
@Table(name = "shops")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Shop extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(length = 500)
    private String description;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "cover_url")
    private String coverUrl;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private ShopStatus status; 

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_level_id")
    private ShopLevel shopLevel;

    // ==========================================
    // BỔ SUNG CÁC TRƯỜNG CÒN THIẾU TỪ DATABASE (V4)
    // ==========================================
    
    @Column(name = "address", length = 500)
    private String address;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "email", length = 255)
    private String email;

    @Column(name = "slug", unique = true)
    private String slug;

    @Column(name = "rating_avg")
    private BigDecimal ratingAvg;

    @Column(name = "follower_count")
    private Integer followerCount;

    // ==========================================

    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ShopImage> images;
}