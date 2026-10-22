package com.utetra.controller.customer;

import com.utetra.dto.request.user.UpdateProfileRequest;
import com.utetra.dto.response.ApiResponse;
import com.utetra.dto.response.user.UserResponse;
import com.utetra.security.UserPrincipal;
import com.utetra.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/customer/profile")
@RequiredArgsConstructor
public class CustomerProfileController {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<ApiResponse<UserResponse>> getProfile(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(ApiResponse.success(userService.getProfile(principal.getId())));
    }

    @PutMapping
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Cập nhật thành công", userService.updateProfile(principal.getId(), request)));
    }

    @PostMapping("/avatar")
    public ResponseEntity<ApiResponse<String>> uploadAvatar(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam("file") MultipartFile file) {
        String url = userService.uploadAvatar(principal.getId(), file);
        return ResponseEntity.ok(ApiResponse.success("Upload avatar thành công", url));
    }
}