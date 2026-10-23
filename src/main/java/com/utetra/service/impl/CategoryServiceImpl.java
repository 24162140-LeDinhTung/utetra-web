package com.utetra.service.impl;

import com.utetra.entity.Category;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.CategoryRepository;
import com.utetra.service.CategoryService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@org.springframework.transaction.annotation.Transactional
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

  private final CategoryRepository categoryRepository;

  @Override
  public Category create(String name, String slug, Long parentId) {
    validate(name, slug);
    Category category = new Category();
    category.setName(name);
    category.setSlug(slug);
    if (parentId != null) {
      Category parent = getById(parentId);
      category.setParent(parent);
    }
    return categoryRepository.save(category);
  }

  @Override
  public Category update(Long id, String name, String slug, Long parentId) {
    validate(name, slug);
    Category ancestor = parentId == null ? null : getById(parentId);
    java.util.Set<Long> seen = new java.util.HashSet<>();
    while (ancestor != null) {
      if (ancestor.getId().equals(id) || !seen.add(ancestor.getId()))
        throw new IllegalArgumentException("Danh má»¥c cha táº¡o vÃ²ng láº·p");
      ancestor = ancestor.getParent();
    }
    Category category = getById(id);
    category.setName(name);
    category.setSlug(slug);
    if (parentId != null) {
      category.setParent(getById(parentId));
    } else {
      category.setParent(null);
    }
    return categoryRepository.save(category);
  }

  @Override
  public void softDelete(Long id) {
    Category category = getById(id);
    category.setIsDeleted(true);
    categoryRepository.save(category);
  }

  @Override
  public Category getById(Long id) {
    return categoryRepository
        .findById(id)
        .filter(c -> !Boolean.TRUE.equals(c.getIsDeleted()))
        .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + id));
  }

  @Override
  public List<Category> getAll() {
    return categoryRepository.findByIsDeletedFalseOrderByNameAsc();
  }

  private void validate(String name, String slug) {
    if (name == null
        || name.isBlank()
        || name.length() > 255
        || slug == null
        || !slug.matches("[a-z0-9]+(?:-[a-z0-9]+)*"))
      throw new IllegalArgumentException("Tên hoặc slug danh mục không hợp lệ");
  }
}
