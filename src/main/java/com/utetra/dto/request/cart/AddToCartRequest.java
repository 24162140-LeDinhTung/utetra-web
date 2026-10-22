package com.utetra.dto.request.cart;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AddToCartRequest {

    @NotNull
    private Long productId;

    @NotNull
    @Positive
    private Integer quantity;

    private String selectedAttributes; // JSON string, ví dụ {"size":"M","duong":"70%"}
}