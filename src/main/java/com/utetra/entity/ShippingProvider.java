package com.utetra.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "shipping_providers")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ShippingProvider extends BaseEntity {

    @Column(nullable = false, length = 100)
    private String name; // GHN, GHTK, Viettel Post

    @Column(name = "base_fee")
    private BigDecimal baseFee;
}