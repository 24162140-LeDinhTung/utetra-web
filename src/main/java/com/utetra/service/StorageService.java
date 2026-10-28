package com.utetra.service;

import org.springframework.web.multipart.MultipartFile;

/**
 * Interface chung cho mọi storage (local, cloud, S3...).
 * Giữ nguyên chữ ký cũ của CloudinaryService để dễ thay thế.
 */
public interface StorageService {

    /**
     * Upload file vào thư mục con được chỉ định.
     *
     * @param file   file cần upload
     * @param folder thư mục con (có thể có dấu "/"), ví dụ "utetra/avatars"
     * @return URL tương đối, ví dụ "/uploads/utetra/avatars/abc.jpg"
     */
    String uploadFile(MultipartFile file, String folder);

    /**
     * Xóa file theo URL tương đối đã trả về trước đó.
     */
    void deleteFile(String fileUrl);
}
