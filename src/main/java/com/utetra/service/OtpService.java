package com.utetra.service;

import com.utetra.enums.OtpType;

public interface OtpService {
    String createOtp(String email, Long userId, OtpType type);
    void verifyOtp(String email, String code, OtpType type);
    void deleteOtp(String email, OtpType type);
}