package com.utetra.entity;

import com.utetra.enums.StaffRole;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shop_staffs")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ShopStaff extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id")
    private Shop shop;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private StaffRole role;
}