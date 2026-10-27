package com.utetra.dto.response.product;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class ProductDetailResponse {

    private Long id;
    private String name;
    private String slug;
    private String description;
    private BigDecimal price;
    private Integer stock;
    private Integer soldCount;
    private String status;
    private Long categoryId;
    private String categoryName;
    private Long shopId;
    private String shopName;
    private List<String> imageUrls;
    private List<ProductAttributeResponse> attributes;
}