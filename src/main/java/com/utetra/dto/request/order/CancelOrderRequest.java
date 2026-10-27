package com.utetra.dto.request.order;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CancelOrderRequest {

  @NotBlank
  @jakarta.validation.constraints.Size(max = 255)
  private String reason;
}
