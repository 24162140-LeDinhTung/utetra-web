package com.utetra.repository;

import com.utetra.entity.WalletTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List; 

@Repository
public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {
    
    // Lấy lịch sử giao dịch của 1 ví
    List<WalletTransaction> findByWalletId(Long walletId);
}