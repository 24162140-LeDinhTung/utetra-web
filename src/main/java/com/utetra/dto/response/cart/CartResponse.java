package com.utetra.dto.response.cart;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

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
        private Long productId;
        private String productName;
        private String productImage;
        private BigDecimal unitPrice;
        private Integer quantity;
        private String selectedAttributes;
        private BigDecimal lineTotal;
    }
}