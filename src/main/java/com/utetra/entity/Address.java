package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "addresses")
@Getter
@Setter
public class Address extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "receiver_name", length = 255, nullable = false)
    private String receiverName;

    @Column(name = "phone", length = 20, nullable = false)
    private String phone;

    @Column(name = "province", length = 255)
    private String province;

    @Column(name = "district", length = 255)
    private String district;

    @Column(name = "ward", length = 255)
    private String ward;

    @Column(name = "detail", length = 500)
    private String detail;

    @Column(name = "label", length = 50)
    private String label;

    @Column(name = "is_default")
    private Boolean isDefault = false;
}