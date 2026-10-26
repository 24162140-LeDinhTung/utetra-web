package com.utetra.controller.api;

import com.utetra.entity.Shop;
import com.utetra.entity.User;
import com.utetra.service.ShopService;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vendor/shops")
public class VendorShopApiController {

    @Autowired
    private ShopService shopService;

    @Autowired
    private UserRepository userRepository;

    // Hàm phụ trợ: Lấy User đang đăng nhập từ Token
    private User getCurrentUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String email;
        if (principal instanceof UserDetails) {
            email = ((UserDetails) principal).getUsername();
        } else {
            email = principal.toString();
        }
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));
    }

    // 1. Tạo shop mới
    @PostMapping
    public ResponseEntity<Shop> createShop(@RequestParam String name, 
                                           @RequestParam(required = false) String description) {
        User owner = getCurrentUser();
        Shop shop = shopService.createShop(owner, name, description);
        return ResponseEntity.ok(shop);
    }

    // 2. Lấy danh sách shop của tôi
    @GetMapping
    public ResponseEntity<List<Shop>> getMyShops() {
        User owner = getCurrentUser();
        return ResponseEntity.ok(shopService.getShopsByOwner(owner.getId()));
    }

    // 3. Cập nhật thông tin shop
    @PutMapping("/{shopId}")
    public ResponseEntity<Shop> updateShop(
            @PathVariable Long shopId,
            @RequestParam String name,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String avatarUrl,
            @RequestParam(required = false) String coverUrl) {
        
        // Kiểm tra xem shop này có phải của user đang đăng nhập không
        User owner = getCurrentUser();
        Shop shop = shopService.getShopById(shopId);
        if (!shop.getOwner().getId().equals(owner.getId())) {
            return ResponseEntity.status(403).build(); // Forbidden
        }

        Shop updatedShop = shopService.updateShop(shopId, name, description, avatarUrl, coverUrl);
        return ResponseEntity.ok(updatedShop);
    }
}