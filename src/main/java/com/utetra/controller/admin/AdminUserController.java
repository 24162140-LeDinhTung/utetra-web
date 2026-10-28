package com.utetra.controller.admin;

import com.utetra.entity.Shop;
import com.utetra.repository.ShopRepository;
import com.utetra.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@Controller
@RequestMapping("/admin/users")
public class AdminUserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ShopRepository shopRepository;

    @GetMapping
    public String listUsers(Model model) {
        model.addAttribute("users", userRepository.findAll());
        model.addAttribute("allShops", shopRepository.findAll().stream().filter(s -> !s.getIsDeleted()).toList());
        return "admin/user-list"; 
    }

    @PostMapping(value = "/shops/delete", produces = "application/json")
    @Transactional 
    public ResponseEntity<?> deleteShop(@RequestParam(required = false) Long shopId) {
        if (shopId == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Thiếu ID của Shop!"));
        }

        try {
            Shop shop = shopRepository.findById(shopId).orElse(null);
            if (shop != null) {
                shop.setIsDeleted(true); 
                shopRepository.save(shop);
                return ResponseEntity.ok(Map.of("message", "Xóa cửa hàng thành công!"));
            }
            return ResponseEntity.badRequest().body(Map.of("message", "Không tìm thấy shop này trong hệ thống."));
        } catch (Exception e) {
            // In chi tiết lỗi ra màn hình Console của Eclipse
            System.out.println("=== LỖI XÓA SHOP ===");
            e.printStackTrace();
            System.out.println("====================");
            
            // Trả về thông báo lỗi cho Javascript
            return ResponseEntity.internalServerError().body(Map.of("message", "Lỗi Database: Không thể xóa Shop này do vướng dữ liệu liên quan (Sản phẩm, Ví, v.v...)."));
        }
    }
}