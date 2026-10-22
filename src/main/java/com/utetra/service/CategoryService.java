package com.utetra.service;

import com.utetra.entity.Category;

import java.util.List;

public interface CategoryService {

    Category create(String name, String slug, Long parentId);

    Category update(Long id, String name, String slug, Long parentId);

    void softDelete(Long id);

    Category getById(Long id);

    List<Category> getAll();
}