package com.utetra.repository;
import com.utetra.entity.CommissionPolicy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface CommissionPolicyRepository extends JpaRepository<CommissionPolicy, Long> {
}