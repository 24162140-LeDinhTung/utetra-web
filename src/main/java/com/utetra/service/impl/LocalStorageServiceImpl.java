package com.utetra.service.impl;

import com.utetra.service.StorageService;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@Slf4j
public class LocalStorageServiceImpl implements StorageService {

    @Value("${app.upload.dir:./uploads}")
    private String uploadDir;

    @Value("${app.upload.url-prefix:/uploads}")
    private String urlPrefix;

    private Path rootPath;

    @PostConstruct
    public void init() {
        try {
            this.rootPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(rootPath);
            log.info("LocalStorage khởi tạo thành công. Thư mục lưu: {}", rootPath);
        } catch (IOException e) {
            throw new IllegalStateException("Không tạo được thư mục upload: " + uploadDir, e);
        }
    }

    @Override
    public String uploadFile(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File rỗng, không thể upload");
        }

        try {
            // Lấy extension gốc
            String originalName = file.getOriginalFilename();
            String ext = "";
            if (originalName != null && originalName.lastIndexOf('.') > 0) {
                ext = originalName.substring(originalName.lastIndexOf('.')).toLowerCase();
            }

            if (!java.util.Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp", ".mp4", ".webm").contains(ext))
                throw new IllegalArgumentException("Chỉ nhận ảnh JPG/PNG/GIF/WebP hoặc video MP4/WebM");

            // Sanitize folder: chỉ cho phép chữ, số, "/", "_", "-"
            String safeFolder = (folder == null)
                    ? ""
                    : folder.replaceAll("[^a-zA-Z0-9/_-]", "")
                            .replaceAll("^/+|/+$", "");

            // Tạo tên file duy nhất
            String fileName = UUID.randomUUID() + ext;

            Path folderPath = safeFolder.isEmpty()
                    ? rootPath
                    : rootPath.resolve(safeFolder).normalize();

            // Chống path traversal
            if (!folderPath.startsWith(rootPath)) {
                throw new RuntimeException("Đường dẫn không hợp lệ");
            }

            Files.createDirectories(folderPath);

            Path target = folderPath.resolve(fileName).normalize();
            if (!target.startsWith(rootPath)) {
                throw new RuntimeException("Đường dẫn không hợp lệ");
            }

            try (var input = file.getInputStream()) {
                Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
            }

            log.info("Đã lưu file: {} -> {}", originalName, target);

            // URL trả về: /uploads/utetra/avatars/{uuid}.jpg
            String relativePath = safeFolder.isEmpty() ? fileName : safeFolder + "/" + fileName;
            return urlPrefix + "/" + relativePath;

        } catch (IOException e) {
            log.error("Lỗi lưu file: {}", e.getMessage(), e);
            throw new RuntimeException("Lỗi upload file: " + e.getMessage(), e);
        }
    }

    @Override
    public void deleteFile(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank() || !fileUrl.startsWith(urlPrefix + "/")) {
            return;
        }
        try {
            String relative = fileUrl.substring(urlPrefix.length() + 1);
            Path path = rootPath.resolve(relative).normalize();
            if (path.startsWith(rootPath)) {
                Files.deleteIfExists(path);
                log.info("Đã xóa file: {}", path);
            }
        } catch (IOException e) {
            log.warn("Không xóa được file {}: {}", fileUrl, e.getMessage());
        }
    }
}
