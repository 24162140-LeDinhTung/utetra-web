package com.utetra.controller.api;

import com.utetra.dto.request.product.ProductSearchRequest;
import com.utetra.dto.response.product.ProductDetailResponse;
import com.utetra.dto.response.product.ProductSearchResponse;
import com.utetra.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductApiController {

    private final ProductService productService;

    @GetMapping
    public ProductSearchResponse search(ProductSearchRequest request) {
        return productService.search(request);
    }

    @GetMapping("/home")
    public ProductSearchResponse getHomeProducts() {
        return productService.getHomeProducts();
    }

    @GetMapping("/{id}")
    public ProductDetailResponse getDetail(@PathVariable Long id) {
        return productService.getDetail(id, null);
    }
}