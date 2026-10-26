package com.utetra.repository;
import com.utetra.entity.ShopImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface ShopImageRepository extends JpaRepository<ShopImage, Long> {
}