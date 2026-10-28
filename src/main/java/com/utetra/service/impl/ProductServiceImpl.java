package com.utetra.service.impl;

import com.utetra.dto.request.product.*;
import com.utetra.dto.response.product.*;
import com.utetra.entity.*;
import com.utetra.enums.ProductStatus;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import com.utetra.util.SlugUtil;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductServiceImpl implements ProductService {
  private final ProductRepository products;
  private final CategoryRepository categories;
  private final ShopRepository shops;
  private final ProductImageRepository images;
  private final ProductAttributeRepository attributes;
  private final ProductAttributeValueRepository values;
  private final ProductViewLogRepository views;
  private final CommerceAccess access;

  private Category category(Long id) {
    return categories
        .findById(id)
        .filter(c -> !Boolean.TRUE.equals(c.getIsDeleted()))
        .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh mục"));
  }

  @Transactional
  public Product create(Long shopId, Long ownerId, CreateProductRequest r) {
    Product p = new Product();
    p.setShop(access.shop(shopId, ownerId));
    p.setCategory(category(r.getCategoryId()));
    p.setName(r.getName().trim());
    p.setSlug(SlugUtil.toSlug(r.getName()) + "-" + UUID.randomUUID().toString().substring(0, 12));
    p.setDescription(r.getDescription());
    p.setPrice(r.getPrice());
    p.setStock(r.getStock());
    p.setSoldCount(0);
    p.setStatus(ProductStatus.PENDING);
    return products.save(p);
  }

  @Transactional
  public Product update(Long id, Long ownerId, UpdateProductRequest r) {
    Product p =
        products
            .lockById(id)
            .filter(x -> !Boolean.TRUE.equals(x.getIsDeleted()))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sản phẩm"));
    access.shop(p.getShop().getId(), ownerId);
    p.setCategory(category(r.getCategoryId()));
    p.setName(r.getName().trim());
    p.setDescription(r.getDescription());
    p.setPrice(r.getPrice());
    p.setStock(r.getStock());
    return products.save(p);
  }

  @Transactional
  public void softDeleteProduct(Long id, Long ownerId) {
    Product p =
        products
            .lockById(id)
            .filter(x -> !Boolean.TRUE.equals(x.getIsDeleted()))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sản phẩm"));
    access.shop(p.getShop().getId(), ownerId);
    p.setIsDeleted(true);
    products.save(p);
  }

  @Transactional
  public ProductDetailResponse getDetail(Long id, Long viewerId) {
    Product p = access.product(id);
    if (p.getStatus() != ProductStatus.ACTIVE
        || Boolean.TRUE.equals(p.getShop().getIsDeleted())
        || p.getShop().getStatus() != com.utetra.enums.ShopStatus.ACTIVE
        || Boolean.TRUE.equals(p.getCategory().getIsDeleted()))
      throw new ResourceNotFoundException("Sản phẩm chưa được mở bán");
    if (viewerId != null) {
      ProductViewLog v = new ProductViewLog();
      v.setUserId(viewerId);
      v.setProduct(p);
      views.save(v);
    }
    return detail(p);
  }

  public ProductDetailResponse getVendorDetail(Long shopId, Long id, Long ownerId) {
    return detail(access.product(shopId, id, ownerId));
  }

  public ProductSearchResponse getVendorProducts(Long shopId, Long ownerId, Pageable page) {
    access.shop(shopId, ownerId);
    return result(products.findByShopIdAndIsDeletedFalse(shopId, page));
  }

  public ProductSearchResponse search(ProductSearchRequest r) {
    if (r.getPage() < 0 || r.getSize() < 1 || r.getSize() > 100)
      throw new IllegalArgumentException("Phân trang không hợp lệ");
    String keyword =
        r.getKeyword() == null || r.getKeyword().isBlank() ? null : r.getKeyword().trim();
    String field = "createdAt";
    Sort.Direction direction = Sort.Direction.DESC;
    if ("price_asc".equals(r.getSort())) {
      field = "price";
      direction = Sort.Direction.ASC;
    } else if ("price_desc".equals(r.getSort())) field = "price";
    else if ("best_selling".equals(r.getSort())) field = "soldCount";
    return result(
        products.search(
            r.getShopId(),
            r.getCategoryId(),
            keyword,
            PageRequest.of(
                r.getPage(), r.getSize(), Sort.by(direction, field).and(Sort.by("id")))));
  }

  public ProductSearchResponse getHomeProducts() {
    ProductSearchRequest r = new ProductSearchRequest();
    r.setSort("best_selling");
    return search(r);
  }

  public ProductSearchResponse getProductsByShop(Long shopId) {
    ProductSearchRequest r = new ProductSearchRequest();
    r.setShopId(shopId);
    r.setSort("best_selling");
    return search(r);
  }

  public Page<ShopProductsResponse> getHomeShops(Pageable page) {
    return shops
        .findByStatusAndIsDeletedFalse(com.utetra.enums.ShopStatus.ACTIVE, page)
        .map(
            s -> {
              Page<Product> p =
                  products.search(
                      s.getId(),
                      null,
                      null,
                      PageRequest.of(
                          0, 12, Sort.by(Sort.Direction.DESC, "soldCount").and(Sort.by("id"))));
              return new ShopProductsResponse(
                  s.getId(), s.getName(), p.map(this::summary).getContent(), p.getTotalElements());
            });
  }

  private ProductResponse summary(Product p) {
    ProductResponse r = new ProductResponse();
    r.setId(p.getId());
    r.setName(p.getName());
    r.setSlug(p.getSlug());
    r.setPrice(p.getPrice());
    r.setStock(p.getStock());
    r.setSoldCount(p.getSoldCount());
    r.setStatus(p.getStatus().name());
    r.setShopId(p.getShop().getId());
    r.setShopName(p.getShop().getName());
    r.setThumbnailUrl(
        images.findByProductIdAndIsDeletedFalseOrderBySortOrderAscIdAsc(p.getId()).stream()
            .findFirst()
            .map(ProductImage::getImageUrl)
            .orElse(""));
    return r;
  }

  private ProductSearchResponse result(Page<Product> p) {
    ProductSearchResponse r = new ProductSearchResponse();
    r.setItems(p.map(this::summary).getContent());
    r.setPage(p.getNumber());
    r.setSize(p.getSize());
    r.setTotalElements(p.getTotalElements());
    r.setTotalPages(p.getTotalPages());
    return r;
  }

  private ProductDetailResponse detail(Product p) {
    ProductDetailResponse r = new ProductDetailResponse();
    r.setId(p.getId());
    r.setName(p.getName());
    r.setSlug(p.getSlug());
    r.setDescription(p.getDescription());
    r.setPrice(p.getPrice());
    r.setStock(p.getStock());
    r.setSoldCount(p.getSoldCount());
    r.setStatus(p.getStatus().name());
    r.setCategoryId(p.getCategory().getId());
    r.setCategoryName(p.getCategory().getName());
    r.setShopId(p.getShop().getId());
    r.setShopName(p.getShop().getName());
    r.setImageUrls(
        images.findByProductIdAndIsDeletedFalseOrderBySortOrderAscIdAsc(p.getId()).stream()
            .map(ProductImage::getImageUrl)
            .toList());
    r.setAttributes(
        attributes.findByProductIdAndIsDeletedFalseOrderByIdAsc(p.getId()).stream()
            .map(
                a -> {
                  ProductAttributeResponse x = new ProductAttributeResponse();
                  x.setAttributeId(a.getId());
                  x.setAttributeName(a.getName());
                  x.setValues(
                      values.findByAttributeIdAndIsDeletedFalseOrderByIdAsc(a.getId()).stream()
                          .map(
                              v -> {
                                ProductAttributeResponse.ValueItem y =
                                    new ProductAttributeResponse.ValueItem();
                                y.setValueId(v.getId());
                                y.setValue(v.getValue());
                                y.setExtraPrice(v.getExtraPrice());
                                return y;
                              })
                          .toList());
                  return x;
                })
            .toList());
    return r;
  }
}
