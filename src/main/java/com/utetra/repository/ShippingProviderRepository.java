package com.utetra.repository;
import com.utetra.entity.ShippingProvider;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
@Repository
public interface ShippingProviderRepository extends JpaRepository<ShippingProvider, Long> {
}