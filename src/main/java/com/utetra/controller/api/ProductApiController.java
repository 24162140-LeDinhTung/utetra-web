package com.utetra.controller.api;

import com.utetra.dto.request.product.*;
import com.utetra.dto.response.product.*;
import com.utetra.security.UserPrincipal;
import com.utetra.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductApiController {
  private final ProductService products;

  @GetMapping
  public ProductSearchResponse search(@Valid @ModelAttribute ProductSearchRequest r) {
    return products.search(r);
  }

  @GetMapping("/home")
  public ProductSearchResponse home() {
    return products.getHomeProducts();
  }

  @GetMapping("/home/shops")
  public Page<ShopProductsResponse> homeShops(@RequestParam(defaultValue = "0") int page) {
    if (page < 0) throw new IllegalArgumentException("Trang không hợp lệ");
    return products.getHomeShops(PageRequest.of(page, 6, Sort.by("id")));
  }

  @GetMapping("/shop/{shopId}")
  public ProductSearchResponse shop(@PathVariable Long shopId) {
    return products.getProductsByShop(shopId);
  }

  @GetMapping("/{id}")
  public ProductDetailResponse detail(
      @PathVariable Long id, @AuthenticationPrincipal UserPrincipal u) {
    return products.getDetail(id, u == null ? null : u.getId());
  }
}
