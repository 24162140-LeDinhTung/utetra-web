package com.utetra.repository;
import com.utetra.entity.Wallet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
@Repository

public interface WalletRepository extends JpaRepository<Wallet, Long> {
	Optional<Wallet> findByShopId(Long shopId);
    @org.springframework.data.jpa.repository.Lock(jakarta.persistence.LockModeType.PESSIMISTIC_WRITE)
    @org.springframework.data.jpa.repository.Query("select w from Wallet w where w.shop.id = :shopId")
    Optional<Wallet> lockByShopId(@org.springframework.data.repository.query.Param("shopId") Long shopId);
}