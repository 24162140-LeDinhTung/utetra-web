package com.utetra.repository;

import com.utetra.entity.Shop;
import com.utetra.enums.ShopStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShopRepository extends JpaRepository<Shop, Long> {

    // Phần của nhóm
    List<Shop> findByOwnerIdAndIsDeletedFalse(Long ownerId);
    Page<Shop> findByIsDeletedFalse(Pageable pageable);

    // Phần C
    Page<Shop> findByStatusAndIsDeletedFalse(ShopStatus status, Pageable pageable);
    long countByStatusAndIsDeletedFalse(ShopStatus status);
    Page<Shop> findByNameContainingIgnoreCaseAndIsDeletedFalse(String name, Pageable pageable);
    long countByIsDeletedFalse();
}