package com.utetra.repository;

import com.utetra.entity.Order;
import com.utetra.enums.OrderStatus;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OrderRepository extends JpaRepository<Order, Long> {

  Optional<Order> findByOrderCode(String orderCode);

  Page<Order> findByUserId(Long userId, Pageable pageable);

  Page<Order> findByUserIdAndStatus(Long userId, OrderStatus status, Pageable pageable);

  Page<Order> findByShopIdAndStatus(Long shopId, OrderStatus status, Pageable pageable);

  Page<Order> findByShopId(Long shopId, Pageable pageable);

  @Query("SELECT o FROM Order o LEFT JOIN FETCH o.user WHERE o.shop.id = :shopId")
  List<Order> findByShopIdWithUser(@Param("shopId") Long shopId);

  // === THÊM HÀM NÀY ĐỂ FIX LỖI Ở TRANG CHI TIẾT ===
  @Query("SELECT o FROM Order o LEFT JOIN FETCH o.user LEFT JOIN FETCH o.shop WHERE o.id = :id")
  Optional<Order> findByIdWithUserAndShop(@Param("id") Long id);

  @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
  @Query("select o from Order o where o.id = :id")
  Optional<Order> lockById(Long id);
}