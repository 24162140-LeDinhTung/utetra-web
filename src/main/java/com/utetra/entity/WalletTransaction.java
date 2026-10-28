package com.utetra.entity;

import com.utetra.enums.WalletTxType;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "wallet_transactions", uniqueConstraints = @UniqueConstraint(name = "uk_wallet_order_type", columnNames = {"order_id", "type"}))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class WalletTransaction extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id")
    private Wallet wallet;

    @Column(name = "order_id")
    private Long orderId;

    @Column(nullable = false)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private WalletTxType type;
    @Column(name = "balance_after", nullable = false)
    private BigDecimal balanceAfter;

    @Column(name = "note")
    private String description;
}
