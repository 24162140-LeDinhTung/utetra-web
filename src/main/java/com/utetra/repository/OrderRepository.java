package com.utetra.repository;

import com.utetra.entity.Order;
import com.utetra.enums.OrderStatus;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRepository extends JpaRepository<Order, Long> {

  Optional<Order> findByOrderCode(String orderCode);

  Page<Order> findByUserId(Long userId, Pageable pageable);

  Page<Order> findByUserIdAndStatus(Long userId, OrderStatus status, Pageable pageable);

  Page<Order> findByShopIdAndStatus(Long shopId, OrderStatus status, Pageable pageable);

  Page<Order> findByShopId(Long shopId, Pageable pageable);

  @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
  @org.springframework.data.jpa.repository.Query("select o from Order o where o.id = :id")
  Optional<Order> lockById(Long id);
}
