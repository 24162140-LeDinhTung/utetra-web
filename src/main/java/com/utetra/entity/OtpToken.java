package com.utetra.entity;

import com.utetra.enums.OtpType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "otp_tokens")
@Getter
@Setter
public class OtpToken extends BaseEntity {

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "email", length = 255, nullable = false)
    private String email;

    @Column(name = "code", length = 10, nullable = false)
    private String code;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", length = 50, nullable = false)
    private OtpType type;

    @Column(name = "expired_at", nullable = false)
    private LocalDateTime expiredAt;

    @Column(name = "used")
    private Boolean used = false;
}