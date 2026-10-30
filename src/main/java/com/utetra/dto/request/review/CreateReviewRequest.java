package com.utetra.dto.request.review;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateReviewRequest {

  @NotNull private Long productId;

  @NotNull private Long orderId; // để verify đã mua hàng trước khi cho review

  @NotNull
  @Min(1)
  @Max(5)
  private Integer rating;

  @Size(max = 5000, message = "Bình luận tối đa 5000 ký tự")
  private String comment;

  private List<String> mediaUrls; // ảnh/video đã upload; không bắt buộc
}
