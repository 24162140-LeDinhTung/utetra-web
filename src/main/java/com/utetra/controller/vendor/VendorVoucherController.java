package com.utetra.controller.vendor;

import com.utetra.dto.request.voucher.CreateVoucherRequest;
import com.utetra.dto.response.CommerceDtos.VoucherItem;
import com.utetra.security.UserPrincipal;
import com.utetra.service.VoucherService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/vendor/shops/{shopId}/vouchers")
@RequiredArgsConstructor
public class VendorVoucherController {
  private final VoucherService service;

  @GetMapping
  public List<VoucherItem> list(
      @PathVariable Long shopId, @AuthenticationPrincipal UserPrincipal u) {
    return service.list(shopId, u.getId());
  }

  @PostMapping
  public VoucherItem create(
      @PathVariable Long shopId,
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody CreateVoucherRequest r) {
    return service.save(shopId, u.getId(), null, r);
  }

  @PutMapping("/{id}")
  public VoucherItem update(
      @PathVariable Long shopId,
      @PathVariable Long id,
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody CreateVoucherRequest r) {
    return service.save(shopId, u.getId(), id, r);
  }

  @DeleteMapping("/{id}")
  public void delete(
      @PathVariable Long shopId, @PathVariable Long id, @AuthenticationPrincipal UserPrincipal u) {
    service.delete(shopId, u.getId(), id);
  }
}
