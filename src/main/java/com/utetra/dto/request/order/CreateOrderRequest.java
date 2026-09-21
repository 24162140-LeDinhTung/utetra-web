package com.utetra.dto.request.order;

import com.utetra.enums.PaymentMethod;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateOrderRequest {

    @NotNull
    private Long shopId;

    @NotBlank
    private String shippingAddress;

    private String voucherCode;

    @NotNull
    private PaymentMethod paymentMethod;
}