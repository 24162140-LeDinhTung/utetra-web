package com.utetra.repository;

import com.utetra.entity.ProductViewLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductViewLogRepository extends JpaRepository<ProductViewLog, Long> {
    // Lấy lịch sử xem, sắp xếp mới nhất lên đầu
    List<ProductViewLog> findByUserIdOrderByCreatedAtDesc(Long userId);
}