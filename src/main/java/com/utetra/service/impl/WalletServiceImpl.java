package com.utetra.service.impl;

import com.utetra.entity.Shop;
import com.utetra.entity.Wallet;
import com.utetra.entity.WalletTransaction;
import com.utetra.enums.WalletTxType;
import com.utetra.repository.WalletRepository;
import com.utetra.repository.WalletTransactionRepository;
import com.utetra.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class WalletServiceImpl implements WalletService {

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private WalletTransactionRepository transactionRepository;

    @Override
    public Wallet createWallet(Shop shop) {
        Wallet wallet = new Wallet();
        wallet.setShop(shop);
        wallet.setBalance(BigDecimal.ZERO);
        return walletRepository.save(wallet);
    }

    @Override
    public Wallet getWalletByShop(Long shopId) {
        return walletRepository.findByShopId(shopId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy ví của shop"));
    }

    @Override
    @Transactional
    public void addMoney(Long shopId, BigDecimal amount, String description) {
        if (amount == null || amount.signum() <= 0) throw new IllegalArgumentException("Số tiền phải lớn hơn 0");
        Wallet wallet = walletRepository.lockByShopId(shopId).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy ví"));
        wallet.setBalance(wallet.getBalance().add(amount));
        walletRepository.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setAmount(amount);
        tx.setBalanceAfter(wallet.getBalance()); // <-- ĐÃ THÊM DÒNG NÀY
        tx.setType(WalletTxType.ORDER_INCOME);
        tx.setDescription(description);
        transactionRepository.save(tx);
    }

    @Override
    @Transactional
    public void deductMoney(Long shopId, BigDecimal amount, String description) {
        if (amount == null || amount.signum() <= 0) throw new IllegalArgumentException("Số tiền phải lớn hơn 0");
        Wallet wallet = walletRepository.lockByShopId(shopId).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy ví"));
        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Số dư trong ví không đủ");
        }
        wallet.setBalance(wallet.getBalance().subtract(amount));
        walletRepository.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setAmount(amount.negate());
        tx.setBalanceAfter(wallet.getBalance()); // <-- ĐÃ THÊM DÒNG NÀY
        tx.setType(WalletTxType.WITHDRAW);
        tx.setDescription(description);
        transactionRepository.save(tx);
    }

    @Override
    public List<WalletTransaction> getTransactionHistory(Long walletId) {
        return transactionRepository.findByWalletId(walletId);
    }
}
