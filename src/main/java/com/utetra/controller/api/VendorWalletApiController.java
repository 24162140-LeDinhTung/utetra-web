package com.utetra.controller.api;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.entity.Wallet;
import com.utetra.entity.WithdrawRequest;
import com.utetra.service.ShopService;
import com.utetra.service.WalletService;
import com.utetra.service.WithdrawService;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/vendor")
public class VendorWalletApiController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private WithdrawService withdrawService;

    @Autowired
    private ShopService shopService;

    @Autowired
    private UserRepository userRepository;

    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String email = (principal instanceof UserDetails) ? ((UserDetails) principal).getUsername() : principal.toString();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
    }

    // 1. Xem số dư ví của shop
    @GetMapping("/shops/{shopId}/wallet")
    public ResponseEntity<Wallet> getShopWallet(@PathVariable Long shopId) {
        // Kiểm tra quyền sở hữu (nên viết thêm hàm check)
        return ResponseEntity.ok(walletService.getWalletByShop(shopId));
    }

    // 2. Tạo yêu cầu rút tiền
    @PostMapping("/withdraw-requests")
    public ResponseEntity<?> requestWithdraw(
            @RequestParam Long shopId,
            @RequestParam BigDecimal amount,
            @RequestParam String bankAccount) {
        try {
            WithdrawRequest request = withdrawService.requestWithdraw(shopId, amount, bankAccount);
            return ResponseEntity.ok(request);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}