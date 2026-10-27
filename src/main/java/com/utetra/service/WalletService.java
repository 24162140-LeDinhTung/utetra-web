package com.utetra.service;

import com.utetra.entity.Shop;
import com.utetra.entity.Wallet;
import com.utetra.entity.WalletTransaction;
import java.math.BigDecimal;
import java.util.List;

public interface WalletService {
    Wallet createWallet(Shop shop);
    Wallet getWalletByShop(Long shopId);
    void addMoney(Long shopId, BigDecimal amount, String description);
    void deductMoney(Long shopId, BigDecimal amount, String description);
    List<WalletTransaction> getTransactionHistory(Long walletId);
}