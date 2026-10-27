package com.utetra.controller.guest;

import com.utetra.entity.Product;
import com.utetra.entity.Shop;
import com.utetra.enums.ProductStatus;
import com.utetra.enums.ShopStatus;
import com.utetra.repository.ProductRepository;
import com.utetra.repository.ShopRepository;
import com.utetra.service.ShopService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class HomeController {

    @Autowired
    private ShopRepository shopRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private ShopService shopService;

    // 1. Trang chủ hiển thị danh sách Shop
    @GetMapping("/")
    public String home(Model model) {
        List<Shop> shops = shopRepository.findByStatusAndIsDeletedFalse(ShopStatus.ACTIVE);
        Map<Long, Long> productCounts = new HashMap<>();
        for (Shop shop : shops) {
            long count = productRepository.countByShopIdAndStatusAndIsDeletedFalse(shop.getId(), ProductStatus.ACTIVE);
            productCounts.put(shop.getId(), count);
        }
        model.addAttribute("shops", shops);
        model.addAttribute("productCounts", productCounts);
        return "guest/home";
    }

    // 2. Trang danh sách sản phẩm (dùng cho cả trang danh mục và tìm kiếm)
    @GetMapping("/products")
    public String productList() {
        return "guest/product-list";
    }

    // 3. Trang chi tiết sản phẩm (có ID)
    @GetMapping("/products/{id}")
    public String productDetail(@PathVariable Long id) {
        return "guest/product-detail";
    }

   

    // 5. Trang chi tiết cửa hàng (click vào Shop ở trang chủ)
    @Transactional(readOnly = true) 
    @GetMapping("/shops/{id}")
    public String shopDetail(@PathVariable Long id, Model model) {
        Shop shop = shopService.getShopById(id);
        if (shop == null) {
            return "redirect:/";
        }
        List<Product> products = productRepository.findByShopIdAndStatusAndIsDeletedFalse(id, ProductStatus.ACTIVE);
        model.addAttribute("shop", shop);
        model.addAttribute("products", products);
        return "guest/shop-detail";
    }
}