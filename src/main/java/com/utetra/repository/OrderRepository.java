package com.utetra.repository;

import com.utetra.entity.Order;
import com.utetra.enums.OrderStatus;
import java.math.BigDecimal;
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

  @Query("SELECT o FROM Order o LEFT JOIN FETCH o.user LEFT JOIN FETCH o.shop WHERE o.id = :id")
  Optional<Order> findByIdWithUserAndShop(@Param("id") Long id);

  @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
  @Query("select o from Order o where o.id = :id")
  Optional<Order> lockById(Long id);

  // === TÍNH TỔNG DOANH THU THẬT (ĐÃ TRỪ PHÍ SHIP) ===
  @Query("SELECT COALESCE(SUM(o.totalAmount - o.shippingFee), 0) FROM Order o WHERE o.status = :status")
  BigDecimal calculateTotalRevenue(@Param("status") OrderStatus status);

  // === LẤY DOANH THU THEO TỪNG THÁNG CỦA NĂM HIỆN TẠI (ĐÃ TRỪ PHÍ SHIP) ===
  // Lưu ý: Tên bảng 'orders' và các cột phải khớp chính xác với Database của bạn
  @Query(value = "SELECT MONTH(o.created_at) as revenue_month, SUM(o.total_amount - COALESCE(o.shipping_fee, 0)) as revenue " +
                 "FROM orders o WHERE o.status = 'DELIVERED' AND YEAR(o.created_at) = YEAR(CURRENT_DATE) " +
                 "GROUP BY MONTH(o.created_at) ORDER BY revenue_month", nativeQuery = true)
  List<Object[]> getMonthlyRevenueCurrentYear();
}
