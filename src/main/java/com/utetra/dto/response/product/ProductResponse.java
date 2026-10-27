package com.utetra.dto.response.product;

import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProductResponse {

  private Long id;
  private Long shopId;
  private String shopName;
  private String name;
  private String slug;
  private BigDecimal price;
  private Integer stock;
  private Integer soldCount;
  private String status;
  private String thumbnailUrl;
}
