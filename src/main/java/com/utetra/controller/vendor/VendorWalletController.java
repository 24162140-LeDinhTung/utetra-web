package com.utetra.controller.vendor;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.entity.Wallet;
import com.utetra.entity.WalletTransaction;
import com.utetra.service.ShopService;
import com.utetra.service.WalletService;
import com.utetra.service.WithdrawService;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/vendor/wallet")
public class VendorWalletController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private ShopService shopService;

    @Autowired
    private WithdrawService withdrawService;

    @Autowired
    private UserRepository userRepository;

    private User getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) {
            return null;
        }
        return userRepository.findByEmail(authentication.getName()).orElse(null);
    }

    // 0. TỰ ĐỘNG CHUYỂN HƯỚNG (Dành cho nút bấm trên Sidebar)
    @GetMapping
    public String redirectToWallet(Authentication authentication) {
        User owner = getCurrentUser(authentication);
        if (owner == null) return "redirect:/auth/login";

        List<Shop> shops = shopService.getShopsByOwner(owner.getId());
        if (shops.isEmpty()) return "redirect:/vendor/my-shops?error=noShop";

        return "redirect:/vendor/wallet/shops/" + shops.get(0).getId();
    }

    // 1. Xem ví và lịch sử giao dịch
    @GetMapping("/shops/{shopId}")
    public String viewWallet(@PathVariable Long shopId, Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);
        if (owner == null) return "redirect:/auth/login";

        Shop shop = shopService.getShopById(shopId);
        Wallet wallet = walletService.getWalletByShop(shopId);
        List<WalletTransaction> transactions = walletService.getTransactionHistory(wallet.getId());

        // === THÊM DÒNG NÀY ĐỂ LẤY DANH SÁCH SHOP CHO DROPDOWN ===
        List<Shop> shops = shopService.getShopsByOwner(owner.getId());
        model.addAttribute("shops", shops);
        // ========================================================

        model.addAttribute("shop", shop);
        model.addAttribute("wallet", wallet);
        model.addAttribute("transactions", transactions);
        return "vendor/wallet";
    }

    // 2. Hiển thị form yêu cầu rút tiền
    @GetMapping("/withdraw/create")
    public String showWithdrawForm(@RequestParam(required = false) Long shopId, 
                                   Authentication authentication, 
                                   Model model) {
        User owner = getCurrentUser(authentication);
        if (owner == null) return "redirect:/auth/login";

        List<Shop> shops = shopService.getShopsByOwner(owner.getId());
        if (shops.isEmpty()) return "redirect:/vendor/my-shops?error=noShop";

        if (shopId == null) {
            shopId = shops.get(0).getId();
        }

        model.addAttribute("shops", shops);
        model.addAttribute("selectedShopId", shopId);
        return "vendor/withdraw-request";
    }

    // 3. Xử lý yêu cầu rút tiền
    @PostMapping("/withdraw/save")
    public String processWithdraw(
            @RequestParam Long shopId,
            @RequestParam BigDecimal amount,
            @RequestParam String bankAccount,
            RedirectAttributes redirectAttributes) {
        try {
            withdrawService.requestWithdraw(shopId, amount, bankAccount);
            redirectAttributes.addFlashAttribute("message", "Gửi yêu cầu rút tiền thành công!");
            return "redirect:/vendor/wallet/shops/" + shopId;
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/vendor/wallet/withdraw/create?shopId=" + shopId;
        }
    }
}