package com.utetra.repository;
import com.utetra.entity.ShopStaff;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface ShopStaffRepository extends JpaRepository<ShopStaff, Long> {
}