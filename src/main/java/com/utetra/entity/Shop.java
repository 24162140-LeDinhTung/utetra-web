package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "shops")
@Getter
@Setter
public class Shop extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(name = "name", nullable = false)
    private String name;

    // TODO: các field còn lại (status, shopLevel, wallet...) do C bổ sung
}