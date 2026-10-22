package com.utetra.service;

import com.utetra.dto.request.auth.LoginRequest;
import com.utetra.dto.response.auth.LoginResponse;

public interface AuthService {
    LoginResponse login(LoginRequest request);
}