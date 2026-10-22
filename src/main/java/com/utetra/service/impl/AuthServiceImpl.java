package com.utetra.service.impl;

import com.utetra.dto.request.auth.*;
import com.utetra.dto.response.auth.LoginResponse;
import com.utetra.entity.RefreshToken;
import com.utetra.entity.Role;
import com.utetra.entity.User;
import com.utetra.enums.OtpType;
import com.utetra.enums.RoleName;
import com.utetra.enums.UserStatus;
import com.utetra.exception.custom.AccountBannedException;
import com.utetra.exception.custom.EmailExistsException;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.RefreshTokenRepository;
import com.utetra.repository.RoleRepository;
import com.utetra.repository.UserRepository;
import com.utetra.security.JwtProvider;
import com.utetra.service.AuthService;
import com.utetra.service.MailService;
import com.utetra.service.OtpService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtProvider jwtProvider;
    private final OtpService otpService;
    private final MailService mailService;

    @Override
    @Transactional
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Email hoặc mật khẩu không đúng"));

        if (user.getStatus() == UserStatus.BANNED) {
            throw new AccountBannedException("Tài khoản của bạn đã bị khóa.");
        }
        if (user.getStatus() == UserStatus.PENDING) {
            throw new AccountBannedException("Tài khoản chưa được kích hoạt bằng OTP.");
        }

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        String accessToken = jwtProvider.generateAccessToken(user.getId(), user.getEmail());

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUserId(user.getId());
        refreshToken.setToken(UUID.randomUUID().toString());
        refreshToken.setExpiredAt(LocalDateTime.now().plusDays(7));
        refreshToken.setRevoked(false);
        refreshTokenRepository.save(refreshToken);

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        LoginResponse response = new LoginResponse();
        response.setAccessToken(accessToken);
        response.setRefreshToken(refreshToken.getToken());
        response.setUserId(user.getId());
        response.setEmail(user.getEmail());
        response.setFullName(user.getFullName());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setRoles(user.getRoles().stream().map(r -> r.getName().name()).collect(Collectors.toSet()));

        return response;
    }

    @Override
    @Transactional
    public void register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailExistsException("Email đã được đăng ký");
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setPhone(request.getPhone());
        user.setStatus(UserStatus.PENDING);
        user.setEmailVerified(false);

        Role customerRole = roleRepository.findByName(RoleName.ROLE_CUSTOMER)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy quyền CUSTOMER"));
        user.getRoles().add(customerRole);

        user = userRepository.save(user);

        String otp = otpService.createOtp(user.getEmail(), user.getId(), OtpType.REGISTER);
        mailService.sendOtpEmail(user.getEmail(), otp, OtpType.REGISTER.name());
    }

    @Override
    @Transactional
    public void verifyOtp(VerifyOtpRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        otpService.verifyOtp(request.getEmail(), request.getOtp(), OtpType.REGISTER);

        user.setStatus(UserStatus.ACTIVE);
        user.setEmailVerified(true);
        userRepository.save(user);

        otpService.deleteOtp(request.getEmail(), OtpType.REGISTER);
    }

    @Override
    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Email không tồn tại trong hệ thống"));

        String otp = otpService.createOtp(user.getEmail(), user.getId(), OtpType.FORGOT_PASSWORD);
        mailService.sendOtpEmail(user.getEmail(), otp, OtpType.FORGOT_PASSWORD.name());
    }

    @Override
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        otpService.verifyOtp(request.getEmail(), request.getOtp(), OtpType.FORGOT_PASSWORD);

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        otpService.deleteOtp(request.getEmail(), OtpType.FORGOT_PASSWORD);
    }
}