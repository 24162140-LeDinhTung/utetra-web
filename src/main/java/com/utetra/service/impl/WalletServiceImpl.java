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
        // Tìm ví theo shopId. Nếu Repo chưa có hàm này, bạn cần thêm vào WalletRepository:
        // Wallet findByShopId(Long shopId);
        return walletRepository.findAll().stream()
                .filter(w -> w.getShop().getId().equals(shopId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Không tìm thấy ví của shop"));
    }

    @Override
    @Transactional
    public void addMoney(Long shopId, BigDecimal amount, String description) {
        Wallet wallet = getWalletByShop(shopId);
        wallet.setBalance(wallet.getBalance().add(amount));
        walletRepository.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setAmount(amount);
        tx.setType(WalletTxType.ORDER_INCOME); // Hoặc truyền Type vào hàm
        tx.setDescription(description);
        transactionRepository.save(tx);
    }

    @Override
    @Transactional
    public void deductMoney(Long shopId, BigDecimal amount, String description) {
        Wallet wallet = getWalletByShop(shopId);
        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Số dư trong ví không đủ");
        }
        wallet.setBalance(wallet.getBalance().subtract(amount));
        walletRepository.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setAmount(amount.negate());
        tx.setType(WalletTxType.WITHDRAW);
        tx.setDescription(description);
        transactionRepository.save(tx);
    }

    @Override
    public List<WalletTransaction> getTransactionHistory(Long walletId) {
        return transactionRepository.findAll(); // Bạn cần thêm hàm findByWalletId vào Repo
    }
}