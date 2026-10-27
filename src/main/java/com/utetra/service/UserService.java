package com.utetra.service;

import com.utetra.dto.request.user.UpdateProfileRequest;
import com.utetra.dto.response.user.UserResponse;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {
    UserResponse getProfile(Long userId);
    UserResponse updateProfile(Long userId, UpdateProfileRequest request);
    String uploadAvatar(Long userId, MultipartFile file);
}