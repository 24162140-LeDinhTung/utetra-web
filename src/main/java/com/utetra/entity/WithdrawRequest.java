package com.utetra.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "withdraw_requests")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class WithdrawRequest extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id")
    private Wallet wallet;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(length = 50)
    private String status; // PENDING, APPROVED, REJECTED

    @Column(name = "bank_account")
    private String bankAccount;
}