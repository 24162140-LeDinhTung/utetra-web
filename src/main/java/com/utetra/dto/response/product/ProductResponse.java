package com.utetra.dto.response.product;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class ProductResponse {

    private Long id;
    private String name;
    private String slug;
    private BigDecimal price;
    private Integer stock;
    private Integer soldCount;
    private String status;
    private String thumbnailUrl;
}