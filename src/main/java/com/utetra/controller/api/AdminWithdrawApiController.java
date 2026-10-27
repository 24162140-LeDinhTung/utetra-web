package com.utetra.controller.api;

import com.utetra.entity.WithdrawRequest;
import com.utetra.service.WithdrawService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/withdraw-requests")
public class AdminWithdrawApiController {

    @Autowired
    private WithdrawService withdrawService;

    // 1. Lấy danh sách yêu cầu đang chờ duyệt
    @GetMapping
    public ResponseEntity<List<WithdrawRequest>> getPendingRequests() {
        return ResponseEntity.ok(withdrawService.getPendingRequests());
    }

    // 2. Duyệt yêu cầu
    @PatchMapping("/{requestId}/approve")
    public ResponseEntity<?> approve(@PathVariable Long requestId) {
        try {
            withdrawService.approveWithdraw(requestId);
            return ResponseEntity.ok("Đã duyệt yêu cầu rút tiền");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 3. Từ chối yêu cầu
    @PatchMapping("/{requestId}/reject")
    public ResponseEntity<?> reject(@PathVariable Long requestId) {
        try {
            withdrawService.rejectWithdraw(requestId);
            return ResponseEntity.ok("Đã từ chối yêu cầu rút tiền và hoàn tiền vào ví");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}