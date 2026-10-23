package com.utetra.repository;

import com.utetra.entity.Shop;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShopRepository extends JpaRepository<Shop, Long> {

  java.util.List<Shop> findByOwnerIdAndIsDeletedFalse(Long ownerId);

  org.springframework.data.domain.Page<Shop> findByIsDeletedFalse(
      org.springframework.data.domain.Pageable pageable);
}
