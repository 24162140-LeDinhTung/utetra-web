package com.utetra.service;

import com.utetra.dto.request.product.*;
import com.utetra.dto.response.product.*;
import com.utetra.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ProductService {
  Product create(Long shopId, Long ownerId, CreateProductRequest request);

  Product update(Long id, Long ownerId, UpdateProductRequest request);

  void softDeleteProduct(Long id, Long ownerId);

  ProductDetailResponse getDetail(Long id, Long viewerUserId);

  ProductDetailResponse getVendorDetail(Long shopId, Long id, Long ownerId);

  ProductSearchResponse search(ProductSearchRequest request);

  ProductSearchResponse getHomeProducts();

  ProductSearchResponse getProductsByShop(Long shopId);

  Page<ShopProductsResponse> getHomeShops(Pageable pageable);

  ProductSearchResponse getVendorProducts(Long shopId, Long ownerId, Pageable pageable);
}
