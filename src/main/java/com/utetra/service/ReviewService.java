package com.utetra.service;

import com.utetra.dto.request.review.CreateReviewRequest;
import com.utetra.dto.response.review.ReviewResponse;
import org.springframework.data.domain.*;

public interface ReviewService {
  ReviewResponse create(Long userId, CreateReviewRequest request);

  Page<ReviewResponse> list(Long productId, Pageable page);
}
