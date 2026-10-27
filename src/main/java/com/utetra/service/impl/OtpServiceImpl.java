package com.utetra.service.impl;

import com.utetra.entity.OtpToken;
import com.utetra.enums.OtpType;
import com.utetra.exception.custom.OtpExpiredException;
import com.utetra.exception.custom.OtpInvalidException;
import com.utetra.repository.OtpTokenRepository;
import com.utetra.service.OtpService;
import com.utetra.util.OtpUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OtpServiceImpl implements OtpService {

    private static final int OTP_EXPIRE_MINUTES = 5;
    private final OtpTokenRepository otpTokenRepository;

    @Override
    @Transactional
    public String createOtp(String email, Long userId, OtpType type) {
        // Xóa OTP cũ nếu có để tránh rác DB
        otpTokenRepository.deleteByEmailAndType(email, type);

        String code = OtpUtil.generateOtp();

        OtpToken otp = new OtpToken();
        otp.setEmail(email);
        otp.setUserId(userId);
        otp.setCode(code);
        otp.setType(type);
        otp.setExpiredAt(LocalDateTime.now().plusMinutes(OTP_EXPIRE_MINUTES));
        otp.setUsed(false);

        otpTokenRepository.save(otp);
        return code;
    }

    @Override
    @Transactional
    public void verifyOtp(String email, String code, OtpType type) {
        OtpToken otp = otpTokenRepository
                .findByEmailAndCodeAndType(email, code, type)
                .orElseThrow(() -> new OtpInvalidException("Mã OTP không chính xác"));

        if (Boolean.TRUE.equals(otp.getUsed())) {
            throw new OtpInvalidException("Mã OTP đã được sử dụng");
        }

        if (otp.getExpiredAt().isBefore(LocalDateTime.now())) {
            throw new OtpExpiredException("Mã OTP đã hết hạn");
        }

        // Đánh dấu là đã dùng
        otp.setUsed(true);
        otpTokenRepository.save(otp);
    }

    @Override
    @Transactional
    public void deleteOtp(String email, OtpType type) {
        otpTokenRepository.deleteByEmailAndType(email, type);
    }
}