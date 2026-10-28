package com.utetra.service.impl;

import com.utetra.dto.request.user.UpdateProfileRequest;
import com.utetra.dto.response.user.UserResponse;
import com.utetra.entity.User;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.UserRepository;
import com.utetra.service.CatalogManagementService;
import com.utetra.service.StorageService;
import com.utetra.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final StorageService storageService;   // ⬅️ Đổi từ CloudinaryService

    @Override
    public UserResponse getProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));
        return mapToResponse(user);
    }

    @Override
    @Transactional
    public UserResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        user.setFullName(request.getFullName());
        user.setPhone(request.getPhone());

        return mapToResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public String uploadAvatar(Long userId, MultipartFile file) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        // Validate MIME và dung lượng — dùng lại hàm có sẵn
        CatalogManagementService.validateMedia(file, false);

        // Xóa avatar cũ (chỉ xóa file local, không xóa URL Cloudinary cũ nếu có)
        if (user.getAvatarUrl() != null && user.getAvatarUrl().startsWith("/uploads")) {
            storageService.deleteFile(user.getAvatarUrl());
        }

        String url = storageService.uploadFile(file, "utetra/avatars");
        user.setAvatarUrl(url);
        userRepository.save(user);

        return url;
    }

    private UserResponse mapToResponse(User user) {
        UserResponse res = new UserResponse();
        res.setId(user.getId());
        res.setEmail(user.getEmail());
        res.setFullName(user.getFullName());
        res.setPhone(user.getPhone());
        res.setAvatarUrl(user.getAvatarUrl());
        res.setCoverUrl(user.getCoverUrl());
        res.setStatus(user.getStatus() != null ? user.getStatus().name() : null);
        res.setCreatedAt(user.getCreatedAt());
        return res;
    }
}
