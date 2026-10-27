package com.utetra.repository;

import com.utetra.entity.Product;
import com.utetra.enums.ProductStatus;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.EntityGraph;

public interface ProductRepository extends JpaRepository<Product, Long> {

  Optional<Product> findBySlug(String slug);

  Page<Product> findByShopIdAndStatus(Long shopId, ProductStatus status, Pageable pageable);

  Page<Product> findByCategoryIdAndStatus(Long categoryId, ProductStatus status, Pageable pageable);

  Page<Product> findByNameContainingIgnoreCaseAndStatus(
      String name, ProductStatus status, Pageable pageable);

  Page<Product> findByShopIdOrderBySoldCountDesc(Long shopId, Pageable pageable);

  Page<Product> findByStatus(ProductStatus status, Pageable pageable);

  @org.springframework.data.jpa.repository.Query(
      "select p from Product p where p.isDeleted = false and p.shop.isDeleted = false and"
          + " p.category.isDeleted = false and p.status = com.utetra.enums.ProductStatus.ACTIVE and"
          + " (:shopId is null or p.shop.id = :shopId) and (:categoryId is null or p.category.id ="
          + " :categoryId) and (:keyword is null or lower(p.name) like lower(concat('%', :keyword,"
          + " '%')))")
  Page<Product> search(Long shopId, Long categoryId, String keyword, Pageable pageable);

  Page<Product> findByShopIdAndIsDeletedFalse(Long shopId, Pageable pageable);

  @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
  @org.springframework.data.jpa.repository.Query("select p from Product p where p.id = :id")
  Optional<Product> lockById(Long id);

  // Đếm số lượng món đang bán của 1 shop
  long countByShopIdAndStatusAndIsDeletedFalse(Long shopId, ProductStatus status);

  // ==========================================
  // SỬA LẠI DÒNG NÀY:
  // ==========================================
  @EntityGraph(attributePaths = {"images", "attributes", "attributes.values"})
  List<Product> findByShopIdAndStatusAndIsDeletedFalse(Long shopId, ProductStatus status);
}