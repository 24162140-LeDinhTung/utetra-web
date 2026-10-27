package com.utetra.repository;
import com.utetra.entity.ShopLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface ShopLevelRepository extends JpaRepository<ShopLevel, Long> {
}