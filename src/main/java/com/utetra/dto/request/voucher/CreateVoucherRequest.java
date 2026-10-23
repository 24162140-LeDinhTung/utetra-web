package com.utetra.dto.request.voucher;

import com.utetra.enums.DiscountType;
import com.utetra.enums.VoucherType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateVoucherRequest {

  @NotBlank private String code;

  @NotNull private VoucherType voucherType;

  @NotNull private DiscountType discountType;

  @NotNull
  @Positive
  @jakarta.validation.constraints.Digits(integer = 10, fraction = 2)
  private BigDecimal discountValue;

  private BigDecimal minOrderAmount;

  private BigDecimal maxDiscountAmount;

  private Integer usageLimit;

  @NotNull private LocalDateTime startDate;

  @NotNull private LocalDateTime endDate;
}
