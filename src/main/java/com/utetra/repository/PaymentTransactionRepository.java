package com.utetra.repository;

import com.utetra.entity.PaymentTransaction;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, Long> {
  Optional<PaymentTransaction> findByReference(String reference);

  Optional<PaymentTransaction> findFirstByOrderIdOrderByIdDesc(Long orderId);
}
