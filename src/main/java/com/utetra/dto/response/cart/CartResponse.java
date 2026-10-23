package com.utetra.dto.response.cart;

import java.math.BigDecimal;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CartResponse {

  private Long shopId;
  private String shopName;
  private List<Item> items;
  private BigDecimal subtotal;

  @Getter
  @Setter
  public static class Item {
    private Long cartItemId;
    private String unavailableReason;
    private Long productId;
    private String productName;
    private String productImage;
    private BigDecimal unitPrice;
    private Integer quantity;
    private String selectedAttributes;
    private BigDecimal lineTotal;
  }
}
