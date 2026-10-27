package com.utetra.repository;

import com.utetra.entity.Shop;
import com.utetra.enums.ShopStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShopRepository extends JpaRepository<Shop, Long> {

    List<Shop> findByOwnerIdAndIsDeletedFalse(Long ownerId);
    List<Shop> findByStatusAndIsDeletedFalse(ShopStatus status);
    
    Page<Shop> findByIsDeletedFalse(Pageable pageable);

    // Dùng JOIN FETCH để tải luôn thông tin owner (chủ shop) lên cùng 1 lúc
    @Query("SELECT s FROM Shop s JOIN FETCH s.owner WHERE s.status = :status AND s.isDeleted = false")
    Page<Shop> findByStatusWithOwner(@Param("status") ShopStatus status, Pageable pageable);
    // ===========================

    Page<Shop> findByStatusAndIsDeletedFalse(ShopStatus status, Pageable pageable);
    long countByStatusAndIsDeletedFalse(ShopStatus status);
    Page<Shop> findByNameContainingIgnoreCaseAndIsDeletedFalse(String name, Pageable pageable);
    long countByIsDeletedFalse();
}