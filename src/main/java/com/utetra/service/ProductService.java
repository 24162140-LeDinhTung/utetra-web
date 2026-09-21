package com.utetra.service;

import com.utetra.dto.request.product.CreateProductRequest;
import com.utetra.dto.request.product.ProductSearchRequest;
import com.utetra.dto.request.product.UpdateProductRequest;
import com.utetra.dto.response.product.ProductDetailResponse;
import com.utetra.dto.response.product.ProductSearchResponse;
import com.utetra.entity.Product;

public interface ProductService {

    Product create(Long shopId, CreateProductRequest request);

    Product update(Long id, UpdateProductRequest request);

    void softDeleteProduct(Long id);

    ProductDetailResponse getDetail(Long id, Long viewerUserId);

    ProductSearchResponse search(ProductSearchRequest request);

    ProductSearchResponse getHomeProducts();
}