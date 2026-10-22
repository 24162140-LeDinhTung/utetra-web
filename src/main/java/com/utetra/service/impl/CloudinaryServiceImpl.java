package com.utetra.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.utetra.service.CloudinaryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryServiceImpl implements CloudinaryService {

    private final Cloudinary cloudinary;

    @Override
    public String uploadFile(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("File không được để trống");
        }
        try {
            Map<?, ?> result = cloudinary.uploader().upload(
                    file.getBytes(),
                    ObjectUtils.asMap("folder", folder, "resource_type", "auto")
            );
            return result.get("secure_url").toString();
        } catch (Exception e) {
            log.error("Lỗi upload file lên Cloudinary: {}", e.getMessage());
            throw new RuntimeException("Lỗi upload file: " + e.getMessage());
        }
    }
}