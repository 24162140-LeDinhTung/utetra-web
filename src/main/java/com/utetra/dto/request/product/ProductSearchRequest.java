package com.utetra.dto.request.product;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProductSearchRequest {

    private String keyword;

    private Long categoryId;

    private Long shopId;

    private String sort; // "newest" | "price_asc" | "price_desc" | "best_selling"

    private int page = 0;

    private int size = 20;
}