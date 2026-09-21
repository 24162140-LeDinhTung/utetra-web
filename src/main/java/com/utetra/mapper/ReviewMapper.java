package com.utetra.mapper;

import com.utetra.dto.response.review.ReviewResponse;
import com.utetra.entity.ProductReview;
import org.mapstruct.Mapping;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ReviewMapper {

    @Mapping(source = "user.fullName", target = "userFullName")
    ReviewResponse toResponse(ProductReview review);
}