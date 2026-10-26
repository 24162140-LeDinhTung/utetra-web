package com.utetra.service.impl;

import com.utetra.entity.Wallet;
import com.utetra.entity.WithdrawRequest;
import com.utetra.repository.WithdrawRequestRepository;
import com.utetra.service.WalletService;
import com.utetra.service.WithdrawService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WithdrawServiceImpl implements WithdrawService {

    @Autowired
    private WithdrawRequestRepository withdrawRepository;

    @Autowired
    private WalletService walletService;

    @Override
    @Transactional
    public WithdrawRequest requestWithdraw(Long shopId, BigDecimal amount, String bankAccount) {
        Wallet wallet = walletService.getWalletByShop(shopId);
        if (wallet.getBalance().compareTo(amount) < 0) {
            throw new RuntimeException("Số dư không đủ để rút");
        }

        WithdrawRequest request = new WithdrawRequest();
        request.setWallet(wallet);
        request.setAmount(amount);
        request.setBankAccount(bankAccount);
        request.setStatus("PENDING");
        
        walletService.deductMoney(shopId, amount, "Tạo yêu cầu rút tiền chờ duyệt");
        return withdrawRepository.save(request);
    }

    @Override
    public List<WithdrawRequest> getPendingRequests() {
        return withdrawRepository.findAll().stream()
                .filter(r -> "PENDING".equals(r.getStatus()))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void approveWithdraw(Long requestId) {
        WithdrawRequest request = withdrawRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        request.setStatus("APPROVED");
        withdrawRepository.save(request);
    }

    @Override
    @Transactional
    public void rejectWithdraw(Long requestId) {
        WithdrawRequest request = withdrawRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
        request.setStatus("REJECTED");
        withdrawRepository.save(request);
        
        walletService.addMoney(request.getWallet().getShop().getId(), request.getAmount(), "Hoàn tiền do từ chối rút");
    }
}