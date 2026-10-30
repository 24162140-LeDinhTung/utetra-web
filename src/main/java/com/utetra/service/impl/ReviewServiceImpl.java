package com.utetra.service.impl;

import com.utetra.dto.request.review.CreateReviewRequest;
import com.utetra.dto.response.review.ReviewResponse;
import com.utetra.entity.*;
import com.utetra.enums.*;
import com.utetra.exception.custom.ResourceNotFoundException;
import com.utetra.repository.*;
import com.utetra.service.*;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ReviewServiceImpl implements ReviewService {
  private final UserRepository users;
  private final OrderRepository orders;
  private final OrderItemRepository items;
  private final ProductReviewRepository reviews;
  private final ReviewMediaRepository media;
  private final CommerceAccess access;

  public ReviewResponse create(Long userId, CreateReviewRequest r) {
    User u = users.lockById(userId).orElseThrow();
    Order o = orders.findById(r.getOrderId())
            .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn"));

    access.order(o, userId);

    if (o.getStatus() != OrderStatus.DELIVERED
        || items.findByOrderId(o.getId()).stream()
            .noneMatch(i -> i.getProduct().getId().equals(r.getProductId())))
      throw new IllegalArgumentException("Chỉ đánh giá sản phẩm trong đơn đã giao");

    if (reviews.existsByUserIdAndProductIdAndIsDeletedFalse(userId, r.getProductId()))
      throw new IllegalArgumentException("Bạn đã đánh giá sản phẩm này");

    if (r.getComment() != null && r.getComment().length() > 5000
        || r.getRating() == null
        || r.getRating() < 1
        || r.getRating() > 5
        || r.getMediaUrls() != null && r.getMediaUrls().size() > 5)
      throw new IllegalArgumentException("Đánh giá cần 1–5 sao, bình luận tối đa 5000 ký tự và tối đa 5 ảnh/video");

    ProductReview review = new ProductReview();
    review.setProduct(access.product(r.getProductId()));
    review.setUser(u);
    review.setRating(r.getRating());
    review.setComment(r.getComment() == null ? "" : r.getComment().trim());
    reviews.save(review);

    for (String url : r.getMediaUrls() == null ? List.<String>of() : r.getMediaUrls()) {
      if (url == null || url.trim().isEmpty() || url.length() > 255
          || !(url.startsWith("/uploads/utetra/reviews/" + userId + "/")
              || url.startsWith("https://res.cloudinary.com/"))) {
        throw new IllegalArgumentException("URL media không hợp lệ");
      }

      // Xác định loại file dựa vào đuôi mở rộng của Local Storage
      String lowerUrl = url.toLowerCase();
      MediaType mediaType = (lowerUrl.endsWith(".mp4") || lowerUrl.endsWith(".webm"))
              ? MediaType.VIDEO : MediaType.IMAGE;

      ReviewMedia m = new ReviewMedia();
      m.setReview(review);
      m.setMediaUrl(url);
      m.setMediaType(mediaType);
      media.save(m);
    }
    return dto(review);
  }

  @Transactional(readOnly = true)
  public Page<ReviewResponse> list(Long product, Pageable page) {
    Product p = access.product(product);
    if (p.getStatus() != ProductStatus.ACTIVE
        || p.getShop().getStatus() != ShopStatus.ACTIVE
        || Boolean.TRUE.equals(p.getShop().getIsDeleted())
        || Boolean.TRUE.equals(p.getCategory().getIsDeleted()))
      throw new ResourceNotFoundException("Sản phẩm chưa mở bán");

    return reviews.findByProductIdAndIsDeletedFalse(product, page).map(this::dto);
  }

  private ReviewResponse dto(ProductReview r) {
    ReviewResponse d = new ReviewResponse();
    d.setId(r.getId());
    d.setUserFullName(r.getUser().getFullName());
    d.setRating(r.getRating());
    d.setComment(r.getComment());
    d.setCreatedAt(r.getCreatedAt());
    d.setMediaUrls(
        media.findByReviewIdAndIsDeletedFalse(r.getId()).stream()
            .map(ReviewMedia::getMediaUrl)
            .toList());
    return d;
  }
}
