package com.utetra.dto.request.order;

import com.utetra.enums.PaymentMethod;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateOrderRequest {

  @NotNull private Long shopId;

  @jakarta.validation.constraints.Positive
  private Long promotionId;

  @jakarta.validation.constraints.Size(min = 1, max = 500)
  private java.util.List<@NotNull @jakarta.validation.constraints.Positive Long> cartItemIds;

  @NotBlank(message = "Bạn chưa nhập địa chỉ nhận hàng.")
  @jakarta.validation.constraints.Size(max = 2000)
  private String shippingAddress;

  @jakarta.validation.constraints.PositiveOrZero
  @jakarta.validation.constraints.Digits(integer = 10, fraction = 2)
  private java.math.BigDecimal expectedTotalAmount;

  @jakarta.validation.constraints.Size(max = 50)
  private String voucherCode;

  @NotNull private PaymentMethod paymentMethod;
}
