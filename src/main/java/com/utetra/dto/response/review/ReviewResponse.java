package com.utetra.dto.response.review;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class ReviewResponse {

    private Long id;
    private String userFullName;
    private Integer rating;
    private String comment;
    private List<String> mediaUrls;
    private LocalDateTime createdAt;
}