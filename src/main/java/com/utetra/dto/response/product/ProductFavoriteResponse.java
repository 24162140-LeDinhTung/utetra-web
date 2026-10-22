package com.utetra.dto.response.product;

import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;

@Getter
@Setter
public class ProductFavoriteResponse {
    private Long productId;
    private String productName;
    private String thumbnailUrl;
    private BigDecimal price;
}