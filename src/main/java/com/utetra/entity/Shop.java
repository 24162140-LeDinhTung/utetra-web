package com.utetra.entity;

import com.utetra.enums.ShopStatus;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

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

    // === QUAN TRỌNG: Bắt buộc phải có status ở đây ===
    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private ShopStatus status; 

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_level_id")
    private ShopLevel shopLevel;

    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ShopImage> images;
}