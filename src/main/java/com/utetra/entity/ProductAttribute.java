package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.util.List; 
import java.util.Set; // Thay vì java.util.List
import java.util.HashSet;// Thêm import này

@Entity
@Table(name = "product_attributes")
@Getter
@Setter
public class ProductAttribute extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "name", nullable = false)
    private String name; // Ví dụ: "Size", "Đường", "Đá", "Topping"

    // THÊM ĐOẠN NÀY ĐỂ LIÊN KẾT TỚI CÁC GIÁ TRỊ (M, L)
    @OneToMany(mappedBy = "attribute", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Set<ProductAttributeValue> values = new HashSet<>();
}