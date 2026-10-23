package com.utetra.controller.api;

import com.utetra.dto.response.CommerceDtos.*;
import com.utetra.repository.*;
import com.utetra.security.UserPrincipal;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CatalogApiController {
  private final CategoryRepository categories;
  private final ShopRepository shops;

  @GetMapping("/api/categories")
  public List<CategoryItem> categories() {
    return categories.findByIsDeletedFalseOrderByNameAsc().stream()
        .map(
            c ->
                new CategoryItem(
                    c.getId(),
                    c.getName(),
                    c.getSlug(),
                    c.getParent() == null ? null : c.getParent().getId()))
        .toList();
  }

  @GetMapping("/api/vendor/catalog/shops")
  public List<ShopItem> owned(@AuthenticationPrincipal UserPrincipal u) {
    return shops.findByOwnerIdAndIsDeletedFalse(u.getId()).stream()
        .map(s -> new ShopItem(s.getId(), s.getName()))
        .toList();
  }
}
