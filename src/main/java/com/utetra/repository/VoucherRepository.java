package com.utetra.repository;

import com.utetra.entity.Voucher;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoucherRepository extends JpaRepository<Voucher, Long> {

  Optional<Voucher> findByCode(String code);

  java.util.List<Voucher> findByShopIdAndIsDeletedFalseOrderByIdDesc(Long id);

  @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
  @org.springframework.data.jpa.repository.Query(
      "select v from Voucher v where v.code = :code and v.isDeleted = false")
  Optional<Voucher> lockByCode(String code);

  @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
  @org.springframework.data.jpa.repository.Query("select v from Voucher v where v.id = :id")
  Optional<Voucher> lockById(Long id);
}
