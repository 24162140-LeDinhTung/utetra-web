package com.utetra.controller.admin;

import com.utetra.entity.Category;
import com.utetra.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/categories")
@RequiredArgsConstructor
public class AdminCategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public List<Category> getAll() {
        return categoryService.getAll();
    }

    @GetMapping("/{id}")
    public Category getById(@PathVariable Long id) {
        return categoryService.getById(id);
    }

    @PostMapping
    public Category create(@RequestParam String name,
                            @RequestParam String slug,
                            @RequestParam(required = false) Long parentId) {
        return categoryService.create(name, slug, parentId);
    }

    @PutMapping("/{id}")
    public Category update(@PathVariable Long id,
                            @RequestParam String name,
                            @RequestParam String slug,
                            @RequestParam(required = false) Long parentId) {
        return categoryService.update(id, name, slug, parentId);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        categoryService.softDelete(id);
    }
}