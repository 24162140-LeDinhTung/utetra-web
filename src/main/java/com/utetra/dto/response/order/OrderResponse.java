package com.utetra.dto.response.order;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
public class OrderResponse {

    private Long id;
    private String orderCode;
    private String shopName;
    private BigDecimal totalAmount;
    private String status;
    private String paymentMethod;
    private String paymentStatus;
    private LocalDateTime createdAt;
}