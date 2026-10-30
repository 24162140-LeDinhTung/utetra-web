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

    @Autowired private com.utetra.service.ProductService catalog;
    @Autowired private com.utetra.repository.CategoryRepository categories;

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
    public String shopDetail(@PathVariable Long id, @jakarta.validation.Valid @org.springframework.web.bind.annotation.ModelAttribute("search") com.utetra.dto.request.product.ProductSearchRequest search, Model model) {
        Shop shop = shopRepository.findById(id)
            .filter(s -> s.getStatus() == ShopStatus.ACTIVE && !Boolean.TRUE.equals(s.getIsDeleted()))
            .orElseThrow(() -> new com.utetra.exception.custom.ResourceNotFoundException("Không tìm thấy cửa hàng đang hoạt động"));
        // The path determines the shop; a query parameter cannot switch the search to another shop.
        search.setShopId(id);
        var result = catalog.search(search);
        var ids = result.getItems().stream().map(com.utetra.dto.response.product.ProductResponse::getId).toList();
        var indexed = productRepository.findAllById(ids).stream()
            .collect(java.util.stream.Collectors.toMap(Product::getId, p -> p));
        model.addAttribute("shop", shop);
        var displayed = ids.stream().map(indexed::get).toList();
        // JSP renders after this read transaction closes; load its image and option collections here.
        for (Product product : displayed) {
            org.hibernate.Hibernate.initialize(product.getImages());
            product.getAttributes().forEach(a -> org.hibernate.Hibernate.initialize(a.getValues()));
        }
        model.addAttribute("products", displayed);
        model.addAttribute("result", result);
        model.addAttribute("categories", categories.findByIsDeletedFalseOrderByNameAsc());
        return "guest/shop-detail";
    }
}
