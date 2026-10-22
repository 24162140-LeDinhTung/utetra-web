package com.utetra.service.impl;

import com.utetra.dto.request.auth.LoginRequest;
import com.utetra.dto.response.auth.LoginResponse;
import com.utetra.entity.RefreshToken;
import com.utetra.entity.User;
import com.utetra.enums.UserStatus;
import com.utetra.exception.custom.AccountBannedException;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.RefreshTokenRepository;
import com.utetra.repository.UserRepository;
import com.utetra.security.JwtProvider;
import com.utetra.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final AuthenticationManager authenticationManager;
    private final JwtProvider jwtProvider;

    @Override
    @Transactional
    public LoginResponse login(LoginRequest request) {
        // 1. Tìm user theo email
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Email hoặc mật khẩu không đúng"));

        // 2. Kiểm tra trạng thái tài khoản
        if (user.getStatus() == UserStatus.BANNED) {
            throw new AccountBannedException("Tài khoản của bạn đã bị khóa.");
        }
        
        if (user.getStatus() == UserStatus.PENDING) {
            throw new AccountBannedException("Tài khoản chưa được kích hoạt bằng OTP.");
        }

        // 3. Xác thực mật khẩu (Sử dụng Spring Security AuthenticationManager)
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        // 4. Tạo Access Token
        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail());

        // 5. Tạo Refresh Token và lưu vào DB
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUserId(user.getId());
        refreshToken.setToken(UUID.randomUUID().toString());
        refreshToken.setExpiredAt(LocalDateTime.now().plusDays(7)); // 7 ngày
        refreshToken.setRevoked(false);
        refreshTokenRepository.save(refreshToken);

        // 6. Cập nhật lastLoginAt
        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        // 7. Trả về kết quả
        LoginResponse response = new LoginResponse();
        response.setAccessToken(accessToken);
        response.setRefreshToken(refreshToken.getToken());
        response.setUserId(user.getId());
        response.setEmail(user.getEmail());
        response.setFullName(user.getFullName());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setRoles(user.getRoles().stream()
                .map(role -> role.getName().name())
                .collect(Collectors.toSet()));

        return response;
    }
}