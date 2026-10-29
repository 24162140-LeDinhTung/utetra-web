package com.utetra.controller.api;

import com.utetra.enums.PaymentMethod;
import com.utetra.security.UserPrincipal;
import com.utetra.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor
public class PaymentController {
  private final PaymentService payments;
  private final com.utetra.service.PaymentAvailability availability;

  @GetMapping("/methods")
  public java.util.List<com.utetra.service.PaymentAvailability.Method> methods() {
    return availability.methods();
  }

  public record PaymentRequest(@NotNull Long orderId) {}

  @PostMapping("/vnpay")
  public Map<String, String> vnpay(
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody PaymentRequest r,
      HttpServletRequest http) {
    return payments.start(u.getId(), r.orderId(), PaymentMethod.VNPAY, http.getRemoteAddr());
  }

  @PostMapping("/vnpay/qr")
  public Map<String, String> vnpayQr(
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody PaymentRequest r, HttpServletRequest http) {
    return payments.startVnpayQr(u.getId(), r.orderId(), http.getRemoteAddr());
  }

  @PostMapping("/momo")
  public Map<String, String> momo(
      @AuthenticationPrincipal UserPrincipal u,
      @Valid @RequestBody PaymentRequest r,
      HttpServletRequest http) {
    return payments.start(u.getId(), r.orderId(), PaymentMethod.MOMO, http.getRemoteAddr());
  }

  @GetMapping("/vnpay/ipn")
  public Map<String, String> vnpayIpn(@RequestParam Map<String, String> p) {
    return payments.vnpayCallback(p);
  }

  @PostMapping("/momo/ipn")
  @ResponseStatus(org.springframework.http.HttpStatus.NO_CONTENT)
  public void momoIpn(@RequestBody Map<String, Object> p) {
    payments.momoCallback(p);
  }
}
