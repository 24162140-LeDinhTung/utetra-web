package com.utetra.controller.admin;

import com.utetra.entity.Shop;
import com.utetra.enums.ShopStatus;
import com.utetra.service.ShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin/shops")
public class AdminShopController {

    @Autowired
    private ShopService shopService;

    // 1. Hiển thị danh sách shop chờ duyệt
    @GetMapping
    public String listShops(@RequestParam(defaultValue = "0") int page, Model model) {
        Page<Shop> shopPage = shopService.getShopsByStatus(ShopStatus.PENDING, PageRequest.of(page, 10));
        model.addAttribute("shops", shopPage.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", shopPage.getTotalPages());
        return "admin/shop-list";
    }

    // 2. Cập nhật trạng thái Shop
    @PostMapping("/update-status")
    public String updateStatus(@RequestParam Long shopId, @RequestParam ShopStatus status) {
        shopService.updateShopStatus(shopId, status);
        return "redirect:/admin/shops";
    }
}