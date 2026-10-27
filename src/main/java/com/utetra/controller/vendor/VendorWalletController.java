package com.utetra.controller.vendor;

import com.utetra.entity.Shop;
import com.utetra.entity.Wallet;
import com.utetra.entity.WalletTransaction;
import com.utetra.entity.WithdrawRequest;
import com.utetra.service.ShopService;
import com.utetra.service.WalletService;
import com.utetra.service.WithdrawService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/vendor")
public class VendorWalletController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private ShopService shopService;

    @Autowired
    private WithdrawService withdrawService;

    // 1. Xem ví và lịch sử giao dịch
    @GetMapping("/shops/{shopId}/wallet")
    public String viewWallet(@PathVariable Long shopId, Model model) {
        Shop shop = shopService.getShopById(shopId);
        Wallet wallet = walletService.getWalletByShop(shopId);
        List<WalletTransaction> transactions = walletService.getTransactionHistory(wallet.getId());

        model.addAttribute("shop", shop);
        model.addAttribute("wallet", wallet);
        model.addAttribute("transactions", transactions);
        return "vendor/wallet";
    }

    // 2. Hiển thị form yêu cầu rút tiền
    @GetMapping("/withdraw/create")
    public String showWithdrawForm(@RequestParam Long shopId, Model model) {
        model.addAttribute("shopId", shopId);
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
            return "redirect:/vendor/shops/" + shopId + "/wallet";
        } catch (RuntimeException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/vendor/withdraw/create?shopId=" + shopId;
        }
    }
}