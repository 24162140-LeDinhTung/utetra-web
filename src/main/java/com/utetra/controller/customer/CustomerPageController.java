package com.utetra.controller.customer;

import com.utetra.dto.response.product.ProductFavoriteResponse;
import com.utetra.security.UserPrincipal;
import com.utetra.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/customer")
@RequiredArgsConstructor
public class CustomerPageController {

    private final FavoriteService favoriteService;

    @GetMapping("/profile")
    public String profilePage() {
        return "customer/profile";
    }

    @GetMapping("/favorites")
    public String favoritesPage(@AuthenticationPrincipal UserPrincipal principal, Model model) {
        if (principal != null) {
            List<ProductFavoriteResponse> favorites = favoriteService.getFavoriteProducts(principal.getId());
            
            // --- DEBUG CONSOLE ---
            System.out.println("====== DEBUG TRANG YÊU THÍCH ======");
            System.out.println("Tài khoản ID: " + principal.getId());
            System.out.println("Số lượng sản phẩm tìm thấy: " + favorites.size());
            for (ProductFavoriteResponse item : favorites) {
                System.out.println("-> ID Sản phẩm: [" + item.getProductId() + "] | Tên: " + item.getProductName());
            }
            System.out.println("====================================");
            // ---------------------

            model.addAttribute("favorites", favorites);
        }
        return "customer/favorite-products";
    }
    
    @GetMapping("/history")
    public String historyPage(@AuthenticationPrincipal UserPrincipal principal, Model model) {
        if (principal != null) {
            List<ProductFavoriteResponse> history = favoriteService.getViewHistory(principal.getId());
            
            // --- DEBUG CONSOLE ---
            System.out.println("====== DEBUG LỊCH SỬ XEM ======");
            System.out.println("Số lượng sản phẩm tìm thấy: " + history.size());
            for (ProductFavoriteResponse item : history) {
                System.out.println("-> ID Sản phẩm: [" + item.getProductId() + "] | Tên: " + item.getProductName());
            }
            System.out.println("===============================");
            // ---------------------

            model.addAttribute("history", history);
        }
        return "customer/view-history";
    }
}