package com.utetra.repository;

import com.utetra.entity.ReviewMedia;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewMediaRepository extends JpaRepository<ReviewMedia, Long> {

  java.util.List<ReviewMedia> findByReviewIdAndIsDeletedFalse(Long id);
}
