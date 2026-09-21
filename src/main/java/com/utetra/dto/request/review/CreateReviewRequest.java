package com.utetra.dto.request.review;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class CreateReviewRequest {

    @NotNull
    private Long productId;

    @NotNull
    private Long orderId; // để verify đã mua hàng trước khi cho review

    @Min(1)
    @Max(5)
    private Integer rating;

    @Size(min = 50, message = "Comment phải có ít nhất 50 ký tự")
    private String comment;

    private List<String> mediaUrls; // ảnh/video đã upload Cloudinary trước
}