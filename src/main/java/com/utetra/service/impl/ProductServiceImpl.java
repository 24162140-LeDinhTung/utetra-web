package com.utetra.service.impl;

import com.utetra.dto.request.product.CreateProductRequest;
import com.utetra.dto.request.product.ProductSearchRequest;
import com.utetra.dto.request.product.UpdateProductRequest;
import com.utetra.dto.response.product.ProductDetailResponse;
import com.utetra.dto.response.product.ProductResponse;
import com.utetra.dto.response.product.ProductSearchResponse;
import com.utetra.entity.Category;
import com.utetra.entity.Product;
import com.utetra.entity.Shop;
import com.utetra.enums.ProductStatus;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.mapper.ProductMapper;
import com.utetra.repository.CategoryRepository;
import com.utetra.repository.ProductRepository;
import com.utetra.repository.ShopRepository;
import com.utetra.service.ProductService;
import com.utetra.util.SlugUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ShopRepository shopRepository;
    private final ProductMapper productMapper;

    @Override
    public Product create(Long shopId, CreateProductRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found: " + shopId));
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + request.getCategoryId()));

        Product product = new Product();
        product.setShop(shop);
        product.setCategory(category);
        product.setName(request.getName());
        product.setSlug(SlugUtil.toSlug(request.getName()));
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
        product.setSoldCount(0);
        product.setStatus(ProductStatus.PENDING);

        return productRepository.save(product);
    }

    @Override
    public Product update(Long id, UpdateProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + id));
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Category not found: " + request.getCategoryId()));

        product.setCategory(category);
        product.setName(request.getName());
        product.setSlug(SlugUtil.toSlug(request.getName()));
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());

        return productRepository.save(product);
    }

    @Override
    public void softDeleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + id));
        product.setIsDeleted(true);
        productRepository.save(product);
    }

    @Override
    public ProductDetailResponse getDetail(Long id, Long viewerUserId) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found: " + id));

        ProductDetailResponse response = new ProductDetailResponse();
        response.setId(product.getId());
        response.setName(product.getName());
        response.setSlug(product.getSlug());
        response.setDescription(product.getDescription());
        response.setPrice(product.getPrice());
        response.setStock(product.getStock());
        response.setSoldCount(product.getSoldCount());
        response.setStatus(product.getStatus().name());
        response.setCategoryId(product.getCategory().getId());
        response.setCategoryName(product.getCategory().getName());
        response.setShopId(product.getShop().getId());
        response.setShopName(product.getShop().getName());
        // imageUrls và attributes sẽ bổ sung khi có ProductImageService/ProductAttributeService
        return response;
    }

    @Override
    public ProductSearchResponse search(ProductSearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        Page<Product> page;

        if (request.getKeyword() != null && !request.getKeyword().isBlank()) {
            page = productRepository.findByNameContainingIgnoreCaseAndStatus(
                    request.getKeyword(), ProductStatus.ACTIVE, pageable);
        } else if (request.getCategoryId() != null) {
            page = productRepository.findByCategoryIdAndStatus(
                    request.getCategoryId(), ProductStatus.ACTIVE, pageable);
        } else if (request.getShopId() != null) {
            page = productRepository.findByShopIdAndStatus(
                    request.getShopId(), ProductStatus.ACTIVE, pageable);
        } else {
            page = productRepository.findAll(pageable);
        }

        return toSearchResponse(page);
    }

    @Override
    public ProductSearchResponse getHomeProducts() {
        // Sản phẩm bán chạy nhất, sort theo soldCount DESC (README mục 3.3)
        Pageable pageable = PageRequest.of(0, 20);
        Page<Product> page = productRepository.findAll(pageable);
        return toSearchResponse(page);
    }

    private ProductSearchResponse toSearchResponse(Page<Product> page) {
        List<ProductResponse> items = page.getContent().stream()
                .map(productMapper::toResponse)
                .toList();

        ProductSearchResponse response = new ProductSearchResponse();
        response.setItems(items);
        response.setPage(page.getNumber());
        response.setSize(page.getSize());
        response.setTotalElements(page.getTotalElements());
        response.setTotalPages(page.getTotalPages());
        return response;
    }
}