package com.utetra.controller.admin;

import com.utetra.dto.response.CommerceDtos.CategoryItem;
import com.utetra.entity.Category;
import com.utetra.service.CategoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/categories")
@RequiredArgsConstructor
@Transactional
public class AdminCategoryController {
  private final CategoryService service;

  private CategoryItem dto(Category c) {
    return new CategoryItem(
        c.getId(), c.getName(), c.getSlug(), c.getParent() == null ? null : c.getParent().getId());
  }

  @GetMapping
  public List<CategoryItem> list() {
    return service.getAll().stream().map(this::dto).toList();
  }

  @GetMapping("/{id}")
  public CategoryItem get(@PathVariable Long id) {
    return dto(service.getById(id));
  }

  @PostMapping
  public CategoryItem create(
      @RequestParam String name,
      @RequestParam String slug,
      @RequestParam(required = false) Long parentId) {
    return dto(service.create(name, slug, parentId));
  }

  @PutMapping("/{id}")
  public CategoryItem update(
      @PathVariable Long id,
      @RequestParam String name,
      @RequestParam String slug,
      @RequestParam(required = false) Long parentId) {
    return dto(service.update(id, name, slug, parentId));
  }

  @DeleteMapping("/{id}")
  public void delete(@PathVariable Long id) {
    service.softDelete(id);
  }
}
