package com.utetra.service.impl;

import com.utetra.entity.Category;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.CategoryRepository;
import com.utetra.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    public Category create(String name, String slug, Long parentId) {
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
        return categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + id));
    }

    @Override
    public List<Category> getAll() {
        return categoryRepository.findAll();
    }
}