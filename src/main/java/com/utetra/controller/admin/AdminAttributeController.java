package com.utetra.controller.admin;

import com.utetra.enums.ProductStatus;
import com.utetra.repository.ProductRepository;
import com.utetra.service.CatalogManagementService;
import com.utetra.service.CatalogManagementService.*;
import jakarta.validation.Valid;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class AdminAttributeController {
  private final CatalogManagementService catalog;
  private final ProductRepository products;

  @GetMapping("/api/admin/attributes")
  public List<AttributeOutput> list(@RequestParam Long productId) {
    return catalog.list(productId);
  }

  @PostMapping("/api/admin/attributes")
  public AttributeOutput create(@Valid @RequestBody AttributeInput r) {
    return catalog.save(null, r);
  }

  @PutMapping("/api/admin/attributes/{id}")
  public AttributeOutput update(@PathVariable Long id, @Valid @RequestBody AttributeInput r) {
    return catalog.save(id, r);
  }

  @DeleteMapping("/api/admin/attributes/{id}")
  public void delete(@PathVariable Long id) {
    catalog.delete(id);
  }

  @GetMapping("/api/admin/catalog/products")
  @Transactional(readOnly = true)
  public org.springframework.data.domain.Page<Map<String, Object>> products(
      @RequestParam(defaultValue = "0") int page) {
    return products
        .findAll(
            org.springframework.data.domain.PageRequest.of(
                Math.max(0, page),
                50,
                org.springframework.data.domain.Sort.by(
                    org.springframework.data.domain.Sort.Direction.DESC, "id")))
        .map(
            p ->
                Map.<String, Object>of(
                    "id",
                    p.getId(),
                    "name",
                    p.getName(),
                    "shopName",
                    p.getShop().getName(),
                    "status",
                    p.getStatus().name(),
                    "isDeleted",
                    Boolean.TRUE.equals(p.getIsDeleted())));
  }

  @PatchMapping("/api/admin/catalog/products/{id}/status")
  public void moderate(@PathVariable Long id, @RequestParam ProductStatus status) {
    catalog.moderate(id, status);
  }
}
