package com.utetra.repository;

import com.utetra.entity.OtpToken;
import com.utetra.enums.OtpType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface OtpTokenRepository extends JpaRepository<OtpToken, Long> {

    Optional<OtpToken> findByEmailAndCodeAndType(String email, String code, OtpType type);

    void deleteByEmailAndType(String email, OtpType type);
}