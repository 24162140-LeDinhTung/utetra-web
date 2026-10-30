package com.utetra.controller.vendor;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.service.ShopService;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/vendor/my-shops") // <-- ĐÃ SỬA THÀNH /my-shops CHO KHỚP VỚI URL VÀ SIDEBAR
public class VendorShopController {

    @Autowired
    private ShopService shopService;

    @Autowired
    private UserRepository userRepository;

    // Hàm lấy User đang đăng nhập an toàn
    private User getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || authentication.getPrincipal().equals("anonymousUser")) {
            return null;
        }
        String email = authentication.getName();
        return userRepository.findByEmail(email).orElse(null);
    }

    // 1. Hiển thị danh sách Shop
    @GetMapping
    public String listShops(Authentication authentication, Model model) {
        User owner = getCurrentUser(authentication);

        if (owner == null) {
            return "redirect:/auth/login";
        }

        System.out.println(">>> ID User đang đăng nhập: " + owner.getId() + " - Email: " + owner.getEmail());

        List<Shop> shops = shopService.getShopsByOwner(owner.getId());

        System.out.println(">>> Số lượng shop tìm thấy: " + shops.size());

        model.addAttribute("shops", shops);
        return "vendor/shop-list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication authentication) {
        User owner = getCurrentUser(authentication);
        if (owner == null) return "redirect:/auth/login";
        Shop shop = shopService.getShopById(id);
        if (Boolean.TRUE.equals(shop.getIsDeleted()) || !shop.getOwner().getId().equals(owner.getId()))
            throw new org.springframework.security.access.AccessDeniedException("Cửa hàng không thuộc bạn");
        model.addAttribute("shop", shop);
        model.addAttribute("backUrl", "/vendor/my-shops");
        return "vendor/shop-detail";
    }

    // 2. Hiển thị form tạo Shop
    @GetMapping("/create")
    public String showCreateForm(Model model) {
        model.addAttribute("shop", new Shop());
        return "vendor/shop-form";
    }

    // 3. Hiển thị form sửa Shop
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model, Authentication authentication) {
        User owner = getCurrentUser(authentication);
        if (owner == null) {
            return "redirect:/auth/login";
        }

        Shop shop = shopService.getShopById(id);
        // Kiểm tra quyền sở hữu
        if (!shop.getOwner().getId().equals(owner.getId())) {
            return "redirect:/vendor/my-shops?error=unauthorized"; // <-- SỬA REDIRECT
        }
        model.addAttribute("shop", shop);
        return "vendor/shop-form";
    }

    // 4. Xử lý Lưu (Thêm mới hoặc Cập nhật)
    @PostMapping("/save")
    public String saveShop(@ModelAttribute Shop shopForm, Authentication authentication) {
        User owner = getCurrentUser(authentication);
        if (owner == null) {
            return "redirect:/auth/login";
        }

        if (shopForm.getId() == null) {
            shopService.createShop(owner, shopForm.getName(), shopForm.getDescription());
        } else {
            shopService.updateShop(shopForm.getId(), shopForm.getName(), shopForm.getDescription(),
                                   shopForm.getAvatarUrl(), shopForm.getCoverUrl());
        }
        return "redirect:/vendor/my-shops"; // <-- SỬA REDIRECT
    }
}
