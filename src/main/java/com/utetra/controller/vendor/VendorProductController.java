package com.utetra.controller.vendor;

import com.utetra.dto.request.product.CreateProductRequest;
import com.utetra.dto.request.product.UpdateProductRequest;
import com.utetra.entity.Product;
import com.utetra.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/vendor/shops/{shopId}/products")
@RequiredArgsConstructor
public class VendorProductController {

    private final ProductService productService;

    @PostMapping
    public Product create(@PathVariable Long shopId, @Valid @RequestBody CreateProductRequest request) {
        return productService.create(shopId, request);
    }

    @PutMapping("/{id}")
    public Product update(@PathVariable Long shopId, @PathVariable Long id,
                           @Valid @RequestBody UpdateProductRequest request) {
        return productService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long shopId, @PathVariable Long id) {
        productService.softDeleteProduct(id);
    }
}