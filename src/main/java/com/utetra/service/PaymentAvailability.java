package com.utetra.service;

import com.utetra.enums.PaymentMethod;
import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;

/** Reports configuration readiness only; it does not certify gateway credentials. */
@Service
@RequiredArgsConstructor
public class PaymentAvailability {
  private final Environment environment;

  public record Method(PaymentMethod code, boolean available, String message) {}

  public boolean available(PaymentMethod method) {
    if (method == null) return false;
    return switch (method) {
      case COD -> true;
      case VNPAY -> configured("payment.vnpay.tmn-code", "payment.vnpay.hash-secret");
      case MOMO -> configured("payment.momo.partner-code", "payment.momo.access-key",
          "payment.momo.secret-key", "payment.momo.ipn-url");
    };
  }

  private boolean configured(String... keys) {
    return Arrays.stream(keys).allMatch(key -> !environment.getProperty(key, "").isBlank());
  }

  public void requireAvailable(PaymentMethod method) {
    if (method == null) throw new IllegalArgumentException("Vui lòng chọn phương thức thanh toán");
    if (!available(method)) throw new IllegalStateException(
        method + " chưa được cấu hình. Vui lòng chọn COD hoặc liên hệ cửa hàng.");
  }

  public List<Method> methods() {
    return Arrays.stream(PaymentMethod.values()).map(method -> new Method(method,
        available(method), available(method) ? "" : "Chưa cấu hình cổng thanh toán")).toList();
  }
}
