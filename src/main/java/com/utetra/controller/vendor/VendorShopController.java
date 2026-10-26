package com.utetra.controller.vendor;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.service.ShopService;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/vendor/shops")
public class VendorShopController {

    @Autowired
    private ShopService shopService;

    @Autowired
    private UserRepository userRepository;

    // Hàm lấy User đang đăng nhập
    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String email = (principal instanceof UserDetails) ? ((UserDetails) principal).getUsername() : principal.toString();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("Không tìm thấy user"));
    }

    // 1. Hiển thị danh sách Shop
    @GetMapping
    public String listShops(Model model) {
        User owner = getCurrentUser();
        List<Shop> shops = shopService.getShopsByOwner(owner.getId());
        model.addAttribute("shops", shops);
        return "vendor/shop-list"; // Trả về file /WEB-INF/views/vendor/shop-list.jsp
    }

    // 2. Hiển thị form tạo Shop
    @GetMapping("/create")
    public String showCreateForm(Model model) {
        model.addAttribute("shop", new Shop());
        return "vendor/shop-form";
    }

    // 3. Hiển thị form sửa Shop
    @GetMapping("/edit/{id}")
    public String showEditForm(@PathVariable Long id, Model model) {
        Shop shop = shopService.getShopById(id);
        // Kiểm tra quyền sở hữu
        if (!shop.getOwner().getId().equals(getCurrentUser().getId())) {
            return "redirect:/vendor/shops?error=unauthorized";
        }
        model.addAttribute("shop", shop);
        return "vendor/shop-form";
    }

    // 4. Xử lý Lưu (Thêm mới hoặc Cập nhật)
    @PostMapping("/save")
    public String saveShop(@ModelAttribute Shop shopForm) {
        User owner = getCurrentUser();
        
        if (shopForm.getId() == null) {
            // Tạo mới
            shopService.createShop(owner, shopForm.getName(), shopForm.getDescription());
        } else {
            // Cập nhật
            shopService.updateShop(shopForm.getId(), shopForm.getName(), shopForm.getDescription(), 
                                   shopForm.getAvatarUrl(), shopForm.getCoverUrl());
        }
        return "redirect:/vendor/shops"; // Quay lại trang danh sách
    }
}