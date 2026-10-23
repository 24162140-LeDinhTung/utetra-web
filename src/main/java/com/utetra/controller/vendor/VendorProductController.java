package com.utetra.controller.vendor;

import com.utetra.dto.request.product.*;
import com.utetra.dto.response.product.*;
import com.utetra.security.UserPrincipal;
import com.utetra.service.*;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/vendor/shops/{shopId}/products")
@RequiredArgsConstructor
public class VendorProductController {
  private final ProductService products;
  private final CommerceAccess access;
  private final CatalogManagementService catalog;

  @GetMapping("/{id}/images")
  public java.util.List<Map<String, Object>> images(
      @PathVariable Long shopId, @PathVariable Long id, @AuthenticationPrincipal UserPrincipal u) {
    return catalog.listImages(shopId, u.getId(), id);
  }

  @GetMapping
  public ProductSearchResponse list(
      @PathVariable Long shopId,
      @AuthenticationPrincipal UserPrincipal u,
      @RequestParam(defaultValue = "0") int page) {
    return products.getVendorProducts(
        shopId,
        u.getId(),
        PageRequest.of(Math.max(0, page), 20, Sort.by(Sort.Direction.DESC, "id")));
  }

  @GetMapping("/{id}")
  public ProductDetailResponse detail(
      @PathVariable Long shopId, @PathVariable Long id, @AuthenticationPrincipal UserPrincipal u) {
    return products.getVendorDetail(shopId, id, u.getId());
  }

  @PostMapping
  public Map<String, Long> create(
      @PathVariable Long shopId,
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody CreateProductRequest r) {
    return Map.of("id", products.create(shopId, u.getId(), r).getId());
  }

  @PutMapping("/{id}")
  public Map<String, Long> update(
      @PathVariable Long shopId,
      @PathVariable Long id,
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody UpdateProductRequest r) {
    products.getVendorDetail(shopId, id, u.getId());
    return Map.of("id", products.update(id, u.getId(), r).getId());
  }

  @DeleteMapping("/{id}")
  public void delete(
      @PathVariable Long shopId, @PathVariable Long id, @AuthenticationPrincipal UserPrincipal u) {
    products.getVendorDetail(shopId, id, u.getId());
    products.softDeleteProduct(id, u.getId());
  }

  @PostMapping("/{id}/images")
  public Map<String, Object> upload(
      @PathVariable Long shopId,
      @PathVariable Long id,
      @AuthenticationPrincipal UserPrincipal u,
      @RequestParam MultipartFile file) {
    return catalog.upload(shopId, u.getId(), id, file);
  }

  @DeleteMapping("/{id}/images/{imageId}")
  public void removeImage(
      @PathVariable Long shopId,
      @PathVariable Long id,
      @PathVariable Long imageId,
      @AuthenticationPrincipal UserPrincipal u) {
    catalog.removeImage(shopId, u.getId(), id, imageId);
  }
}
