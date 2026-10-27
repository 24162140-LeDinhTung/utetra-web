package com.utetra.service;

import com.utetra.entity.*;
import com.utetra.enums.ProductStatus;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Transactional
public class CatalogManagementService {
  private final CommerceAccess access;
  private final ProductRepository products;
  private final ProductAttributeRepository attributes;
  private final ProductAttributeValueRepository values;
  private final ProductImageRepository images;
  private final CloudinaryService cloud;

  public record ValueInput(
      @NotBlank @Size(max = 255) String value,
      @NotNull @PositiveOrZero @Digits(integer = 10, fraction = 0) BigDecimal extraPrice) {}

  public record AttributeInput(
      @NotNull Long productId,
      @NotBlank @Size(max = 255) String name,
      @NotEmpty @Size(max = 100) List<@Valid ValueInput> values) {}

  public record ValueOutput(Long id, String value, BigDecimal extraPrice) {}

  public record AttributeOutput(Long id, Long productId, String name, List<ValueOutput> values) {}

  @Transactional(readOnly = true)
  public List<AttributeOutput> list(Long productId) {
    access.product(productId);
    return attributes.findByProductIdAndIsDeletedFalseOrderByIdAsc(productId).stream()
        .map(this::dto)
        .toList();
  }

  public AttributeOutput save(Long id, AttributeInput r) {
    Product p = access.product(r.productId());
    ProductAttribute a =
        id == null
            ? new ProductAttribute()
            : attributes
                .findById(id)
                .filter(x -> !Boolean.TRUE.equals(x.getIsDeleted()))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thuộc tính"));
    if (id != null && !a.getProduct().getId().equals(p.getId()))
      throw new IllegalArgumentException("Không được chuyển thuộc tính sang sản phẩm khác");
    String name = r.name().trim();
    if (attributes.findByProductIdAndIsDeletedFalseOrderByIdAsc(p.getId()).stream()
        .anyMatch(x -> !x.getId().equals(id) && x.getName().equalsIgnoreCase(name)))
      throw new IllegalArgumentException("Tên thuộc tính đã tồn tại");
    if (r.values().stream().map(v -> v.value().trim().toLowerCase(Locale.ROOT)).distinct().count()
        != r.values().size()) throw new IllegalArgumentException("Giá trị thuộc tính bị trùng");
    a.setProduct(p);
    a.setName(name);
    attributes.save(a);
    if (id != null)
      for (ProductAttributeValue v : values.findByAttributeIdAndIsDeletedFalseOrderByIdAsc(id)) {
        v.setIsDeleted(true);
        values.save(v);
      }
    for (ValueInput v : r.values()) {
      ProductAttributeValue n = new ProductAttributeValue();
      n.setProduct(p);
      n.setAttribute(a);
      n.setValue(v.value().trim());
      n.setExtraPrice(v.extraPrice());
      values.save(n);
    }
    return dto(a);
  }

  public void delete(Long id) {
    ProductAttribute a =
        attributes
            .findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thuộc tính"));
    a.setIsDeleted(true);
    attributes.save(a);
  }

  private AttributeOutput dto(ProductAttribute a) {
    return new AttributeOutput(
        a.getId(),
        a.getProduct().getId(),
        a.getName(),
        values.findByAttributeIdAndIsDeletedFalseOrderByIdAsc(a.getId()).stream()
            .map(v -> new ValueOutput(v.getId(), v.getValue(), v.getExtraPrice()))
            .toList());
  }

  public Map<String, Object> upload(Long shop, Long owner, Long product, MultipartFile file) {
    Product p = access.product(shop, product, owner);
    validateMedia(file, false);
    String url = cloud.uploadFile(file, "utetra/products/" + shop);
    ProductImage img = new ProductImage();
    img.setProduct(p);
    img.setImageUrl(url);
    img.setSortOrder(
        images.findByProductIdAndIsDeletedFalseOrderBySortOrderAscIdAsc(product).size());
    img.setIsDefault(img.getSortOrder() == 0);
    images.save(img);
    return Map.of("id", img.getId(), "url", url);
  }

  public void removeImage(Long shop, Long owner, Long product, Long id) {
    access.product(shop, product, owner);
    ProductImage img =
        images
            .findById(id)
            .filter(x -> x.getProduct().getId().equals(product))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy ảnh"));
    img.setIsDeleted(true);
    images.save(img);
  }

  @Transactional(readOnly = true)
  public List<Map<String, Object>> listImages(Long shop, Long owner, Long product) {
    access.product(shop, product, owner);
    return images.findByProductIdAndIsDeletedFalseOrderBySortOrderAscIdAsc(product).stream()
        .map(
            i ->
                Map.<String, Object>of(
                    "id",
                    i.getId(),
                    "url",
                    i.getImageUrl(),
                    "sortOrder",
                    i.getSortOrder() == null ? 0 : i.getSortOrder(),
                    "isDefault",
                    Boolean.TRUE.equals(i.getIsDefault())))
        .toList();
  }

  public void moderate(Long id, ProductStatus status) {
    Product p =
        products
            .lockById(id)
            .filter(x -> !Boolean.TRUE.equals(x.getIsDeleted()))
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy sản phẩm"));
    p.setStatus(status);
    products.save(p);
  }

  public static void validateMedia(MultipartFile f, boolean video) {
    String type = f == null ? null : f.getContentType();
    if (f == null
        || f.isEmpty()
        || f.getSize() > 20 * 1024 * 1024
        || type == null
        || !Set.of("image/jpeg", "image/png", "image/webp", "image/gif").contains(type)
            && !(video && Set.of("video/mp4", "video/webm").contains(type)))
      throw new IllegalArgumentException(
          "Chỉ nhận JPG, PNG, WebP, GIF" + (video ? ", MP4, WebM" : "") + " tối đa 20 MB");
  }
}
