package com.utetra.controller.customer;

import com.utetra.dto.request.review.CreateReviewRequest;
import com.utetra.dto.response.review.ReviewResponse;
import com.utetra.security.UserPrincipal;
import com.utetra.service.*;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
public class CustomerReviewController {
  private final ReviewService reviews;
  private final StorageService storage;   // ⬅️ Đổi từ CloudinaryService cloud

  @PostMapping("/api/customer/reviews")
  public ReviewResponse create(
      @AuthenticationPrincipal UserPrincipal u, @Valid @RequestBody CreateReviewRequest r) {
    return reviews.create(u.getId(), r);
  }

  @PostMapping("/api/customer/reviews/media")
  public Map<String, String> upload(
      @AuthenticationPrincipal UserPrincipal u, @RequestParam MultipartFile file) {
    CatalogManagementService.validateMedia(file, true);
    return Map.of("url", storage.uploadFile(file, "utetra/reviews/" + u.getId()));
  }

  @GetMapping("/api/products/{id}/reviews")
  public Page<ReviewResponse> list(
      @PathVariable Long id, @RequestParam(defaultValue = "0") int page) {
    return reviews.list(
        id, PageRequest.of(Math.max(0, page), 10, Sort.by(Sort.Direction.DESC, "id")));
  }
}
