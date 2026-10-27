package com.utetra.entity;

import com.utetra.enums.*;
import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "payment_transactions")
@Getter
@Setter
public class PaymentTransaction extends BaseEntity {
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "order_id", nullable = false)
  private Order order;

  @Column(nullable = false, unique = true, length = 100)
  private String reference;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 50)
  private PaymentMethod provider;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 50)
  private PaymentStatus status = PaymentStatus.PENDING;

  @Column(nullable = false, precision = 12, scale = 2)
  private BigDecimal amount;

  @Column(name = "gateway_transaction_id", length = 100)
  private String gatewayTransactionId;

  @Column(name = "payment_url", columnDefinition = "TEXT")
  private String paymentUrl;

  @Column(name = "result_code", length = 50)
  private String resultCode;
}
