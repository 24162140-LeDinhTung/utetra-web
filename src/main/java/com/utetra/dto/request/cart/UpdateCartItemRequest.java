package com.utetra.dto.request.cart;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateCartItemRequest {

    @NotNull
    @Positive
    private Integer quantity;
}