package com.utetra.dto.request.order;

import com.utetra.enums.OrderStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateOrderStatusRequest {

  @NotNull private OrderStatus status;

  @jakarta.validation.constraints.Size(max = 255)
  private String note;
}
