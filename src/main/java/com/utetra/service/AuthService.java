package com.utetra.service;

import com.utetra.dto.request.auth.*;
import com.utetra.dto.response.auth.LoginResponse;

public interface AuthService {
    LoginResponse login(LoginRequest request);
    void register(RegisterRequest request);
    void verifyOtp(VerifyOtpRequest request);
    void forgotPassword(ForgotPasswordRequest request);
    void resetPassword(ResetPasswordRequest request);
}