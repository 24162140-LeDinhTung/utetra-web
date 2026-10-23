package com.utetra.controller.vendor;

import com.utetra.dto.request.promotion.CreatePromotionRequest;
import com.utetra.dto.response.CommerceDtos.PromotionItem;
import com.utetra.security.UserPrincipal;
import com.utetra.service.PromotionService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/vendor/shops/{shopId}/promotions")
@RequiredArgsConstructor
public class VendorPromotionController {
  private final PromotionService service;

  @GetMapping
  public List<PromotionItem> list(
      @PathVariable Long shopId, @AuthenticationPrincipal UserPrincipal u) {
    return service.list(shopId, u.getId());
  }

  @PostMapping
  public PromotionItem create(
      @PathVariable Long shopId,
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody CreatePromotionRequest r) {
    return service.save(shopId, u.getId(), null, r);
  }

  @PutMapping("/{id}")
  public PromotionItem update(
      @PathVariable Long shopId,
      @PathVariable Long id,
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody CreatePromotionRequest r) {
    return service.save(shopId, u.getId(), id, r);
  }

  @DeleteMapping("/{id}")
  public void delete(
      @PathVariable Long shopId, @PathVariable Long id, @AuthenticationPrincipal UserPrincipal u) {
    service.delete(shopId, u.getId(), id);
  }
}
