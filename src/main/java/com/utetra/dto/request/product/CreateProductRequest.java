package com.utetra.dto.request.product;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateProductRequest {

  @NotNull private Long categoryId;

  @NotBlank
  @jakarta.validation.constraints.Size(max = 255)
  private String name;

  private String description;

  @NotNull
  @Positive
  @jakarta.validation.constraints.Digits(integer = 10, fraction = 0)
  private BigDecimal price;

  @NotNull @PositiveOrZero private Integer stock;
}
