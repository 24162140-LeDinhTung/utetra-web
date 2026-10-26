package com.utetra.service;

import com.utetra.entity.WithdrawRequest;
import java.math.BigDecimal;
import java.util.List;

public interface WithdrawService {
    WithdrawRequest requestWithdraw(Long shopId, BigDecimal amount, String bankAccount);
    List<WithdrawRequest> getPendingRequests();
    void approveWithdraw(Long requestId);
    void rejectWithdraw(Long requestId);
}