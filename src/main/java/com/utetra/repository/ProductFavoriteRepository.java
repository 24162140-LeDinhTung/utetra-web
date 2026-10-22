package com.utetra.repository;

import com.utetra.entity.ProductFavorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductFavoriteRepository extends JpaRepository<ProductFavorite, Long> {
    Optional<ProductFavorite> findByUserIdAndProductId(Long userId, Long productId);
    List<ProductFavorite> findByUserId(Long userId);
}