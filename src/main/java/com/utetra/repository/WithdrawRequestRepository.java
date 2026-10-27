package com.utetra.repository;
import com.utetra.entity.WithdrawRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface WithdrawRequestRepository extends JpaRepository<WithdrawRequest, Long> {
	@Query("SELECT w FROM WithdrawRequest w JOIN FETCH w.wallet wl JOIN FETCH wl.shop")
    List<WithdrawRequest> findAllWithWalletAndShop();
}