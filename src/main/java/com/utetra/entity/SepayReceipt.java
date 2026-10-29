package com.utetra.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

/** A bank event can settle only one payment, even across concurrent webhook deliveries. */
@Entity
@Table(name = "sepay_receipts")
@Getter @Setter
public class SepayReceipt {
  @Id private Long id;
  @Column(nullable = false, length = 100) private String paymentReference;
}
