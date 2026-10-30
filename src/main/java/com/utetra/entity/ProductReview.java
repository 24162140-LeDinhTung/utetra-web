package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "product_reviews")
@Getter
@Setter
public class ProductReview extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "rating", nullable = false)
    private Integer rating; // 1-5

    @Column(name = "comment", nullable = false, columnDefinition = "TEXT")
    private String comment; // Bình luận không bắt buộc; lưu chuỗi rỗng khi chỉ chấm sao
}