package com.utetra.controller.admin;

import com.utetra.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin/products") // Đường dẫn này
public class AdminProductController {

    @Autowired
    private ProductRepository productRepository;

    @GetMapping
    public String listProducts(Model model) {
        try {
            // Lấy toàn bộ sản phẩm
            model.addAttribute("products", productRepository.findAll());
            return "admin/product-list"; 
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "Lỗi tải danh sách sản phẩm: " + e.getMessage());
            return "admin/product-list";
        }
    }
}