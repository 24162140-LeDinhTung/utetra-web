package com.utetra.repository;
import com.utetra.entity.WithdrawRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface WithdrawRequestRepository extends JpaRepository<WithdrawRequest, Long> {
}